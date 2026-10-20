# HUD 버튼 · 디자인 시트 채택 · 2026-10-20

사용자의 “디자인 시트에 적용해” 승인에 따라 기존 Penpot 파일에 반영했다. 새 페이지는 만들지 않았다. 게임 화면·테마·동작 연결은 이번 범위에 포함하지 않는다.

## 편집 원본

- [00 · 02 / 버튼 · A 채택 · 메인 5종](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=d9c1a69c-6a27-809e-8008-d107e6137aa4): 지도·능력·강화·자동화·메뉴.
- [00 · 03 / 버튼 · A 채택 · 공통 조작·비용·메뉴](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=d9c1a69c-6a27-809e-8008-d107e619a122): 뒤로·닫기·이전·다음, 자판기·쓰레기통 탭, 골드·재료 비용, 계속하기·설정·타이틀.
- [02 · 에셋 · HUD A](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=d9c1a69c-6a27-809e-8008-d107e6329245): 14종 아이콘, 6크기 × 5상태 프레임, 연결된 버튼 견본 18개와 A 글꼴 견본.

실제 객체·컴포넌트 ID는 [penpot-manifest.json](penpot-manifest.json)에 기록했다. Computer Use로 편집했다. 새 UI 79개는 네이티브 Text와 연결된 프레임·아이콘으로 구성한다. 기존 `100 G` 기본 컴포넌트를 재사용해 16종 × 5상태를 제공하며, 금액·재료 부족 예시는 disabled 상태의 문구 오버라이드로 관리한다. 기존 가격 기본형의 글리프 윤곽선은 보존했다.

00의 [01 / 파운데이션 · A 채택](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=438228d3-7709-80fa-8008-d11fbc46be89)에서 승인 팔레트 24색·글꼴·크기를 확인한다. 현재 구현과 참고 자료는 [시스템 전체 안내](../current-game-system/README.md)의 90–99 보드로 구분했다. 에셋 시트의 제목·설명 위치도 실제 견본에 맞춰 갱신했다.

## 사용 규격

A 픽셀의 파란 면·굵은 외곽선·계단형 모서리·입체 밑면, Cafe24 PRO UP Regular를 사용한다. HUD 본체는 176×64, 아이콘은 32×32다. 프레임은 176×64 / 136×56 / 56×56 / 224×64 / 192×64 / 144×56의 6크기다. 출력 여백은 사방 6px이며 본체 크기와 파일 캔버스 크기를 구분한다.

상태는 normal(default)·hover·pressed·disabled·focus다. 호버 90ms, 눌림 60ms·아래 4px, 복귀 100ms를 시트에 표기했다. 실제 애니메이션 구현은 로컬 시안에서 확인할 수 있으며 Penpot은 상태별 원본이다. 비용은 금액·아이콘·수량만 표시한다. 모든 금액과 수량은 예시다.

게임용 분리 벡터는 [src/shared/ui/icons/hud_buttons/](../../src/shared/ui/icons/hud_buttons/)에 준비했으며 게임 화면에는 연결하지 않았다. 현재 Play 팔레트·테마를 교체한 작업이 아니다.

## 확인 자료와 이전 시안

- `penpot-main.png`, `penpot-common.png`, `penpot-assets.png`: 실제 Penpot 편집기의 저장·외형 검수.
- `01-hud.png`, `02-common.png`, `03-states.png`, `index.html`: 승인받은 이전 비교 시안과 입력 반응 확인용 자료. 이미지의 승인 전 표기는 제작 당시 상태다.
- `exports/`: 이전 검토용 18개 예시 × 5상태 SVG 90개. 부족 예시는 별도 마스터가 아니다.
- `build.js`, `font-outlines.swift`, `font-outlines.json`: 이전 시안 생성 소스. `build.js`는 승인 전 안내와 manifest를 재생성하므로 현재 등록 상태를 보존하지 않은 채 실행하지 않는다.

등록된 79개 마스터·44개 분리 원본과 중첩 참조, 네이티브 문구, 글꼴, 금액·재료 부족 견본을 확인했다. 모든 신규 SVG의 XML 파싱과 공백 검사를 수행했다. 게임 로직·화면을 바꾸지 않아 Godot 실행 검증은 하지 않았다.
