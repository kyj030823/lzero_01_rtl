#!/usr/bin/env python3
"""WB 검증 전용 실행기. 긴 LUT와 fusion 순서 시험은 기본 실행에서 제외한다."""
from pathlib import Path
from datetime import datetime, timezone
import argparse
import hashlib
import json
import os
import subprocess
import sys
import xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(HERE))
from source_paths import production_sources, canonical_hashes

TESTS = ROOT / "src/test/scala/weightbuffer"
SOURCES = production_sources(ROOT)
GROUPS = {
    "boundaries": ["CircularBufferBoundarySpec"],
    "acceptance": ["WeightBufferAcceptanceSpec"],
    "regression": ["WeightBufferContextSpec", "WeightBufferLutSpec", "WeightBufferPrefillSpec",
                   "WeightBufferStatusSpec", "WeightBufferStreamOrderSpec"],
}
RESULTS = HERE / "results"


def hashes(paths):
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}


def command(args, cwd, log):
    with log.open("w", encoding="utf-8") as out:
        p = subprocess.Popen(args, cwd=cwd, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, text=True, bufsize=1)
        for line in p.stdout:
            print(line, end="", flush=True)
            out.write(line)
            out.flush()
        return p.wait()



def update_latest(latest, group, run, filtered=None):
    latest[group if not filtered else group + ":" + filtered] = str(run)
    if group == "all" and not filtered:
        for name in GROUPS:
            latest[name] = str(run)
    return latest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--only", choices=list(GROUPS) + ["all"], default="all")
    parser.add_argument("--test-only", action="store_true")
    parser.add_argument("--render-only", action="store_true")
    parser.add_argument("--filter", help="ScalaTest 이름에 포함된 문자열")
    parser.add_argument("--reuse-build", type=Path, help="동일 소스 hash의 이전 run 디렉터리")
    args = parser.parse_args()
    RESULTS.mkdir(exist_ok=True)
    if args.render_only:
        from report import build
        return build()

    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    run = RESULTS / "runs" / stamp
    trace = run / "traces"
    junit = run / "junit"
    work = run / "work"
    for directory in [trace, junit, work]:
        directory.mkdir(parents=True, exist_ok=True)
    test_sources = sorted(TESTS.glob("*.scala"))
    prod_hashes, test_hashes = hashes(SOURCES), hashes(test_sources)
    cache = Path(os.environ.get("WB_COURSIER_CACHE", str(Path.home() / ".cache/coursier")))
    compiler = [next(cache.rglob(n)) for n in [
        "scala-compiler-2.13.12.jar", "scala-library-2.13.12.jar", "scala-reflect-2.13.12.jar"]]
    plugin = next(cache.rglob("chisel-plugin_2.13.12-6.7.0.jar"))
    priority = [next(cache.rglob(n)) for n in ["chisel_2.13-6.7.0.jar", "chiseltest_2.13-6.0.0.jar"]]
    jars = list(dict.fromkeys(compiler + priority + sorted(
        p for p in cache.rglob("*.jar") if "_2.12" not in p.name)))
    cp = ":".join(map(str, jars))
    metadata = {
        "schemaVersion": 1, "startedAt": datetime.now(timezone.utc).isoformat(),
        "runDirectory": str(run), "group": args.only, "filter": args.filter,
        "sourceHashes": prod_hashes, "testSourceHashes": test_hashes,
        "excludedTags": ["npu.core.memory.WbExtendedLut"],
        "excludedScope": ["fused logical order/source split (criterion 4)", "long LUT combinations",
                          "real CCU/programming-unit integration", "real AG address generation"],
        "versions": {"scala": "2.13.12", "chisel": "6.7.0", "chiseltest": "6.0.0"},
    }
    classes = work / "classes"
    code = 0
    print("Artifacts: " + str(run), flush=True)
    if args.reuse_build:
        prior = json.loads((args.reuse_build / "run.json").read_text())
        if canonical_hashes(prior["sourceHashes"]) != canonical_hashes(prod_hashes) or prior["testSourceHashes"] != test_hashes:
            raise SystemExit("이전 build와 소스 hash가 달라 재사용할 수 없습니다.")
        classes = Path(prior["classesDirectory"])
        if not classes.exists():
            raise SystemExit("이전 classes가 없습니다.")
        metadata["reusedBuild"] = str(args.reuse_build)
    else:
        classes.mkdir()
        print("Compiling WB sources and organized test suites...", flush=True)
        code = command(
            ["java", "-cp", ":".join(map(str, compiler)), "scala.tools.nsc.Main",
             "-classpath", cp, "-Xplugin:" + str(plugin), "-language:reflectiveCalls",
             "-deprecation", "-feature", "-d", str(classes)] +
            list(map(str, SOURCES + test_sources)), work, run / "compile.log")
    metadata["compileExitCode"] = code
    metadata["classesDirectory"] = str(classes)
    suites = sum(GROUPS.values(), []) if args.only == "all" else GROUPS[args.only]
    metadata["suites"] = suites
    if code == 0:
        args_java = [
            "java", "-Dwb.acceptanceTraceDir=" + str(trace),
            "-Dwb.streamOrderTraceDir=" + str(trace / "stream-order"),
            "-cp", str(classes) + ":" + cp, "org.scalatest.tools.Runner",
            "-R", str(classes), "-oD", "-u", str(junit),
            "-l", "npu.core.memory.WbExtendedLut"]
        for suite in suites:
            args_java += ["-s", "npu.core.memory." + suite]
        if args.filter:
            args_java += ["-z", args.filter]
        code = command(args_java, work, run / "tests.log")
    metadata["exitCode"] = code
    metadata["productionUnchanged"] = prod_hashes == hashes(SOURCES)
    metadata["testsUnchangedDuringRun"] = test_hashes == hashes(test_sources)
    counts = {key: 0 for key in ["tests", "failures", "errors", "skipped"]}
    for path in junit.glob("*.xml"):
        suite = ET.parse(path).getroot()
        for key in counts:
            counts[key] += int(suite.attrib.get(key, 0))
    metadata["junitCounts"] = counts
    metadata["finishedAt"] = datetime.now(timezone.utc).isoformat()
    if not metadata["productionUnchanged"] or not metadata["testsUnchangedDuringRun"]:
        code = code or 1
    metadata["exitCode"] = code
    (run / "run.json").write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + "\n")
    latest_path = RESULTS / "latest.json"
    latest = json.loads(latest_path.read_text()) if latest_path.exists() else {}
    latest = update_latest(latest, args.only, run, args.filter)
    latest_path.write_text(json.dumps(latest, ensure_ascii=False, indent=2) + "\n")
    if not args.test_only:
        from report import build
        code = code or build()
    print("Validation exit code: " + str(code), flush=True)
    return code


if __name__ == "__main__":
    sys.exit(main())
