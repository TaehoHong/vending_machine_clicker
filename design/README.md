# 기획·디자인 원본 안내

기획 SSOT는 [Notion 자판기 클릭커 게임](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de), 디자인 SSOT는 [Penpot](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650)이다. 로컬 문서는 원본을 대체하지 않는다. 작업 규칙은 [DESIGN.md](../DESIGN.md), 기획 요약은 [PRODUCT.md](../PRODUCT.md)를 따른다.

## Penpot 구성

파일 ID: `cd444aaf-0d8c-801b-8008-cda246e18650` · 팀 ID: `ce180602-f36b-8035-8008-cda23f0a1b46`.

| 페이지 | 내용 |
| --- | --- |
| [00 · 디자인 시스템](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers) | [팔레트·폰트](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=438228d3-7709-80fa-8008-d11fbc46be89), [공통 버튼](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=b1fb0fb9-8b3e-80e3-8008-d384ceb4bf36), [공통 패널·HUD](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=b1fb0fb9-8b3e-80e3-8008-d3862cdbb8e2) |
| [01 · 게임 화면](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers) | 채택 화면 29개의 배치·상태 · 에셋은 02 원본의 인스턴스 |
| [02 · 에셋](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers) | 모든 컴포넌트 원본의 SSOT · HUD(버튼·패널 포함), 자판기, 음료, 아트의 네 보드 |
| [99 · 보관함](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe00be50226&layout=layers) | 이전·미채택 시안. [이전 공통 UI 검토안](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe00be50226&layout=layers&board-id=80a74875-ea87-801d-8008-d12ac018eeb8) 포함 |

02의 이전 검토 보드 7개와 A로 대체된 구형 버튼 4개는 기존 99 보관함으로 이동했다. 현재 화면의 참조와 확정 원본은 유지한다. [이전 재화·가격판 검토 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe00be50226&layout=layers&board-id=cba4763b-9ae7-8052-8008-d2a633070914)은 보관 자료이며 현재 화면 디자인으로 사용하지 않는다.

컴포넌트 원본: [버튼](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=b1fb0fb9-8b3e-80e3-8008-d383e5fd8f92), [패널·HUD·LCD](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=b1fb0fb9-8b3e-80e3-8008-d3844c04d0ca). 00의 버튼·패널은 이 원본의 인스턴스 견본이다. 18개 베리언트 세트는 `State`로 전환한다. 원본 변경 전파·문구 오버라이드 보존을 검증했다. 이전 화면 4개와 교체된 구형 UI는 기존 99로 옮겼다.

## 적용 파일

| 자료 | 안내·파일 | 상태 |
| --- | --- | --- |
| HUD A 버튼 | [규격·ID](hud-buttons/README.md), `src/shared/ui/icons/hud_buttons/` | 01의 29개 화면과 기존 A 프레임 사용 중, 새 Play 배치는 게임 미적용 |
| 가격 LCD | [원본 안내](purchase-button/README.md) | 56×32, 초록 숫자만 표시하는 네이티브 Text |
| Play·음료와 능력 화면 | [적용본 안내](drink-screen-references/applied/play-style/README.md) | 기존 버전 적용, 이번 수정은 게임 미적용 |
| 재화 HUD·가격 LCD | [표시 규칙·이전 원본 안내](currency-hud/README.md) | 표시 규칙은 게임 적용, 새 원본은 02 공통 패널·HUD, 게임 미적용 |
| 음료·자판기 원본 | [음료 15종](v9/README.md), [자판기](v10/README.md) | 445×524 본체·진열 15종, 정렬·접지 그림자 적용 |
| 재화·수색 안내 | 02 HUD 보드 | Penpot 네이티브 원본, 게임 출력 교체는 별도 작업 |

## 채택 디자인 화면 · 2026-10-22

확정된 작은 HUD·내부 LCD·정렬한 진열·픽셀 장갑을 원본에 수정했다. 사용자의 디자인 파일 한정 지시에 따라 새 디자인은 게임 미적용이다. 기존 29개 보드 ID와 배치를 유지한다. 타이틀 3개를 제외한 26개 원본 화면의 공통 배경과 음료 선택 원본의 전면 자판기 7개를 연결했다. 아래 수치·문구는 디자인 검수 예시이며 새 기획 확정이 아니다.

| Y | 원본 보드·수 | 상태 |
| --- | --- | --- |
| 0 | [플레이 · 4개](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers&board-id=55aeaacb-aa46-80be-8008-cdca500ac9c3) | 기본, 첫 목표 보상 가능, 빈캔 목표, 목표 모두 완료 |
| 900 | [타이틀 · 3개](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers&board-id=51ff814c-57a3-802e-8008-d25b0cb9e685) | 저장 없음, 이어하기 가능, 백업 실패 |
| 1800 | [음료와 능력 · 4개](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers&board-id=51ff814c-57a3-802e-8008-d25b104b45d6) | 초기, 추가 가능, 빈캔 부족, 선행 조건 미충족 |
| 2700 | [음료와 능력 · 3개](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers&board-id=51ff814c-57a3-802e-8008-d25b1da5805d) | 획득 상세, 추가 완료, 능력 요약 |
| 3600 | [일시정지 · 4개](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers&board-id=51ff814c-57a3-802e-8008-d25b27e800e0) | 기본, 저장 완료, 저장 실패, 종료 저장 실패 |
| 4500 | [피버 · 4개](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers&board-id=51ff814c-57a3-802e-8008-d25b3502e170) | 수색 피버, 피버 수색 보상, 펀치 피버 타격, 피버 동시 활성 |
| 5400 | [플레이 피드백 · 3개](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers&board-id=51ff814c-57a3-802e-8008-d25b480ef9d9) | 수색 꽝, 고액 동전 획득, 구매 골드 부족 |
| 6300 | [구매 연출 · 4개](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers&board-id=51ff814c-57a3-802e-8008-d25b50a62c19) | 동전 투입, 음료 배출, 능력 버튼으로 이동, 능력 획득 알림 |

게임의 기존 구현은 이번 작업 직전 상태로 유지한다. 새 디자인을 적용할 대상은 기존 Play·DrinkScreen·공유 테마이며, 원본과의 차이를 구현 완료로 표시하지 않는다. Penpot 원본은 445×524 상품 제외 본체·진열 15종 조립과 네이티브 HUD다. [현재 상태](../DESIGN.md#현재-적용-상태--2026-10-22)를 따른다.

## MCP 원본 접근 복구 절차

현재 파일 ID를 대조하고 읽기·쓰기 결과를 확인한다. MCP가 연결되지 않으면 로그인된 Penpot을 Computer Use로 직접 편집한다. 접속값이 다른 경우 현재 계정의 기존 서버 연결을 확인하되 인증값을 문서·로그·저장소에 남기지 않는다. 저장 후 다시 열어 반영과 렌더링을 확인한다. 접근 실패·미검수는 [DESIGN.md](../DESIGN.md)에 대기 항목으로 기록한다.
