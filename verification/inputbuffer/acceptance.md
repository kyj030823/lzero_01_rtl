# UB 추가 acceptance 검증

최소 시험 이후 부족했던 버퍼 경계와 외부 interface 계약을 별도 실행기로 확인한다. 제품 RTL은 수정하지 않는다.

~~~sh
python3 verification/inputbuffer/run_acceptance.py
python3 verification/inputbuffer/acceptance_report.py
~~~

기본 실행은 UB 추가 6개 + 현재 공용 버퍼 단위 4개다. 기존 UB 최소 6개, WB smoke 2개, 긴 LUT는 반복하지 않는다. 소스 hash가 같을 때 기존 최소 결과 8개를 함께 참조한다.

| 추가 시험 | 만드는 조건 |
| --- | --- |
| extra-full-cache-races | 16KiB row × 2개 × 2pass. 중간 pass 마지막·row 마지막·연산 마지막 출력 hold. 예약/반환 및 write/read/reclaim 동시 수락을 강제로 발생 |
| extra-ub-mask-wrap | 실제 traffic으로 일반/16KiB wrap 주변/32KiB wrap 주변에 도달. mask 4종 × 시작 bank 4종 × 주소영역 3종 = 48개 |
| extra-entry-policy-block | 16,320B free여도 metadata 4개이면 5번째 선행 적재 차단. 소비 후 재개. 정책 제한을 EXPECTED_BACKPRESSURE로 기록 |
| extra-full-pending-tail | 4096B free에서 16B 예약 승인 → 4080B free/full. 미도착 예약 보존 후 기존 응답 정상 수락 |
| extra-source-split-contract | DRAM-only, IB-only, mixed backing의 source 분할. 중간 physical last와 logical last 구분, 실제 UB 출력 digest 일치 |
| extra-fusion-reference-contract | CACHE/STREAM × 3 source profile. N=3, 총 6pass를 W1→W2 per-column reference와 비교 |

공용 단위 시험은 현재 revision에서 mask/bank/정확한 wrap 위치 48조합, 4096/4080 admission·예약, 동시 delta, metadata response hold를 검사한다.

## 경계와 모형

UB mask 시험은 4112B compact row를 사용해 logical chunk 시작을 16B씩 이동시킨다. Pointer를 직접 주입하지 않는다. 48개는 mask×bank×주소영역의 조합이며, 모든 조합이 각각 ring 끝을 가로지른다는 뜻은 아니다. 실제 물리/확장 wrap crossing도 별도로 센다. 정확한 끝 word에서의 mask×bank 48조합은 공용 저장소 단위 시험으로 확인한다. 이 시험의 consumer는 memory 경로를 확인하기 위한 always-ready sink이며, 실제 compact CU cadence는 기존 최소 시험에서 별도로 검증한다.

Source resolver, DRAM/IB engine, physical-last normalizer와 fusion phase reference는 시험용 모형이다. 실제 제품의 AG/IB controller와 response adapter를 구현하거나 연결한 결과로 표시하지 않는다. 현재 저장소의 IbController.scala는 비어 있고 기존 Arbiter는 segment 처리가 추후 항목이다.

Fusion reference는 각 column마다 W1 한 pass 후 W2 한 pass를 소비하는 명시적인 예시다. Actual production block/phase/qparam/IB epoch wiring은 미확정 또는 미연결 상태다.

## 결과 위치

~~~text
results/acceptance/
  latest.json
  summary.json / summary.md
  runs/<실행 ID>/
    run.json / compile.log / ub.log / shared.log
    junit/ub / junit/shared
    traces/ub / traces/shared
    work/                       Git에서 제외한 compiler/simulator 생성물
~~~

summary.md는 명세 13개 항목마다 버퍼 확인, 공용 확인, 모형 계약 확인 및 실제 통합 미확인을 구분한다. 실제 통합까지 끝나지 않았으면 allProductionIntegrationComplete=false로 기록한다.

--only ub 또는 --only shared로 나눌 수 있다. --filter <시험 이름 일부>는 문제 분석용이며 전체 통과 보고로 대체하지 않는다. --reuse-build <기존 run>은 RTL과 시험 소스 hash가 모두 같은 경우에만 재사용한다.
