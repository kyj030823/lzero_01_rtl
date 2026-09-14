#!/usr/bin/env bash
set -o pipefail
cd /workspace/lzero_01_rtl
mkdir -p src/test/logs
sbt -Dsbt.color=false  'set Compile / sources := (Compile / sources).value.filter(f => Set("WbController.scala", "OCM.scala").contains(f.getName))'  'set Test / sources := (Test / sources).value.filter(_.getName == "WbCircularRegression_Test.scala")'  'testOnly npu.core.memory.WbCircularRegression_Test -- -oD'  2>&1 | tee src/test/logs/wb-lut-regression.log