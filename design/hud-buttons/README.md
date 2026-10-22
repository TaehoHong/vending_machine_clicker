# HUD A 버튼

디자인 시트와 Penpot 01의 29개 게임 화면에 연결했다. 현재 타이틀·Play·음료와 능력·일시정지에 연결했다. 공유 외형은 `src/shared/ui/themes/play_theme.tres`, Button의 상태 피드백은 `src/shared/ui/pixel_button.gd`가 소유한다. 전체 원본 위치는 [design/README.md](../README.md)를 따른다.

- [공통 버튼 마스터](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=b1fb0fb9-8b3e-80e3-8008-d383e5fd8f92): 현재 화면에서 사용하는 버튼 8세트 39상태. 가격 LCD·목표 진행은 같은 02 HUD의 패널 보드에 각각 5상태로 관리한다. 상태는 네이티브 베리언트의 `State`로 전환한다.
- 기본 Play 디자인 원본은 54.4×54.4 능력·메뉴 아이콘 버튼, 124.8×54.4 목표 진행 버튼을 사용한다. 재화 24px, 목표 진행 22.4px(게임 22px), 가격 LCD 19px를 02 원본에 반영했다. 00은 연결된 인스턴스 견본이다. 새 Play 디자인은 게임 미적용이며 기존 다른 화면의 넓은 A 버튼은 유지한다.
- [팔레트·글꼴](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=438228d3-7709-80fa-8008-d11fbc46be89): 기존 팔레트와 가격 LCD 초록 `#C0E58C`, Cafe24 PRO UP Regular. 메인 문구 28px·공통 문구 28/24px, 문구 외곽 2.2px.
- [프레임·아이콘 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=d9c1a69c-6a27-809e-8008-d107e6329245): 아이콘 7종과 프레임 21종. 중복 연결 견본 18개는 제거했으며 조립 견본은 00에서만 확인한다. 가격 기본형을 포함한 문구는 네이티브 Text다.
- 프레임 본체: 136×56(현재 기본형만 사용) / 56×56 / 224×64 / 192×64 / 144×56. 출력 여백은 사방 6px다.
- 상태: normal·hover·pressed·disabled·focus. 호버 90ms, 눌림 60ms·아래 4px, 복귀 100ms. 금액·수량은 예시다.

게임용 SVG는 `src/shared/ui/icons/hud_buttons/`에 있다. 실제 객체·컴포넌트 ID는 [penpot-manifest.json](penpot-manifest.json)을 따른다. 미사용 지도·강화·자동화·뒤로·이전·다음·자판기 탭·회수함 탭과 전용 부품은 기존 99 보관함으로 옮겼다. 같은 마스터를 다시 등록하거나 예전 생성 스크립트로 현재 원본을 덮어쓰지 않는다.
