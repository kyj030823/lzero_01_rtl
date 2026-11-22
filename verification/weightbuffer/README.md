# WB v3 검증

테스트 소스, 실행기, 원본 결과를 아래 두 폴더로 모았다. 제품 RTL 6개는 commonbuffer와 weightbuffer 하위 폴더로 구분하고, 다른 구현을 검증하는 기존 WbController*_Test 등은 이동하지 않았다.

~~~text
src/main/scala/
  commonbuffer/                     UB/WB 공통 저장소·쓰기·읽기·core
    CircularBufferStorage.scala
    CircularBufferWritePath.scala
    CircularBufferReadPath.scala
    CircularBufferCore.scala
  weightbuffer/                     WB 전용 정책·연결
    WeightBufferController.scala
    WeightBufferDataPath.scala
src/test/scala/weightbuffer/
  CircularBufferBoundarySpec.scala   저장소·예약·동시 갱신·응답 metadata
  WeightBufferAcceptanceSpec.scala   추가한 WB 전체 경로 시험
  WeightBufferTestSupport.scala      테스트 전용 관측·정답 모델·JSON 기록
  WeightBufferContextSpec.scala      설정과 context 수명
  WeightBufferLutSpec.scala          LUT 정상·거부·취소
  WeightBufferPrefillSpec.scala      다음 context 선행 적재
  WeightBufferStatusSpec.scala       준비·경고·완료 상태
  WeightBufferStreamOrderSpec.scala  m→n→k 논리 순서
verification/weightbuffer/
  run.py / report.py / report-template.html
  source_paths.py                   현재 소스 위치 및 이전 경로 대응
  results/
    index.html / report.json         전체 결과와 추가 시험 시각화
    latest.json                     분류별 최근 실행 위치
    runs/<실행 ID>/
      run.json / compile.log / tests.log
      junit/ / traces/              원본 결과
      work/                         분리 컴파일·SRAM 시뮬레이터 생성물
    layout-migration.json           기존 파일 이동 기록
    production-before.json          정리 시작 전 제품 RTL hash
  stream-order/                     기존 STREAM 상세 보고서와 전용 실행기
  docs/CircularBufferImplementation.md  이전 구현 단계 기록
~~~

새 실행의 생성물은 해당 runs/<실행 ID> 안에만 생성한다. work/와 Python cache는 Git에서 제외한다. 기존 로그·trace는 삭제하지 않는다.

## 결과 열기

results/index.html을 브라우저에서 직접 연다. 서버나 외부 라이브러리가 필요 없다. 명세 항목별 검증 범위, 전체 ScalaTest, 원본 로그·JSON 링크, 추가 시험 cycle 타임라인을 포함한다.

Windows 탐색기에 다음 경로를 넣고 index.html을 열어도 된다.

~~~text
\\wsl.localhost\Ubuntu-22.04\home\kyj03\lzero_01_rtl\verification\weightbuffer\results
~~~

## 실행

프로젝트 루트에서:

~~~sh
python3 verification/weightbuffer/run.py
~~~

Windows PowerShell에서는:

~~~powershell
wsl -d Ubuntu-22.04 --exec python3 /home/kyj03/lzero_01_rtl/verification/weightbuffer/run.py
~~~

전체 실행은 단위 시험 4개 + WB 추가 시험 7개 + 기존 짧은 회귀 51개 = 62개다. 세 분류는 따로 실행할 수도 있다.

~~~sh
python3 verification/weightbuffer/run.py --only boundaries
python3 verification/weightbuffer/run.py --only acceptance
python3 verification/weightbuffer/run.py --only regression
python3 verification/weightbuffer/run.py --render-only
~~~

--render-only는 RTL을 다시 실행하지 않는다. --test-only는 원본 결과까지만 생성한다. --reuse-build <이전 run 경로>는 제품·시험 소스 SHA-256이 모두 동일할 때만 컴파일 결과를 재사용한다. --filter <문자열>은 문제 분석용 일부 선택이며 전체 회귀 결과를 대신하지 않는다.

Java와 로컬 Coursier 캐시의 Scala 2.13.12, Chisel 6.7.0, ChiselTest 6.0.0, compiler plugin을 사용한다. 다운로드하지 않는다. 캐시 위치가 다르면 WB_COURSIER_CACHE로 지정한다. 제품 소스 6개와 이 폴더의 시험만 분리 컴파일하며, 실행 전후 hash 및 보고서 생성 시 현재 소스를 대조한다.

## 추가한 시험

| ID | 명세 항목 | 실제로 만드는 조건 |
| --- | --- | --- |
| storage-mask-matrix | 10 | 시작 bank 4 × mask 4 × 주소 위치 3 = 48조합, 이웃 384회 비교, 동시 read/write 16조합 |
| writer-admission | 10 | full에서 예약 응답 수락, 4080/4096B 경계, entry 4개, 미확정 4KiB 예약의 남는 credit 반환 |
| writer-simultaneous | 10 | credit+ingress+reclaim, allocate+release, ingress+release |
| reader-metadata-hold | 14 | 입력 metadata를 바꾸어도 발행 당시 context/tag/group/last 보존, 수락과 seek 동시 처리 |
| lut-commit-transition | 5·6 | 64B만 받은 LUT에서 4beat 출력 후 정지, 수신 완료 다음 clock 요청, 같은 clock LUT 출력/weight 입력 |
| lut-tail-wrap | 7·11 | 80/96/112/128B tail, 실제 traffic으로 16KiB·32KiB 경계 통과, 포인터·kind·준비 상태 분리 |
| lut-entry-budget | 6·10 | LUT entry 1개 + weight 3개로 다음 예약 차단, LUT 반환 후 재개 |
| full-cache-final | 2·13 | 16KiB unique 1회 공급, 3,072beat 출력, 중간 reclaim 없음, 마지막 출력 5clock hold |
| special-contexts | 11·12 | disabled/constant/zero × LUT 유무 6조합 후 정상 context |
| reader-context-drain | 14 | read 발행 직후 readEnable 해제, 응답 5clock 보관, 다른 context 전환 |
| programming-timings | 8·9 | W-S-P / S-W-P / S-P-W / S-W=P / S=W-P 및 UB 준비 대기 |

R은 LUT 마지막 입력 수락, S는 마지막 출력 수락, P는 programming 완료 모형, W는 첫 weight chunk 완료다. R→S→P 인과관계를 유지하면서 W의 상대 순서를 바꾼다.

JSON에는 수락 전 clock의 실제 신호와 비교한 값이 기록된다. WB 추가 시험은 SRAM read 발행 주소도 관측한다. Python은 별도 fingerprint·공간 회계·완료 순서로 trace를 재검사한다. 단위 시험의 상세 데이터 비교는 Scala assertion과 JUnit을 근거로 한다.

## 범위와 제외 항목

- 4번 fused logical order/source split은 요청에 따라 실행하지 않았다. 3번의 fusion 합산 용량 설정 검증은 기존 회귀에 포함한다.
- 이전에 제외한 LUT 조합 6개는 WbExtendedLut 태그로 구분하고 기본 실행에서 제외한다. 긴 LUT 시험을 다시 실행하지 않았다.
- 8·9번은 실제 WB에 외부 동작 모형을 붙인 계약 시험이다. 실제 CCU·programming unit 및 실제 lutProgrammingDone 연결은 미검증이다.
- 1번은 AG 모형이 제공한 논리 stream의 보존을 검증한다. 실제 AG의 DRAM/IB 주소 생성은 별도다.
- 6번의 수신 종료는 WB memoryChunkLast 수락 기준이다. Physical AXI RLAST를 논리 종료로 바꾸는 adapter는 별도다.
- VPU 데이터는 현재 구현의 computeData 포트를 사용한다. 별도 VPU 직접 출력 연결은 이번 범위가 아니다.

docs/CircularBufferImplementation.md는 이전 단계의 설계·실험 기록이다. 현재 구조 및 이번 시험 결과는 이 README와 results/index.html을 기준으로 본다.


## 이번 실행 결과

2026-11-20 실행에서 단위 시험 4개, 추가 WB 시험 7개, 기존 짧은 회귀 51개가 모두 통과했다. 제품 RTL은 정리 시작 전과 동일하다. 추가 관측 JSON 11개와 이번 STREAM JSON 4개도 Python 독립 검사를 통과했다.

결과 HTML은 데스크톱과 좁은 화면에서 실제 Chrome으로 점검했다. Windows headless의 500px viewport에서 문서 폭을 414px로 강제한 검사를 좁은 화면 결과로 기록한다. 원본 점검과 화면은 results/qa에 있고, 이전 STREAM UI 점검은 stream-order/results/history에 있다.

보고서만 다시 점검하려면 다음 명령을 실행한다. RTL을 재실행하지 않는다.

~~~sh
python3 verification/weightbuffer/tools/check_report.py
~~~

이 도구는 잘못된 출력, 조기 완료, 미기록 SRAM read, 공간 회계 오류, holding 중 compute 수락, 늦어진 요청 가능 시점을 주입해 검사기가 거부하는지 확인한다. 브라우저 점검은 사용 가능한 로컬 Windows Chrome을 사용하며 별도 설치나 게시를 하지 않는다.

## 제품 소스 폴더 분리

2026-11-22에 공통 4개를 src/main/scala/commonbuffer, WB 전용 2개를 src/main/scala/weightbuffer로 이동했다. 파일 내용과 package npu.core.memory는 유지한다. sbt 하위 소스 검색과 전용 실행기 모두 새 위치를 사용한다.

이전 run.json의 경로와 hash는 원본 그대로 보존한다. source_paths.py가 명시적인 6개 이전 경로만 새 위치로 대응시켜 실제 내용 hash를 검사한다. 파일명만으로 임의 검색하지 않으며, 내용이 달라지면 이전 결과를 현재 검증으로 인정하지 않는다. 이동 및 컴파일 확인 기록은 results/layout-checks에 둔다.

## UB group handoff 추가 이후의 검증 범위

2026-11-22에 UB의 같은 context 내 row overlap을 위해 공용 Core/WritePath가 확장됐다. WB는 enableGroupPrefill=false를 유지하고 WB 전용 RTL은 바뀌지 않았다. 이번 revision에서는 [UB 최소 검증](../inputbuffer/README.md)의 WB smoke 2개를 확인했다. 이 문서의 기존 62개 결과는 확장 전 소스 hash에 대한 기록이며 전체 회귀를 다시 실행한 결과가 아니다. 기존 원본 run.json은 그대로 보존한다.

## 명세서 11장 항목별 검증 설명

정리 기준일은 2026-11-22다. 아래 표는 저장된 실행 기록을 설명하며, 이 문서를 추가하면서 테스트나 컴파일을 실행하지 않았다.

WB 종합 검증은 2026-11-20에 62개가 모두 통과했다. 이후 UB의 group handoff를 위해 공용 Core/WritePath가 바뀌었으므로 이 62개를 현재 revision 전체 통과로 표시하지 않는다. 변경 후에는 WB 핵심 시험 2개와 공용 경계 시험 4개가 통과했다. WB 전용 RTL 두 파일의 내용은 유지됐다.

| 번호 | 명세서 요구사항 | 실제 확인한 내용과 결과 |
| --- | --- | --- |
| 1 | Normal STREAM의 m→n→k 및 weightReplayCount=inputRowCount | 통과. M=3, N=2, K=4에서 데이터와 순서를 비교했다. DMA/compute 정지 및 4KiB+512B 경계에서도 순서가 유지됐다. M과 replay count가 다른 설정은 거부했다. |
| 2 | Full-cache unique fill 후 hungry 억제와 M-group replay | 통과. 16KiB를 한 번 공급하고 3pass, 16B 출력 3,072개를 확인했다. Unique fill 이후 hungry/추가 refill을 억제하고 중간 pass에서 공간을 보존했다. |
| 3 | W1+W2 합계로 cache mode 검증 | 통과. W1=12KiB, W2=12KiB이면 합계 24KiB이므로 cache 설정을 거부했다. 합산 carry가 잘려 작은 용량으로 오판하지 않는지도 확인했다. |
| 4 | First-pass fused logical order 재생 및 source split과 phase 분리 | 미실행. 요청에 따라 제외했다. 3번의 합산 용량 설정 검사는 fusion 출력 순서 검증과 별개다. |
| 5 | LUT 조기 streaming 및 committed bytes 초과 read 금지 | 통과. 64B만 받은 상태에서 16B 4beat를 출력하고 추가 수신 전에는 멈췄다. SRAM read도 committed 범위를 넘지 않았다. |
| 6 | LUT 수신 종료 직후 weight 요청 가능 및 LUT output/weight ingress overlap | 통과. LUT 마지막 입력 수락 다음 clock에 요청 가능 상태가 됐고, LUT 출력과 weight 입력의 동시 수락을 확인했다. |
| 7 | LUT tail과 첫 weight의 kind·mask·순서 보존 | 통과. LUT 80/96/112/128B tail과 실제 traffic에 의한 물리/확장 ring wrap에서 데이터가 섞이지 않았다. |
| 8 | Receive/stream/programming/첫 weight 준비의 서로 다른 timing | 외부 모형 연결 시험 통과. W-S-P, S-W-P, S-P-W, S-W=P, S=W-P의 5가지 순서를 확인했다. 실제 programming unit은 미연결이다. |
| 9 | Central holding/compute pause 중 DMA·LUT programming 진행 | 외부 모형 연결 시험 통과. Compute 대기 중에도 DMA와 LUT 경로가 진행됐다. 실제 CCU/programming unit과의 통합 시험은 별도다. |
| 10 | Mask·wrap·bank steering·full·예약·4-entry·동시 update | 통과. Mask 4종×시작 bank 4종×주소 위치 3종의 48조합, 이웃 데이터 384회 비교, 동시 read/write 16조합을 확인했다. Free 4096/4080B, 예약 응답, 5번째 entry 차단 및 동시 갱신도 검사했다. |
| 11 | LUT last에서 ring reset 없음 및 LUT bytes를 weight 준비에 합산하지 않음 | 통과. LUT 이후 같은 ring pointer에서 이어 공급했고, LUT만 받은 상태를 첫 weight chunk 준비로 오판하지 않았다. |
| 12 | Disabled/constant/zero-length의 compute impending 억제 및 LUT-only 허용 | 통과. 세 조건×LUT 유무의 6조합에서 불필요한 weight 요청·compute 출력·impending을 억제하고 필요한 LUT-only 초기화를 진행했다. |
| 13 | Last supply와 last consumption 분리 및 premature operationDone 금지 | 통과. 수신 완료 후에도 cache replay를 마칠 때까지 완료하지 않았다. 최종 출력 5clock hold 뒤 실제 수락에서만 operationDone이 1회 발생했다. |
| 14 | SRAM 응답 hold·context drain·최종 소비 이후 impending 억제 | 통과. 응답을 5clock 유지해 data/metadata가 보존되는지 확인했다. 이전 read/output을 drain한 뒤 context를 전환하고 마지막 소비 후 불필요한 impending을 억제했다. |

1번은 AG 모형의 논리 공급 순서를 실제 WB가 보존하는지 확인한 범위다. 실제 AG의 DRAM/IB 주소 생성은 미검증이다. 6번의 수신 종료는 WB의 memoryChunkLast 수락 기준이며, physical AXI RLAST를 logical chunk 종료로 바꾸는 제품 adapter는 별도다. 긴 LUT 확장 조합 6개도 제외했다.

원본 결과는 [WB HTML 보고서](results/index.html), [WB 결과 JSON](results/report.json), 변경 후 WB 2개 결과는 [UB 최소 검증 요약](../inputbuffer/results/summary.json), 공용 4개 재실행은 [UB 추가 검증 요약](../inputbuffer/results/acceptance/summary.md)에서 확인한다.

### 응답을 5clock 보관했다는 의미

SRAM에서 읽어온 응답을 받는 쪽이 수락하지 않도록 ready=0으로 두고 5clock 유지했다는 뜻이다. SRAM 자체의 read latency는 1clock이다. 읽기 발행을 막는 readEnable과 이미 나온 출력을 수락하는 ready는 역할이 다르다.

| 구간 | valid | ready | 기대 동작 |
| --- | --- | --- | --- |
| 응답 보관 5clock | 1 | 0 | Data, last, context/tag/group metadata 유지. 소비와 완료 처리 보류 |
| 이후 수락 clock | 1 | 1 | 보관한 응답을 한 번 전달하고 소비 처리 |

소비 기준 readPtr는 응답을 보관하는 동안 전진하지 않는다. 최종 데이터도 실제 수락 전에는 operationDone을 발생시키지 않는다.

### LUT programming의 의미

Programming은 WB가 공급한 LUT 데이터를 CU 내부 LUT 테이블에 기록해 연산에 사용할 수 있도록 준비하는 과정이다.

외부 메모리 → WB → LUT programming unit → CU 내부 LUT

- LUT receive 완료: 외부 메모리에서 WB로 전부 받았다.
- LUT stream 완료: WB에서 programming unit으로 전부 전달했다.
- LUT programming 완료: 내부 테이블 기록과 준비를 마쳤다. 상위에서 lutProgrammingDone으로 알린다.

시험의 S는 LUT stream 완료, P는 programming 완료, W는 첫 weight chunk 완료다. Programming unit과 CCU는 외부 동작 모형으로 표현했으며 실제 장치가 연결됐다는 의미는 아니다.

## Cache 교체 경로 코드 검토

2026-11-22에 코드를 읽어 검토한 내용이다. 이 검토를 위해 새 테스트나 컴파일을 실행하거나 RTL을 수정하지 않았다.

WB는 현재 context A의 마지막 사용 중 다음 context B를 선행 적재한다. UB의 같은 context 내 row 전환과 공간을 재사용하는 원리는 같고, WB는 contextId로 소속을 구분한다. Core의 enableContextPrefill=true, enableGroupPrefill=false를 사용하며 cache descriptor는 한 벌이다.

1. 현재 공급이 끝나고 cache의 마지막 pass일 때 다음 context prefill을 허용한다. Core도 진행 중 refill이 없고 기존 cache가 교체 가능한지 확인한다.
2. 다음 CACHE이면 prefill 승인과 descriptor 교체를 같은 clock에 확정한다. 다음 context 설정을 저장한 뒤 공급 카운터를 B용으로 사용하고, A의 읽기 cursor와 chunk 정보는 유지한다.
3. Descriptor가 B 소유가 되면 남은 A chunk는 contextId가 달라 cache replay 대상에서 빠진다. A는 마지막 사용이므로 소비한 chunk부터 공간과 entry를 반환한다.
4. 실제 B refill은 여유 공간 4KiB 이상과 빈 entry가 있어야 승인된다. 미소비 A 영역에 덮어쓰도록 허용하지 않는다.
5. A의 마지막 출력과 descriptor 교체가 겹쳐도 Core의 이전 pass 상태 갱신은 cacheConfigurationFire로 차단한다. WB의 출력 pass 판정도 nextConfigValid일 때 A의 최종 pass를 유지한다.
6. B 활성화 시에는 이전 reader가 drain됐는지 확인한다. 선행 적재된 B가 CACHE이면 preserveCacheOnActivate로 B의 cache 상태와 SRAM 데이터를 보존한다.

코드 검토상 현재 지원하는 A→B cache 교체에서 상태가 섞일 명백한 경로는 발견하지 못했다. 다음 데이터가 준비되지 않았거나 공간/entry가 부족하면 대기한다. 이 검토는 전체 WB 회귀 62개를 현재 revision에서 재실행한 결과를 대신하지 않는다. 현재 prefill은 서로 다른 contextId와 유효한 다음 compute 설정을 요구하며, 유효한 LUT 초기화가 필요한 다음 context는 prefill 대상으로 받지 않는다.

관련 코드: [WB prefill 조건·설정](../../src/main/scala/weightbuffer/WeightBufferDataPath.scala#L184), [WB 출력 pass 판정](../../src/main/scala/weightbuffer/WeightBufferDataPath.scala#L323), [Core cache 교체](../../src/main/scala/commonbuffer/CircularBufferCore.scala#L181), [동시 교체 보호](../../src/main/scala/commonbuffer/CircularBufferCore.scala#L403).
