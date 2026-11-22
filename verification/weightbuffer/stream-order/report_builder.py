"""실제 cycle trace를 독립적으로 재검사하고 단일 HTML 보고서를 만든다."""
from pathlib import Path
from datetime import datetime, timezone
from collections import Counter
import json


def audit(case):
    errors = []
    def check(ok, message):
        if not ok and len(errors) < 30:
            errors.append(message)
    rows = case.get("samples", [])
    if case.get("kind") == "config":
        check(len(rows) == 2, "설정 비교 관측 2개 필요")
        for row in rows:
            expected = row["inputRowCount"] == row["weightReplayCount"]
            check(row["configValid"] == expected, "설정 유효성 불일치")
            check(row["contextReady"] == expected, "설정 ready 불일치")
            check(not row["contextAccepted"], "검사 중 context가 실행됨")
        case["auditErrors"] = errors
        case["verified"] = case.get("status") == "PASS" and not errors
        return case

    c = case["config"]
    m_count, n_count, k_count = c["m"], c["n"], c["k"]
    group_bytes = n_count * k_count * 256
    group_beats = group_bytes // 16
    expected = [(m, n, k, b) for m in range(m_count) for n in range(n_count)
                for k in range(k_count) for b in range(16)]
    requests = [(m, offset, min(4096, group_bytes - offset))
                for m in range(m_count) for offset in range(0, group_bytes, 4096)]
    releases = {m * group_beats + (offset + size) // 16 - 1: size
                for m, offset, size in requests}
    def word(n, k, b):
        value = (0x5742 << 112) | (c["contextId"] << 96) | (n << 64) | (k << 32) | b
        return "0x" + format(value, "032x")
    req_index = output_index = granted = reclaimed = received = 0
    by_group = [0] * m_count
    pending = None
    held = None
    tile_counts = Counter()
    output_cycles = []
    pass_cycles = []
    op_cycles = []
    context_cycles = []
    for index, row in enumerate(rows):
        cycle = row["cycle"]
        check(cycle == index, f"cycle 기록 불연속: {cycle}")
        check(row["freeBytes"] == 16384 - granted + reclaimed, f"공간 회계 불일치 @{cycle}")
        check(row["refillPending"] == (pending is not None), f"pending 불일치 @{cycle}")
        check(row["outputFire"] == (row["outputValid"] and row["outputReady"]), f"output fire 불일치 @{cycle}")
        check(row["memoryFire"] == (row["memoryValid"] and row["memoryReady"]), f"memory fire 불일치 @{cycle}")
        check(row["requestFire"] == (row["requestValid"] and row["requestReady"]), f"request fire 불일치 @{cycle}")
        if held is not None:
            check(row["outputValid"] and
                  (row["outputData"], row["passIndex"], row["outputLast"]) == held,
                  f"정지 중 출력 변경 @{cycle}")
        held = ((row["outputData"], row["passIndex"], row["outputLast"])
                if row["outputValid"] and not row["outputReady"] else None)
        if row["outputValid"]:
            check(output_index < len(expected), f"추가 출력 @{cycle}")
            if output_index < len(expected):
                m, n, k, b = expected[output_index]
                check(row["outputData"] == word(n, k, b), f"실제 출력 순서/데이터 불일치 @{cycle}")
                check(row["expectedData"] == word(n, k, b), f"Scala 기대값 불일치 @{cycle}")
                check(row["passIndex"] == m, f"M-group 불일치 @{cycle}")
                check((row["actualN"], row["actualK"], row["actualBeat"]) == (n, k, b),
                      f"실제 n/k/beat 불일치 @{cycle}")
                check(row["outputLast"] == (output_index == len(expected) - 1),
                      f"최종 marker 불일치 @{cycle}")
                local_byte = (output_index % group_beats) * 16
                chunk_end = min((local_byte // 4096 + 1) * 4096, group_bytes)
                check(by_group[m] >= chunk_end, f"chunk commit 이전 출력 @{cycle}")
        expected_pass = row["outputFire"] and (output_index + 1) % group_beats == 0
        expected_done = row["outputFire"] and output_index == len(expected) - 1
        check(row["passDone"] == expected_pass, f"passDone timing 불일치 @{cycle}")
        check(row["operationDone"] == expected_done, f"operationDone timing 불일치 @{cycle}")
        if row["requestFire"]:
            check(pending is None, f"outstanding 중복 @{cycle}")
            check(req_index < len(requests), f"추가 refill 요청 @{cycle}")
            if req_index < len(requests):
                m, offset, size = requests[req_index]
                check((row["requestGroup"], row["requestBytes"]) == (m, size),
                      f"refill descriptor 불일치 @{cycle}")
                pending = {"m": m, "offset": offset, "size": size, "sent": 0}
                granted += size
            req_index += 1
        if row["memoryFire"]:
            check(pending is not None, f"예약 없는 입력 @{cycle}")
            if pending:
                beat_index = (pending["offset"] + pending["sent"]) // 16
                n = beat_index // (k_count * 16)
                k = (beat_index // 16) % k_count
                check(row["inputM"] == pending["m"], f"DMA group 불일치 @{cycle}")
                check(row["memoryData"] == word(n, k, beat_index % 16),
                      f"AG 모형의 입력 word 불일치 @{cycle}")
                size = row["memoryBytes"]
                check(pending["sent"] + size <= pending["size"], f"예약 초과 @{cycle}")
                pending["sent"] += size
                by_group[pending["m"]] += size
                received += size
                if pending["sent"] == pending["size"]:
                    pending = None
        if row["outputFire"]:
            if output_index < len(expected):
                tile_counts[expected[output_index][:3]] += 1
            output_cycles.append(cycle)
            reclaimed += releases.get(output_index, 0)
            output_index += 1
        if row["passDone"]: pass_cycles.append(cycle)
        if row["operationDone"]: op_cycles.append(cycle)
        if row["contextDone"]:
            context_cycles.append(cycle)
            check(output_index == len(expected) and received == group_bytes * m_count,
                  f"조기 context 완료 @{cycle}")
    check(output_index == len(expected), "전체 출력 beat 수 불일치")
    check(req_index == len(requests), "전체 refill 요청 수 불일치")
    check(received == group_bytes * m_count, "전체 입력 byte 수 불일치")
    check(len(pass_cycles) == m_count and len(op_cycles) == 1 and len(context_cycles) == 1,
          "완료 pulse 횟수 불일치")
    check(pending is None and 16384 - granted + reclaimed == 16384, "미반환 공간/예약")
    check(all(count == 16 for count in tile_counts.values()) and
          len(tile_counts) == m_count * n_count * k_count, "tile별 출력 beat 수 불일치")
    if c.get("preload"):
        check(bool(output_cycles) and output_cycles[-1] - output_cycles[0] + 1 == len(expected),
              "기본 연속 출력에 빈 cycle 발생")
    output_stalls = sum(r["outputValid"] and not r["outputReady"] for r in rows)
    if c.get("stalls"):
        check(output_stalls >= 6, "출력 정지 검사 미발생")
    case["metrics"] = {
        "cycles": len(rows), "outputBeats": output_index, "inputBytes": received,
        "requestCount": req_index, "outputStallCycles": output_stalls,
        "firstOutputCycle": output_cycles[0] if output_cycles else None,
        "lastOutputCycle": output_cycles[-1] if output_cycles else None,
        "outputSpanCycles": output_cycles[-1] - output_cycles[0] + 1 if output_cycles else 0,
        "passDoneCycles": pass_cycles, "operationDoneCycles": op_cycles,
        "contextDoneCycles": context_cycles,
        "tiles": [{"m": m, "n": n, "k": k, "beats": tile_counts[(m, n, k)]}
                  for m in range(m_count) for n in range(n_count) for k in range(k_count)],
    }
    case["auditErrors"] = errors
    case["verified"] = case.get("status") == "PASS" and not errors
    return case


def build(run_path, results, trace_dir=None, metadata_override=None):
    run_path = Path(run_path)
    results = Path(results)
    metadata = metadata_override or json.loads((run_path / "run.json").read_text(encoding="utf-8"))
    trace_dir = Path(trace_dir) if trace_dir else run_path / "traces"
    cases = []
    for name in metadata["expectedCases"]:
        path = trace_dir / (name + ".json")
        if path.exists():
            cases.append(audit(json.loads(path.read_text(encoding="utf-8"))))
        else:
            cases.append({"id": name, "title": name, "kind": "missing", "status": "NOT_RUN",
                          "verified": False, "auditErrors": ["실행 trace 없음"], "samples": []})
    passed = sum(c["verified"] for c in cases)
    overall = (passed == len(metadata["expectedCases"]) and
               metadata["testExitCode"] == 0 and metadata["productionUnchanged"])
    report = {
        "schemaVersion": 1, "title": "WB STREAM 순서 검증",
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "scope": metadata["scope"], "metadata": metadata, "cases": cases,
        "summary": {"status": "PASS" if overall else "FAIL", "passedCases": passed,
                    "totalCases": len(cases),
                    "outputBeats": sum(c.get("metrics", {}).get("outputBeats", 0) for c in cases),
                    "inputBytes": sum(c.get("metrics", {}).get("inputBytes", 0) for c in cases)},
    }
    payload = json.dumps(report, ensure_ascii=False, separators=(",", ":"))
    template = (Path(__file__).parent / "report-template.html").read_text(encoding="utf-8")
    assert template.count("__REPORT_DATA__") == 1
    # file://에서도 열리도록 모든 관측 데이터와 JS/CSS를 한 파일에 담는다.
    html = template.replace("__REPORT_DATA__", payload.replace("<", "\\u003c").replace("&", "\\u0026"))
    results.mkdir(parents=True, exist_ok=True)
    (results / "report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    (results / "index.html").write_text(html, encoding="utf-8")
    print("Report: " + str(results / "index.html"), flush=True)
    print("Independent trace audit: " + str(passed) + "/" + str(len(cases)) +
          "; output beats=" + str(report["summary"]["outputBeats"]), flush=True)
    return 0 if overall else 1
