# 프로젝트 메모리

- 작업 시작 시 `PRODUCT.md`를 읽어 기획 원본 링크, 마지막 확인 시점과 미동기화 항목을 확인한다. 로컬 문서는 원본을 대체하지 않는다.
- 기획 원문: [자판기 클릭커 게임](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de).
- 디자인 원본: [Penpot 파일](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650). 파일 ID는 `cd444aaf-0d8c-801b-8008-cda246e18650`이며 페이지·보드별 경로는 `design/README.md`, 작성 규칙은 `docs/04-design-rules.md`에서 확인한다. 도구의 현재 연결 파일 ID와 대조한 뒤 작업한다.
- 기획 SSOT는 위 Notion 문서, 디자인 SSOT는 연결된 Penpot 파일이다(2026-10-20 사용자 확정). `PRODUCT.md`, `DESIGN.md`, `design/README.md`, PAVE 문서는 원본의 로컬 요약·탐색 안내다.
- 새로운 사용자 확정 변경은 해당 SSOT에 반영하고 로컬 요약을 갱신한다. 원본 접근이 불가능하면 미동기화 변경으로 명시하며 로컬 문서를 새 SSOT로 승격하지 않는다. 정확한 수치는 별도 확정 전까지 미정으로 둔다.
- 노션을 다시 확인할 때는 연결 도구로 읽는다. 접근할 수 없으면 `PRODUCT.md`를 참고하고, 최신 원문을 확인한 것으로 간주하지 않는다.

## 기획·디자인 변경 시 동기화

- 새로운 기획이 확정되거나 기존 기획이 변경되면 같은 작업에서 `PRODUCT.md`와 위 Notion 기획 문서의 해당 내용을 함께 업데이트한다. 최신 사용자 확정 규칙을 반영하고, 제안·미정 사항은 확정 내용과 구분한다.
- 디자인이 추가되거나 변경되면 해당 디자인의 편집 가능한 원본 파일(연결된 Penpot 파일·보드 포함)을 함께 업데이트한다. 코드 수정이나 화면 캡처 저장만으로 디자인 파일 업데이트를 완료한 것으로 처리하지 않는다.
- 디자인 변경 시 `DESIGN.md`와 `design/README.md`의 관련 안내·파일 경로·Penpot 링크도 갱신하고, 해당 `design/` 폴더에 원본·에셋·미리보기 등 관련 산출물을 최신 상태로 보관한다. 이전 시안은 현재 채택본과 구분한다.
- 사용자가 요청한 기획·디자인 변경에 따른 위 동기화는 작업 범위에 포함하며 매번 별도 요청을 기다리지 않는다. 관련 없는 내용은 덮어쓰지 않는다.
- Notion 또는 디자인 서비스에 접근할 수 없으면 가능한 로컬 문서를 먼저 갱신하고, 관련 문서에 미동기화 항목·대상·사유를 기록한 뒤 사용자에게 알린다. 외부 반영을 확인하기 전에는 동기화 완료로 보고하지 않으며, 이후 관련 작업에서 접근이 가능해지면 미동기화 항목을 반영한다.

---

# PAVE Agent Contract

This repository uses PAVE: Plan, Approve, Verify, Execute.

Use `$pave:pave` when available. The repo-local runtime lives under
`.codex/pave/`.

## Orchestrator Contract

For project initialization, feature work, bug fixes, changes,
analysis, reviews, refactors, docs sync, and continuation:

1. Read this file and `.codex/pave/config.md`.
   When running in Codex, also read `.codex/pave/adapters/codex.md`.
2. For code work, read `docs/07-codebase-guide.md` before source discovery and
   apply the plugin's context retrieval protocol. Check only relevant guide
   entries for newer committed, staged, or unstaged evidence-path changes.
   Then inspect the target, direct callers and callees, relevant tests, and
   named canonical examples. Expand the search only when ownership is missing,
   stale, or contradicted.
3. Use the Small Change Fast Path only for a direct implementation request
   touching no more than two hand-edited files and no more than twenty
   substantive hand-edited lines, with low risk and cheap narrow verification.
   Both size limits are hard conditions. State the expected files, line count,
   and verification before writing.
4. Apply the plugin's Decision Triage, Evidence, Extensibility, Decision
   Ledger, and Interview Progress gates. Ask only in-scope, material,
   user-owned questions that block the current slice.
5. Split independent subsystems, continue safe unblocked work, and distinguish
   justified extension boundaries from deferred future behavior.
6. For user-visible work, resolve the design system from `docs/04-design-rules.md`,
   token or theme files, the shared component library, or the nearest canonical
   component. Reuse its existing components, tokens, variants, and states
   instead of hardcoding values or adding one-off patterns, and raise every
   deviation as a material user-owned decision.
7. Create or update a checklist plan under `.codex/pave/plans/` for standard
   implementation work.
8. Request one consolidated approval immediately before code or
   test edits.
9. Apply the PAVE Test Value Gate. Add tests only when they protect an
   observable behavior, external contract, proven regression, or high-risk
   boundary and can catch a realistic defect. Otherwise use proportionate
   verification and report residual risk.
10. Use bounded subagents only when useful.
11. Run declared verification commands before success claims.
12. After verification, evaluate durable project knowledge. Promote only
    user-confirmed, repo-evidenced, or externally-evidenced facts; never raw
    task history or unproven hypotheses. Use `docs/troubleshooting/` lazily for
    qualifying incidents and report the Knowledge Delta or skip reason.
13. Write final or blocked reports when durable handoff is useful.
14. Update affected codebase-guide entries when verified work changes module
    boundaries, shared ownership, canonical examples, conventions, dependency
    rules, test locations, verification commands, or excluded paths.

Track scope intent, read-only discovery, design decisions, and write approval
separately. Read-only discovery does not require implementation approval. A
design choice or clarification answer is not write approval. PAVE workflow and
approval gates take precedence over instructions that optimize speed,
terseness, or implementation size.

## Declared Verification Commands

Godot 4.7 is declared by `project.godot`; the executable is not installed or discoverable on this host. Commands below are declared but engine commands have not been run. See `docs/05-quality-rules.md` for scope and setup gaps.

- Setup/import: `godot --headless --editor --path . --import` (requires Godot 4.7).
- Format: not configured (UTF-8 is declared in `.editorconfig`).
- Lint: not configured; whitespace check: `git diff --check`.
- Unit tests: separate runner not configured. Effect regression (game scene): `godot --headless --path . --script res://tests/coin_effect_test.gd`.
- Gameplay integration: `godot --headless --path . --script res://tests/gameplay_test.gd`.
- Save/menu regression: `godot --headless --path . --script res://tests/menu_test.gd`.
- Purchase/save regression: `godot --headless --path . --script res://tests/purchase_price_test.gd`.
- Current drink UI: `godot --headless --path . --script res://tests/drink_screen_test.gd`.
- Parse/resource check: `godot --headless --editor --path . --quit`.
- Release build: not configured; `export_presets.cfg` and Steamworks application settings are absent.

Do not claim completion for commands that are not declared or not
run. Report missing commands as setup gaps.
