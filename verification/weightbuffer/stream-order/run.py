#!/usr/bin/env python3
"""WB STREAM 전용 회귀. 생산 RTL은 수정하지 않으며 로컬 캐시로 분리 컴파일한다."""
from pathlib import Path
from datetime import datetime, timezone
import argparse
import hashlib
import json
import os
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(HERE.parent))
from source_paths import production_sources

SOURCES = production_sources(ROOT)
SPEC = ROOT / "src/test/scala/weightbuffer/WeightBufferStreamOrderSpec.scala"
RESULTS = HERE / "results"


def hashes():
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in SOURCES}


def stream_command(command, cwd, log_path):
    with log_path.open("w", encoding="utf-8") as log:
        process = subprocess.Popen(command, cwd=cwd, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT, text=True, bufsize=1)
        for line in process.stdout:
            print(line, end="", flush=True)
            log.write(line)
            log.flush()
        return process.wait()


def render(run_path, trace_dir=None, metadata_override=None):
    from report_builder import build
    return build(run_path, RESULTS, trace_dir=trace_dir, metadata_override=metadata_override)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--test-only", action="store_true", help="테스트/JSON만 생성")
    parser.add_argument("--render-only", action="store_true", help="최근 JSON으로 HTML만 재생성")
    args = parser.parse_args()
    RESULTS.mkdir(parents=True, exist_ok=True)
    if args.render_only:
        latest = json.loads((RESULTS / "last-run.json").read_text(encoding="utf-8"))
        return render(Path(latest["runDirectory"]), latest.get("traceDirectory"), latest.get("metadataOverride"))

    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")
    run_path = RESULTS / "runs" / stamp
    trace_dir = run_path / "traces"
    junit_dir = run_path / "junit"
    trace_dir.mkdir(parents=True)
    junit_dir.mkdir()
    work = Path(tempfile.mkdtemp(prefix="wb-stream-order-"))
    classes = work / "classes"
    classes.mkdir()
    cache = Path(os.environ.get("WB_COURSIER_CACHE", str(Path.home() / ".cache/coursier")))
    if not cache.exists():
        raise SystemExit("로컬 Coursier 캐시가 없습니다. WB_COURSIER_CACHE 경로를 지정하세요.")
    compiler = [next(cache.rglob(n)) for n in [
        "scala-compiler-2.13.12.jar", "scala-library-2.13.12.jar", "scala-reflect-2.13.12.jar"]]
    plugin = next(cache.rglob("chisel-plugin_2.13.12-6.7.0.jar"))
    priority = [next(cache.rglob(n)) for n in ["chisel_2.13-6.7.0.jar", "chiseltest_2.13-6.0.0.jar"]]
    jars = list(dict.fromkeys(compiler + priority +
        sorted(p for p in cache.rglob("*.jar") if "_2.12" not in p.name)))
    classpath = ":".join(map(str, jars))
    before = hashes()
    metadata = {
        "schemaVersion": 1, "startedAt": datetime.now(timezone.utc).isoformat(),
        "runDirectory": str(run_path), "buildDirectory": str(work),
        "scope": "WB + 실제 SRAM + AG 논리 공급 모형. AG DRAM/IB 주소 생성은 별도 검증.",
        "sourceHashes": before, "testSourceHash": hashlib.sha256(SPEC.read_bytes()).hexdigest(),
        "versions": {"scala": "2.13.12", "chisel": "6.7.0", "chiseltest": "6.0.0"},
        "expectedCases": ["baseline", "stalls", "chunk-boundary", "count-mismatch"],
        "excluded": "긴 LUT 및 기존 전체 회귀는 실행하지 않음",
    }
    print("Artifacts: " + str(run_path), flush=True)
    print("Compiling 6 WB sources and STREAM order spec...", flush=True)
    compile_code = stream_command(
        ["java", "-cp", ":".join(map(str, compiler)), "scala.tools.nsc.Main",
         "-classpath", classpath, "-Xplugin:" + str(plugin), "-language:reflectiveCalls",
         "-deprecation", "-feature", "-d", str(classes)] + list(map(str, SOURCES + [SPEC])),
        work, run_path / "compile.log")
    metadata["compileExitCode"] = compile_code
    code = compile_code
    if compile_code == 0:
        print("Running 4 focused STREAM tests...", flush=True)
        code = stream_command([
            "java", "-Dwb.streamOrderTraceDir=" + str(trace_dir),
            "-cp", str(classes) + ":" + classpath,
            "org.scalatest.tools.Runner", "-R", str(classes), "-oD", "-u", str(junit_dir),
            "-s", "npu.core.memory.WeightBufferStreamOrderSpec",
        ], work, run_path / "tests.log")
    metadata["testExitCode"] = code
    metadata["productionUnchanged"] = before == hashes()
    metadata["finishedAt"] = datetime.now(timezone.utc).isoformat()
    if not metadata["productionUnchanged"]:
        code = code or 1
    (run_path / "run.json").write_text(json.dumps(metadata, ensure_ascii=False, indent=2), encoding="utf-8")
    (RESULTS / "last-run.json").write_text(json.dumps(
        {"runDirectory": str(run_path)}, indent=2), encoding="utf-8")
    if not args.test_only:
        report_code = render(run_path)
        code = code or report_code
    print("Validation exit code: " + str(code), flush=True)
    return code


if __name__ == "__main__":
    raise SystemExit(main())
