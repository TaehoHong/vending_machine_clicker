# Play 픽셀 스타일 통일 · 현재 게임 적용본 · 2026-10-19

- Play 왼쪽 아래 음료수 추가 버튼을 제거하고 능력 버튼 하나로 통합 화면을 연다.
- 빈캔 개수는 왼쪽 위 제목 아래 HUD로 표시한다. 능력 요약·ESC 닫기 버튼은 실제 Play `ability_*.tres`, 음료 정보·요약 패널은 `quest_style.tres`, 추가 버튼은 `quest_claim_*.tres`를 공유한다.
- 자판기 원본 384×576, 2:3 비율·클릭 전용 정보·재진입 초기화·연결선 제거를 유지한다. 능력·해금 비용·저장·가격 증가 규칙은 바꾸지 않았다.

## 실제 실행 캡처

[Play 화면](play.png) · [초기 상태](initial.png) · [미해금 음료 선택](locked-selected.png) · [획득 음료 선택](acquired-selected.png) · [능력 요약](summary.png)

## 편집 원본과 동기화

[초기 SVG](initial.svg) · [선택 SVG](locked-selected.svg) · [전체 상태 SVG](editable-states.svg) · [생성 소스](build_sources.py). 패널·버튼·문구는 편집 가능한 벡터이며 배경·자판기는 원본 이미지다. Godot 실제 캡처가 엔진의 nine-patch 렌더링 기준이다.

[Penpot 통합 페이지](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe19a746796&layout=layers) Y=9400에 두 상태를 추가했다. 중복 내장 이미지 누락은 선택 SVG를 별도 가져와 보완했다. [Penpot 확인](penpot-synced.png).

[Notion 기획 문서](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de)의 최신 디자인 기록을 Play 스타일 통일 적용 완료로 갱신했다. [Notion 확인](notion-synced.png). PRODUCT.md·DESIGN.md·design/README.md 동기화 완료. 이전 Y=8400 원본은 과거 시안이다.

## 검증

`tests/drink_screen_test.gd`: 실제 능력 버튼 클릭 진입, 음료수 추가 버튼 제거, 공유 픽셀 스타일, 호버 무반응, 클릭 선택·재진입 초기화, 선행 조건, 빈캔 5개 정확 차감·중복 해금 방지, 획득량·누적 능력, 요약·ESC·창 크기 대응을 확인했다. 실제 D3D12 실행과 headless 실행 모두 통과했다.
