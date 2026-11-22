# WB STREAM 순서 검증

실제 WeightBufferDataPath와 공통 SRAM을 사용한다. AG 모형이 제공한 m→n→k 논리 순서의 보존, M-group별 재공급, chunk 경계, 정지 시 출력 보관 및 완료 시점을 검사한다. AG의 DRAM/IB 주소 생성은 별도 검증 대상이다.

## 실행

프로젝트 루트에서 다음 명령을 실행한다.

~~~sh
python3 verification/weightbuffer/stream-order/run.py
~~~

Scala 2.13.12, Chisel 6.7.0, ChiselTest 6.0.0 및 compiler plugin을 로컬 Coursier 캐시에서 찾는다. Java가 필요하다. 캐시 경로가 다르면 WB_COURSIER_CACHE 환경변수로 지정한다. 프로젝트의 기존 전체 테스트를 컴파일하지 않고 WB 생산 소스 6개와 이번 Spec만 분리 컴파일한다. 생산 RTL의 실행 전후 SHA-256을 비교한다.

Windows에서 WSL로 실행할 수도 있다.

~~~powershell
wsl -d Ubuntu-22.04 --exec python3 /home/kyj03/lzero_01_rtl/verification/weightbuffer/stream-order/run.py
~~~

테스트를 다시 돌리지 않고 최근 관측값으로 HTML만 재생성하려면:

~~~sh
python3 verification/weightbuffer/stream-order/run.py --render-only
~~~

--test-only는 테스트와 원본 JSON만 생성한다. ScalaTest를 다른 방식으로 실행할 때는 JVM property wb.streamOrderTraceDir로 trace 경로를 지정할 수 있다. 기본값은 target/wb-stream-order/traces다.

## 테스트 사례

| ID | M/N/K | 공급 | 비교할 출력 | 주요 확인 |
| --- | --- | --- | ---: | --- |
| baseline | 3/2/4 | 2KiB × 3회 | 384 beat | 준비된 출력이 M 경계에서도 연속 전달 |
| stalls | 3/2/4 | 2KiB × 3회 | 384 beat | 고정 seed 입력 지연, read pause, 출력 backpressure |
| chunk-boundary | 2/3/6 | (4KiB + 512B) × 2회 | 576 beat | n/k 논리 순서가 refill 경계를 넘어 유지 |
| count-mismatch | 3/2/4 | 공급 없음 | 설정 비교 | replay=2 거부, replay=3 허용 |

전체 weight 한 tile은 256B, 출력 beat는 16B다. 데이터에는 context/n/k/tile 내부 beat를 구분하는 패턴을 넣고, m은 passIndex와 대조한다. 기대 출력은 독립적인 m/n/k/beat 반복문으로 만들며 DUT의 index를 기대값 생성에 사용하지 않는다. 입력은 AG 모형의 source offset에서 별도로 계산한다.

각 cycle에서 요청·입력·출력의 valid/ready/fire, 실제/기대 데이터, index, 공간, 완료 pulse를 기록한다. Python 보고서 생성기는 관측 trace를 별도의 기대 순서와 다시 대조한다. 잘못된 실제 데이터와 조기 operationDone을 넣은 trace가 거부되는지도 확인했다.

현재 RTL의 STREAM 제어에서 weightReplayCount를 총 M-group 수로 사용하는 동작을 검사한다. 이번 작업에서 생산 인터페이스나 제어 정책은 변경하지 않았다.

## 결과 보기

results/index.html을 브라우저에서 연다. CSS/JavaScript와 관측 데이터를 모두 포함하므로 서버나 CDN이 필요 없다.

- 사례 선택과 cycle 재생, 화살표/슬라이더/타임라인 클릭으로 관측 위치 이동
- M-group별 tile 선택과 출력 16 beat 필터
- 입력 수락, 출력 수락, 출력 정지, passDone, operationDone 타임라인
- 기대 128bit와 실제 128bit 비교 및 원본 JSON 다운로드
- 예약을 포함한 실제 점유 공간 그래프

Cycle 0은 context 수락 다음 cycle이고, 각 기록은 clock edge 직전의 신호다. 재생 속도는 보고서 탐색용이며 RTL의 실제 클럭 주파수를 의미하지 않는다.

results/report.json은 독립 검사 결과를 포함한다. results/runs/ 아래에는 원본 case JSON, JUnit 결과, 컴파일/실행 로그와 생산 소스 hash가 남는다. browser-qa*.json과 preview-*.png는 이번 HTML의 데스크톱/좁은 화면 동작 확인 기록이다.

## 최초 실행 결과

네 테스트 모두 통과했다. 1,344개 출력 beat와 21KiB 입력을 비교했고, 생산 소스 6개는 변경되지 않았다.

| 사례 | 관측 cycle | 출력 구간 cycle | 출력 정지 cycle | passDone | operationDone |
| --- | ---: | ---: | ---: | --- | --- |
| baseline | 485 | 384 | 0 | 227, 355, 483 | 483 |
| stalls | 535 | 490 | 85 | 204, 367, 533 | 533 |
| chunk-boundary | 823 | 741 | 132 | 449, 821 | 821 |

출력 구간은 첫 출력 수락부터 마지막 출력 수락까지다. 정지가 있는 사례에서는 그 구간에 입력/읽기 대기로 valid가 없는 cycle도 포함된다. 출력 정지 cycle은 valid=1, ready=0인 cycle만 센다. 긴 LUT와 기존 전체 회귀는 이번 실행에 포함하지 않았다.
