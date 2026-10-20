# Backstreet Clicker

Godot 4.7 게임이다. `project.godot`를 열면 `src/app/main.tscn`에서 시작한다.
기획 SSOT는 Notion, 디자인 SSOT는 Penpot이다. 원본 링크는 [자료 안내](design/README.md), 작업 규칙은 [AGENTS.md](AGENTS.md)를 따른다.

## 구조·실행

- [아키텍처](docs/06-architecture.md): 실제 폴더·상태 소유권·의존성 규칙.
- [코드 안내](docs/07-codebase-guide.md): 기능별 진입점·공유 구현·관련 회귀 테스트.
- [개발 규칙](docs/02-development-rules.md): 코드 스타일·재사용·파일 생성·main 통합.
- [검증 안내](docs/05-quality-rules.md): 실행 명령·검증 결과·한계.

```sh
godot --headless --editor --path . --import
godot --path .
```

`godot`이 PATH에 없으면 실제 Godot 실행 파일 경로로 바꾼다. 별도 게임용 패키지 매니저나 Python 설치는 필요하지 않다.

## 플레이·저장

New Game은 기존 저장을 백업하고 새 진행으로 시작하며, Load Game은 저장된 진행을 복원한다. 플레이 중 수색·음료 구매·빈캔 해금과 피버를 사용한다. ESC에서 일시정지·저장·종료할 수 있고 저장 실패 시 종료하지 않는다.

기존 `user://progress.cfg`와 `user://backups/`를 유지한다. 가격·능력·밸런스의 코드 소유자는 [코드 안내](docs/07-codebase-guide.md), 확정 기획과 원문 차이는 [PRODUCT.md](PRODUCT.md)에서 확인한다. Steam Cloud·모바일 계정은 아직 연결되지 않았다.

## 검증·개발 도구

```sh
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/features/gameplay_test.gd
godot --headless --path . --script res://tests/features/menu_test.gd
godot --headless --path . --script res://tests/features/purchase_price_test.gd
godot --headless --path . --script res://tests/features/drink_screen_test.gd
godot --headless --path . --script res://tests/integrations/progress_store_test.gd
```

테스트 저장과 캡처는 `.godot/` 아래 임시 산출물로 분리한다. 전체 관련 테스트는 [검증 안내](docs/05-quality-rules.md)를 따른다. [개발 생성기](tools/README.md)는 이전 레이아웃의 미리보기만 만들며 채택 씬을 덮어쓰지 않는다.
