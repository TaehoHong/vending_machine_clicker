# 승인된 손님 애니메이션의 4종 적용

## 승인·범위

- user-confirmed: v3 미리보기 그대로 게임 적용(2026-10-27). 기본 손님 1종으로 축소하지 않고 기존 4종을 유지하며 나머지 3종도 같은 기준으로 추가 제작·검수.
- 원본: Penpot cd444aaf-0d8c-801b-8008-cda246e18650. 공통 파츠·외형 01/02/03/08, 기본 동작 보드 3a3dd3bc-800b-8093-8008-da4da209e847, 귀·호흡·파지 보완 f128a085-12ce-8061-8008-da6496c95969.
- owner-found: customer_flow.gd(등장/생산/퇴장, facility_world.gd가 생성/produced 호출), 기존 미승인 customer_animation.gd + customer_frames.tres(원본 프레임 재생). 승인 전 중단된 원본 30프레임 구현을 v3 승인본으로 대체한다. 관절 분리 회전·가로 눌림은 사용하지 않는다.
- 그림체·파츠 규칙: docs/04-design-rules.md와 DESIGN.md. 기본 6보행 PNG·귀 복구·연속 메시 호흡·원본 쥔 수령 자세는 그대로 사용. 새 3종은 공통 몸·머리·피부·하의·신발을 재사용하고 부족한 동작은 머리·목·어깨·손까지 연결된 상체 단위로 추가 원화를 제작하고 공통 동작 하체와 조합. 퇴장은 원본 음료 보행 하체를 재사용한다.
- 규칙/저장/스테이지/자판기 위치/가격은 preserve-current-behavior. 새 스테이지와 외형 추가는 out-of-scope. 남은 material blocker 0.

## 실행 계약

수정 대상: assets/penpot/customers의 실제 사용 동작 아틀라스, customer_animation.gd / customer_frames.tres / customer_flow.gd, 전용 customer_animation_test.gd. 이전 관절 전용 customer_rig.gd·customer_poses.gd와 미사용 에셋은 승인 동작으로 전환한 뒤 제거. 별도 공용 애니메이션 프레임워크·매니저 없음. 4종 표현 데이터는 동일 SpriteFrames 리소스에 모아 중복 상태 로직을 만들지 않는다.

- [x] 추가 3종 공통 파츠·보행·조작·줍기·수령·퇴장 그림 제작 → 같은 크기/타이밍 4종 미리보기에서 귀·접합부·파지 검수, 기본 6보행 바이트 유지.
- [x] 기존 actor/flow에 승인 클립·4종 순환 연결 → .36초 정지 + .36초 후면 대기, 2.4초/4px 호흡, 첫 숙임부터 음료, 파지 및 발 기준 고정.
- [x] 동작 회귀 검사 → 4종 순환, 각 클립 경계/길이, 귀 포함 승인 이미지·발 고정, 수령 물품 유무, 생산 시점·pause·반복 등장·정리, 게임 보상/저장 비변경.
- [x] 실제 Metal 게임 주기를 재생·캡처 → 자판기 접근/정지/조작/줍기/수령/퇴장과 4종을 실제 크기로 확인.
- [x] Penpot 편집 원본과 승인 상태·Notion/PRODUCT/DESIGN/design README, 관련 코드 안내·검증 명령 동기화.
- [ ] Godot 4.7 import/parse, customer_animation/facilities/facility_rules/gameplay/menu/purchase_price/progress_store/drink_screen/coin_effect 회귀, git diff --check → 검증한 기능 단위 커밋 후 로컬 main 통합·재검증.

Test Value Gate: 실제 변형·상태 경계·순환/중복/cleanup·pause 회귀를 잡는 하나의 고객 동작 검사와 기존 시설/저장 회귀를 사용한다. 단순 파일 존재·상수 복제 테스트는 추가하지 않는다. 시각 자연스러움은 실제 렌더링과 프레임 비교로 확인하며 자동 검사만으로 보장하지 않는다.

기존 dirty DESIGN의 상단 파츠 규칙 보완, .DS_Store와 관계없는 변경은 커밋에서 제외한다. 새 원화/합성 소스는 Penpot에서 편집 가능하게 동기화하고, 검토용 출력은 임시 산출물로 유지한다. 게임에는 실제 쓰는 최종 아틀라스만 둔다.

검증: 고객 동작 RED는 기존 등장·단일 외형 경로에서 실패, GREEN은 4종 5회 순환·정지·호흡·수령·pause·생산 fallback·cleanup과 재화 비변경을 통과. 시설/시설규칙/게임플레이/메뉴/구매가격/저장호환/음료화면/동전 회귀 통과. Metal 실제 Play 26초·5초 생산에서 4종 순환과 방문자 누적 방지 확인. Sol/Terra 검수 후 조작 허리 띠·퇴장 골반판을 수정했고 Sol 재검수에서 해소와 투명 틈 없음 확인. 미세한 옷자락 윤곽은 적용 차단 결함으로 보지 않음.

퇴장은 대기 .36초·줍기 .72초·수령 .72초 후 3초 보행으로 최단 생산 주기 5초에서도 이용 위치를 비우도록 연결했다. 미리보기의 포즈 반복 감상 시간을 게임 이용 대기로 확대하지 않는다.

원본 동기화: Notion 연결 도구로 승인된 4종·대기·호흡 규칙을 갱신했다. Penpot 새 보드 f128a085-12ce-8061-8008-da762abc6bce에 4종×12포즈의 상체/하체 96개 컴포넌트를 저장했다. MCP 연결 중단 이후에는 브라우저 편집으로 반영·검수했다. 기존 상단 DESIGN 파츠 규칙 수정, .DS_Store, 이전 미승인 계획은 커밋에서 제외한다.

Knowledge Delta: 승인된 4종·정지·호흡 규칙은 PRODUCT/DESIGN과 SSOT에, 재생 소유권·프레임 캔버스·검증은 코드 안내/품질 문서에 반영했다. 별도 troubleshooting 문서는 생략: 이번 변경의 지속 규칙·검증 경계는 기존 소유 문서에 기록했으며 외부 도구 연결 지연을 제품 장애 지식으로 승격하지 않는다.
