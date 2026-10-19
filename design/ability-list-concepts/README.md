# 능력 목록 창 비교 시안 · 미채택 · 2026-10-19

대상은 왼쪽 아래 **능력** 버튼을 눌렀을 때 나오는 목록 창이다. 획득 직후 상단 알림이나 음료수 추가 창은 대상이 아니다. 게임 코드·능력 규칙은 변경하지 않았다.

| 방향 | AI 시각 레퍼런스 | 편집용 레이아웃 | 특징 |
|---|---|---|---|
| A 카드형 도감 | [a-collection.png](a-collection.png) | [a-layout.svg](a-layout.svg) | 여러 음료의 획득량·효과를 동시에 비교 |
| B 목록 + 상세형 | [b-details.png](b-details.png) | [b-layout.svg](b-layout.svg) | 선택 음료의 개당 효과와 누적 효과를 분리. 추천 |
| C 자판기 진열장형 | [c-showcase.png](c-showcase.png) | [c-layout.svg](c-layout.svg) | 게임의 자판기 분위기와 수집 감각 강조 |

- PNG는 AI 생성 시각 레퍼런스다. SVG는 패널·텍스트를 수정할 수 있는 별도 레이아웃 원본이며 PNG의 픽셀 단위 재현본은 아니다.
- 생성 프롬프트: [prompts.json](prompts.json). SVG 생성 소스: [build_sources.py](build_sources.py). 비교 원본: [editable-gallery.svg](editable-gallery.svg).
- 수치·효과 문구는 배치 예시이며 확정 밸런스로 사용하지 않는다. 실제 적용 때 PRODUCT.md와 게임 데이터를 연결한다. A 이미지의 ‘보유’는 구현 시 누적 획득량을 뜻하는 ‘획득’으로 정리한다.
- 해금된 음료가 늘어나면 스크롤로 15종을 수용한다. 아직 사용자 채택 전인 디자인 제안이다.
- [Penpot 05 · 능력 창 · 비교 시안](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe00be50226&layout=layers)에 세 가지 편집용 레이아웃을 추가했다. [화면 확인](penpot-synced.png).
- Penpot SVG 붙여넣기에서 내장 음료 이미지가 표시되지 않는 부분이 있다. 음료 아트가 포함된 완성 분위기는 PNG를 기준으로 비교한다. 네이티브 패널·텍스트는 반영되었고, 음료 이미지까지 동일한 원본 동기화는 미완료다.
- 새로운 기획 확정이 없으므로 PRODUCT.md와 Notion의 확정 규칙은 변경하지 않았다.
