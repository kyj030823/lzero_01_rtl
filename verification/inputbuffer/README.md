# Input Buffer / UB v3

UB 명세서 v3를 기준으로 구현했다. WB와 같은 공용 CircularBufferStorage/WritePath/ReadPath/Core를 재사용한다.

~~~text
src/main/scala/inputbuffer/
  InputBufferController.scala   설정·검증·context 수락/완료
  InputBufferDataPath.scala     공개 입출력, row/pass·공급·소비 제어
src/test/scala/inputbuffer/
  InputBufferSpec.scala         꼭 필요한 UB 시험 6개
verification/inputbuffer/
  run.py                       UB 6개 + WB smoke 2개를 한 번에 실행
  baseline/                    변경 전 공용 소스·기존 WB hash
  results/runs/<실행 ID>/       컴파일/시험 로그, JUnit, 간단한 사건 JSON
~~~

## 구현 동작

- Dense GEMM row는 K×256B, compact row는 K×16B다. STREAM 공급은 m→pass→k이며 반복할 때 AG가 같은 row를 재공급한다.
- LOCAL_ROW_CACHE는 row 한 벌을 최대 4KiB씩 packed 저장한다. 첫 chunk complete 후 첫 pass를 시작할 수 있고 중간 pass는 metadata와 데이터를 보존한다.
- 현재 row의 마지막 pass부터 다음 row의 unique fill을 허용한다. 같은 context의 group identity로 구분하고 마지막 사용 중인 이전 row는 chunk별로 반환한다. Descriptor는 한 벌만 유지한다.
- inputRowDone 이후 다음 row의 rowPassIndex는 0이다. 다음 row가 준비됐으면 reader가 연속으로 이어지고, 준비되지 않았으면 DMA가 진행되는 동안 기다린다.
- Compact는 실제 computeDataReady 수락마다 16B만 소비한다. ZeroPadder의 zero rows는 UB가 생성하지 않으며 wall-clock 분주기를 넣지 않는다.
- VPU_DIRECT는 vectorPayloadBytes의 단일 linear stream이다. row cache와 GEMM row marker는 적용하지 않는다. 같은 computeData 포트를 사용하고 상위에서 VPU로 라우팅한다.
- 마지막 공급과 마지막 소비를 구분한다. operationDone은 마지막 compute output 수락의 pulse이며, contextDone은 이후 응답 drain까지 확인한다.
- Disabled/zero-length는 가짜 operationDone 없이 context를 마친다. softReset은 DMA/read/output 응답을 drain한 뒤 사용한다.
- 4KiB 미만 free에서 짧은 tail을 새로 승인하지 않는 정책, logical outstanding 1개와 공통 4-entry 제한은 그대로 적용한다.

## 설정과 입출력

Public top은 WB의 WeightBufferDataPath에 대응하는 InputBufferDataPath다. InputBufferController는 context 설정을 latch하고 검증하는 내부 제어부다. 모든 클래스의 package는 npu.core.memory다.

InputBufferConfig는 명세의 mode, compactInputEnable, M/K/N, rowReplayCount, vectorPayloadBytes, 일반/compact threshold, contextId를 갖는다. 일반 GEMM은 rowReplayCount=N을 검사한다. Fusion은 추가 통합 필드 fusionEnable=true로 상위가 명시한 양의 총 pass를 사용한다. 2×N은 가능한 schedule의 예이며 하드웨어가 임의로 고정하지 않는다. STREAM fusion도 local rewind 없이 상위가 그 pass 수만큼 재공급한다.

Row 길이 계산 폭은 max(payloadByteWidth, countWidth+8)로 두어 dense K×256을 자르지 않는다. STREAM groupIndex는 m×rowReplayCount+pass를 나타내므로 2×countWidth다. CACHE groupIndex는 rowIndex다. AG에는 refillRequestRowIndex와 refillRequestRowPassIndex도 직접 제공한다.

refillRequestStartsNewGroup은 각 공급 row/pass의 첫 chunk다. refillRequestAllowsOverwrite는 새 row의 첫 pass/첫 chunk에서 IB rolling-region 교체를 요청할 수 있음을 뜻한다. 실제 overwrite 허가·epoch 교체는 AG/IB가 확인하며 UB가 직접 실행하지 않는다.

computeDataReady와 readEnable은 전체 memory 경로를 정지시키지 않는다. rowPassDone/inputRowDone은 GEMM 전용 pulse이고, VPU에서는 0이다. rowCacheReady는 현재 소비 row의 unique 수신 완료이며, Core descriptor를 다음 row로 넘겨도 이전 row의 준비 상태와 혼동하지 않는다. initialReady는 context의 최초 chunk 준비 상태다. 이후 row 부족은 impending/readable 상태로 판단한다.

## 공용 경로 변경

CircularBufferCore의 enableGroupPrefill 옵션을 UB에서만 켠다. 마지막 pass에서만 다음 group descriptor를 설정하고, context+group으로 read/예약/수신의 cache 귀속을 구분한다. CircularBufferWritePath의 refillGroupIndex 출력은 진행 중 요청의 group identity를 전달한다.

WB는 이 옵션의 기본값 false를 유지한다. WB 전용 두 RTL 파일은 수정하지 않았다. 공용 파일의 내용은 변경됐으므로 이전 WB 62개 결과를 이번 revision 전체 회귀 결과로 재해석하지 않는다.

## 최소 검증

구현 후 아래 실행기로 컴파일과 필요한 시험을 한 번에 실행한다.

~~~sh
python3 verification/inputbuffer/run.py
~~~

~~~powershell
wsl -d Ubuntu-22.04 --exec python3 /home/kyj03/lzero_01_rtl/verification/inputbuffer/run.py
~~~

| 시험 | 확인할 내용 |
| --- | --- |
| config | 일반/fusion replay, cache 용량·폭·compact threshold, 설정 latch |
| stream | Dense m/pass/k, replay 1회/여러 회 및 fusion AG 재공급 |
| cache-6k | 4KiB+2KiB packing, 조기 첫 출력, 중간 pass 보존, 다음 row overlap |
| cache-16k | 4-entry·full, 마지막 pass에서 공간 반환 후 다음 row 수신, ring wrap |
| compact-vpu | Compact 16-step 수락 모형, CU pause 중 DMA, fusion N=1 총 2 pass, VPU 80B tail |
| context-drain | 마지막 출력 hold, context drain, stale 응답 차단, disabled/zero/reset |
| WB smoke 2개 | LUT→CACHE→다음 CACHE 및 마지막 pass의 descriptor handoff |

공용 mask/bank의 48조합과 긴 LUT 및 WB 전체 회귀를 반복하지 않는다. AG physical 주소/IB hit-miss/epoch, 실제 ZeroPadder, production fusion phase 연동과 합성 primitive/Fmax는 이번 검증 범위가 아니다.

## 이번 실행 결과

구현을 마친 뒤 한 묶음으로 실행해 UB 6개와 WB smoke 2개가 모두 통과했다. 총 15개 데이터 경로 context에서 49136B 입력과 3845개 16B 출력 beat를 비교했다. 여기에 별도 설정 검증 16조건과 latch 확인이 포함된다. 테스트 8개는 ScalaTest 등록 단위이며 각 시험 안에 여러 설정·context가 들어 있다.

요약은 [results/summary.json](results/summary.json), 실행 위치는 [results/latest.json](results/latest.json)에 있다. 전체 WB 62개와 긴 LUT는 다시 실행하지 않았다. 이번 실행 중 제품·시험 소스는 바뀌지 않았고 WB 전용 두 소스의 기존 hash도 유지됐다.

## 추가 acceptance 실험

최소 검증 이후 남은 버퍼 경계 및 외부 계약 시험을 추가했다. [추가 실험 안내](acceptance.md)와 [명세 항목별 결과](results/acceptance/summary.md)를 참고한다.

추가 UB 6개와 현재 공용 경계 시험 4개가 한 묶음으로 모두 통과했다. 이번 실험에서는 제품 RTL을 수정하지 않았으며, 같은 RTL revision의 기존 최소 8개 결과도 유효함을 hash로 확인했다. 합계는 서로 다른 등록 시험 18개다. Source split·IB hit/miss·fusion reference는 시험용 모형이며 실제 AG/IB/production phase 통합 완료를 뜻하지 않는다.
