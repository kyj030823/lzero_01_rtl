# UB acceptance 추가 시험 결과

실행한 시험: **PASS**. 추가 10개와 같은 RTL의 기존 최소 8개를 구분해 기록한다.
실제 AG/IB/production fusion 통합 완료를 뜻하지 않는다.

| 항목 | 상태 | 범위 |
| --- | --- | --- |
| 1 | BUFFER_PASS | 기존 Dense STREAM 1/2pass 및 이번 fusion STREAM 6pass |
| 2 | BUFFER_PASS | 기존 6KiB 4KiB+2KiB/2pass 보존 및 조기 출력 |
| 3 | BUFFER_PASS | 16KiB 4-entry, 2row×2pass, 마지막 pass next-row overlap |
| 4 | BUFFER_PASS | 기존 N=1 일반/fusion 및 이번 N=3 fusion 총 6pass |
| 5 | BUFFER_PASS_WITH_CU_MODEL | 기존 compact 실제 ready 수락·CU pause·DMA; 실 CU는 미연결 |
| 6 | SHARED_AND_BUFFER_PASS | 공용 정확 경계 48조합 + UB mask/bank/주소영역 48조합과 실제 wrap |
| 7 | BUFFER_PASS | accepted logical last 직후 실제 entry.endPtr 및 출력 byte 검사 |
| 8 | SHARED_AND_BUFFER_PASS | UB write/read/reclaim·grant/reclaim 강제 동시 수락, 4096/4080, 공용 delta 시험 |
| 9 | BUFFER_PASS_WITH_POLICY_LIMIT | 4-entry에서 여유 공간이 있어도 5번째 차단; 제한을 정상 선행 적재로 오판하지 않음 |
| 10 | BUFFER_PASS | in-flight 응답 보관 3지점, 중간 pass rewind, row 교체, data/last 안정 |
| 11 | CONTRACT_MODEL_PASS | physical last를 논리 완료와 구분한 adapter 모형 + 실제 UB; 제품 adapter 미연결 |
| 12 | BUFFER_PASS | 기존 disabled/zero/done 경고 억제와 stale context 차단 |
| 13 | CONTRACT_MODEL_PASS | W1→W2 per-column reference × CACHE/STREAM × DRAM/IB/mixed; 제품 phase·epoch 미연결 |

## 원본 결과

- 추가 실행: /home/kyj03/lzero_01_rtl/verification/inputbuffer/results/acceptance/runs/20261122T075936277832Z
- 기존 최소 실행: /home/kyj03/lzero_01_rtl/verification/inputbuffer/results/runs/20261122T060251535344Z
- run.json / JUnit / ub.log / shared.log / traces/ub / traces/shared
- 전체 관측값과 검사 결과: [summary.json](summary.json)

## 해석 시 주의

UB 48조합의 주소영역은 일반/16KiB wrap 주변/32KiB wrap 주변이다. 모든 mask×bank를 정확한 끝 word에 놓는 조합은 공용 저장소 48조합에서 별도로 확인한다. UB 시험의 wrap은 pointer 주입 없이 실제 traffic으로 발생시킨다.

5번째 metadata 선행 적재는 지원하지 않는 정책 제한이며 EXPECTED_BACKPRESSURE로 기록한다. Consumer를 재개하면 기존 FIFO 순서로 진행하는 것을 검사한다.

Source/phase 시험은 실제 UB와 SRAM에 시험용 resolver/engine/normalizer/reference를 붙인다. 제품 AG/IB controller와 split-response adapter, 실제 W1/W2/qparam/epoch wiring은 없어 통합 확인이 남아 있다.
