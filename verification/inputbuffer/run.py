#!/usr/bin/env python3
"""구현 후 한 번에 수행하는 UB 최소 검증: UB 6개 + 공용 경로 WB smoke 2개."""
from pathlib import Path
from datetime import datetime, timezone
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
    ROOT / "src/test/scala/weightbuffer/WeightBufferPrefillSpec.scala",
]
PHASES = [
    ("ub", "npu.core.memory.InputBufferSpec", [], 6),
    ("wb-lut-prefill", "npu.core.memory.WeightBufferPrefillSpec", [
        "-t", "WB context prefill should keep LUT, final-use CACHE and prefetched CACHE in one FIFO without mixing outputs"], 1),
    ("wb-cache-handoff", "npu.core.memory.WeightBufferPrefillSpec", [
        "-t", "WB context prefill should hand the single cache descriptor to the next CACHE only on the final pass"], 1),
]


def hashes(paths):
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}


def execute(args, cwd, log):
    with log.open("w", encoding="utf-8") as out:
        process = subprocess.Popen(args, cwd=cwd, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT, text=True, bufsize=1)
        for line in process.stdout:
            print(line, end="", flush=True)
            out.write(line)
            out.flush()
        return process.wait()


def main():
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    result = HERE / "results/runs" / stamp
    work = result / "work"
    classes = work / "classes"
    traces = result / "traces"
    for directory in [classes, traces]:
        directory.mkdir(parents=True, exist_ok=True)
    before = hashes(SOURCES)
    test_hashes = hashes(TESTS)
    baseline = json.loads((HERE / "baseline/hashes.json").read_text())["hashes"]
    cache = Path(os.environ.get("WB_COURSIER_CACHE", str(Path.home() / ".cache/coursier")))
    compiler = [next(cache.rglob(name)) for name in [
        "scala-compiler-2.13.12.jar", "scala-library-2.13.12.jar", "scala-reflect-2.13.12.jar"]]
    plugin = next(cache.rglob("chisel-plugin_2.13.12-6.7.0.jar"))
    priority = [next(cache.rglob(name)) for name in ["chisel_2.13-6.7.0.jar", "chiseltest_2.13-6.0.0.jar"]]
    jars = list(dict.fromkeys(compiler + priority + sorted(
        p for p in cache.rglob("*.jar") if "_2.12" not in p.name)))
    cp = ":".join(map(str, jars))
    metadata = {
        "startedAt": datetime.now(timezone.utc).isoformat(), "runDirectory": str(result),
        "sourceHashes": before, "testSourceHashes": test_hashes,
        "scope": "UB 실제 SRAM 경로 6개 + 변경된 공용 경로의 WB smoke 2개",
        "excluded": ["WB 전체 62개 회귀", "긴 LUT", "실제 AG/IB source resolver",
                     "실제 CU ZeroPadder", "production fusion phase/IB epoch 통합"],
        "versions": {"scala": "2.13.12", "chisel": "6.7.0", "chiseltest": "6.0.0"},
        "changedExistingSources": [name for name in baseline if before.get(name) != baseline[name]],
        "wbSourcesUnchanged": all(before[name] == digest for name, digest in baseline.items()
                                  if "/weightbuffer/" in name),
    }
    print("Artifacts: " + str(result), flush=True)
    print("Compiling all UB/WB/common RTL and only the required test sources...", flush=True)
    code = execute([
        "java", "-cp", ":".join(map(str, compiler)), "scala.tools.nsc.Main", "-classpath", cp,
        "-Xplugin:" + str(plugin), "-language:reflectiveCalls", "-deprecation", "-feature",
        "-d", str(classes)] + list(map(str, SOURCES + TESTS)), work, result / "compile.log")
    metadata["compileExitCode"] = code
    phases = []
    if code == 0:
        for name, suite, selection, expected in PHASES:
            junit = result / "junit" / name
            junit.mkdir(parents=True)
            print("Running " + name + " (" + str(expected) + " tests)...", flush=True)
            phase_code = execute([
                "java", "-Dub.traceDir=" + str(traces),
                "-cp", str(classes) + ":" + cp, "org.scalatest.tools.Runner", "-R", str(classes),
                "-oD", "-u", str(junit), "-s", suite] + selection, work, result / (name + ".log"))
            counts = {key: 0 for key in ["tests", "failures", "errors", "skipped"]}
            for xml in junit.glob("*.xml"):
                report = ET.parse(xml).getroot()
                for key in counts:
                    counts[key] += int(report.attrib.get(key, 0))
            if counts["tests"] != expected or any(counts[k] for k in ["failures", "errors", "skipped"]):
                phase_code = phase_code or 1
            phases.append({"name": name, "exitCode": phase_code, "expected": expected, "counts": counts})
            code = code or phase_code
    metadata["phases"] = phases
    metadata["totalTests"] = sum(p["counts"]["tests"] for p in phases)
    metadata["productionUnchangedDuringRun"] = before == hashes(SOURCES)
    metadata["testsUnchangedDuringRun"] = test_hashes == hashes(TESTS)
    if not metadata["productionUnchangedDuringRun"] or not metadata["testsUnchangedDuringRun"]:
        code = code or 1
    metadata["exitCode"] = code
    metadata["finishedAt"] = datetime.now(timezone.utc).isoformat()
    (result / "run.json").write_text(json.dumps(metadata, ensure_ascii=False, indent=2) + "\n")
    (HERE / "results/latest.json").write_text(json.dumps({"runDirectory": str(result)}, indent=2) + "\n")
    print("Validation exit code: " + str(code), flush=True)
    print("Total tests: " + str(metadata["totalTests"]), flush=True)
    return code


if __name__ == "__main__":
    raise SystemExit(main())
