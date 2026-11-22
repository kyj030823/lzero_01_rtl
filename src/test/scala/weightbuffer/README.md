# WB v3 시험 소스

제품 RTL은 src/main/scala/commonbuffer의 CircularBuffer 4개와 src/main/scala/weightbuffer의 WeightBuffer 2개다. 이 폴더는 그 구현을 검증하는 7개 suite와 공통 시험 지원 코드만 포함한다. Scala package는 npu.core.memory로 유지했다.

실행 방법·항목별 범위·결과 위치는 [WB 검증 안내](../../../../verification/weightbuffer/README.md)를 참고한다. 브라우저 결과는 [전체 보고서](../../../../verification/weightbuffer/results/index.html)에서 볼 수 있다.

기본 실행은 62개다. WeightBufferLutSpec의 이전 확장 조합 6개는 WbExtendedLut 태그로 제외한다. 제품 IO를 바꾸지 않는 관측 포트와 외부 CCU/programming 동작 모형은 WeightBufferTestSupport 및 AcceptanceSpec에만 있다.

기존 src/test/scala의 WbController*_Test 등은 다른 RTL을 대상으로 하므로 이 폴더에 합치지 않았다.
