# 시설 구매·업그레이드 승인 시안 적용

사용자 승인: 2026-10-28, 승인 시안을 Penpot에 추가하고 게임에 적용하라는 직접 지시.

- [x] Penpot 파일 cd444aaf-0d8c-801b-8008-cda246e18650에 편집 가능한 구매·강화 원본과 상태를 추가하고 기존 버튼·시설·재화 컴포넌트를 재사용한다. 검증: 원본 재조회·저장 후 새로고침·실제 렌더.
- [x] 기존 src/features/facilities/{purchase,auto_upgrade,trash_upgrade}_design.tscn을 새 원본으로 갱신하고 facilities_screen.gd의 상태 표시·입력만 연결한다. src/shared/ui/design_view.gd의 fit 소유자를 통해 1280×720 원본을 균등 축소한다. 검증: 실제 구매·강화·뒤로·닫기, 기본/보유/부족/최대 캡처.
- [x] tests/features/facilities_test.gd를 확장해 구매 후 재화 HUD·강화 전후/단계/다음 비용·최대·조건 설명 갱신과 차감 경계를 보호한다. 검증: 기존 시설/시설 규칙·화면/메뉴 회귀 및 import·parse·git diff --check.
- [x] Notion·PRODUCT·DESIGN·design/README와 관련 코드 안내를 승인된 현재 동작으로 동기화한다. 새로운 트리 선행 조건·경제 수치·관리 화면은 추가하지 않는다.
- [x] 검증 후 기능 단위 커밋, 로컬 main 반영, 사용자 기존 요청에 따라 push 및 원격 해시 확인.

owner-found: 시설 계산/결제는 facility_rules.gd 및 game_session.gd, 표시/입력은 facilities_screen.gd, 화면 배율/버튼은 design_view.gd와 기존 A 테마/프레임, 자산은 Penpot의 기존 시설·아이콘·버튼 원본. 새 규칙 카탈로그/런타임 테마/에셋 복제는 만들지 않는다.

preserve-current-behavior: 빈캔 단일 구매·즉시 설치, 골드 강화 비용/최대 5회, 저장 호환, 생산·수령, 미리보기 무차감, 설치 본체 무동작.
결정: 승인된 목록→시설별 강화 상세 채택, 트리와 선행 조건은 이번 적용에서 제외. blocking decisions: 0.

검증: Godot 4.7 import·parse, 선언된 회귀 20개, 최종 시설 검사와 Metal 상태/배율 캡처를 통과했다. Penpot 공통 원본 3개·연결 화면 9개는 네이티브 Text/도형/연결 컴포넌트로 저장·재조회했다. 연결 인스턴스의 content/visibility/fill/layer-effects 오버라이드를 보존하고 프로토타입 전환 영역을 분리했다.
Knowledge Delta: 현재 UI 구조·상태 표시·원본 링크·루트 캔버스별 fit 소유자를 기존 문서에 반영했다. 일시적인 연결 실패는 별도 제품 규칙으로 승격하지 않았다.
통합: 작업 중 main에 추가된 시설 타이머·골드 저장 수정 3개 커밋은 보존해 통합 검증한다.

완료 증거: UI 기능 `0c50b47`, 저장 수정 통합 `1f12a59`. 통합본 전체 회귀 20개와 import·parse, main 시설 검사, Metal 최종 캡처 통과. main fast-forward 및 최초 push 뒤 원격 해시 `1f12a59a5928b8ce1c245f2abef4d9041e6277ab`를 확인했다. 검증·계획 기록은 별도 chore 커밋으로 추가한다.
