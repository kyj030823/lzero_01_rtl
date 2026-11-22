"""추가 acceptance와 같은 RTL revision의 기존 최소 결과를 합쳐 검증 범위를 기록한다."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
RESULTS = HERE / "results/acceptance"
UB_CASES = [
    "extra-full-cache-races", "extra-ub-mask-wrap", "extra-entry-policy-block",
    "extra-full-pending-tail", "extra-source-split-contract", "extra-fusion-reference-contract",
]
SHARED_CASES = [
    "storage-mask-matrix", "writer-admission", "writer-simultaneous", "reader-metadata-hold",
]


def validate(path, run=None):
    run = Path(run) if run else Path(json.loads((RESULTS / "latest.json").read_text())["all"])
    meta = json.loads((run / "run.json").read_text())
    errors = []
    def check(ok, message):
        if not ok:
            errors.append(message)
    check(meta["exitCode"] == 0 and meta["compileExitCode"] == 0, "컴파일/실행 실패")
    check(meta["group"] == "all" and not meta["filter"], "전체 추가 시험 결과가 아님")
    check(meta["sourcesUnchangedDuringRun"] and meta["testsUnchangedDuringRun"], "실행 중 소스 변경")
    for name, digest in dict(meta["sourceHashes"], **meta["testSourceHashes"]).items():
        check((ROOT / name).exists() and hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest,
              "현재 소스 hash 불일치: " + name)
    tests = []
    for xml in sorted((run / "junit").rglob("*.xml")):
        suite = ET.parse(xml).getroot()
        for t in suite.findall("testcase"):
            ok = t.find("failure") is None and t.find("error") is None and t.find("skipped") is None
            tests.append({"name": t.attrib["name"], "suite": suite.attrib["name"],
                          "seconds": float(t.attrib.get("time", 0)), "passed": ok})
    check(len(tests) == 10 and all(t["passed"] for t in tests), "추가 JUnit 10개 모두 통과해야 함")
    cases = {}
    for folder, names in [("ub", UB_CASES), ("shared", SHARED_CASES)]:
        for name in names:
            file = run / "traces" / folder / (name + ".json")
            if not file.exists():
                check(False, "관측값 누락: " + name)
                continue
            case = json.loads(file.read_text())
            check(case.get("passed", case.get("status") == "PASS"), "관측값 실패: " + name)
            cases[name] = case
    check(len(cases) == 10, "모든 관측값이 필요함")
    if len(cases) == 10:
        metrics = cases["extra-full-cache-races"]["metrics"]
        check(metrics["requestAndReclaimCycles"] >= 2, "예약/반환 동시 수락 부족")
        check(metrics["writeReadReclaimCycles"] >= 1, "write/read/reclaim 동시 수락 없음")
        check(metrics["inFlightResponseHoldPoints"] == 3 and metrics["heldClocks"] == 15,
              "in-flight/rewind/row 교체 hold 관측 부족")
        job = cases["extra-full-cache-races"]["jobs"][0]
        check(job["rowBytes"] == 16384 and job["rows"] == 2 and job["passes"] == 2 and
              job["outputBeats"] == 4096 and job["nextRowGrantsBeforeRowDone"] > 0,
              "16KiB 다중 pass와 next-row overlap 조건 부족")
        check(job["lastOutputCycle"] - job["firstOutputCycle"] + 1 == 4111, "예상 밖 출력 공백")
        case = cases["extra-ub-mask-wrap"]
        observed = [e for e in case["events"] if e["event"] == "mask-target"]
        expected = {(region, bank, mask) for region in ["ordinary", "physical-wrap", "extended-wrap"]
                    for bank in range(4) for mask in [1, 3, 7, 15]}
        check({(e["region"], e["bank"], e["mask"]) for e in observed} == expected and len(observed) == 48,
              "UB mask/bank/region 48조합 누락")
        check(sum(e["crossPhysical"] for e in observed) >= 2 and
              sum(e["crossExtended"] for e in observed) >= 1, "UB 실제 wrap-crossing beat 누락")
        check(cases["storage-mask-matrix"]["metrics"]["matrixCases"] == 48,
              "공용 저장소의 정확한 경계 48조합 누락")
        check(cases["extra-entry-policy-block"]["metrics"]["expectedPolicyBlock"],
              "정책 제한을 별도 결과로 기록해야 함")
        blocks = [e for e in cases["extra-entry-policy-block"]["events"] if e["event"] == "expected-policy-block"]
        check(len(blocks) == 1 and blocks[0]["entries"] == 4 and blocks[0]["freeBytes"] == 16320 and
              blocks[0]["fifthEntrySupported"] is False,
              "5번째 선행 적재 제한을 정상 지원으로 표시하면 안 됨")
        check(cases["extra-full-pending-tail"]["metrics"]["freeDuringReservedTail"] == 4080 and
              cases["extra-full-pending-tail"]["metrics"]["reservedResponseAcceptedWhileFull"],
              "4080B/full에서 예약 응답 수락 검증 누락")
        for case_id in ["extra-source-split-contract", "extra-fusion-reference-contract"]:
            c = cases[case_id]
            records = [m for key, m in c["metrics"].items() if key.startswith(("stream-", "cache-"))]
            check(len(records) == (6 if case_id == "extra-fusion-reference-contract" else 3),
                  "source profile 결과 누락")
            check(len({m["outputSha256"] for m in records}) == 1, "IB hit/miss별 실제 출력 digest 불일치")
            for key, m in c["metrics"].items():
                if not key.startswith(("stream-", "cache-")):
                    continue
                check(m["physicalLasts"] == m["logicalCompletions"] + m["intermediatePhysicalLasts"],
                      "physical/logical last 계수 불일치")
                if key.endswith(("ib", "mixed")):
                    check(m["intermediatePhysicalLasts"] > 0, "중간 physical last가 실제 발생하지 않음")
                if key.endswith("mixed"):
                    check(m["ibBeats"] > 0 and m["dramBeats"] > 0, "IB/DRAM 혼합 입력 없음")
            if case_id == "extra-fusion-reference-contract":
                check(len(records) == 6 and all(m["phaseReferenceBeats"] == 384 for m in records),
                      "CACHE/STREAM × 3 source profile reference 부족")
                for cache in [True, False]:
                    for profile in ["dram", "ib", "mixed"]:
                        events = [e for e in c["events"] if e["event"] == "phase-reference" and
                                  e["cache"] == cache and e["profile"] == profile]
                        reference = [(row, col, phase, 2 * col + index, col == 2 and phase == "W2")
                                     for row in range(2) for col in range(3)
                                     for index, phase in enumerate(["W1", "W2"])]
                        actual = [(e["row"], e["column"], e["phase"], e["pass"], e["inputRowDone"]) for e in events]
                        check(actual == reference, "행/column/W1-W2 phase reference 순서 불일치")
    previous = Path(meta["previousMinimalRun"])
    minimal = json.loads((previous / "run.json").read_text())
    compatible = meta["previousMinimalCompatible"] and minimal["exitCode"] == 0 and minimal["totalTests"] == 8 and (
        minimal["sourceHashes"] == meta["sourceHashes"]) and all(
        hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest
        for name, digest in minimal["testSourceHashes"].items())
    check(compatible, "기존 최소 8개 결과와 같은 revision이 아님")
    coverage = [
        (1, "BUFFER_PASS", "기존 Dense STREAM 1/2pass 및 이번 fusion STREAM 6pass"),
        (2, "BUFFER_PASS", "기존 6KiB 4KiB+2KiB/2pass 보존 및 조기 출력"),
        (3, "BUFFER_PASS", "16KiB 4-entry, 2row×2pass, 마지막 pass next-row overlap"),
        (4, "BUFFER_PASS", "기존 N=1 일반/fusion 및 이번 N=3 fusion 총 6pass"),
        (5, "BUFFER_PASS_WITH_CU_MODEL", "기존 compact 실제 ready 수락·CU pause·DMA; 실 CU는 미연결"),
        (6, "SHARED_AND_BUFFER_PASS", "공용 정확 경계 48조합 + UB mask/bank/주소영역 48조합과 실제 wrap"),
        (7, "BUFFER_PASS", "accepted logical last 직후 실제 entry.endPtr 및 출력 byte 검사"),
        (8, "SHARED_AND_BUFFER_PASS", "UB write/read/reclaim·grant/reclaim 강제 동시 수락, 4096/4080, 공용 delta 시험"),
        (9, "BUFFER_PASS_WITH_POLICY_LIMIT", "4-entry에서 여유 공간이 있어도 5번째 차단; 제한을 정상 선행 적재로 오판하지 않음"),
        (10, "BUFFER_PASS", "in-flight 응답 보관 3지점, 중간 pass rewind, row 교체, data/last 안정"),
        (11, "CONTRACT_MODEL_PASS", "physical last를 논리 완료와 구분한 adapter 모형 + 실제 UB; 제품 adapter 미연결"),
        (12, "BUFFER_PASS", "기존 disabled/zero/done 경고 억제와 stale context 차단"),
        (13, "CONTRACT_MODEL_PASS", "W1→W2 per-column reference × CACHE/STREAM × DRAM/IB/mixed; 제품 phase·epoch 미연결"),
    ]
    data = {
        "checkedAt": datetime.now(timezone.utc).isoformat(),
        "executedTestsStatus": "PASS" if not errors else "FAIL",
        "allProductionIntegrationComplete": False,
        "additionalTests": len(tests), "previousCompatibleTests": 8 if compatible else 0,
        "totalDistinctTestsForCurrentRtl": len(tests) + (8 if compatible else 0),
        "runDirectory": str(run), "previousMinimalRun": str(previous),
        "productRtlChanged": minimal["sourceHashes"] != meta["sourceHashes"], "tests": tests, "coverage": [
            {"criterion": i, "status": status if not errors else "NOT_CONFIRMED", "detail": detail}
            for i, status, detail in coverage],
        "externalUnavailable": meta["externalUnavailable"],
        "errors": errors, "cases": cases,
    }
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
    lines = ["# UB acceptance 추가 시험 결과", "",
        "실행한 시험: **" + data["executedTestsStatus"] + "**. 추가 10개와 같은 RTL의 기존 최소 8개를 구분해 기록한다.",
        "실제 AG/IB/production fusion 통합 완료를 뜻하지 않는다.", "",
        "| 항목 | 상태 | 범위 |", "| --- | --- | --- |"]
    lines += ["| " + str(i) + " | " + status + " | " + detail + " |" for i, status, detail in coverage]
    lines += ["", "## 원본 결과", "",
        "- 추가 실행: " + str(run),
        "- 기존 최소 실행: " + str(previous),
        "- run.json / JUnit / ub.log / shared.log / traces/ub / traces/shared",
        "- 전체 관측값과 검사 결과: [summary.json](summary.json)", "",
        "## 해석 시 주의", "",
        "UB 48조합의 주소영역은 일반/16KiB wrap 주변/32KiB wrap 주변이다. "
        "모든 mask×bank를 정확한 끝 word에 놓는 조합은 공용 저장소 48조합에서 별도로 확인한다. "
        "UB 시험의 wrap은 pointer 주입 없이 실제 traffic으로 발생시킨다.",
        "",
        "5번째 metadata 선행 적재는 지원하지 않는 정책 제한이며 EXPECTED_BACKPRESSURE로 기록한다. "
        "Consumer를 재개하면 기존 FIFO 순서로 진행하는 것을 검사한다.",
        "",
        "Source/phase 시험은 실제 UB와 SRAM에 시험용 resolver/engine/normalizer/reference를 붙인다. "
        "제품 AG/IB controller와 split-response adapter, 실제 W1/W2/qparam/epoch wiring은 없어 통합 확인이 남아 있다.",
    ]
    if errors:
        lines += ["", "## 오류", ""] + ["- " + error for error in errors]
    path.with_suffix(".md").write_text("\n".join(lines) + "\n")
    print("Acceptance report: " + str(path))
    print("Executed tests: " + data["executedTestsStatus"] + "; additional=" + str(len(tests)) +
          "; previous-compatible=" + str(data["previousCompatibleTests"]))
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(validate(RESULTS / "summary.json"))
