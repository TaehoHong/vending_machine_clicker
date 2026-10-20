# 05. 품질·검증

사용자 확정 품질 방향은 Notion, 실행 명령의 진입점은 [AGENTS.md](../AGENTS.md)다. 자동 검증과 사람의 실제 화면·플레이 검수를 함께 적용한다. 기능 변경에 맞는 관찰 가능한 동작·저장 경계를 검증하며 저가치 테스트를 복제하지 않는다.

## 현재 검증 방식

`tests/*.gd`는 `SceneTree` 기반 직접 실행 스크립트다. 별도 GUT·GdUnit 패키지는 확인되지 않았다. 일부는 게임 스크립트를 상속해 랜덤·저장을 통제하고 `.godot/` 아래 임시 저장 파일을 쓴다. 일반 `user://progress.cfg`를 직접 사용하지 않도록 각 테스트를 확인한다.

```sh
# Godot 4.7을 설치하고 저장소 루트에서 실행
# 바이너리 이름이 다르면 godot을 실제 실행 파일 경로로 바꾼다.
godot --headless --editor --path . --import
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/gameplay_test.gd
godot --headless --path . --script res://tests/menu_test.gd
godot --headless --path . --script res://tests/purchase_price_test.gd
godot --headless --path . --script res://tests/drink_screen_test.gd
godot --headless --path . --script res://tests/coin_effect_test.gd
```

## 검증 범위와 합격 기준

- 구매·해금·저장·불러오기: 중복 차감과 진행 손실을 막고 기존 저장 호환을 확인한다. 저장 성공·실패와 실제 UI 상태를 함께 검사한다.
- 수색·피버·입력·일시정지: 관련 스크립트는 [코드 안내](07-codebase-guide.md)에서 찾는다. 종료 코드뿐 아니라 assertion·스크립트 오류·완료 출력도 확인한다.
- 실제 화면: headless는 렌더링·글리프·가독성·마우스 감각을 보장하지 않는다. 사용자 플레이 검수와 지원 언어·창 크기 확인이 별도로 필요하다.
- 과거 스킬트리 테스트는 최신 통합 화면과 기대값이 맞는지 먼저 확인한다. 기존 README의 테스트 목록을 현재 전체 회귀 스위트로 간주하지 않는다.

## 초기화 검증과 설정 공백

- PAVE 설치 헬퍼의 내장 파일·계약 검증을 통과했다.
- 문서 로컬 링크·명령의 대상 파일·공유 심볼·SSOT 표기·기존 코드/에셋 보존을 정적으로 확인했다. 공백 검증은 `git diff --check`다.
- Godot 실행 파일이 PATH와 일반적인 macOS 앱 설치 위치에서 발견되지 않았다. 게임 테스트·import·parse·내보내기는 실행하지 못했으며 통과로 보고하지 않는다.
- 포매터·린터·CI·릴리스 export 명령은 설정되지 않았다. 성능 수치·지원 하드웨어 하한은 `unresolved-after-asking`이며 임의의 FPS 합격 기준을 만들지 않는다.

## Linked Sources

| Source | Owns | Not covered | Evidence paths |
| --- | --- | --- | --- |
| [AGENTS.md](../AGENTS.md) | 선언 검증 명령 | 실제 실행 성공 증거 | AGENTS.md, tests/ |
| [README.md](../README.md) | 기존 검증 설명 | 최신 전체 UI 회귀 범위 | README.md, tests/ |
| [Notion](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de) | 제품 합격 방향 | 엔진 테스트 구현 | PRODUCT.md |
