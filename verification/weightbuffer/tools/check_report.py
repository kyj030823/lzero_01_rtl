#!/usr/bin/env python3
"""RTL을 재실행하지 않고 보고서 독립 검사기와 로컬 브라우저 표시를 점검한다."""
from pathlib import Path
from datetime import datetime, timezone
import copy
import hashlib
import html
import importlib.util
import json
import re
import subprocess
import tempfile
import shutil

HERE = Path(__file__).resolve().parents[1]
RESULTS = HERE / "results"
QA = RESULTS / "qa"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_auditor():
    spec = importlib.util.spec_from_file_location("wb_auditor", HERE / "report.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


HARNESS = r"""
<script>
(()=> {
 const checks=[];
 const test=(ok,name)=>checks.push({name,passed:!!ok});
 try {
  test(document.documentElement.dataset.reportReady==='true','report-ready');
  test(report.status==='PASS','aggregate-pass');
  test(report.tests.length===62&&report.tests.every(t=>t.passed),'62-ScalaTest-results');
  test(report.cases.length===11&&report.cases.every(c=>c.verified),'11-audited-cases');
  test(document.querySelectorAll('#coverage tr').length===14,'14-criteria-visible');
  test(document.querySelectorAll('#coverage .model').length===2,'two-model-scopes-labeled');
  test(document.querySelectorAll('#groups tr').length===3,'three-run-groups');
  test(document.querySelectorAll('#tests tr').length===62,'all-test-rows');
  test(document.body.textContent.includes('실제 상위 모듈은 미연결'),'integration-limit-visible');
  const select=document.getElementById('case-select');
  let viewed=0;
  for(let i=0;i<select.options.length;i++){
   select.value=String(i);select.dispatchEvent(new Event('change'));
   const item=report.cases[i];
   const timed=item.samples.some(r=>r.event==='cycle'||r.event==='writer');
   test(document.getElementById('explorer').hidden===!timed,'view-mode-'+item.id);
   if(timed)test(document.getElementById('sample').textContent.includes('"cycle"'),'sample-'+item.id);
   else test(document.getElementById('unit-details').textContent.length>30,'unit-'+item.id);
   viewed++;
  }
  test(viewed===11,'all-cases-open');
  select.value=String(report.cases.findIndex(c=>c.id==='full-cache-final'));
  select.dispatchEvent(new Event('change'));
  const metrics=JSON.parse(document.getElementById('metrics').textContent);
  test(metrics.expectedOutputBeats===3072,'cache-output-metric');
  test(metrics.expectedInputBytes===16384,'cache-input-metric');
  const slider=document.getElementById('position');
  slider.value='10';slider.dispatchEvent(new Event('input'));
  const before=Number(slider.value);
  document.getElementById('next').click();test(Number(slider.value)===before+1,'next-control');
  document.dispatchEvent(new KeyboardEvent('keydown',{key:'ArrowLeft',bubbles:true}));
  test(Number(slider.value)===before,'keyboard-control');
  const raw=document.getElementById('raw-link').getAttribute('href');
  test(raw.includes('/traces/full-cache-final.json'),'raw-evidence-link');
  document.getElementById('play').click();test(document.getElementById('play').textContent==='정지','play-start');
  document.getElementById('play').click();test(document.getElementById('play').textContent==='재생','play-stop');
  test(document.getElementById('timeline').toDataURL().length>1000,'canvas-rendered');
  test(document.body.scrollWidth<=document.body.clientWidth+1,'no-body-horizontal-overflow');
 } catch(e) { checks.push({name:'harness-exception',passed:false,error:String(e)}); }
 const out=document.createElement('pre');out.id='wb-browser-qa';out.hidden=true;
 out.textContent=JSON.stringify({checks,errors:window.wbQaErrors||[],
   viewportWidth:window.innerWidth,layoutWidth:document.body.clientWidth,
   passed:checks.every(c=>c.passed)&&!(window.wbQaErrors||[]).length});
 document.body.appendChild(out);
})();
</script>
"""


def browser(report_path, width, label, force_layout=False):
    chrome = Path("/mnt/c/Program Files/Google/Chrome/Application/chrome.exe")
    if not chrome.exists():
        return {"status": "SKIPPED", "reason": "Windows Chrome unavailable"}
    temp_parent = Path("/mnt/c/Users/kyj03/AppData/Local/Temp")
    temp = Path(tempfile.mkdtemp(prefix="wb-verification-ui-", dir=temp_parent))
    text = report_path.read_text()
    monitor = "<script>window.wbQaErrors=[];window.addEventListener('error',e=>window.wbQaErrors.push(String(e.message)));</script>"
    text = text.replace("<style>", monitor + "<style>", 1)
    if force_layout:
        text = text.replace("</style>", "html,body{width:414px!important;max-width:414px!important}</style>", 1)
    page = temp / "qa.html"
    page.write_text(text.replace("</html>", HARNESS + "</html>"))
    windows = subprocess.check_output(["wslpath", "-w", str(temp)], text=True).strip()
    url = "file:///" + (windows + "\\qa.html").replace("\\", "/")
    screenshot = temp / (label + ".png")
    command = [str(chrome), "--headless=new", "--disable-gpu", "--no-first-run",
        "--no-default-browser-check", "--disable-background-networking",
        "--user-data-dir=" + windows + "\\profile", "--virtual-time-budget=1800",
        "--window-size=" + str(width) + ",1800", "--dump-dom",
        "--screenshot=" + windows + "\\" + screenshot.name, url]
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                            text=True, timeout=60)
    (QA / (label + "-browser.log")).write_text(result.stderr)
    match = re.search(r'<pre id="wb-browser-qa"[^>]*>(.*?)</pre>', result.stdout, re.S)
    if not match:
        raise RuntimeError("Browser QA DOM marker missing: " + result.stderr[-1500:])
    data = json.loads(html.unescape(match.group(1)))
    data["sourceHtmlSha256"] = digest(report_path)
    data["forced414Layout"] = force_layout
    (QA / (label + ".json")).write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
    if screenshot.exists():
        (QA / (label + ".png")).write_bytes(screenshot.read_bytes())
    if not data["passed"]:
        raise AssertionError(label + ": " + json.dumps(data, ensure_ascii=False))
    return data


def main():
    QA.mkdir(exist_ok=True)
    auditor = load_auditor()
    document = json.loads((RESULTS / "report.json").read_text())
    assert document["status"] == "PASS" and len(document["tests"]) == 62
    assert len(document["cases"]) == 11
    assert document["streamOrderSummary"]["passedCases"] == 4
    cases = {c["id"]: c for c in document["cases"]}
    mutations = []
    def reject(case_id, label, change):
        changed = copy.deepcopy(cases[case_id])
        change(changed)
        result = auditor.audit(changed)
        assert not result["verified"], label + " mutation was incorrectly accepted"
        mutations.append({"name": label, "rejected": True, "errors": result["auditErrors"]})
    def first(case, predicate):
        return next(r for r in case["samples"] if predicate(r))
    reject("full-cache-final", "wrong-output-data",
        lambda c: first(c, lambda r:r.get("computeValid")).update(computeData="0x00000000000000000000000000000000"))
    reject("lut-commit-transition", "premature-operation-done",
        lambda c: first(c, lambda r:r.get("memoryFire")).update(operationDone=True))
    reject("lut-commit-transition", "uncommitted-SRAM-read",
        lambda c: first(c, lambda r:r.get("readIssue")).update(
            readAddress=first(c, lambda r:r.get("readIssue"))["writePtr"]))
    reject("writer-simultaneous", "wrong-free-space",
        lambda c: c["samples"][1].update(freeBytes=c["samples"][1]["freeBytes"] + 16))
    reject("programming-timings", "compute-accepted-during-holding",
        lambda c:first(c, lambda r:r.get("computeFire")).update(modelHolding=True))
    def lose_eligibility(c):
        receive=first(c, lambda r:r.get("receiveDone"))["cycle"]
        first(c, lambda r:r.get("cycle")==receive+1).update(requestValid=False)
    reject("lut-commit-transition", "late-weight-eligibility", lose_eligibility)
    (QA / "audit-negative-controls.json").write_text(json.dumps(mutations, ensure_ascii=False, indent=2) + "\n")

    # HTML의 정적 링크와 원본 evidence 경로를 실제 파일과 대조한다.
    links = []
    for c in document["cases"]:
        path = RESULTS / c["evidencePath"]
        assert path.exists(), path
        links.append(c["evidencePath"])
    for group in document["groups"]:
        for filename in ["tests.log", "run.json"]:
            path = RESULTS / group["relativePath"] / filename
            assert path.exists(), path
            links.append(str(path.relative_to(RESULTS)))
    for filename in ["../README.md", "../stream-order/results/index.html", "report.json"]:
        assert (RESULTS / filename).resolve().exists(), filename
        links.append(filename)

    # 전체 실행 한 번의 JUnit 묶음도 4/7/51로 중복 없이 나눠야 한다.
    latest = json.loads((RESULTS / "latest.json").read_text())
    grouping = {}
    with tempfile.TemporaryDirectory(prefix="wb-grouping-qa-") as temp:
        merged = Path(temp)
        (merged / "junit").mkdir()
        for name in ["boundaries", "acceptance", "regression"]:
            for path in (Path(latest[name]) / "junit").glob("*.xml"):
                shutil.copy2(path, merged / "junit" / path.name)
        for name, expected in auditor.EXPECTED_COUNTS.items():
            counts, selected = auditor.junit_for_group(merged, name)
            assert counts["tests"] == expected == len(selected)
            grouping[name] = counts["tests"]
        removed = next((merged / "junit").glob("*BoundarySpec*.xml"))
        removed.unlink()
        assert auditor.junit_for_group(merged, "boundaries")[0]["tests"] == 0

    spec = importlib.util.spec_from_file_location("wb_runner", HERE / "run.py")
    runner = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runner)
    simulated = runner.update_latest({"boundaries": "old"}, "all", "/new")
    assert all(simulated[name] == "/new" for name in runner.GROUPS)
    filtered = runner.update_latest(dict(simulated), "all", "/filtered", "one-case")
    assert all(filtered[name] == "/new" for name in runner.GROUPS)
    (QA / "runner-grouping.json").write_text(json.dumps({
        "mergedJUnitCounts": grouping, "missingJUnitRejected": True,
        "allRunUpdatesAllGroups": True, "filteredRunPreservesFullResult": True,
        "rtlRerun": False}, indent=2) + "\n")

    desktop = browser(RESULTS / "index.html", 1440, "desktop")
    mobile = browser(RESULTS / "index.html", 500, "mobile", force_layout=True)
    summary = {"checkedAt": datetime.now(timezone.utc).isoformat(),
        "htmlSha256": digest(RESULTS / "index.html"), "negativeControls": len(mutations),
        "fileLinksChecked": len(links), "desktopPassed": desktop.get("passed"),
        "mobilePassed": mobile.get("passed"), "desktopChecks": len(desktop.get("checks", [])),
        "mobileChecks": len(mobile.get("checks", [])),
        "mobileNote": "Windows headless viewport 500px에서 414px 문서 폭을 강제한 layout 검사",
        "rtlRerun": False}
    (QA / "summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(summary, ensure_ascii=False))


if __name__ == "__main__":
    main()
