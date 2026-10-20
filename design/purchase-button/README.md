# 구매 버튼 · 외형 재검토

## Penpot 등록 완료 · 가격 버튼 A

사용자의 버튼 추가 요청에 따라 MCP로 기존 **02 · 에셋 라이브러리**에 `UI 마스터 · 가격 버튼 A` 보드를 추가했다. 재사용 컴포넌트는 `Clicker/UI/Price/가격 버튼 · A · 100 G`다. 144×56 원본과 3배 확대, 글꼴 견본을 함께 정리했다. 외곽과 금액은 벡터 도형이다. 원본의 금액은 Cafe24 PRO UP Regular의 실제 글리프를 윤곽선으로 변환해 작은 크기의 Penpot PNG 내보내기에서 대체 글꼴로 바뀌는 현상을 피했다. 액션 문구는 넣지 않았다.

글꼴은 Penpot의 사용자 글꼴 목록에서 확인한 Cafe24 PRO UP을 적용했고, `Clicker/UI/Pixel/Price · Cafe24 PRO UP · 28` 텍스트 스타일로 등록했다. 원본 글꼴과 배포 안내는 `ui/fonts/`에 함께 보존한다. 등록 ID와 검수 상태는 `penpot-manifest.json`에 기록한다.

`price-only-v3.svg`의 텍스트 원본과 `price-outline.json`, `price-label-outlined.svg`를 함께 보존한다. `register.penpot.js`는 중복 등록을 막는 생성 소스이고, `finish.penpot.js`는 확대본 크기·글꼴 적용, `apply-outlined-amount.penpot.js`는 원본 금액 윤곽선 적용, `verify.penpot.js`는 등록 확인용이다. Penpot의 실제 검수 이미지는 `penpot-board.png`, `price-button-penpot.png`다.

[Penpot 가격 버튼 보드](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=af2aed71-3cfe-80ea-8008-ceaf7492d553&board-id=8e4548c6-4cd1-8076-8008-ceef6ba14bff&layout=layers)

## 현재 · 투입구와 가격 버튼 배치 시안 03

사용자가 1번(A · 픽셀 아케이드) 스타일과 금액만 표시하는 버튼을 선택했다. 자판기 투입구와 함께 놓인 모습을 먼저 검토한다.

- `placement-v3.svg` / `placement-v3.png`: 자판기 전체 배치와 결제부 확대. 기존 B PNG를 그대로 참조하고 가격 UI만 별도로 얹었다.
- `placement-v3.json`: 배치·스타일·승인 상태. 144×56 가격 버튼과 3배 확대다.
- `price-only-v3.svg`: `100 G`만 표시하는 독립 픽셀 가격 버튼.
- `build-context.js`: 현재 `index.html`과 배치 시안을 생성한다.
- `browser-proof-v3.png`: 실제 브라우저 글꼴로 검수한 시안.

1번의 파랑·굵은 먹선·계단 모서리·입체 밑면을 유지한다. 버튼에 액션 문구를 넣지 않는다. 골드 값은 예시이며 실제 구매와 연결되지 않는다. 기존 B 이미지와 그 안의 진열물은 위치 참고용 원본으로 보존하며, 이번 작업에서 음료 15종의 확정 외형을 변경하지 않는다.

Penpot은 MCP로만 접근한다. 사용자의 후속 추가 요청에 따라 위 가격 버튼만 기존 02 에셋 페이지에 등록했다. 자판기 배치 이미지는 검토 기록으로 보존한다.

## 보존 · 외형 비교 시안 02

2026-10-18 사용자 피드백: 기존 금속·녹색 상태등 방향은 게임 버튼처럼 보이지 않아 불채택했다. 기존 5개는 같은 외형의 상태 비교였으며, 새 시안은 외형이 서로 다른 3개 방향이다.

- `directions-v2.png` / `directions-v2.svg`: 픽셀 아케이드·카툰 팝·레트로 자판기의 기본·눌림 비교.
- `browser-proof-v2.png`: 실제 브라우저 글꼴로 확인한 현재 시안. PNG 변환기의 대체 글꼴과 차이가 있어 이 브라우저 이미지를 외형 검수 기준으로 사용한다.
- `concepts-v2/`: 세 방향의 기본·눌림 SVG 6개.
- 외형 비교 3종의 HTML은 `build-directions.js`로 재생성할 수 있다. 현재 `index.html`은 위 배치 시안 03이다.
- `build-directions.js`: 새 시안 생성 소스. 사용 중인 시스템 글꼴 Cafe24 PRO UP·배달의민족 주아·Pretendard를 참조한다.

실제 [Click the Button](https://store.steampowered.com/app/3946950/Click_the_Button/)과 [Balatro](https://store.steampowered.com/app/2379780/Balatro/)의 Steam 스크린샷을 브라우저에서 직접 확인했다. 게임 조작부의 강한 명암·두께·큰 글자를 참고하되 아트워크나 로고를 재사용하지 않았다. 가격은 100 G 예시이며 실제 구매와 연결되지 않는다.

이번 단계는 외형 승인 전 비교다. Penpot에는 반영하지 않았으며, 승인 후 기존 **02 · 에셋 라이브러리** 안에서 작업한다.

브라우저에서 A 마우스 클릭, B Space, C Enter 조작을 확인했다. 세 버튼의 눌림 이동은 각각 6·8·6px이며 키보드 포커스와 모션 줄이기를 지원한다. 이 결과는 로컬 컴포넌트 시안의 조작 검증이다.

## 불채택된 시안 01 보존

2026-10-18 사용자 승인 대기 시안. 구매 버튼의 기본·호버·눌림·골드 부족·구매 중 5개 상태를 비교한다. 게임 화면과 게임 코드 적용은 포함하지 않는다.

- `states.png`: 5개 상태 전체 확인 이미지.
- `states.svg`: 동일한 전체 벡터 확인 이미지.
- `states/`: 312×88 개별 SVG 5개. 가격·동작·외장·버튼 면을 그룹으로 구분했다.
- `build.js`: 이전 5상태 시안 생성 소스. 실행하면 현재 `index.html`을 이전 시안으로 덮으므로 새 시안은 `build-directions.js`로 생성한다.

금속 외곽 프레임, 짙은 녹색 버튼 면, 얕은 눌림, 작은 점등부를 사용한다. 가격은 상태가 바뀌어도 같은 위치에 유지한다. 부족 상태는 색상과 문구로 구분하며 가격을 숨기지 않는다. 버튼 입력 영역은 고정하고 눌리는 면만 2px 이동한다.

호버 120ms, 눌림 70ms, 복귀 110ms, 투입 표시 600ms 반복을 제안한다. 모션 줄이기에서는 전환과 반복 점등을 멈춘다. HTML의 100 G·보유 160/60 G·720ms 구매 중 연출은 예시이며 실제 재화·효과·결과와 연결되지 않는다.

승인 후 기존 Penpot **02 · 에셋 라이브러리**(`af2aed71-3cfe-80ea-8008-ceaf7492d553`) 안에 편집 가능한 컴포넌트로 정리한다. 새 페이지를 만들지 않는다.
