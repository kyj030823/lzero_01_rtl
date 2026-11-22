> 이전 구현 단계의 기록입니다. 현재 구조와 이번 검증 결과는 [WB 검증 안내](../README.md) 및 [전체 결과](../results/index.html)를 참고하세요.

# UB/WB 공통 Circular Buffer 구현 노트

> 기준: UB/WB Controller 명세서 v3와 현재 Scala 소스  
> 정리 시점: 2026-11-15  
> 구현 범위: 공통 저장소, 쓰기·읽기 경로, STREAM 연결, 단일 cache group 재사용

이 문서는 현재 구현의 구조와 동작을 설명한다. UB의 row 제어와 WB의 weight/LUT 제어를 모두 완성했다는 의미는 아니다.

## 1. 현재 어디까지 구현했는가

| 파일 | 역할 | 현재 상태 |
| --- | --- | --- |
| [CircularBufferStorage.scala](../../../src/main/scala/commonbuffer/CircularBufferStorage.scala) | 16KiB SRAM, 입력 lane 배치, 16B 읽기 | 구현·개별 검증 |
| [CircularBufferWritePath.scala](../../../src/main/scala/commonbuffer/CircularBufferWritePath.scala) | 공간 예약, 입력 commit, chunk metadata 원형 큐 | 구현·개별 검증 |
| [CircularBufferReadPath.scala](../../../src/main/scala/commonbuffer/CircularBufferReadPath.scala) | SRAM read 발행, 응답 보관, consumer handshake | 구현·저장소 연결 검증 |
| [CircularBufferCore.scala](../../../src/main/scala/commonbuffer/CircularBufferCore.scala) | 세 모듈 연결, STREAM 소비·반환, 단일 group replay | 구현·통합 검증 |
| [WeightBufferController.scala](../../../src/main/scala/weightbuffer/WeightBufferController.scala) | WB 설정 저장·검사, context 수락·완료·초기화 | 구현·context 단위 검증, 데이터 경로 미연결 |

공통 모듈은 UB와 WB에서 각각 인스턴스화하는 구조다. UB와 WB가 하나의 물리 SRAM이나 포인터를 함께 사용하는 것은 아니다. 각 인스턴스는 독립적인 저장소와 상태를 가진다.

### 공통 core가 담당하는 것

- 유효 payload를 빈틈없이 기록한다.
- 승인한 refill이 사용할 공간과 metadata entry를 예약한다.
- 기록된 범위를 읽고, consumer가 멈추면 출력을 보관한다.
- STREAM에서 최종 소비한 chunk를 반환한다.
- 단일 cache group의 중간 pass에서는 데이터를 보존하고, 마지막 pass에서 반환한다.

### 상위 제어부가 결정할 것

- 해당 group이 UB의 input row인지, WB의 weight working set인지
- group의 유효 byte 수와 총 사용 횟수
- AG/Arbiter에 요청할 source·주소·공급 순서
- UB/WB별 초기 준비, urgency, 전체 operation 완료
- UB의 다음 row overlap과 WB의 LUT 수신·출력 phase

## 2. 전체 구조

```text
상위 제어부 / AG·response adapter
       │
       ├─ reserveRefill: logical refill의 공간·entry 예약
       ├─ memoryData + mask + marker + context/tag
       └─ cacheGroup: 단일 재사용 group 설정
       │
┌──────▼──────────── CircularBufferCore ──────────────────────┐
│                                                           │
│  CircularBufferWritePath                                   │
│    ├─ 공간 예약 / writeCommitPtr                          │
│    └─ chunkEntries: head·tail 원형 큐                      │
│              │ write                                      │
│              ▼                                            │
│  CircularBufferStorage: 4 × 256 × 128bit                    │
│              │ 16B read / 1cycle 응답                       │
│              ▼                                            │
│  CircularBufferReadPath                                   │
│    ├─ readIssuePtr / readPtr                               │
│    └─ 응답 보관 / data·tag·marker 유지                      │
│              │                                            │
│              └─ output.valid && output.ready               │
│                         │                                 │
│  Core: 현재 chunk 선택, replay, 최종 사용 시 reclaim/release│
└─────────────────────────┬─────────────────────────────────┘
                          ▼
                  상위 consumer 연결부
```


## 3. 기본 계약과 용어

| 항목 | 현재 구현 |
| --- | --- |
| 저장소 용량 | 16384B = 16KiB |
| 일반 logical refill 최대 크기 | 4096B = 4KiB |
| 입력 beat | 64B = 512bit |
| 출력 beat | 16B = 128bit |
| bank 수 | 4 |
| bank 하나의 구조 | 256 × 128bit |
| chunk metadata entry | 최대 4개 |
| local byte pointer | 15bit: 물리 offset 14bit + wrap bit 1bit |
| SRAM read latency | 1cycle |
| 진행 중 logical refill | 인스턴스당 최대 1개 |
| read in-flight | 최대 1개 |

### 3.1 Chunk와 group

**Chunk**는 한 번의 logical refill로 공급받는 데이터 구간이다. 일반 refill의 크기는 최대 4KiB다.

**Group**은 한 번의 pass에서 순서대로 소비할 전체 데이터 범위다. 여러 chunk로 구성할 수 있다.

```text
6KiB group
  ├─ chunk 0: 4KiB
  └─ chunk 1: 2KiB
```

4KiB는 refill의 최대 크기이며, cache group 전체 크기는 아니다. 단일 cache group의 유효 payload는 현재 최대 16KiB다.

### 3.2 Outstanding

요청이 승인됐지만 마지막 응답을 아직 수락하지 않은 logical refill을 뜻한다.

```text
reserveRefill.fire
    → refillPending = true

memoryDataValid && memoryDataReady && memoryChunkLast
    → refillPending = false
```

이미 수신이 끝나 저장소에 남아 있는 chunk는 outstanding에 포함되지 않는다. 소비 중인 chunk와 대기 중인 chunk가 여러 개 있어도, 현재 수신 중인 logical refill은 하나만 허용한다.

### 3.3 Context, group, tag

| 신호 | 의미 |
| --- | --- |
| `contextId` | 어느 실행 context에 속하는 데이터인지 식별 |
| `groupIndex` | 그 context 안에서 어느 logical group에 속하는지 식별 |
| `userTag` | 상위가 정의한 부가 정보 |

Response adapter는 **요청 당시의 contextId**를 보관했다가 응답의 `memoryContextId`에 붙여야 한다. 현재 context와 다르면 쓰기 경로가 응답을 수락하지 않는다.

공통 모듈은 tag의 의미를 해석하지 않는다. 예약 당시 저장한 값과 `memoryUserTag`가 일치하는지만 확인한다. UB는 구분이 필요 없으면 0으로 고정할 수 있다. WB enum의 세 값을 전달하려면 `userTagWidth = 2`가 필요하다.

불일치 응답을 수락하지 않는 기능과 외부 adapter의 stale 응답 폐기·drain 처리는 별개다. 현재 core가 외부 DMA를 cancel하거나 stale 응답을 자동으로 버리지는 않는다.

## 4. Pointer와 register의 소유권

| 소유 모듈 | 주요 상태 | 역할 |
| --- | --- | --- |
| WritePath | `writeCommitPtr` | 실제 기록한 payload의 끝 |
| WritePath | `reclaimPtr` | 더 이상 사용할 필요가 없어 반환한 구간의 경계 |
| WritePath | `reservedRefillBytes` | 승인했으나 아직 기록되지 않은 공간 |
| WritePath | `refillPending`, `activeRefillEntryIndex` | 진행 중 refill과 할당된 entry |
| WritePath | `entryHead`, `entryTail`, `entryCount` | metadata 원형 큐 |
| ReadPath | `readIssuePtr` | 다음 SRAM read를 발행할 위치 |
| ReadPath | `readPtr` | consumer가 아직 수락하지 않은 다음 위치 |
| ReadPath | `readInFlight`, `outputValidReg`, `outputReg` | 응답과 미수락 출력 관리 |
| Core | `currentChunkEntryIndex` | 현재 소비·재생하는 entry |
| Core | cache 범위·pass 관련 상태 | group 보존, rewind, 최종 반환 |

### 4.1 왜 pointer가 15bit인가

16KiB의 물리 byte offset은 14bit지만, 한 바퀴 돌아 같은 물리 위치에 왔는지를 구분하기 위해 wrap bit를 추가한다.

```text
pointer = [wrap bit 1개][물리 byte offset 14개]

0     → 물리 위치 0, wrap=0
16384 → 물리 위치 0, wrap=1
```

Pointer 차이는 다음 modulus로 계산한다.

```text
distance(endPtr, startPtr) = (endPtr - startPtr) mod 32768
```

SRAM은 하위 14bit만 주소로 사용한다. 공간 계산은 wrap bit를 포함한 pointer로 수행한다.

Cache replay에서는 read pointer가 되돌아가므로, 읽은 거리로 빈 공간을 계산할 수 없다. 공간 계산에는 `writeCommitPtr`와 `reclaimPtr`를 사용한다.

### 4.2 내부 register와 출력 포트는 다르다

명세의 register 목록이 모두 외부 포트여야 한다는 뜻은 아니다. 실제 register는 해당 상태를 관리하는 모듈에 두고, 다른 모듈에 필요한 값만 IO로 전달한다.

```scala
val writeCommitPtr = RegInit(0.U(localPointerWidth.W))
io.writeCommitPtr := writeCommitPtr
```

위 출력은 내부 register의 값을 전달한다. 같은 상태를 저장하는 register를 추가하는 것이 아니다.

## 5. 저장소 구현

### 5.1 입력 lane 배치

64B 입력을 16B lane 네 개로 나눈다.

| 입력 lane | bit 범위 |
| --- | --- |
| 0 | `[127:0]` |
| 1 | `[255:128]` |
| 2 | `[383:256]` |
| 3 | `[511:384]` |

유효 mask는 `0001`, `0011`, `0111`, `1111`만 지원한다.

```text
acceptedPayloadBytes = popcount(memoryLaneValidMask) × 16
```

Invalid lane은 기록하지 않고 공간으로 세지 않는다. 다음 입력은 직전 유효 payload 바로 뒤에 이어 쓴다.

### 5.2 Bank 선택과 주소

```text
lanePosition = writeBytePtr / 16

입력 lane j:
    physicalLane    = (lanePosition + j) mod 1024
    bankIndex       = physicalLane mod 4
    bankWordAddress = physicalLane / 4
```

예를 들어 80B 위치부터 64B를 쓰면:

| 입력 lane | byte 위치 | bank | bank 내부 주소 |
| --- | ---: | ---: | ---: |
| 0 | 80 | 1 | 1 |
| 1 | 96 | 2 | 1 |
| 2 | 112 | 3 | 1 |
| 3 | 128 | 0 | 2 |

시작 주소가 64B 경계에 맞지 않아도 bank별 주소가 다를 수 있으므로 연속 배치를 유지할 수 있다.

각 bank는 먼저 주소와 데이터를 `Mux1H`로 선택한 뒤 write 한 번을 수행한다. 따라서 bank마다 write port를 하나씩 사용한다.

### 5.3 읽기

```text
readBankIndex   = (readBytePtr / 16) mod 4
readWordAddress = (readBytePtr / 64) mod 256
```

`readEnable`을 올리면 다음 cycle에 16B와 `readDataValid`가 유효해진다. 응답에 맞춰 bank 선택도 1cycle 지연한다.

같은 물리 16B 위치를 동시에 읽고 쓰는 접근은 assertion으로 검출한다. 실제 충돌 예방은 상위의 commit·공간 관리가 담당한다.

SRAM 내용 자체는 reset으로 지우지 않는다. 제어 상태를 초기화한 뒤 새로 기록된 유효 범위만 읽는다.

## 6. 쓰기 경로와 공간 예약

### 6.1 예약과 기록은 별개의 사건이다

```text
reservationFire = reserveRefill.valid && reserveRefill.ready
memoryWriteFire = memoryDataValid && memoryDataReady
```

예약이 수락되면 byte 공간과 metadata entry를 함께 확보한다. 데이터와 pointer, 끝 marker는 memory beat가 실제로 수락됐을 때 갱신한다.

예약 정보의 `payloadBytes = 0`은 **길이 미확정**을 뜻하며, 4096B를 예약한다. Zero-length context는 이 예약을 발행하지 않아야 한다.

입력 mask의 byte 수는 WritePath에서 한 번 계산해 `memoryPayloadBytes`로 Core에 전달한다. 이는 valid/ready로 gate하지 않은 현재 beat의 후보 값이며, Core의 group 길이 검사에 사용한다. 실제 수락 여부는 WritePath의 `storageWriteEnable`을 공유한다.

### 6.2 공간 계산

```text
residentBytes = distance(writeCommitPtr, reclaimPtr)
usedAndReservedBytes = residentBytes + reservedRefillBytes
freeBytes = 16384 - usedAndReservedBytes

full = freeBytes < 4096
```

예를 들어 4096B를 예약한 뒤 64B를 받으면:

| 시점 | resident | reserved | free |
| --- | ---: | ---: | ---: |
| 예약 전 | 0 | 0 | 16384 |
| 예약 수락 | 0 | 4096 | 12288 |
| 64B 수락 | 64 | 4032 | 12288 |

기록이 진행되면 예약 공간이 실제 점유 공간으로 바뀐다. Chunk가 예상보다 짧게 끝나면 미사용 예약을 반환한다.

**full은 새 요청 admission을 제한한다. 이미 예약한 응답을 full로 막지 않는다.**

또한 free가 정확히 4096B면 full=false다. Free가 4080B면 full=true이며, 짧은 tail 요청도 새로 승인하지 않는다.

### 6.3 Chunk metadata

각 entry는 다음 정보를 가진다.

```text
allocated, complete
startPtr, endPtr, payloadBytes
userTag, groupIndex
lastInGroup, lastInStream
```

`endPtr`는 end-exclusive이며 마지막 유효 payload 바로 다음 위치다. `allocated=true, complete=false`는 진행 중 refill에 예약된 entry다.

4개 entry는 4KiB 고정 데이터 슬롯이 아니다. 실제 데이터는 ring에 이어 쓰고, entry는 logical chunk의 경계만 관리한다.

### 6.4 Metadata 원형 큐

- `entryTail`: 다음 예약에 할당할 entry
- `entryHead`: 최종 사용 후 반환할 가장 오래된 entry
- `entryCount`: 현재 할당된 entry 수

```text
할당 순서: 0 → 1 → 2 → 3 → 0 → …
```

예를 들어 A/B/C를 entry 0/1/2에 넣고 A를 반환한 뒤 D를 받으면, D는 tail인 entry 3에 들어간다. 빈 번호를 PriorityEncoder로 다시 찾지 않는다.

읽기 cursor는 head와 별개다. Cache 중간 pass에서 읽기 cursor가 이동하거나 rewind해도 head는 반환 전까지 유지된다.

할당과 반환이 동시에 발생하면 entryCount를 유지한다. Metadata가 가득 찬 cycle의 반환으로 생긴 자리는 다음 cycle admission에 반영한다.

`full=false`라도 진행 중 refill이나 metadata 부족 때문에 `reserveRefill.ready=false`일 수 있다.

## 7. 공통 읽기 경로

### 7.1 Read 발행 조건

현재 core의 일반 소비 경로는 complete된 chunk를 읽는다. ReadPath는 다음 조건을 확인한다.

- 초기 `seek`가 적용됐는가?
- 읽기가 허용됐고 현재 chunk가 할당되어 있는가?
- 현재 chunk의 읽을 수 있는 범위에 16B가 있는가?
- Write commit 범위 안에 데이터가 있는가?
- 새 응답을 수용할 공간이 있는가?

ReadPath 자체는 `allowIncompleteChunk` 입력으로 수신 중인 chunk의 기록분을 읽는 기능도 제공한다. **현재 Core는 이 값을 false로 연결한다.** WB 전용 수신 중 streaming 연결은 후속 작업이다.

### 7.2 Issue와 consume 분리

```text
SRAM read 발행
    → readIssuePtr += 16

output.valid && output.ready
    → readPtr += 16
```

Read 발행이나 응답 도착만으로 consumer가 데이터를 사용했다고 판단하지 않는다.

### 7.3 응답 보관과 backpressure

SRAM 응답을 consumer가 바로 받을 수 있으면 직접 전달한다. 받지 못하면 data와 metadata를 register에 보관한다.

보관하는 정보는 다음과 같다.

- data와 userTag
- chunkEntryIndex와 groupIndex
- lastInChunk, lastInGroup, lastInStream

미수락 동안 이 정보는 유지된다. 다음 응답이 기존 출력을 덮어쓰지 않도록 read 발행을 제한한다.

데이터가 준비되어 있고 readEnable과 output.ready가 true이면 chunk와 cache pass의 경계를 포함해 연속 16B/cycle을 전달한다. 최초 SRAM 응답에는 1cycle의 pipeline 지연이 있지만, 준비된 다음 chunk나 replay를 시작하기 위한 별도 출력 공백은 넣지 않는다.

입력 데이터가 아직 준비되지 않았거나 readEnable/output.ready가 낮은 경우에는 해당 조건에 따라 대기한다.

### 7.4 readEnable과 ready

`readEnable=false`는 새 SRAM read 발행을 막는다. 이미 발행한 응답 capture와 기존 출력 수락은 계속 처리한다.

Consumer를 정지하려면 `output.ready=false`로 전달한다. 전체 memory controller를 멈추는 global stall 입력은 사용하지 않는다.

### 7.5 Seek

`seek.valid && seek.ready`에서 readIssuePtr와 readPtr를 새 위치로 설정한다.

Seek는 pipeline이 비어 있거나, 기존 output을 현재 cycle에 수락하여 이전 응답이 모두 정리되는 경우에 수락한다. 아직 도착하지 않은 응답이나 미수락 출력이 남아 있으면 수락하지 않는다.

readEnable이 true이고 새 범위의 데이터가 준비되어 있으면 seek 수락과 새 주소의 SRAM read를 같은 cycle에 수행한다. 이 경우 기존 output의 수락으로 readPtr를 증가시키는 대신, 새 pass의 시작 위치를 readPtr에 저장한다.

| Cycle | Consumer 출력 | SRAM read |
| --- | --- | --- |
| N | 이전 pass의 마지막 데이터 수락 | seek와 다음 pass의 첫 read 동시 발행 |
| N+1 | 다음 pass의 첫 데이터 | 이어지는 16B read 발행 |

현재 출력의 metadata는 register에 고정되어 있으므로, 다음 read의 metadata 선택과 섞이지 않는다.

## 8. STREAM 연결 동작

```text
refill 예약
  → 데이터 기록
  → chunk complete
  → 최초 시작 주소로 seek
  → 16B 단위 read와 output 전달
  → chunk 마지막 output 수락
  → 공간과 entry 반환
  → 다음 chunk
```

Core는 `currentChunkEntryIndex`로 읽을 metadata를 선택한다. 이 cursor는 writer의 FIFO 반환 순서를 따른다.

첫 complete chunk에서 seek와 첫 read를 함께 수행할 수 있다. 이후 payload는 연속 배치되어 있으므로 pointer를 이어 쓴다. 큐가 잠시 비어도 cursor를 유지해 다음 tail 할당과 연결한다.

현재 chunk의 마지막 출력을 수락하는 cycle에는 다음 entry의 metadata를 read 경로에 미리 선택한다. 다음 chunk가 준비되어 있으면 그 첫 read를 같은 cycle에 발행해 경계의 공백을 없앤다. 공간 반환에는 기존 currentChunk를 사용하고, 새 read용 metadata 선택과 구분한다.

Chunk 반환 조건은 다음과 같다.

```text
chunkConsumed = output.fire && output.bits.lastInChunk
```

STREAM에서는 이 사건에서 reclaim 경계를 chunk.endPtr로 옮기고 entry를 반환한다.

`memoryStreamLast`를 받았다는 사실만으로 소비가 완료되지 않는다. STREAM에서 다음 공급이 필요한지의 판단과 요청 생성은 상위 제어부가 담당한다.

## 9. 단일 cache group 재사용

### 9.1 설정

초기 상태는 STREAM이다. Core가 비어 있을 때 `cacheGroup.valid && cacheGroup.ready`로 단일 cache group을 설정한다.

```text
cacheGroup.bits.payloadBytes = 6144
cacheGroup.bits.replayCount  = 3
cacheGroup.bits.groupIndex   = 7
```

계약은 다음과 같다.

- Payload 길이는 16B 정렬, 16..16384B다.
- replayCount는 최초 사용을 포함한 총 횟수이며 1 이상이다.
- 해당 group의 refill은 동일한 groupIndex를 사용한다.
- 마지막 chunk의 예약 정보에 lastInGroup을 표시한다.
- 전체 unique payload가 끝나는 beat에는 memoryChunkLast도 필요하다.

Group의 의미는 상위가 정한다. UB에서는 input row, WB에서는 전체 weight working set에 대응시킬 수 있다. 현재 core는 그 의미를 해석하지 않는다.

### 9.2 Cache 범위

첫 실제 refill 예약에서 다음 정보를 저장한다.

```text
cacheStartPtr = 현재 writeCommitPtr
cacheEndPtr   = cacheStartPtr + 설정된 payloadBytes
cacheFirstChunkEntryIndex = 이번에 할당한 entry
```

Cache 시작을 0으로 가정하지 않는다. 앞에 다른 stream이 있었으면 그 뒤에서 시작한다.

| Register | 의미 |
| --- | --- |
| cacheStartPtr / cacheEndPtr | 고정된 replay 범위 |
| cacheRangeValid | 범위 설정 완료 |
| cacheFillComplete | 전체 unique payload 기록 완료 |
| cacheBytesCommitted | 실제 수신한 unique byte 수 |
| cacheFirstChunkEntryIndex | replay 시작 metadata |
| cachePassIndex | 현재 pass 번호, 최초 0 |
| cachePassBytesConsumed | 현재 pass에서 실제 수락된 byte 수 |

현재 단일 group 구조에서는 보존 중인 entry 수를 WritePath의 entryCount로 관리한다. Core에 같은 수를 세는 register를 따로 두지 않는다. 할당·반환이 겹치는 경우의 개수 갱신과 4-entry 제한도 WritePath가 담당한다.

`cachePassIndex`는 공통 구현에서 사용하는 이름이다. 상위에서는 명세의 UB `rowPassIndex`, WB `weightPassIndex` 의미에 맞춰 연결하게 된다.

`rewindAtPassEnd`는 별도 register가 아니라 마지막 출력 수락과 다음 pass 필요 여부를 나타내는 조합 조건이다. 이 조건으로 cache 첫 entry와 시작 주소를 같은 cycle의 새 read에 선택한다.

### 9.3 첫 pass와 unique fill

첫 chunk가 complete되면 첫 pass를 시작할 수 있다. 전체 group 적재를 기다리지 않는다.

첫 pass가 진행되는 동안 나머지 unique 데이터를 계속 수신한다. 실제 commit byte 수가 payloadBytes와 같아지면 cacheFillComplete를 설정하고 추가 refill을 차단한다.

### 9.4 중간 pass

Chunk를 소비해도 reclaim과 entry 반환을 보류한다. 읽기 cursor만 다음 chunk로 이동한다.

전체 group의 마지막 출력을 수락하면:

```text
cachePassIndex += 1
cachePassBytesConsumed = 0
currentChunkEntryIndex = cacheFirstChunkEntryIndex
```

마지막 출력을 수락하는 cycle에 seek로 read pointer를 cacheStartPtr로 되돌리면서 첫 read도 발행한다. 다음 cycle부터 새 pass의 출력이 이어진다. 데이터 복사나 재수신, 별도 rewind 대기 cycle은 필요 없다.

### 9.5 마지막 pass

```text
isFinalCachePass = cachePassIndex + 1 == cacheReplayCount
```

마지막 pass에서는 chunk의 마지막 출력이 수락될 때마다 해당 공간과 entry를 반환한다.

총 사용 횟수가 1이면 최초 pass가 곧 마지막 pass다. 이 경우 fill과 chunk 반환이 겹칠 수 있고, 반환한 entry를 이후 chunk에 재사용할 수 있다.

### 9.6 예: 6KiB를 총 3회 사용

```text
unique ingress: chunk 0 = 4KiB, chunk 1 = 2KiB
cache 범위: [0, 6144)                 ← 이 예제의 시작 주소는 0

pass 0: chunk 0 → chunk 1 → rewind   데이터·entry 보존
pass 1: chunk 0 → chunk 1 → rewind   데이터·entry 보존
pass 2: chunk 0 → chunk 1             chunk별 반환
```

| 시점 | read 동작 | reclaim 경계 |
| --- | --- | ---: |
| 첫 pass | 0 → 6144 | 0 유지 |
| 두 번째 pass | 0 → 6144 | 0 유지 |
| 마지막 pass의 chunk 0 소비 완료 | 4096 도달 | 4096 |
| 마지막 pass의 chunk 1 소비 완료 | 6144 도달 | 6144 |

### 9.7 완료 신호

| 신호 | 의미 |
| --- | --- |
| output.bits.lastInChunk | 이 payload가 해당 chunk의 마지막 |
| output.bits.lastInGroup | 이 payload가 이번 group pass의 마지막 |
| output.bits.lastInStream | 입력 공급 stream의 마지막 표시 |
| passIndex | 현재 사용 횟수의 index |
| passDone | group 한 pass의 마지막 출력이 수락된 cycle |
| groupDone | group의 모든 사용이 끝난 마지막 출력 수락 cycle |

Cache의 lastInStream은 저장된 공급 marker이므로 replay에서도 다시 전달된다. 이 marker만으로 전체 사용 완료를 판단하면 안 된다.

```text
passDone  = output.fire && lastInGroup
groupDone = passDone && 마지막 pass
```

STREAM에서는 각 group을 한 번 사용하므로 groupDone과 passDone이 함께 발생한다.

Consumer가 마지막 출력을 아직 수락하지 않았다면 pass counter, rewind, 최종 반환, 완료 pulse가 먼저 진행되지 않는다.

### 9.8 다음 group

현재 구현은 마지막 pass 중 다음 group을 미리 공급하지 않는다. Unique fill 완료 후에는 공간이 반환되어도 추가 refill을 막는다.

Group 완료 후 비어 있는 상태에서 새 cacheGroup 설정을 수락할 수 있다. Byte pointer와 metadata tail을 reset하지 않고 다음 group을 이어 배치한다.

Cache 설정 이후 STREAM으로 돌아가려면 현재 인터페이스에서는 안전한 경계의 softReset을 사용한다.

## 10. 중요한 구현 제한과 후속 작업

### 10.1 데이터 공간과 metadata 공간은 별도 제한이다

16KiB 이하라는 이유만으로 모든 chunk 배치가 실행 가능한 것은 아니다.

- 보존할 데이터가 저장소 용량에 들어가야 한다.
- 동시에 보존하는 metadata entry가 4개 이하여야 한다.
- Free가 4096B 미만이면 짧은 요청도 새로 승인하지 않는다.

여러 pass를 사용하는 group이 16B chunk 5개로 나뉘면, 첫 4개를 보존한 상태에서 다섯 번째 entry를 확보하지 못할 수 있다. 현재 prototype은 자동 병합이나 STREAM 전환으로 우회하지 않는다.

총 1회 사용은 소비한 entry를 바로 반환하므로, 동시에 4개를 넘겨 보존하지 않으면서 더 많은 chunk를 차례로 처리할 수 있다.

### 10.2 현재 core에 아직 없는 기능

- UB의 마지막 row pass와 다음 row fill overlap
- UB compact profile, row 전환과 rowReplayCount의 상위 설정
- WB bounded LUT transfer의 CCU credit과 receive/program/weight preload overlap
- WB W1/W2 working set 검증과 실제 fusion 공급 순서 연결
- WB context 관리부와 실제 데이터 경로 연결, UB context 설정 latch
- disabled / zero-length / constant operand의 상위 경로 처리
- initialReady, hungry, starving, impending의 상위 mode별 계산
- AG/Arbiter의 refill 요청 생성과 source/address/IB lifetime 연결
- 전체 computeDataLast와 operationDone의 UB/WB별 최종 판단

현재 WritePath는 최대 4KiB의 일반 refill을 다룬다. 이 제한을 WB의 전체 bounded LUT 길이 제한으로 해석하면 안 된다. WB 전용 credit과 수신 phase는 후속 설계 항목이다.

## 11. 검증한 내용

### 11.1 검증 방법

11.2~11.4의 기존 검증 결과는 중복 정리 이전의 실행 기록이다. 11.4의 추가 사례인 3KiB chunk 4개·총 3 pass 검증은 중복 정리 이후의 현재 코드에서 실행했다. 이때 이전 테스트 전체를 다시 실행하지는 않았다.

Scala 2.13.12, Chisel 6.7.0과 해당 compiler plugin을 사용해 관련 소스를 컴파일했다. ChiselTest에서 실제 SyncReadMem 저장소와 제어부를 연결해 데이터와 metadata를 비교했다.

검증은 로컬의 별도 임시 디렉터리에서 실행한 개별·통합 테스트벤치 기준이다. 전체 기존 프로젝트의 빌드, 플랫폼 통합, FPGA 합성이나 Fmax 검증까지 완료했다는 뜻은 아니다. 테스트벤치를 저장소의 지속적인 회귀 테스트로 정리하는 작업은 후속 항목이다.

### 11.2 개별·STREAM 검증

| 대상 | 확인한 내용 |
| --- | --- |
| Storage | prefix mask, bank 회전, tail packing, ring wrap, read valid, 동시 1R1W |
| WritePath | FIFO 할당·반환, full/예약, stale/tag 불일치, 동시 갱신, pointer wrap — 838개 상태 전이 |
| ReadPath + Storage | 범위 검사, 연속 전달, 응답 보관, tag·marker 유지, seek drain, wrap — 2090개 read beat |
| Core STREAM | 입력부터 출력까지 데이터·metadata 비교, 동시 수신·소비, pause, full, byte/entry wrap — 48개 chunk·3341개 output beat |

ReadPath의 수신 중 읽기 기능도 별도로 검증했지만, 현재 Core의 일반 경로는 complete chunk 읽기로 연결되어 있다.

### 11.3 단일 cache group 검증

| 시나리오 | 확인한 결과 |
| --- | --- |
| 6KiB = 4KiB + 2KiB, 총 3회 | 첫 chunk 소비와 나머지 fill overlap, 1152개 cache output beat |
| 16KiB, 총 2회 | 80B 선행 stream 이후의 비영점 시작 주소, metadata·물리 wrap, 2048개 cache output beat |
| 80B를 16B chunk 5개로 공급, 총 1회 | 마지막 사용의 entry 반환과 추가 fill이 이어짐 |
| 16B, 총 3회 | 각 pass 마지막 출력을 정지시켜 조기 완료·rewind가 없음을 확인 |
| Unique fill 완료 후 추가 요청 | 마지막 pass에서 공간이 생겨도 추가 공급을 차단 |
| 완료 후 명시적 재설정 | Reset 없이 다음 group의 범위·counter·entry가 올바르게 시작 |
| 여러 pass의 5개 짧은 chunk 배치 | 4-entry 제한으로 대기함을 확인. 정상 완료 사례로 취급하지 않음 |

Cache 기능 추가 후 기존 STREAM 통합 검증도 다시 통과했다.

### 11.4 Chunk/pass 경계의 연속 전달 검증

#### 횟수를 읽는 방법

이 절에서 **1 pass는 group 전체를 처음부터 끝까지 한 번 소비하는 것**이다. **총 pass 수는 최초 사용을 포함한 횟수**이며, cache 설정의 `replayCount`에 해당한다. 예를 들어 `replayCount = 3`이면 최초 사용 1회와 재사용 2회를 합쳐 총 3 pass다.

Chunk 개수와 pass 수는 서로 다르다. Chunk가 4개인 group을 총 3 pass로 설정하면 다음 순서로 출력한다.

| Pass | 출력 순서 | 의미 |
| --- | --- | --- |
| 0 | chunk 0 → chunk 1 → chunk 2 → chunk 3 | 최초 사용 |
| 1 | chunk 0 → chunk 1 → chunk 2 → chunk 3 | 첫 번째 재사용 |
| 2 | chunk 0 → chunk 1 → chunk 2 → chunk 3 | 두 번째 재사용, 최종 사용 |

따라서 chunk 4개를 각각 3번 출력해, chunk 단위 소비는 총 12번 발생한다. 메모리에서는 원본 group을 한 번만 받아 저장하고, 이후 pass에서는 저장된 데이터를 다시 읽는다.

출력 1 beat는 16B다. 따라서 `pass당 beat 수 = group 전체 byte 수 ÷ 16`이고, `전체 beat 수 = pass당 beat 수 × 총 pass 수`다.

#### 연속 출력 결과

아래 표는 `readEnable`과 consumer의 `ready`를 유지한 조건에서, 첫 유효 출력부터 마지막 출력 수락까지 매 cycle `output.valid`가 유지되는지 검사한 결과다. 초기 pipeline 채움 시간은 출력 구간 cycle 수에서 제외한다.

| 한 pass의 group 구성 | 총 pass 수<br>(최초 포함) | pass당 출력 beat 수 | 전체 출력 beat 수 | 출력 구간 cycle 수 |
| --- | ---: | ---: | ---: | ---: |
| 16B chunk 1개 = 16B | 8 | 1 | 8 | 8 |
| 16B chunk 4개 = 64B | 5 | 4 | 20 | 20 |
| 48B + 32B = 80B | 3 | 5 | 15 | 15 |
| 4KiB + 2KiB = 6KiB | 3 | 384 | 1152 | 1152 |
| 16KiB, 비영점 시작·wrap | 2 | 1024 | 2048 | 2048 |
| **3KiB chunk 4개 = 12KiB** | **3** | **768** | **2304** | **2304** |
| STREAM의 준비된 chunk 4개 = 176B | 1회 소비 | 11 | 11 | 11 |

STREAM 행은 cache 재사용 없이 각 chunk를 한 번씩 소비한 결과다. 모든 행에서 출력 beat 수와 출력 구간 cycle 수가 같으므로, 측정 구간에 chunk/pass 경계로 인한 빈 cycle이 없었다.

각 replay 경계의 backpressure에서도 valid/data/tag/marker를 유지하고, 수락한 다음 cycle에 새 pass의 첫 출력을 제공하는지 확인했다. Consumer가 `ready`를 낮춘 cycle에는 출력 수락이 발생하지 않으므로, 위의 매 cycle 수락 조건과 구분한다.

#### 추가 사례: 3KiB chunk 4개를 총 3 pass로 소비

3KiB는 3072B이므로 chunk 하나는 16B 출력 192 beat다. 한 pass에서는 chunk 4개를 모두 읽어 `192 × 4 = 768 beat`를 출력하고, 이를 3 pass 반복해 `768 × 3 = 2304 beat`를 출력한다.

| 확인 항목 | 실행 결과 |
| --- | --- |
| 메모리에서 받은 원본 데이터 | 12KiB를 한 번 공급: 64B 입력 192 beat |
| 각 pass의 chunk별 출력 | chunk 0·1·2·3 각각 192 beat, 합계 768 beat |
| 3 pass의 전체 출력 | 2304 beat = 36KiB |
| 첫 출력부터 최종 수락까지 | 2304 cycle, 빈 cycle 0개 |
| 데이터·metadata | 각 chunk의 데이터, tag, group/entry 정보와 종료 marker 일치 |
| 수신과 첫 pass의 겹침 | 원본 group 전체 수신 완료 전에 첫 출력 시작 |
| 완료 신호 | `passDone` 3회, `groupDone` 1회 |
| 최종 pass의 chunk별 반환 후 여유 공간 | 7KiB → 10KiB → 13KiB → 16KiB |

원본 12KiB를 저장한 상태의 여유 공간은 4KiB다. 앞선 pass에서는 재사용할 데이터를 유지하고, 최종 pass에서는 chunk 하나의 마지막 출력을 수락할 때마다 3KiB씩 반환하므로 위 순서로 여유 공간이 늘어난다.

이 추가 사례는 Core/Read/Write 중복 정리 이후의 현재 코드에서 실행했다. 나머지 행은 이전 연속 전달 검증의 실행 기록이다. 당시 seek와 경계 read 발행을 변경한 뒤 연속 전달 검증과 기존 cache/STREAM 통합 회귀를 확인했으며, 이번 추가 사례 실행 때 이전 테스트 전체를 다시 실행하지는 않았다.


## 12. 설계 결정 기록

1. **주소는 byte 단위로 관리한다.** 16B tail을 정확히 이어 붙이고 wrap을 구분하기 위해서다.
2. **공간 예약을 실제 기록과 분리한다.** 아직 도착하지 않은 응답도 사용할 공간이 필요하다.
3. **Metadata는 FIFO 원형 큐로 관리한다.** 순서대로 오는 logical refill의 소비 순서를 유지하기 위해서다.
4. **읽기 발행과 소비 수락을 분리한다.** SRAM 응답과 consumer 정지는 서로 다른 타이밍이기 때문이다.
5. **Reclaim을 read pointer와 분리한다.** Cache에서는 이미 읽은 데이터도 다음 pass에서 다시 사용한다.
6. **Cache 범위를 고정한다.** 뒤에 기록되는 데이터를 현재 pass에 포함하지 않기 위해서다.
7. **완료는 실제 출력 수락에서 판단한다.** 마지막 공급, 마지막 read 발행, 마지막 소비는 서로 다른 사건이다.

이 공통 기반 위에 WB 설정 저장과 context 관리부를 추가했다. 다음 구현 단계는 실제 데이터 경로와 WB별 group·공급·재사용 정책의 연결이다.

## 13. WB 설정과 context 관리부

[WeightBufferController.scala](../../../src/main/scala/weightbuffer/WeightBufferController.scala)에 WB 명세서 2절과 공통 context 계약을 구현했다. 이 절은 설정/context 관리부의 단독 구현·검증 기록이며, 이후 연결한 실제 LUT/weight 경로의 검증은 14절에 정리했다.

### 13.1 설정 수락과 검사

- 명세의 설정 17개를 `WeightBufferConfig`로 묶었다.
- `contextStart && contextReady`에서 전체 설정을 저장한다. 실행 중 live config가 바뀌어도 저장한 설정은 유지한다.
- `contextReady`는 이전 작업 종료, DMA/read/output drain, 새 입력 설정의 유효성을 모두 요구한다. 상위는 수락될 때까지 start/config를 유지한다.
- VPU의 STREAM 사용, 비-fusion GEMM의 set1=0, 유효 payload·threshold의 16B 정렬을 검사한다.
- 활성 GEMM은 replayCount=inputRowCount 및 양수 조건을 검사한다. Dense 단일 weight는 reductionTileCount × outputColumnCount × 256B와 크기를 비교한다.
- 활성 cache는 W1+W2를 carry까지 포함해 합산하여 16KiB 이하인지 검사한다. Fusion의 미확정 block 순서는 추측하지 않는다.
- 잘못된 설정은 수락하지 않고, 안전한 수락 경계의 start에서 assertion으로 원인을 알린다.

전체 payload 길이의 기본 폭은 32bit, shape/replay count는 16bit, contextId는 8bit이며 모두 parameter다. 이는 기존 ABI 확정이나 LUT transfer 길이의 새 상한이 아니다. Working set 합산은 payload 폭보다 1bit 넓게 유지한다.

### 13.2 완료와 초기화

`pathStatus`는 이후 데이터 경로에서 연결할 내부 상태 입력이다. `refillPending`, `readInFlight`, `outputPending`으로 drain을 확인하고, `computeDone`, `lutReceiveDone`, `lutStreamDone` pulse를 각각 기억한다. Refill pending에는 아직 도착할 응답도 포함해야 한다.

세 작업이 모두 끝나고 응답도 drain된 경우 `contextDone`을 한 번 내보내고 active 상태를 해제한다. 따라서 chunk 사이에 잠시 응답이 없다는 이유로 새 context를 받지 않는다. 이 `contextDone`은 명세의 `operationDone`이나 programming unit의 `lutProgrammingDone`과 별개다.

Disabled/constant-bypass/0B compute는 시작할 때 compute 완료 상태로 둔다. LUT load가 없거나 LUT 길이가 0이면 LUT 수신·출력도 완료 상태로 시작한다. 데이터가 전혀 없는 context는 drain 조건을 만족하면 수락 다음 cycle에 contextDone이 가능하며, 가상의 compute 출력이나 operationDone pulse는 만들지 않는다. Compute가 disabled여도 유효 LUT load는 유지한다.

`softReset`은 상위가 새 요청 중단과 cancel/drain을 보장한 뒤 사용한다. 미도착 응답이 있으면 reset을 수락하지 않고 assertion으로 알린다. 새 context 수락 또는 안전한 softReset에서 `dataPathClear` pulse를 내보내며, 다음 단계에서 공통 데이터 경로의 초기화에 연결한다. 이 관리부 자체가 DMA 취소를 수행하지는 않는다.

### 13.3 검증 결과와 다음 연결

[WeightBufferContextSpec.scala](../../test/scala/WeightBufferContextSpec.scala)에 회귀 테스트를 남겼다. Scala 2.13.12, Chisel 6.7.0 및 compiler plugin, ChiselTest 6.0.0으로 현재 WB 파일과 해당 suite를 별도 컴파일하고 ScalaTest Runner에서 실행했다. **22개 테스트 모두 통과**했으며 실패·중단은 없었다.

| 확인 대상 | 결과 |
| --- | --- |
| 설정 유효성 | 정상·오류·경계 설정 34개. 정확히 16KiB cache 허용, 초과 거부, STREAM/VPU의 16KiB 초과 길이 허용 |
| 산술 폭 | W1+W2 carry 보존, 32bit를 넘는 STREAM 합계, dense shape 곱셈의 잘림 방지 |
| 설정 저장 | 17개 필드 전체 보존, 실행 중 live config 변경과 대기 중 start가 기존 설정을 덮어쓰지 않음 |
| 완료 순서 | compute/LUT receive/LUT stream의 가능한 상대 순서 및 동시 완료 6가지 |
| Drain | DMA·SRAM·output pending의 7가지 비어 있지 않은 조합에서 완료·다음 context 수락을 보류 |
| 비활성 경로 | disabled, constant VPU, zero-length, LUT-only, 0B LUT의 초기 완료 상태 |
| Reset·재시작 | 안전한 softReset, 동시 start보다 reset 우선, system reset, 이전 완료 pulse의 새 context 유입 방지 |
| Parameter | 기본 폭 외에 payload 15/40bit, count 8/20bit, contextId 4/12bit로 동작 |
| 재현 가능한 timing 변화 | 고정 seed의 100개 context, 1274 cycle을 scoreboard와 비교 |
| 의도한 오류 거부 | 잘못된 start 8가지와 DMA/SRAM/output 미완료 softReset 3가지에서 assertion 발생 확인 |

오류 거부 테스트의 assertion 출력은 기대한 결과이며 suite 실패가 아니다. 테스트 실행 전후 기존 production Scala 파일의 hash가 동일함을 확인했으며, 기능 코드 수정은 없었다.

이 검증은 `pathStatus`에 완료·pending 상태를 주입한 context 관리부 단위 검증이다. 실제 SRAM/AG/CCU 데이터 경로의 연결, 전체 프로젝트 빌드, 합성·타이밍은 이번 검증 범위에 포함하지 않았다.

이후 실제 데이터 경로를 연결한 LUT 통합 검증 결과는 14절에 기록했다.

## 14. WB LUT 전송 경로 검증 요약

[WeightBufferLutSpec.scala](../../test/scala/WeightBufferLutSpec.scala)로 실제 SRAM을 포함한 WB 경로를 검증했다. **LUT 통합 13개와 기존 context 22개, 총 35개 테스트가 모두 통과**했다. CCU의 credit 공급과 programming unit의 출력 수락은 테스트벤치에서 모사했다.

| 항목 | 확인한 결과 |
| --- | --- |
| 수신 중 출력·동시 진행 | 전체 LUT 수신 전에 출력 시작. LUT 출력과 weight 수신이 겹치며 데이터 종류가 섞이지 않음 |
| 긴 LUT·wrap | 40KiB+48B LUT의 2,563 beat 전달, 16KiB SRAM 및 15bit pointer wrap, 반복 credit 정상 동작 |
| Tail·정지 | 16/32/48/80B tail, 독립적인 수신·출력 정지, 미수락 data/last 유지 |
| Cache 전환 | 80B LUT 뒤에 12KiB weight를 적재하고 총 3 pass, 2,304 beat 출력. LUT는 weight 반복·완료 계산에서 제외 |
| Credit·entry 제한 | Credit 없는 입력·잘못된 context/kind/mask 거부. LUT 1개 + weight 3개 entry가 점유 중이면 byte 공간이 충분해도 추가 요청 차단 |
| 완료·reset | 수신/출력/compute 완료 구분, 안전한 취소·재시작, pending credit이 남은 reset 거부. Disabled·constant·zero-length·LUT 없는 context도 정상 동작 |

기존 공통 Core의 3KiB chunk 4개·총 3 pass 회귀도 통과했다. 출력 구간에서 2,304 beat를 2,304 cycle에 전달했고 빈 cycle은 없었다. 오류 입력에서 발생한 assertion은 기대한 거부 동작이다. 이번 검증에서 기능 코드 수정은 없었으며, 실제 CCU/programming unit 연결과 합성·타이밍은 검증 범위에 포함하지 않았다.
