# 피버 HUD 에셋 · 2026-10-21

현재 게임의 상단 수색/펀치 피버 HUD를 편집 가능한 도형·네이티브 텍스트로 추출했다.
화면 전체 이미지나 타격 FX를 합친 에셋이 아니다. 게임 구현과 효과·밸런스는 변경하지 않았다.

## Penpot 원본

파일 ID `cd444aaf-0d8c-801b-8008-cda246e18650`를 대조했다.
00 디자인 시스템의 기존 **공통 패널·HUD** 보드 내부, 일시정지 패널 아래에 배치했다.
보드는 기존 콘텐츠를 보존하고 높이만 1250 → 1700으로 늘렸다.

| 에셋 | 원본 프레임 ID | 보드 상대 위치 | 내보내기 |
| --- | --- | --- | --- |
| [수색 피버 HUD](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=36bbde85-1d66-8082-8008-d2c3a47e5852) | `36bbde85-1d66-8082-8008-d2c3a47e5852` | 64, 1320 | [search_fever.svg](search_fever.svg), 388×84 |
| [펀치 피버 HUD](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=36bbde85-1d66-8082-8008-d2c3d5b0bd4e) | `36bbde85-1d66-8082-8008-d2c3d5b0bd4e` | 520, 1320 | [punch_fever.svg](punch_fever.svg), 388×84 |

두 에셋을 각각 독립된 재사용 컴포넌트로 등록했다.
프레임·제목·시간·게이지·배율 표시는 분리되어 있으며 글자는 Cafe24 PRO UP의 네이티브 Text다.

## 게임과의 대응

- `src/features/play/effects/search_fever.gd`: SEARCH FEVER, 주황 게이지, 남은 시간, GOLD x2.
- `src/features/play/effects/punch_fever.gd`: PUNCH FEVER, 붉은 프레임, 얇은 게이지, 남은 시간, GOLD x3.
- SVG는 가득 찬 상태의 정적 내보내기다. 10.0s/5.0s는 표시 예시이며 새로운 시간 규칙이 아니다.
- 게임의 동적 게이지·무늬 이동·화면 주변 FX는 기존 스크립트가 계속 그린다.
  이번 작업에서 런타임 SVG 연결이나 코드·테스트 수정은 하지 않았다.

## 검증

SVG의 XML 문법·388×84 치수·Text를 확인하고, Penpot에서 글꼴·시간·배율·게이지가
잘리지 않는지 검수했다. 페이지 새로고침 후에도 두 컴포넌트가 남아 있음을 확인했다.
게임 코드 변경이 없어 Godot 회귀 테스트는 실행 대상이 아니다. 게임 기능 적용으로 보고하지 않는다.
