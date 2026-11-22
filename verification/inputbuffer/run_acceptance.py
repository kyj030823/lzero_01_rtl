#!/usr/bin/env python3
"""UB의 부족했던 acceptance를 한 묶음으로 검증한다. 실제 AG/IB 통합과 모형을 구분한다."""
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
sys.path.insert(0, str(ROOT / "verification/weightbuffer"))
from source_paths import production_sources

SOURCES = production_sources(ROOT) + [
    ROOT / "src/main/scala/inputbuffer/InputBufferController.scala",
    ROOT / "src/main/scala/inputbuffer/InputBufferDataPath.scala",
]
TESTS = [
    ROOT / "src/test/scala/inputbuffer/InputBufferSpec.scala",
    ROOT / "src/test/scala/inputbuffer/InputBufferAcceptanceSpec.scala",
    ROOT / "src/test/scala/weightbuffer/WeightBufferTestSupport.scala",
    ROOT / "src/test/scala/weightbuffer/CircularBufferBoundarySpec.scala",
]
GROUPS = {
    "ub": ("npu.core.memory.InputBufferAcceptanceSpec", 6),
    "shared": ("npu.core.memory.CircularBufferBoundarySpec", 4),
}
EXPECTED_CASES = [
    "extra-full-cache-races", "extra-ub-mask-wrap", "extra-entry-policy-block",
    "extra-full-pending-tail", "extra-source-split-contract", "extra-fusion-reference-contract",
]


def hashes(paths):
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}


def execute(command, cwd, log):
    with log.open("w", encoding="utf-8") as out:
        process = subprocess.Popen(command, cwd=cwd, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT, text=True, bufsize=1)
        for line in process.stdout:
            print(line, end="", flush=True)
            out.write(line)
            out.flush()
        return process.wait()


def classpath():
    cache = Path(os.environ.get("WB_COURSIER_CACHE", str(Path.home() / ".cache/coursier")))
    compiler = [next(cache.rglob(name)) for name in [
        "scala-compiler-2.13.12.jar", "scala-library-2.13.12.jar", "scala-reflect-2.13.12.jar"]]
    plugin = next(cache.rglob("chisel-plugin_2.13.12-6.7.0.jar"))
    priority = [next(cache.rglob(name)) for name in ["chisel_2.13-6.7.0.jar", "chiseltest_2.13-6.0.0.jar"]]
    jars = list(dict.fromkeys(compiler + priority + sorted(
        p for p in cache.rglob("*.jar") if "_2.12" not in p.name)))
    return compiler, plugin, ":".join(map(str, jars))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--only", choices=["all", "ub", "shared"], default="all")
    parser.add_argument("--filter", help="문제 분석용 ScalaTest 이름 일부")
    parser.add_argument("--reuse-build", type=Path, help="동일 source/test hash의 기존 acceptance run")
    args = parser.parse_args()
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    result = HERE / "results/acceptance/runs" / stamp
    work = result / "work"
    classes = work / "classes"
    traces = result / "traces"
    for directory in [work, traces / "ub", traces / "shared"]:
        directory.mkdir(parents=True, exist_ok=True)
    before, test_hashes = hashes(SOURCES), hashes(TESTS)
    previous = Path(json.loads((HERE / "results/latest.json").read_text())["runDirectory"])
    minimal = json.loads((previous / "run.json").read_text())
    previous_compatible = minimal["sourceHashes"] == before and all(
        hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest
        for name, digest in minimal["testSourceHashes"].items())
    metadata = {
        "startedAt": datetime.now(timezone.utc).isoformat(), "runDirectory": str(result),
        "sourceHashes": before, "testSourceHashes": test_hashes,
        "previousMinimalRun": str(previous), "previousMinimalCompatible": previous_compatible,
        "previousMinimalTests": minimal["totalTests"] if previous_compatible and minimal["exitCode"] == 0 else 0,
        "group": args.only, "filter": args.filter,
        "integrationScope": "actual UB/common SRAM; resolver, physical response adapter and fusion reference are test models",
        "externalUnavailable": ["production AG/IB controller", "production split-response adapter",
                                "production W1/W2/qparam schedule and IB epoch wiring"],
        "expectedCases": EXPECTED_CASES if args.only in ["all", "ub"] and not args.filter else [],
    }
    compiler, plugin, cp = classpath()
    print("Artifacts: " + str(result), flush=True)
    code = 0
    if args.reuse_build:
        earlier = json.loads((args.reuse_build / "run.json").read_text())
        if earlier["sourceHashes"] != before or earlier["testSourceHashes"] != test_hashes:
            raise SystemExit("소스 hash가 달라 compile 결과를 재사용할 수 없습니다.")
        classes = Path(earlier["classesDirectory"])
        if not classes.exists():
            raise SystemExit("기존 classes directory가 없습니다.")
    else:
        classes.mkdir()
        print("Compiling current UB/WB/common RTL and acceptance helpers...", flush=True)
        code = execute([
            "java", "-cp", ":".join(map(str, compiler)), "scala.tools.nsc.Main", "-classpath", cp,
            "-Xplugin:" + str(plugin), "-language:reflectiveCalls", "-deprecation", "-feature",
            "-d", str(classes)] + list(map(str, SOURCES + TESTS)), work, result / "compile.log")
    metadata["compileExitCode"] = code
    metadata["classesDirectory"] = str(classes)
    phases = []
    if code == 0:
        selected = list(GROUPS) if args.only == "all" else [args.only]
        for name in selected:
            suite, expected = GROUPS[name]
            junit = result / "junit" / name
            junit.mkdir(parents=True)
            print("Running " + name + " (" + str(expected) + " tests)...", flush=True)
            command = ["java", "-Dub.traceDir=" + str(traces / "ub"),
                "-Dwb.acceptanceTraceDir=" + str(traces / "shared"),
                "-cp", str(classes) + ":" + cp, "org.scalatest.tools.Runner", "-R", str(classes),
                "-oD", "-u", str(junit), "-s", suite]
            if args.filter:
                command += ["-z", args.filter]
            phase_code = execute(command, work, result / (name + ".log"))
            counts = {key: 0 for key in ["tests", "failures", "errors", "skipped"]}
            for xml in junit.glob("*.xml"):
                report = ET.parse(xml).getroot()
                for key in counts:
                    counts[key] += int(report.attrib.get(key, 0))
            if (not args.filter and counts["tests"] != expected) or counts["tests"] == 0 or any(
                    counts[key] for key in ["failures", "errors", "skipped"]):
                phase_code = phase_code or 1
            phases.append({"name": name, "exitCode": phase_code, "counts": counts})
            code = code or phase_code
    metadata["phases"] = phases
    metadata["totalTests"] = sum(p["counts"]["tests"] for p in phases)
    metadata["sourcesUnchangedDuringRun"] = before == hashes(SOURCES)
    metadata["testsUnchangedDuringRun"] = test_hashes == hashes(TESTS)
    if not metadata["sourcesUnchangedDuringRun"] or not metadata["testsUnchangedDuringRun"]:
        code = code or 1
    metadata["exitCode"] = code
    metadata["finishedAt"] = datetime.now(timezone.utc).isoformat()
    (result / "run.json").write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + "\n")
    pointer = HERE / "results/acceptance/latest.json"
    if not args.filter:
        previous_pointer = json.loads(pointer.read_text()) if pointer.exists() else {}
        previous_pointer[args.only] = str(result)
        pointer.write_text(json.dumps(previous_pointer, ensure_ascii=False, indent=2) + "\n")
    print("Validation exit code: " + str(code), flush=True)
    print("Additional tests: " + str(metadata["totalTests"]), flush=True)
    return code


if __name__ == "__main__":
    raise SystemExit(main())
