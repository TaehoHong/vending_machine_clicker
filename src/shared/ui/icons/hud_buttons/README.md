# HUD A 분리 벡터

2026-10-20 승인된 HUD 버튼의 프레임·아이콘 출력 조각이다. 편집 원본과 실제 컴포넌트 ID는 [디자인 안내](../../../../../design/hud-buttons/README.md), [Penpot 등록 목록](../../../../../design/hud-buttons/penpot-manifest.json)을 따른다.

- `frames/`: 본체 6크기 × normal / hover / pressed / disabled / focus = 30개. 사방 6px 여백을 포함한다.
- `icons/`: 32×32 벡터 14개. 문구·프레임과 분리해서 사용한다.
- 문구는 게임의 `assets/fonts/Cafe24PROUP.ttf`로 표시하며 프레임 파일에 구워 넣지 않는다.

승인 시안의 벡터를 분리하고 같은 도형을 Penpot 네이티브 원본으로 등록했다. 현재 타이틀·Play·음료와 능력·일시정지에서 `src/shared/ui/themes/play_theme.tres`와 `src/shared/ui/pixel_button.gd`를 통해 재사용한다. 기존 6크기 전체를 런타임 변형으로 만들지 않고 현재 쓰는 크기·상태만 연결한다.
