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

## 명세서 9장 항목별 검증 설명

정리 기준일은 2026-11-22다. 아래는 기존 실행 기록과 코드 검토를 설명한 문서 보완이며, 이 문서를 추가하면서 테스트나 컴파일을 실행하지 않았다.

UB 전용 시험은 최소 6개와 추가 6개, 합계 12개가 통과했다. 현재 공용 버퍼 시험 4개도 통과했다. WB 핵심 재확인 2개까지 포함하면 서로 다른 등록 시험은 18개다. 18개 전체가 UB 전용 시험이라는 의미는 아니다. 추가 실험 당시 제품 RTL은 바꾸지 않았고, 기존 최소 결과와 소스 hash가 같은지도 확인했다.

| 번호 | 명세서 요구사항 | 실제 확인한 내용과 결과 |
| --- | --- | --- |
| 1 | Dense STREAM m→n→k 및 rowReplayCount 1회/여러 회 | 통과. Row/pass/K 순서와 실제 데이터를 비교했다. 1/2pass 및 fusion STREAM 6pass를 확인했으며 반복 데이터는 AG 모형이 다시 공급했다. |
| 2 | 6KiB row의 4KiB+2KiB compact 저장·중간 pass 보존 | 통과. Slot 사이 빈 공간 없이 저장하고 2pass 재생했다. 첫 chunk 완료 후 전체 row 수신 전 출력이 가능했고 중간 pass에는 refill/reclaim이 없었다. |
| 3 | 16KiB row 4-entry 재생과 마지막 pass의 next-row overlap | 통과. 16KiB row 2개를 각각 2pass 재생했다. 마지막 사용 중 소비한 chunk를 반환하고 다음 row를 미리 받았다. |
| 4 | Non-fusion N=1의 1pass 및 fusion N=1의 2pass, 최종 row 이후 추가 refill 금지 | 통과. 일반 1pass와 fusion 2pass에서 첫 pass의 reclaim/완료 차이를 확인했다. N=3의 총 6pass도 확인했다. |
| 5 | Compact 16B cadence, CU pause 중 소비 pointer 유지·DMA 지속 | CU 모형 연결 시험 통과. 모형이 16 CU step마다 16B를 수락하도록 했다. Pause 중 소비 pointer와 출력은 유지하고 가능한 DMA는 계속 수신했다. 실제 CU/ZeroPadder는 미연결이다. |
| 6 | Mask 0001/0011/0111/1111과 lane offset·ring wrap | 통과. 실제 UB traffic으로 mask 4종×시작 bank 4종×주소영역 3종의 48조합과 물리/확장 wrap을 확인했다. 정확한 끝 word의 mask/bank 조합은 공용 저장소 시험으로 보완했다. |
| 7 | memoryChunkLast의 마지막 유효 byte를 endPtr에 포함 | 통과. Logical last 수락 직후 실제 chunk entry의 endPtr를 비교하고 최종 출력 payload까지 확인했다. |
| 8 | Simultaneous write/read/reclaim·예약·full의 4096/4080B 경계 | 통과. Grant/reclaim 및 write/read/reclaim을 같은 clock에 강제로 수락시켰다. Free 4096B에서 16B 예약 후 4080B/full이 되어도 기존 예약 응답은 수신했다. |
| 9 | Metadata 4-entry와 full 제한을 넘는 발행 금지 | 통과. Free 16,320B여도 4-entry가 차면 5번째 요청을 차단했다. 소비·반환 후 재개했다. 제한 발생은 EXPECTED_BACKPRESSURE로 기록했다. |
| 10 | SRAM in-flight와 rewind/row 교체, backpressure의 data·last 유지 | 통과. 중간 pass 끝, row 끝, 최종 출력에서 응답을 보관했다. Rewind 및 row 교체 시 읽기 응답과 data/last가 보존됐다. |
| 11 | Source split의 중간 physical last를 logical chunk 경계로 사용하지 않음 | 모형 연결 시험 통과. DRAM-only/IB-only/mixed의 물리 분할을 logical last로 정규화해 실제 UB에 공급했다. Source가 달라도 실제 출력 digest가 같았다. 제품 adapter는 미연결이다. |
| 12 | Disabled/zero-length/operationDone 이후 impending 억제와 late old-context 차단 | 통과. 불필요한 요청·출력·경고를 억제하고 이전 context의 늦은 응답을 받지 않았다. Context 전환 drain과 안전한 reset도 확인했다. |
| 13 | Cache fusion replay와 상위 W1/W2 reference 일치, STREAM AG 재공급·IB hit/miss 순서 유지 | 모형 연결 시험 통과. N=3, 총 6pass를 column별 W1→W2 reference와 비교했다. CACHE/STREAM×DRAM/IB/mixed의 6조합에서 출력이 같았다. 실제 production phase/qparam/IB epoch 연결은 별도다. |

6번의 UB 48조합은 mask×bank×주소영역의 조합이다. 각 조합이 모두 ring 끝을 가로질렀다는 뜻은 아니다. 실제 wrap crossing과 공용 저장소의 정확한 경계 시험을 함께 확인한다.

설정 시험에는 cache 용량, row 길이 계산 폭, 일반/fusion replay, threshold 정렬과 설정 latch가 포함된다. VPU_DIRECT는 80B linear 입력이 16B 출력 5개로 나오는지도 확인했다.

11·13번의 source resolver, DRAM/IB engine, physical-last normalizer, fusion phase reference는 시험용 모형이다. 실제 AG/IB controller·제품 응답 adapter·production phase 연결까지 검증된 상태는 아니다.

원본 결과는 [최소 검증 요약](results/summary.json), [추가 검증 요약](results/acceptance/summary.md), [추가 검증 JSON](results/acceptance/summary.json)을 참고한다. 이 항목별 설명은 기존 실행 결과를 재해석하는 문서이며 새로운 시험 결과를 생성하지 않는다.

## Row group 교체 경로 코드 검토

2026-11-22에 UB의 row group A→B 전환을 코드를 따라 검토했다. 새 테스트나 컴파일을 실행하지 않았고 RTL도 수정하지 않았다. 아래 판단은 코드 검토 결과이며 위의 실행 시험 결과와 구분한다.

Cache 교체는 어느 group을 보존·재생할지 정하는 descriptor를 B로 넘기는 동작이다. SRAM과 chunk queue에는 아직 소비하지 않은 A 데이터와 미리 받은 B 데이터가 함께 남을 수 있다. Descriptor는 한 벌만 사용한다.

### 전환 순서와 보호 조건

1. **A의 마지막 pass에서만 B 설정을 허용한다.** UB의 fillRowAllowed는 현재 row 또는 현재 row의 마지막 pass에서 바로 다음 row만 허용한다. Core도 A의 cacheFillComplete, 마지막 pass, 미도착 refill 없음 및 group identity 변경을 확인한다. 중간 pass에는 A의 descriptor를 넘기지 않는다.
2. **B descriptor를 받으면서 읽기 위치는 유지한다.** B의 길이·총 pass·groupIndex를 저장하고 fill/pass 상태를 초기화한다. 기존 데이터가 남아 있으면 A의 읽기 cursor와 readPositioned를 유지한다.
3. **남은 A는 마지막 사용으로 소비·반환한다.** A chunk의 groupIndex는 새 descriptor B와 다르므로 readUsesCache=false가 된다. A의 남은 데이터를 순서대로 출력하고 각 chunk의 최종 출력 수락에서 공간과 entry를 반환한다. B chunk는 새 cache에 속하므로 설정한 횟수만큼 재생한다.
4. **B 수신량을 A와 구분한다.** Ingress의 cache 귀속은 상위의 현재 fill row가 아니라 Writer가 요청 당시 저장한 refillGroupIndex로 판정한다. B의 첫 예약에서 cacheStartPtr/cacheEndPtr와 첫 chunk entry를 고정한다. 진행 중인 A refill이 있으면 descriptor 교체 자체를 기다린다.
5. **교체와 A의 마지막 출력이 겹쳐도 B 상태를 보호한다.** Core의 이전 cache pass/완료 갱신은 !cacheConfigurationFire일 때만 수행한다. B 상태를 초기화한 clock에 A 완료 처리가 B의 cacheGroupComplete/pass 상태를 덮어쓰지 않도록 되어 있다.
6. **UB의 소비 진행은 독립적으로 유지한다.** inputRowIndex, rowPassIndex, rowPassBytesConsumed는 실제 출력 수락에서만 바뀐다. Core descriptor를 B로 넘겨도 A의 최종 pass 판정은 유지되며, A의 최종 pass가 끝난 뒤 소비 row를 B로 넘기고 pass를 0으로 시작한다.
7. **미수락 SRAM 응답은 기존 소속을 유지한다.** ReadPath는 read 발행 당시 group/context/last를 저장한다. Descriptor가 바뀌어도 보관 중인 A 응답의 metadata가 B로 바뀌지 않으며 consumer 수락 전에는 다음 응답으로 덮어쓰지 않는다.

### 코드 검토 판단과 제한

현재 지원하는 같은 context 내 다음 row 전환에서는 cache 소속과 소비 상태를 구분하는 보호 조건이 갖춰져 있다. 코드 검토상 A/B 상태가 섞이는 명백한 경로는 발견하지 못했다.

B descriptor 교체가 허용돼도 실제 refill에는 freeBytes 4096B 이상과 빈 chunk entry가 필요하다. 동시에 반환한 공간과 entry는 다음 clock부터 새 요청 승인에 반영된다. B 데이터가 준비되면 이어 읽고, 미준비 상태라면 도착할 때까지 기다린다. 모든 공급 지연에서 무정지 출력을 보장한다는 판단은 아니다.

UB는 실행 중 config를 바꿔 STREAM↔CACHE mode를 전환하거나 다음 context를 선행 적재하지 않는다. 여기서 검토한 대상은 LOCAL_ROW_CACHE의 같은 context 내 A row→B row 전환이다. 새 context는 기존 DMA/read/output을 drain한 안전한 수락 경계에서 초기화한다.

관련 코드: [UB 다음 row 허용](../../src/main/scala/inputbuffer/InputBufferDataPath.scala#L129), [UB 소비 row/pass 갱신](../../src/main/scala/inputbuffer/InputBufferDataPath.scala#L296), [Core 교체 조건](../../src/main/scala/commonbuffer/CircularBufferCore.scala#L181), [Core 수신 소속](../../src/main/scala/commonbuffer/CircularBufferCore.scala#L217), [Core 읽기 소속](../../src/main/scala/commonbuffer/CircularBufferCore.scala#L250), [Core 동시 교체 보호](../../src/main/scala/commonbuffer/CircularBufferCore.scala#L403), [ReadPath metadata 보관](../../src/main/scala/commonbuffer/CircularBufferReadPath.scala#L191).
