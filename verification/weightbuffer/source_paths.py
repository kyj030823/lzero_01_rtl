"""현재 RTL 경로와 폴더 분리 전 검증 기록의 경로를 연결한다."""
from pathlib import Path

RELATIVE_SOURCES = (
    "src/main/scala/commonbuffer/CircularBufferStorage.scala",
    "src/main/scala/commonbuffer/CircularBufferReadPath.scala",
    "src/main/scala/commonbuffer/CircularBufferWritePath.scala",
    "src/main/scala/commonbuffer/CircularBufferCore.scala",
    "src/main/scala/weightbuffer/WeightBufferController.scala",
    "src/main/scala/weightbuffer/WeightBufferDataPath.scala",
)
# 과거 run.json은 수정하지 않고, 실제 파일을 검사할 때만 경로를 변환한다.
LEGACY_PATHS = {
    "src/main/scala/" + Path(relative).name: relative
    for relative in RELATIVE_SOURCES
}


def canonical_path(relative):
    relative = str(relative).replace(chr(92), "/")
    return LEGACY_PATHS.get(relative, relative)


def production_sources(root):
    return [Path(root) / relative for relative in RELATIVE_SOURCES]


def resolve_source(root, relative):
    return Path(root) / canonical_path(relative)


def canonical_hashes(recorded):
    result = {}
    for relative, digest in recorded.items():
        key = canonical_path(relative)
        if key in result and result[key] != digest:
            raise ValueError("동일 source에 서로 다른 hash가 기록됨: " + key)
        result[key] = digest
    return result
