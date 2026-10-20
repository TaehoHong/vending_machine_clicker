# 05. 품질·검증

제품 품질 방향은 Notion, 실행 명령의 진입점은 [AGENTS.md](../AGENTS.md)다. [개발 규칙의 코드 품질 필수 검사](02-development-rules.md#코드-품질-필수-검사)와 자동 회귀·실제 화면 검수를 함께 적용한다. 테스트 대상·소유자는 [코드 안내](07-codebase-guide.md)를 따른다.

## 실행 환경·명령

Godot 4.7을 사용한다. 이 호스트에서는 공식 4.7-stable 아카이브의 SHA512를 대조한 임시 실행 파일 `/private/tmp/clicker-godot-4.7/Godot.app/Contents/MacOS/Godot`로 검증했다. 버전은 `4.7.stable.official.5b4e0cb0f`이며 시스템/PATH 설치를 뜻하지 않는다. 아래 `godot`은 실제 실행 파일 경로로 바꿀 수 있다.

```sh
godot --headless --editor --path . --import
godot --headless --editor --path . --quit

godot --headless --path . --script res://tests/features/gameplay_test.gd
godot --headless --path . --script res://tests/features/menu_test.gd
godot --headless --path . --script res://tests/features/purchase_price_test.gd
godot --headless --path . --script res://tests/features/drink_screen_test.gd
godot --headless --path . --script res://tests/features/drink_unlock_screen_test.gd
godot --headless --path . --script res://tests/features/vending_display_test.gd
godot --headless --path . --script res://tests/features/search_test.gd
godot --headless --path . --script res://tests/features/coin_effect_test.gd
godot --headless --path . --script res://tests/features/search_fever_test.gd
godot --headless --path . --script res://tests/features/punch_fever_test.gd
godot --headless --path . --script res://tests/features/drink_dispense_test.gd
godot --headless --path . --script res://tests/features/purchase_area_test.gd
godot --headless --path . --script res://tests/features/abilities_test.gd
godot --headless --path . --script res://tests/features/skill_tree_test.gd
godot --headless --path . --script res://tests/features/expanded_skills_test.gd
godot --headless --path . --script res://tests/integrations/progress_store_test.gd

git diff --check
```

종료 코드와 함께 `SCRIPT ERROR`·assertion·리소스 읽기 오류·완료 출력을 확인한다. Godot은 스크립트 오류가 있어도 0을 반환할 수 있으므로 종료 코드만으로 통과를 판단하지 않는다. 각 테스트를 독립 프로세스로 실행하고 타임아웃도 실패로 처리한다.

## 검증 경계

- `tests/features/`는 실제 씬과 주입된 게임 세션을 사용한다. `tests/support/game_fixture.gd`는 별도 저장 경로와 세션 대역을 연결하며 게임 규칙을 대신 구현하지 않는다.
- 저장은 `res://.godot/`의 테스트 전용 파일을 사용한다. 캡처는 `.godot/test_artifacts/`에 출력하며 채택 디자인이나 플레이어의 실제 저장을 덮어쓰지 않는다.
- 구매·해금·퀘스트: 잔액 부족·중복 입력·잘못된 순서가 진행을 바꾸지 않는지, 차감/획득/가격·진행이 함께 저장되는지 확인한다.
- 저장·백업: 기존 키와 기본값·타입/범위 처리·정수 키 음료 수·해금·이전 진행 복원·새 게임 백업·저장 실패 시 종료 차단을 확인한다.
- 입력·피버·일시정지: 클릭 영역과 클릭 위치, 꽝·보상·기간·중첩·pause·정상 복귀를 검증한다. viewport 로컬 좌표를 보내는 테스트는 `push_input(..., true)`로 좌표계를 명시한다.
- 디자인: 기존 공통 테마·상태 리소스·폰트 재사용과 선택·잠김·초기화·resize를 검사한다. headless만으로 실제 렌더링·글리프·가독성·조작 감각을 보장하지 않는다.
- 구조: 세션/규칙에 씬·Control·파일 I/O 의존이 없는지, UI가 직접 저장하지 않는지, 중복 진행 원장·규칙·스타일을 만들지 않았는지 실제 diff와 참조를 검토한다.

## 구조 전환 검증 기록 · 2026-10-20

- 변경 전 main `34cff7c`: 15개 중 11개 통과·4개 실패를 분리된 복사본에서 확인했다.
- 기존 입력 실패 2개(`punch_fever`, `purchase_area`)는 로컬 좌표를 전역 좌표처럼 전달한 테스트 문제였다. 생산 코드와 기존 assertion을 유지한 원본 복사본에서 좌표계만 명시하자 통과했다.
- 기존 표시 실패 2개(`abilities`, `skill_tree`)는 이미 교체된 Catalog/Summary 노드를 검사했다. 현재 선택 상세·능력 요약·잠금/비용/획득 표시를 확인하도록 바꿨다. 가격·보상·차감·저장 기대값은 완화하지 않았다.
- `progress_store_test`는 새 구조에서 정수 키 획득량·해금·플래그·기존 저장 정규화 유실을 보호한다. 음료 수 저장을 일부러 누락시켰을 때 2개 assertion이 실패하는 것을 확인하고 원본을 복원했다.
- 실제 렌더러에서 같은 1152×648 크기·수색 안내 애니메이션 위상으로 메뉴·플레이·음료 초기·잠금 선택·요약·pause 6개 화면을 비교해 픽셀 차이가 없음을 확인했다. 이미지·글꼴·라이선스 등 53개 파일의 원본 바이트도 동일하다.
- 코드/테스트 29개에 임시 gdtoolkit 4.5.0의 `gdformat -l 100 --check`를 적용했다. 단순 이동한 데이터·연출·에셋을 일괄 포맷하지 않았고, 게임/저장소의 패키지 의존성을 추가하지 않았다.
- 구조 전환 후 회귀 16개 전체와 Godot import·parse를 통과했다. 통합 검증은 [구조 전환 계획](../.codex/pave/plans/2026-10-20-runtime-architecture-refactor.md)에 기록한다.

## 남은 설정·검증 범위

CI·저장소에서 고정한 포매터/린터 설치·릴리스 export/Steamworks 설정은 아직 없다. `.editorconfig`는 편집 기준이며 의미상 중복·아키텍처·디자인 일치까지 자동 강제하지 않는다. Windows 실제 배포 빌드·지원 언어 전체·플레이 감각의 최종 사람 검수는 별도로 필요하다. 성능 수치·지원 하드웨어 하한은 미확정이며 임의의 FPS 합격 기준을 만들지 않는다.

## Linked Sources

| Source | Owns | Not covered | Evidence paths |
| --- | --- | --- | --- |
| [AGENTS.md](../AGENTS.md) | 선언 명령·작업 진입 | 원격 CI 실행 | project.godot, tests/ |
| [코드 안내](07-codebase-guide.md) | 소유 모듈·관련 회귀 | 제품 기획 원본 | src/, tests/ |
| [개발 규칙](02-development-rules.md) | 재사용·파일 생성·코드 품질 | 실제 렌더링 증거 | docs/02-development-rules.md |
| [Notion](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de) | 제품 차원의 품질 목표 | Godot 실행 환경 | PRODUCT.md |
