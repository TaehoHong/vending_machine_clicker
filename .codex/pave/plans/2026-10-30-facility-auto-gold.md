# 시설 생산 골드 자동 획득·빈캔 직접 수령

## 요청과 상태

2026-10-30 사용자 요청: 자동 자판기 손님이 만든 골드는 수색처럼 튀어오른 뒤 자동 획득하며, 빈캔은 랜덤으로 떨어지고 클릭하여 수령한다. 사용자 “두개다 해줘”로 시설 변경과 BGM 시안 3개 제작의 통합 승인을 받았다. 기존 골드 클릭 수령 규칙을 변경하는 작업이며 Small Change Fast Path 범위를 넘는다.

## 범위·결정·기존 소유자

- user-owned active: 골드는 클릭 없이 짧은 튀어오름 완료 시 지급한다. 빈캔은 바닥에 남아 클릭 수령한다. 새 확률/금액/생산 주기 변경 요청은 없다.
- repo-evidenced retained: 생산 10초/10 Gold, 빈캔 드롭 20%, 15초 소멸, 강화 효과·쓰레기통 확률 자동 수집을 유지한다. 유지 범위를 알린 통합 승인안으로 승인받았다. 비구매 행인은 보상을 만들지 않는다.
- owner-found: src/features/facilities/facility_world.gd의 advance/refresh와 gold 클릭 콜백이 현재 생산 보상 표현/세션 요청을 담당한다. 골드 버튼을 자동 연출로 대체하고 기존 collect_facility_gold 호출을 연출 완료에 연결한다. 원본 생산 보상은 기존 data.gold가 소유하며 별도 지급 원장을 만들지 않는다.
- owner-found: src/game/automation/facility_rules.gd의 advance/collect_gold/collect_item이 실제 지급·20% 확률·소멸·수집을 소유한다. 기존 gold 저장을 보존하고 연출 중 종료하면 다음 진입에 미수령 골드를 다시 표현·단 한 번 지급한다. 표현만을 위해 생산 골드/드롭 규칙을 복제하지 않는다.
- owner-found: src/features/play/effects/search_coin.gd의 동전 그림·breakdown과 기존 공유 폰트/금액 스타일을 재사용한다. 수색 팝업 그룹이나 피버 배율에 시설 효과를 섞지 않고 시설 월드의 발밑 좌표에서 표시한다. 새 런타임 파일·범용 효과 매니저·테마는 만들지 않는다.
- owner-found: customer_flow.gd의 produced는 구매 손님의 생산 이후 수령/퇴장을 연결한다. 보상은 기존 생산 이벤트에 연결하고 비구매 행인과 구분한다. 구매 동작/손님 아트는 변경하지 않는다.
- 완료 콜백의 중복 지급 방지, 한꺼번에 여러 생산 주기를 진행했을 때의 합계, resize/pause/화면 종료 정리와 원본 저장 잔액 보존을 확인한다. 빈캔 클릭 영역과 골드 자동 효과가 서로 입력을 가리지 않도록 한다.

## 코드·테스트·문서 범위

- 기존 시설 월드·필요한 세션 접점 및 직접 관련 회귀를 수정한다. 시설 규칙은 자동 수령에 필요한 최소 접점만 변경하고 기존 저장 스키마는 유지한다.
- tests/features/facilities_test.gd와 tests/integrations/facility_rules_test.gd, customer_animation_test.gd의 기존 보상·행인 계약을 대조한다. 표현 수명·자동 수령과 미클릭 빈캔·단일 클릭 지급·중복 클릭 무지급의 현실적 회귀를 기존 테스트에 추가한다.
- Notion 시설 수령 규칙과 PRODUCT.md를 같은 작업에서 갱신한다. Penpot 지정 파일 cd444aaf-0d8c-801b-8008-cda246e18650의 시설 골드 획득 원본/사용처에 튀어오름→자동 획득 상태를 반영하고 빈캔 직접 수령을 유지한다. DESIGN.md/design README는 바뀐 규칙·원본 안내만 갱신한다. 외부 접근 실패 시 대상/사유를 미동기화로 기록한다.
- docs/07-codebase-guide.md의 시설 수령 계약과 검증 안내를 갱신한다. 새 모듈·파일 경계는 만들지 않으며 관련 없는 기존 코드는 정리하지 않는다.

## 검증과 완료

- [x] PRODUCT/PAVE/코드 안내·직접 호출/기존 시각 효과·시설/저장 회귀 확인.
- [x] 통합 코드·테스트 작성 승인.
- [x] 기존 소유자에서 자동 골드 효과·완료 지급, 랜덤 빈캔 클릭 수령 연결.
- [x] 생산/기존 미수령 합계·종료/재진입·중복·pause/resize·빈캔·쓰레기통 회귀와 실제 GPU 검수.
- [x] 시설/손님/저장/수색/퀘스트 관련 검사, Godot editor parse, git diff --check.
- [x] Notion/Penpot 및 로컬 요약·코드 안내 동기화. 접근 실패는 명시.
- [x] 실제 diff 재사용·책임·타입/탭/LF/100자 검토. 검증된 계약만 Knowledge Delta로 남기고 일회성 로그는 별도 문서화하지 않는다.
- [x] 검증한 변경 커밋·로컬 main 머지·통합 검사. push/PR 없음.


## 검증 결과·외부 원본·Knowledge Delta

- Godot 4.7.2 공식 실행 파일로 기존 feature/integration 21개 실행: 20개 통과, purchase_area_test의 기존 메모 HUD resize 좌표 검사 1개 실패. 현재 변경 파일을 main 버전으로 임시 복원한 동일 검사에서도 같은 assertion이 실패함을 확인하고 원래 변경을 복구했다. 관련 없는 기대값은 수정하지 않았다.
- 최종 facilities_test(생산·복수 주기 합계·미수령 저장/재진입·중복 방지·pause·빈캔 클릭) 및 customer_animation_test, facility_rules_test, progress_store_test, coin_effect_test, quest_screen_test 재검사 통과. 시설 검사는 실제 GPU에서도 통과했으며 발밑 튀어오름을 화면에서 확인했다.
- 선언된 Godot headless editor parse/resource check와 git diff --check 통과. 편집기 설정 폴더 접근은 권한이 있는 공식 실행으로 검증했다. 추가 GDScript의 LF·100자 한도를 확인했다. 별도 린터/릴리스 빌드는 기존 미설정 상태다.
- Notion 기존 시설 최종 문단을 수정하고 새로고침 후 확인했다. Penpot 지정 파일 02 에셋의 기존 골드 FX 메인 컴포넌트를 유지하고 상승·소멸 연결 인스턴스를 추가했다. 36px 상승/0.18초, 소멸/0.16초를 연결하고 보기 모드에서 자동 완료 상태까지 도달하는 것을 확인했다. 게임은 위치 tween, 원본 시연은 두 위치 사이 디졸브를 사용한다.
- 새 런타임 파일·보상 원장·경제 규칙·테마를 추가하지 않았다. 동전 그림/금액 포맷/AccentLabel·세션 수령·저장 계약을 재사용했다. 시각 입자만 등급당 8개로 제한하여 예전 저장의 큰 잔액도 과도한 노드를 만들지 않고 실제 금액은 전액 지급한다.
- Knowledge Delta: 검증된 시설 자동 수령 및 customer_flow.reward_origin 계약만 PRODUCT/DESIGN/design README/코드 안내에 반영했다. 일회성 실행 로그·기존 HUD 실패는 이 계획의 검증 근거로 남기며 별도 troubleshooting 문서는 만들지 않았다.
- BGM은 게임에 적용하지 않은 3개 비교 시안이다. 기존 음원·샘플·사운드폰트 없이 직접 작성한 음표와 수학적 합성으로 stereo 44.1kHz/16-bit WAV를 만들었다. 저녁 골목 80 BPM/25.5초, 네온 산책 92 BPM/22.37초, 비 오는 밤 72 BPM/28.17초. 유한 신호·클리핑 없음·파일 헤더를 검사했다. 최종 루프/게임 적용은 별도 선택 사항이다. 시안·composer.py·메타데이터는 사용자에게 제공하는 visualization 산출물에 보관하고 프로젝트 에셋으로 편입하지 않았다.
