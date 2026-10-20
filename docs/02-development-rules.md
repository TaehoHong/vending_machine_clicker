# 02. 개발 규칙

## 진입 순서와 역할

[AGENTS.md](../AGENTS.md), [.codex/pave/config.md](../.codex/pave/config.md), [코드 안내](07-codebase-guide.md)를 따른다. 제품 결정은 Notion, 디자인 결정은 Penpot에 반영한다. 사용자가 설계·최종 검수를 맡고 에이전트가 구현한다. 이 초기화는 게임 기능 구현이나 구조 변경을 포함하지 않는다.

## 저장소에서 확인한 사실

- Godot 4.7 선언, GDScript·`.tscn`·`.tres` 사용. 게임용 패키지 매니저·Node 빌드 시스템은 없다.
- 게임 스크립트는 탭 들여쓰기와 snake_case 함수명을 사용한다. `.editorconfig`는 UTF-8을 지정한다.
- `ui/build_scenes.py`는 씬·테마를 쓰는 생성 도구다. 현재 수작업 씬을 덮어쓸 수 있으므로 초기화·설치 명령으로 실행하지 않는다.
- 런타임 음료 카탈로그는 `ui/drink_catalog.gd`다. `ui/drinks.json`은 생성 도구 입력이므로 동등성 확인 없이 최신 런타임 기준으로 취급하지 않는다.

## 변경·협업

- 작은 범위로 수정하고 현재 소유 모듈과 공유 리소스를 재사용한다. 목적에 없는 인접 정리·재설계를 하지 않는다.
- 기획 확정·구현 현황·제안 수치를 구분한다. 원본에 반영되지 않은 변경은 미동기화로 기록한다.
- 기능별로 자연스럽게 함께 리뷰할 변경을 묶는다. 커밋 접두어는 영어(`feat:`, `fix:`, `docs:`, `chore:`, `test:`, `refactor:`), 내용은 구체적인 한국어로 쓴다. 기능 관련 문서는 같은 커밋, 샘플·로컬 기록은 별도 `chore:`로 분리한다.
- 검증 명령·한계는 [05](05-quality-rules.md)에 모은다. 코드 경계가 바뀌면 [07](07-codebase-guide.md)의 관련 항목만 갱신한다.

## Linked Sources

| Source | Owns | Not covered | Evidence paths |
| --- | --- | --- | --- |
| [AGENTS.md](../AGENTS.md) | 저장소 지침·PAVE 진입·검증 명령 | 제품 기획 원본 | AGENTS.md |
| [README.md](../README.md) | 편집·실행 안내 | 최신 기능 규칙·전체 최신 테스트 목록 | README.md, project.godot, tests/ |
| [PRODUCT.md](../PRODUCT.md) | 역할 분담 원본 요약 | 코드 스타일 | PRODUCT.md |
