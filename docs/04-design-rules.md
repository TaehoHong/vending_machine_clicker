# 04. 디자인 규칙

**디자인 SSOT는 Penpot이다.** [연결 안내](../design/README.md)의 기존 파일·페이지·보드를 사용한다. `DESIGN.md`, SVG·PNG·캡처와 이 문서는 로컬 안내·보관물이며 원본을 대체하지 않는다.

## 대상 Penpot 파일

- [디자인 원본 파일 열기](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650)
- 팀 ID: `ce180602-f36b-8035-8008-cda23f0a1b46` / 파일 ID: `cd444aaf-0d8c-801b-8008-cda246e18650`.
- 페이지·보드별 최신 경로와 적용 상태는 [design/README.md](../design/README.md)와 [DESIGN.md](../DESIGN.md)에서 찾는다. 페이지 재편 전 주소나 Y 좌표를 현재 원본 위치로 고정하지 않는다.

위 경로는 저장소에 기록된 식별자다. 실제 도구 연결 파일 ID와 대조하고 대상 페이지·보드의 현재 상태를 확인한 뒤 편집한다. 연결되지 않았거나 ID가 다르면 다른 파일을 원본으로 간주하지 않는다.

MCP에서 연결 오류가 나면 [MCP 원본 접근 복구 절차](../design/README.md#mcp-원본-접근-복구-절차)를 먼저 따른다. 연결 안내 링크를 추가한 것과 원본을 실제로 읽고 수정할 수 있음을 검증한 것은 구분한다. 접속값 교체 후 새 세션 검증과 기존 도구의 재시작·재검증도 구분한다.

## 원본과 구현을 찾는 순서

1. 작업 대상의 Penpot 원본과 채택·검토·이전 상태를 확인한다. 오래된 보드가 남아 있다는 이유로 채택본으로 취급하지 않는다.
2. [DESIGN.md](../DESIGN.md)와 [design/README.md](../design/README.md)에서 적용 상태·로컬 경로를 찾는다. 통합 화면 Play 스타일은 `design/drink-screen-references/applied/play-style/`에 연결되어 있다.
3. 구현은 `src/shared/ui/themes/play_theme.tres`, `src/shared/ui/themes/`, `src/features/drinks/drink_screen.gd`의 공유 자원을 먼저 확인한다. Main은 `src/shared/ui/themes/backstreet_theme.tres`를 사용한다.
4. 실제 디자인 변경은 Penpot 편집 원본, 게임 적용 에셋, 원본·적용 경로 안내를 함께 갱신한다. 로컬 자료는 [개발 규칙의 보관 범위](02-development-rules.md#에셋-관리와-보관-범위)를 따른다. 캡처만으로 원본 동기화 완료를 선언하지 않는다.

## 디자인 작업 준수사항

작성·편집·검수 절차는 [DESIGN.md의 디자인 작업 준수사항](../DESIGN.md#디자인-작업-준수사항)을 따른다. 사용자는 준수사항을 `DESIGN.md`에 유지하고 Penpot 안의 작성 규칙 보드는 제거하도록 지시했다. 디자인 원본의 SSOT는 계속 Penpot이며, 작업 절차 문서와 구분한다.

페이지 구성은 00 시스템 / 01 게임 화면 / 02 에셋(HUD 포함) / 99 보관함으로 사용자 확정되었고, 후속 디자인 정리 작업에서 실제 Penpot 반영·검수를 마쳤다. [현재 원본 링크·이동 검증](../design/page-organization/README.md)을 따른다. 작성 규칙 보드는 제거했으며 과거 [규칙 초안 기록](../design/authoring-rules/README.md)은 보관 자료다.

## 정책과 현재 구현의 구분

제품 차원의 언어·기기·접근성 목표는 Notion의 새 확정 절을 따른다. 현재 1152×648 창 크기 설정은 출시 목표 1280×720 이상을 검증한 결과가 아니다. 번역·중국어 및 일본어 글리프·화면 흔들림 옵션은 후속 검증이 필요하다. 기존 Cafe24 PRO UP 지정이 모든 언어의 글리프 지원을 보장하지 않는다.

이번 초기화는 SSOT 지정·문서·정책 연결만 수행한다. 새 화면·컴포넌트·폰트 대체·배치·옵션 UI는 만들지 않았다. 상세 접근성 표현과 언어별 화면은 `deferred-to-feature-planning`이며 Penpot에서 검수한다.

## Linked Sources

| Source | Owns | Not covered | Evidence paths |
| --- | --- | --- | --- |
| [Penpot](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650) | 디자인 SSOT·편집 원본 | 실제 게임 동작 검증 | design/README.md |
| [DESIGN.md](../DESIGN.md), [자료 안내](../design/README.md) | 원본 링크·적용 상태·이전 시안 | 독립 디자인 원본 | DESIGN.md, design/README.md |
| [적용본 안내](../design/drink-screen-references/applied/play-style/README.md) | 통합 화면 소스·실행 캡처 연결 | 미래 접근성·번역 화면 | src/features/drinks/drink_screen.gd, src/shared/ui/ |
| [글꼴 출처](../assets/fonts/Cafe24PROUP-SOURCE.md), [글꼴 안내](../assets/fonts/README.md) | 글꼴·라이선스 근거 | 전체 언어 지원 보장 | assets/fonts/, src/shared/ui/themes/play_theme.tres |
