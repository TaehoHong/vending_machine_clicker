# 02. 개발 규칙

## 진입 순서와 역할

[AGENTS.md](../AGENTS.md), [.codex/pave/config.md](../.codex/pave/config.md), [코드 안내](07-codebase-guide.md)를 따른다. 제품 결정은 Notion, 디자인 결정은 Penpot에 반영한다. 사용자가 설계·최종 검수를 맡고 에이전트가 구현한다. 이 초기화는 게임 기능 구현이나 구조 변경을 포함하지 않는다.

이 문서는 개발·코드 스타일·Git·협업·에셋 관리의 기준 문서다. 아래 작업 규칙과 코드 스타일은 2026-10-20 사용자 확정 사항이다. 기획 원문은 Notion, 편집 가능한 디자인 원본은 Penpot을 계속 따른다.

## 저장소에서 확인한 사실

- Godot 4.7 선언, GDScript·`.tscn`·`.tres` 사용. 게임용 패키지 매니저·Node 빌드 시스템은 없다.
- 기존 GDScript에는 들여쓰기 방식이 혼용되어 있다. 현재 파일의 관례를 프로젝트 표준으로 간주하지 않고 아래 확정 스타일을 적용한다.
- `ui/build_scenes.py`는 씬·테마를 쓰는 생성 도구다. 현재 수작업 씬을 덮어쓸 수 있으므로 초기화·설치 명령으로 실행하지 않는다.
- 런타임 음료 카탈로그는 `ui/drink_catalog.gd`다. `ui/drinks.json`은 생성 도구 입력이므로 동등성 확인 없이 최신 런타임 기준으로 취급하지 않는다.

## 변경·협업

- 작은 범위로 수정하고 현재 소유 모듈과 공유 리소스를 재사용한다. 목적에 없는 인접 정리·재설계를 하지 않는다.
- 기획 확정·구현 현황·제안 수치를 구분한다. 원본에 반영되지 않은 변경은 미동기화로 기록한다.
- 새 작업은 작업별 `codex/<task-name>` 브랜치를 사용한다. 작업명은 내용을 알 수 있는 영어 소문자와 하이픈으로 쓴다. 예: `codex/drink-unlock`.
- 기능·문서 등 자연스럽게 함께 리뷰할 작업 단위를 구현하고 필요한 검증을 마치면 별도 요청 없이 로컬 커밋한다. 실패하거나 미완료인 검증은 통과로 기록하지 않는다. 다른 작업자의 변경은 해당 커밋에 섞지 않는다.
- 커밋 접두어는 영어(`feat:`, `fix:`, `docs:`, `chore:`, `test:`, `refactor:`), 내용은 구체적인 한국어로 쓴다. 기능 관련 문서는 같은 커밋에 포함한다.
- push·PR 생성·merge는 사용자가 요청했을 때만 진행한다.
- 동시에 작업할 때는 파일별 담당 범위를 먼저 정한다. 같은 파일을 수정하기 전 최신 변경을 다시 확인하고, 다른 작업자의 수정은 보존한다. 공유 체크아웃의 브랜치 전환은 진행 중인 다른 작업과 조율한다.
- 검증 명령·한계는 [05](05-quality-rules.md)에 모은다. 코드 경계가 바뀌면 [07](07-codebase-guide.md)의 관련 항목만 갱신한다.

## 코드 스타일

새 코드와 수정하는 부분부터 적용한다. 관련 없는 기존 코드의 일괄 포맷·이름 변경은 별도 작업으로 다룬다.

| 항목 | 확정 규칙 |
| --- | --- |
| GDScript 들여쓰기 | 탭, 표시 폭 4칸 |
| 텍스트 파일 | UTF-8, LF, 파일 끝 개행, 줄 끝 공백 제거 |
| 스크립트·씬·리소스 파일명 | `snake_case`: `drink_catalog.gd`, `purchase_button.tscn` |
| 클래스·노드 이름 | `PascalCase`: `DrinkCatalog`, `PurchaseButton` |
| 함수·변수 이름 | `snake_case`: `purchase_drink`, `current_gold` |
| 상수 | `UPPER_SNAKE_CASE`: `MAX_DRINK_COUNT` |
| 내부 멤버 | `_` 접두어: `_refresh_ui`, `_current_selection` |
| 타입 | 함수 인자·반환값·멤버 변수에 명시한다. 타입이 명확한 지역 변수는 `:=`를 허용한다. |
| 줄 길이 | GDScript는 100자 이내로 작성한다. |
| 문자열·목록 | 큰따옴표를 기본으로 사용하고, 여러 줄 목록의 마지막 항목에도 쉼표를 붙인다. |
| 언어 | 식별자는 영어, 문서·주석은 한국어. 주석은 코드 반복 설명보다 이유와 제약을 기록한다. |

[.editorconfig](../.editorconfig)는 문자 인코딩·개행·공백과 GDScript 들여쓰기·줄 길이 기준을 선언한다. 편집기의 지원 범위에서 적용되며, 이름·타입·따옴표까지 검사하는 포매터나 린터는 아직 설정되지 않았다. 생성된 씬·리소스에 GDScript의 줄 길이 제한을 적용하지 않는다.

## 에셋 관리와 보관 범위

- 편집 가능한 디자인 원본은 Penpot에서 관리한다. 로컬 `design/`을 Penpot 전체 복제본이나 작업 이력 보관함으로 유지하지 않는다.
- 게임이 실제로 사용하는 이미지·아이콘·스타일 리소스는 저장소의 해당 런타임 경로에서 관리한다. 현재 경로 예시는 `images/`, `ui/pixel/`이며, 임의로 중복 복사하거나 전체 경로를 재편하지 않는다.
- 디자인 적용 시 원본 보드·컴포넌트 링크와 적용 파일 경로를 [DESIGN.md](../DESIGN.md)·[design/README.md](../design/README.md)의 해당 안내에서 연결한다. 내보낸 파일은 게임에서 크기·비율·선명도를 확인한다.
- 비교 시안·이전 버전·미리보기·작업 기록은 기본 영구 보관 대상이 아니다. 버전 추적은 Git 이력을 사용하고, 검수용 임시 출력은 필요할 때만 만든다. 현재 작업에 필요한 로컬 소스·산출물이나 사용자가 보관을 요청한 자료만 목적에 맞게 남긴다.
- 이 기준은 앞으로의 보관 정책이다. 기존 자료 삭제나 Penpot 보관함 정리는 별도로 범위를 정하며, 이 문서 추가만으로 기존 파일을 일괄 삭제하지 않는다.

## Linked Sources

| Source | Owns | Not covered | Evidence paths |
| --- | --- | --- | --- |
| [AGENTS.md](../AGENTS.md) | 저장소 지침·PAVE 진입·검증 명령 | 제품 기획 원본 | AGENTS.md |
| [README.md](../README.md) | 편집·실행 안내 | 최신 기능 규칙·전체 최신 테스트 목록 | README.md, project.godot, tests/ |
| [PRODUCT.md](../PRODUCT.md) | 역할 분담 원본 요약 | 코드 스타일 | PRODUCT.md |
| [DESIGN.md](../DESIGN.md), [design/README.md](../design/README.md) | 디자인 작성·검수 규칙과 원본·적용 경로 | 개발·Git 규칙 | DESIGN.md, design/README.md |
| [Godot GDScript 스타일 가이드](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) | 코드 스타일의 공식 참고 | 사용자 확정 프로젝트 규칙을 대체하지 않음 | 위 코드 스타일 절 |
| [Godot 정적 타입 안내](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html) | 타입 표기의 공식 참고 | 프로젝트의 타입 적용 범위 결정 | 위 코드 스타일 절 |
