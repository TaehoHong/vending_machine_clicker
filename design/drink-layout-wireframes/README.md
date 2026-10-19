# 중앙 자판기 + 선택 정보 카드 · 단순 배치도 · 2026-10-19

현재 게임 자판기 아트를 넣은 후속 [미리보기·정확한 비율의 편집 원본](game-machine-preview/README.md)을 추가했다. 게임 표시의 기본 크기 384×576, 2:3이며 Penpot Y=6400에서 확인할 수 있다. 아래 순수 배치도는 유지한다.

## 최신 A 수정 · 캔 배지 제거

사용자 요청으로 A의 음료 이름 아래 캔 비용 배지를 모두 제거했다. 음료 아래에는 이름만 남고 캔 필요 수량은 오른쪽 선택 카드의 추가 버튼에서만 보인다. 현재 [A PNG](a-right-card.png)·[A SVG](a-right-card.svg)가 최신이며 배치·오른쪽 카드 내용은 유지했다. 기존 배지 있는 A는 `archive/a-with-cost-badges.png`와 SVG로 보존했다. B/C는 이전 비교 기록이다.

Penpot 동일 페이지 Y=5400에 최신 A 원본을 추가했다. [Penpot 확인](penpot-a-no-badges.png), [Notion 수정 확인](notion-a-no-badges.png). PRODUCT.md·DESIGN.md에도 최신 규칙을 반영했다. 게임에는 미적용이다. 아래 미해금 배지 안내는 이전 비교 단계의 기록이다.

사용자는 이전 완성 이미지들을 미채택하고 중앙 자판기·근처의 작은 정보 카드·미해금에만 캔 배지·상단 능력 요약·단순 정보 카드 스타일 방향에 동의했다. 이번에는 완성 아트 대신 흑백 도형으로 배치만 비교한다. A/B/C 중 최종 선택은 아직 없으며 게임 코드는 변경하지 않았다.

| 배치 | PNG | 편집 원본 | 검토점 |
|---|---|---|---|
| A 오른쪽 카드 · 추천 | [PNG](a-right-card.png) | [SVG](a-right-card.svg) | 자판기를 가리지 않고 오른쪽 공간 활용. 미해금 선택 예시 |
| B 왼쪽 카드 | [PNG](b-left-card.png) | [SVG](b-left-card.svg) | 왼쪽 음료는 왼쪽에 카드 배치. 획득한 음료 선택 예시 |
| C 아래 카드 | [PNG](c-below-card.png) | [SVG](c-below-card.svg) | 카드 위치가 일정한 대신 자판기 크기가 작아지는 절충 |

권장 실제 동작은 A/B처럼 선택 위치와 화면 경계에 따라 카드가 가까운 빈 공간으로 이동하는 방식이다. 선택 전에는 카드가 없고, 해금한 음료는 획득량·개당/누적 효과, 미해금 음료는 능력·비용·추가 버튼만 보여준다. 전체 누적 능력은 상단 버튼으로 펼친다. 음료 이미지는 도형 자리표시, 연결선은 설명용이며 최종 게임 장식으로 확정하지 않는다. 수치·비용은 예시다.

결정적인 도형 배치를 직접 생성했다. [생성 소스](build.py), [편집용 전체 SVG](editable-gallery.svg). imagegen으로 생성한 완성 이미지가 아니다. 1200×760의 세 배치도이며 SVG 도형·텍스트를 직접 수정할 수 있다.

[Penpot 통합 시안 페이지](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe19a746796&layout=layers)의 X=-1528, Y=4400에 3종 편집 원본을 추가했다. [확인](penpot-synced.png). Notion에는 이전 기록 아래 최신 동의 방향을 추가했으며 기존 동일 크기 박스안을 미채택으로 명시했다. [Notion 확인](notion-synced.png). PRODUCT.md·DESIGN.md도 이 구분을 반영했다.
