"""실행 기록을 모아 독립 검사와 로컬 HTML 결과 목록을 만든다."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import sys
import html
import json
import xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(HERE))
from source_paths import resolve_source
RESULTS = HERE / "results"
EXPECTED = {
    "boundaries": ["storage-mask-matrix", "writer-admission", "writer-simultaneous", "reader-metadata-hold"],
    "acceptance": ["lut-commit-transition", "lut-tail-wrap", "lut-entry-budget", "full-cache-final",
                   "special-contexts", "reader-context-drain", "programming-timings"],
    "regression": [],
}
EXPECTED_COUNTS = {"boundaries": 4, "acceptance": 7, "regression": 51}
GROUP_SUITES = {
    "boundaries": {"CircularBufferBoundarySpec"},
    "acceptance": {"WeightBufferAcceptanceSpec"},
    "regression": {"WeightBufferContextSpec", "WeightBufferLutSpec", "WeightBufferPrefillSpec",
                   "WeightBufferStatusSpec", "WeightBufferStreamOrderSpec"},
}


def junit_for_group(run_path, group):
    counts = {key: 0 for key in ["tests", "failures", "errors", "skipped"]}
    tests = []
    for xml in sorted((Path(run_path) / "junit").glob("*.xml")):
        suite = ET.parse(xml).getroot()
        if suite.attrib.get("name", "").split(".")[-1] not in GROUP_SUITES[group]:
            continue
        for key in counts:
            counts[key] += int(suite.attrib.get(key, 0))
        for t in suite.findall("testcase"):
            tests.append({"suite": t.attrib.get("classname", suite.attrib.get("name", "")),
                "name": t.attrib["name"], "seconds": float(t.attrib.get("time", 0)),
                "passed": t.find("failure") is None and t.find("error") is None and t.find("skipped") is None})
    return counts, tests


def fingerprint(context, index, lut=False):
    return "0x" + format(((0x4c55 if lut else 0x5742) << 112) |
                         (context << 96) | (index << 48) | (0x12340000 + index), "032x")


def audit(case):
    errors = []
    def check(ok, text):
        if not ok and len(errors) < 20:
            errors.append(text)
    check(case.get("status") == "PASS", "Scala 시험이 통과하지 않음")
    rows = case.get("samples", [])
    metrics = case.get("metrics", {})
    if any(r.get("event") == "cycle" for r in rows):
        resident = reserved = written = reclaimed = entries = 0
        states = {}
        for r in rows:
            cycle = r.get("cycle")
            if r.get("event") == "context-start":
                check(resident == reserved == entries == 0, "이전 context 미반환")
                context = r["contextId"]
                states[context] = dict(config=r, lutIn=0, lutOut=0, weightIn=0,
                    output=0, requested=0, pending=0, requestCount=0, op=0, done=0,
                    overlap=0, passDone=0, receive=None, stream=None, weightReady=None, programming=None)
                entries = int(r["lutBytes"] > 0)
                continue
            if r.get("event") != "cycle":
                continue
            s = states[r["contextId"]]
            c = s["config"]
            count = c["bytes"] // 16
            output_total = count * (1 if c["vpu"] else c["passes"]) if c["computeEnabled"] else 0
            check(r["freeBytes"] == 16384 - resident - reserved, f"공간 회계 @{cycle}")
            check(r["residentBytes"] == resident and r["reservedBytes"] == reserved, f"점유/예약 @{cycle}")
            check(r["writePtr"] == written % 32768 and r["reclaimPtr"] == reclaimed % 32768, f"포인터 연속성 @{cycle}")
            check(r["entries"] == entries and 0 <= entries <= 4, f"entry 개수 @{cycle}")
            if r["readIssue"]:
                check(16 <= (r["writePtr"] - r["readAddress"]) % 32768 <= 16384, f"미기록 read @{cycle}")
                check(16 <= (r["issueEnd"] - r["readAddress"]) % 32768 <= 16384, f"chunk 초과 read @{cycle}")
            if r["lutValid"]:
                check(r["lutData"] == fingerprint(r["contextId"], s["lutOut"], True), f"LUT 데이터 @{cycle}")
                check((s["lutOut"] + 1) * 16 <= s["lutIn"], f"미수신 LUT 출력 @{cycle}")
            if r["computeValid"]:
                check(c["computeEnabled"] and s["output"] < output_total, f"추가 출력 @{cycle}")
                check(s["lutOut"] * 16 == c["lutBytes"], f"LUT 추월 @{cycle}")
                check(r["computeData"] == fingerprint(r["contextId"], s["output"] % count), f"weight 데이터 @{cycle}")
                check(r["passIndex"] == s["output"] // count, f"pass index @{cycle}")
                check(r["computeLast"] == (s["output"] == output_total - 1), f"최종 marker @{cycle}")
            expected_done = r["computeFire"] and s["output"] + 1 == output_total
            check(r["operationDone"] == expected_done, f"조기/누락 operationDone @{cycle}")
            expected_pass = r["computeFire"] and (s["output"] + 1) % max(1, count) == 0
            check(r["passDone"] == expected_pass, f"passDone @{cycle}")
            if r["requestFire"]:
                size = min(4096, c["bytes"] - s["requested"] % c["bytes"])
                check(r["requestBytes"] == size and s["pending"] == 0, f"요청 길이/중복 @{cycle}")
                s["requested"] += size
                s["pending"] = size
                s["requestCount"] += 1
                reserved += size
                entries += 1
            if r["creditFire"]:
                reserved += r["creditBytes"]
            if r["memoryFire"]:
                n = r["memoryBytes"]
                written += n
                reserved -= n
                resident += n
                if r["memoryLut"]:
                    s["lutIn"] += n
                    if r["receiveDone"]:
                        s["receive"] = cycle
                else:
                    s["weightIn"] += n
                    s["pending"] -= n
                    if r["memoryLast"]:
                        check(s["pending"] == 0, f"요청보다 이른 chunk last @{cycle}")
                        if s["weightReady"] is None:
                            s["weightReady"] = cycle
            if r["lutFire"]:
                s["lutOut"] += 1
                reclaimed += 16
                resident -= 16
                if r["streamDone"]:
                    s["stream"] = cycle
                    entries -= 1
            if r["computeFire"]:
                consumed = (s["output"] % count + 1) * 16
                final_use = not c["cache"] or s["output"] // count == c["passes"] - 1
                if final_use and (consumed % 4096 == 0 or consumed == c["bytes"]):
                    n = consumed % 4096 or 4096
                    reclaimed += n
                    resident -= n
                    entries -= 1
                s["output"] += 1
            s["op"] += int(r["operationDone"])
            s["passDone"] += int(r["passDone"])
            s["done"] += int(r["contextDone"])
            if r["lutFire"] and r["memoryFire"] and not r["memoryLut"]:
                s["overlap"] += 1
            if r.get("modelProgrammed") and s["programming"] is None:
                s["programming"] = cycle
            if "modelHolding" in r and r["computeFire"]:
                check(not r["modelHolding"] and r["modelProgrammed"] and r["modelUbReady"],
                      f"상위 준비 전 compute 수락 @{cycle}")
            check(resident >= 0 and reserved >= 0, f"음수 점유량 @{cycle}")
        for context, s in states.items():
            c = s["config"]
            expected = c["bytes"] // 16 * (1 if c["vpu"] else c["passes"]) if c["computeEnabled"] else 0
            check(s["output"] == expected and s["lutOut"] * 16 == c["lutBytes"], f"출력 수 context={context}")
            check(s["op"] == int(c["computeEnabled"]) and s["done"] == 1, f"완료 pulse context={context}")
            if case["id"] == "programming-timings":
                R, S, P, W = s["receive"], s["stream"], s["programming"], s["weightReady"]
                check(all(x is not None for x in [R, S, P, W]) and R <= S <= P, f"programming 인과관계 context={context}")
                order = next(r["timingOrder"] for r in rows if r.get("event") == "cycle" and r["contextId"] == context)
                expected_order = {"W-S-P": W < S < P, "S-W-P": S < W < P,
                                  "S-P-W": S < P < W, "S-W=P": S < W == P, "S=W-P": S == W < P}[order]
                check(expected_order, f"요구한 사건 순서가 실제로 발생하지 않음: {order}")
        check(resident == reserved == entries == 0, "마지막 공간/entry가 반환되지 않음")
        if case["id"] == "programming-timings":
            check(any(r.get("modelHolding") and r.get("lutFire") for r in rows), "holding 중 LUT 진행 없음")
            check(any(r.get("modelHolding") and r.get("memoryFire") and not r.get("memoryLut") for r in rows),
                  "holding 중 weight ingress 진행 없음")
        if case["id"] == "lut-commit-transition":
            check(metrics.get("eligibleCycle") == metrics.get("receiveCycle", -3) + 1, "RLAST 다음 clock eligibility")
            check(any(s["overlap"] > 0 for s in states.values()), "동일 clock LUT/weight 수락 없음")
            receive = next(r["cycle"] for r in rows if r.get("receiveDone"))
            after = next(r for r in rows if r.get("cycle") == receive + 1)
            check(after.get("requestValid"), "관측 신호에서 RLAST 다음 clock 요청 없음")
        if case["id"] == "full-cache-final":
            check(sum(s["weightIn"] for s in states.values()) == 16384, "16KiB unique input")
            check(sum(s["output"] for s in states.values()) == 3072, "48KiB replay output")
            check(sum(s["requestCount"] for s in states.values()) == 4, "cache 재공급 발생")
            accepted = [r["cycle"] for r in rows if r.get("computeFire")]
            check(accepted[-1] - accepted[0] + 1 == 3077, "cache 준비 구간의 예상 밖 출력 공백")
            last_input = max(r["cycle"] for r in rows if r.get("memoryFire") and not r.get("memoryLut"))
            check(accepted[0] < last_input, "전체 cache fill 전에 첫 pass 출력이 시작되지 않음")
        if case["id"] == "lut-tail-wrap":
            check(metrics.get("tailCases") == 6 and written > 32768, "두 wrap 경계를 실제 traffic으로 지나지 않음")
    elif case["id"].startswith("writer-"):
        resident = reserved = written = entries = 0
        for r in rows:
            check(r["freeBytes"] == 16384 - resident - reserved, "writer 공간 회계")
            check(r["reservedBytes"] == reserved and r["residentBytes"] == resident, "writer 점유량")
            check(r["entries"] == entries and r["writePtr"] == written % 32768, "writer entry/포인터")
            if r["requestFire"]:
                reserved += r["requestBytes"]
                entries += 1
            if r["creditFire"]:
                reserved += r["creditBytes"]
            if r["memoryFire"]:
                resident += r["memoryBytes"]
                written += r["memoryBytes"]
                reserved -= r["memoryBytes"]
                if r["memoryLast"]:
                    reserved = 0
            resident -= r["reclaimBytes"]
            entries -= int(r["release"])
        check(resident == reserved == entries == 0, "writer 종료 후 미반환")
        if case["id"] == "writer-simultaneous":
            check(sum(bool(r["creditFire"] and r["memoryFire"] and r["reclaimBytes"]) for r in rows) == 2,
                  "3중 갱신이 실제 발생하지 않음")
    elif case["id"] == "storage-mask-matrix":
        combinations = {(r["address"] - r["startBank"] * 16, r["startBank"], r["mask"]) for r in rows}
        check(len(combinations) == 48 and metrics.get("neighborReadChecks") == 384, "mask/bank/wrap 행렬 부족")
        check(metrics.get("simultaneousReadWriteCases") == 16, "동시 SRAM 접근 부족")
    elif case["id"] == "reader-metadata-hold":
        check(len(rows) == 5 and all(r["context"] == 3 and r["tag"] == 2 and not r["seekReady"] for r in rows),
              "응답 metadata 보관 관측 부족")
    else:
        check(False, "알 수 없는 evidence 유형")
    case["auditErrors"] = errors
    case["verified"] = not errors
    return case


def build():
    latest = json.loads((RESULTS / "latest.json").read_text())
    groups = []
    cases = []
    tests = []
    all_errors = []
    for name, expected in EXPECTED.items():
        path = Path(latest[name]) if name in latest else None
        if path is None or not (path / "run.json").exists():
            groups.append({"id": name, "status": "MISSING"})
            continue
        meta = json.loads((path / "run.json").read_text())
        errors = []
        if meta["exitCode"] or not meta["productionUnchanged"] or not meta["testsUnchangedDuringRun"]:
            errors.append("실행 실패 또는 실행 중 소스 변경")
        counts, group_tests = junit_for_group(path, name)
        if counts["tests"] != EXPECTED_COUNTS[name] or len(group_tests) != counts["tests"]:
            errors.append("현재 JUnit 파일의 실제 시험 수가 예상과 다름")
        if any(counts[key] for key in ["failures", "errors", "skipped"]) or not all(t["passed"] for t in group_tests):
            errors.append("JUnit 실패/오류/건너뛴 시험 존재")
        for relative, digest in meta["sourceHashes"].items():
            if hashlib.sha256(resolve_source(ROOT, relative).read_bytes()).hexdigest() != digest:
                errors.append("현재 생산 RTL과 결과 hash가 다름: " + relative)
        for relative, digest in meta["testSourceHashes"].items():
            if hashlib.sha256((ROOT / relative).read_bytes()).hexdigest() != digest:
                errors.append("현재 테스트와 결과 hash가 다름: " + relative)
        for case_id in expected:
            evidence = path / "traces" / (case_id + ".json")
            if not evidence.exists():
                errors.append("관측 JSON 누락: " + case_id)
                continue
            case = audit(json.loads(evidence.read_text()))
            case["group"] = name
            case["evidencePath"] = str(evidence.relative_to(RESULTS))
            cases.append(case)
            errors += [case_id + ": " + e for e in case["auditErrors"]]
        tests.extend(group_tests)
        groups.append({"id": name, "status": "PASS" if not errors else "FAIL",
            "runDirectory": str(path), "relativePath": str(path.relative_to(RESULTS)),
            "counts": counts, "startedAt": meta["startedAt"], "finishedAt": meta["finishedAt"],
            "productionUnchanged": meta["productionUnchanged"], "errors": errors})
        all_errors += errors
    # STREAM 전용 시각화도 이번 regression의 원본 trace를 그대로 사용한다.
    stream_summary = None
    regression = next((g for g in groups if g["id"] == "regression" and g["status"] == "PASS"), None)
    if regression:
        import importlib.util
        run_path = Path(regression["runDirectory"])
        meta = json.loads((run_path / "run.json").read_text())
        stream_meta = dict(meta,
            expectedCases=["baseline", "stalls", "chunk-boundary", "count-mismatch"],
            testExitCode=meta["exitCode"],
            testSourceHash=meta["testSourceHashes"]["src/test/scala/weightbuffer/WeightBufferStreamOrderSpec.scala"],
            scope="WB + 실제 SRAM + AG 논리 공급 모형. 실제 AG 주소 생성은 별도 검증.",
            excluded="긴 LUT 및 fused logical order/source split은 제외")
        spec = importlib.util.spec_from_file_location("wb_stream_report", HERE / "stream-order/report_builder.py")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        stream_results = HERE / "stream-order/results"
        result = module.build(run_path, stream_results,
            trace_dir=run_path / "traces/stream-order", metadata_override=stream_meta)
        stream_summary = json.loads((stream_results / "report.json").read_text())["summary"]
        (stream_results / "last-run.json").write_text(json.dumps({
            "runDirectory": str(run_path), "traceDirectory": str(run_path / "traces/stream-order"),
            "metadataOverride": stream_meta}, ensure_ascii=False, indent=2) + "\n")
        if result:
            all_errors.append("이번 STREAM trace의 독립 검사 실패")
    status = "FAIL" if all_errors else "PASS" if all(g["status"] == "PASS" for g in groups) else "INCOMPLETE"
    document = {"schemaVersion": 1, "generatedAt": datetime.now(timezone.utc).isoformat(),
        "status": status, "groups": groups, "tests": tests, "cases": cases, "streamOrderSummary": stream_summary,
        "limitations": ["4번 fused logical order/source split 미실행", "긴 LUT 조합 6개 제외",
            "8·9번은 실제 WB와 상위 동작 모형: 실제 CCU/programming unit 미연결",
            "1번은 WB 논리 stream 기준: 실제 AG DRAM/IB 주소 생성 미검증"],
        "errors": all_errors}
    (RESULTS / "report.json").write_text(json.dumps(document, ensure_ascii=False, indent=2) + "\n")
    # HTML에는 관측에 필요한 열만 포함하고 전체 원본 JSON은 그대로 보존한다.
    compact = dict(document)
    keep = {"cycle", "contextId", "event", "freeBytes", "reservedBytes", "entries", "writePtr", "reclaimPtr",
        "readIssue", "readAddress", "requestFire", "memoryFire", "memoryLut", "lutFire", "computeFire",
        "receiveDone", "streamDone", "passDone", "operationDone", "contextDone", "initialReady", "impending",
        "modelProgrammed", "modelHolding", "computeData", "computeExpected", "lutData", "lutExpected",
        "caseIndex", "startBank", "lanes", "mask", "address", "passed", "holdCycle", "context", "tag",
        "reclaimBytes", "release", "creditFire", "creditBytes", "memoryBytes", "requestBytes"}
    compact["cases"] = [dict(c, samples=[{k: v for k, v in r.items() if k in keep} for r in c["samples"]]) for c in cases]
    template = (HERE / "report-template.html").read_text()
    data = json.dumps(compact, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
    (RESULTS / "index.html").write_text(template.replace("__WB_REPORT_DATA__", data))
    print("Report: " + str(RESULTS / "index.html"))
    print("Status: " + status + ", ScalaTest: " + str(len(tests)) + ", independently audited cases: " + str(len(cases)))
    return int(bool(all_errors))
