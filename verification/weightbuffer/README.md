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
