# 디자인 원본

디자인 SSOT는 [Penpot](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650), 기획 SSOT는 [Notion](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de)이다. 편집·검수는 [DESIGN.md](../DESIGN.md)를 따른다.

자동 자판기 외형은 [04 · 자동 자판기 시안 · 5종 비교](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=cebe859c-7117-8010-8008-e9a2930b4d75&board-id=c8bc558b-a83e-8050-8008-e9a392a99d97)에서 검토한다. 비교 보드·개별 확대 보드는 편집 가능한 네이티브 텍스트·도형과 교체 가능한 PNG로 구성한다. 채택 전 제안이며 [레퍼런스·생성 자료](auto-vending-concepts/README.md)를 함께 확인한다.

화면에는 조작·비용·효과·오류 복구에 필요한 안내만 남긴다. 캔버스의 퀘스트·시설 메모는 편집·시연 주의사항으로 제한하고, 상세 기획과 작업 이력을 중복 기재하지 않는다.

[게임 화면·애니메이션 재생](https://design.penpot.app/#/view?file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&section=interactions&index=3)에서 상단 화면 목록이나 플로우를 선택해 확인한다.

HUD 정렬은 기본 게임 영역의 보이는 가장자리·버튼 사이 간격 16px, 정사각 조작 프레임 외곽 44.8px, 아이콘 높이 24px를 적용한다. [공통 HUD 원본](hud-buttons/README.md)과 퀘스트 상시 진행 HUD를 사용하며 화면 크기에 맞춰 내부 그림·상태 프레임·입력 영역을 함께 확대한다.

일반 자판기의 표면·진열실 빛은 02의 [상품 제외 본체](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&board-id=bc6ae191-dc09-8041-8008-cf0ba90d335e), 접지는 [공통 선반 그림자](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&board-id=57cf90e6-1346-80ff-8008-d2e6269a39c0)에서 편집한다. 조작부 덮개는 같은 원화의 빨간 면을 마스크로 자르며, 조립 원본과 화면 인스턴스의 음료·슬롯 위치는 유지한다. 게임 적용 PNG와 아틀라스 구역은 [공유 소유자 안내](../docs/07-codebase-guide.md#공유-소유자정규-예시)를 따른다.

퀘스트는 02의 [상시 진행 HUD](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&board-id=790bd3fd-c08b-804e-8008-dc86331ca4af&layout=layers)와 [공통 행](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&board-id=280ac456-7a93-8056-8008-df7b5ff31a45&layout=layers)에서 편집한다. 크기를 바꿀 때는 컨테이너·그림·글자·받기 입력 영역을 함께 조정한다.

재화는 02의 [골드](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&board-id=57cf90e6-1346-80ff-8008-d2e7c0912fc5)·[빈캔](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&board-id=57cf90e6-1346-80ff-8008-d2e7c092588e) 공통 원본을 사용한다. HUD·비용·퀘스트·보상·투입에서 같은 그림과 비율을 재사용하고 금액별 코인은 색상만 바꾼다. 게임용 내보내기는 `src/shared/ui/icons/coin_*.svg`, `can_icon.svg`이며 연결 소유자는 [코드 안내](../docs/07-codebase-guide.md)에서 확인한다.

수색 클릭 영역은 [수색 시작 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=b1fb0fb9-8b3e-80e3-8008-d39cd4a94a32)의 투명 클릭 도형에서 편집한다. 투명 여백을 제외한 자판기 높이의 하단 2%부터 기존 바닥 영역까지 포함하며, 이어지는 수색 상태도 같은 경계를 사용한다.

[시설 구매 동선](https://design.penpot.app/#/view?file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&section=interactions&frame-id=794452ab-8261-80e1-8008-dbc02d6bcd4a&zoom=fit)은 메인 하단의 시설 아이콘에서 시작한다. 현재 편집 원본은 [시설 구매창](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&layout=layers&page-id=78528b83-c102-8057-8008-cec032c8f181&board-id=ab3ae66f-886e-80f5-8008-dbae482dc81b), [자동 자판기 강화](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&layout=layers&page-id=78528b83-c102-8057-8008-cec032c8f181&board-id=ab3ae66f-886e-80f5-8008-dbae482dc87c), [쓰레기통 강화](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&layout=layers&page-id=78528b83-c102-8057-8008-cec032c8f181&board-id=ab3ae66f-886e-80f5-8008-dbae482e09e1)이며 02 에셋 페이지의 공통 컴포넌트를 수정한다. 01 게임 화면의 ‘채택 / 시설 v2’ 보드들은 이 원본에 연결된 인스턴스다.

시설은 빈캔 10/15개로 한 번에 구매·설치한다. 미보유 행은 비활성 외형, 구매 버튼은 빈캔 아이콘·수량, 보유 버튼은 ‘업그레이드’로 구분한다. 강화 상세에는 현재 성능·다음 성능·단계·골드 비용을 표시하고 부족·최대 상태를 같은 원본에서 관리한다. 수집량이 현재 드롭 개수 이상일 때는 수집량 증가에 효과가 없다는 조건을 표시한다. 구매·각 시설 보유·모두 보유·강화·강화 직후·재화 부족·최대 상태는 01의 같은 시설 v2 구역에서 확인한다. 시설 관리·보상 카드 보드는 미채택이며 설치 본체 클릭에는 동작을 연결하지 않는다. 골드는 튀어오른 뒤 금액과 함께 선명하게 대기하고 페이드 후 자동 수령하며 빈캔은 별도 직접 수령한다. 시설·음료 창은 생산물과 행인보다 앞에 표시한다.

시설 골드의 편집 가능한 키프레임은 01의 [생산·수령 대기](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=280ac456-7a93-8056-8008-de3a77615c1d), [튀어오름 정점](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=280ac456-7a93-8056-8008-de3a7c1f7573), [선명한 대기](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=cebe859c-7117-8010-8008-e9a313710a0d), [자동 수령 완료](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=280ac456-7a93-8056-8008-de3a7facd881)에 둔다. 기존 연결 골드 아이콘을 사용하고 완료 시 아이콘을 숨긴다. [보기 모드](https://design.penpot.app/?screen=viewer&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&section=interactions&frame-id=280ac456-7a93-8056-8008-de3a77615c1d)는 상승·하강·1.2초 선명한 대기·0.3초 페이드 후 수령을 자동 연결한다. 키프레임 사이의 부드러운 이동·페이드는 실제 게임에서 검수한다.

배치 시안: [자동 자판기·쓰레기통 설치 후 플레이 · 위치 검토](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers&board-id=50762640-c848-806c-8008-d8c7ba42a837) · [쓰레기통 아트 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=eb1d83d1-2566-809d-8008-d4480ac50cd6).

손님 연출: [그림체 기준 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=50762640-c848-806c-8008-d8e0c440ce7a) · [게임 배치·이용 순서 재생](https://design.penpot.app/#/view?file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&section=interactions&frame-id=50762640-c848-806c-8008-d8e04c9ed4d4&index=50&zoom=fit) · [파츠 조합 견본](https://design.penpot.app/#/view?file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&section=interactions&frame-id=80be7183-7452-802a-8008-d900d5b9d83b&zoom=fit) · [공통 동작 재생](https://design.penpot.app/#/view?file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&section=interactions&frame-id=80be7183-7452-802a-8008-d90438955353&zoom=fit) · [모듈 파츠 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=46a0cf04-8550-8023-8008-d8f3ba983b7e).

[손님 접합부·크기·호흡 수정 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=3a3dd3bc-800b-8093-8008-da4da209e847)에서 원본 보행 6포즈의 연결된 상체·팔/하체·신발과 외형 조합별 대기·조작·줍기 파츠를 편집한다. 전신 크기를 맞추고 첫 숙임부터 음료를 표시한다. 정지 후 전환·조작 호흡은 검수 뒤 승인된 0.36초 정지·0.36초 후면 대기와 4px·2.4초 주기를 따른다.

| 원본 | 용도 |
| --- | --- |
| [00 · 디자인 시스템](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers) | 공유 색상·폰트와 인스턴스 견본 |
| [01 · 게임 화면](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers) | 채택 화면·상태·배치 |
| [02 · 에셋](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers) | 에셋·컴포넌트 원본 · [음료 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=6d00bd1a-d292-8094-8008-d0f9484645ce) · [자판기 조립 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=bc6ae191-dc09-8041-8008-cf0ab4c1d40c) · [자동 자판기 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=a4035161-685a-8060-8008-d637682be43a) |
| [99 · 보관함](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=6587dfe1-cdcc-8063-8008-cfe00be50226&layout=layers) | 이전·미채택 원본 |

[음료 상세 · 순서 없는 해금 견본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers&board-id=51ff814c-57a3-802e-8008-d25b1a13d887)은 선행 음료 안내 없이 빈캔 비용만 표시하는 상태의 원본이다.

음료 상세의 채택 상태는 같은 효과·상태 영역을 사용한다. 효과 문구는 의미 단위로 줄을 나누고 아래 상태 안내와 분리한다. 위 콜라 견본과 [획득 상태](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=51ff814c-57a3-802e-8008-d25b1da5805d)에서 긴 본문의 줄바꿈·간격을 편집한다.

[연속 구매 · 겹친 동전 투입](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers&board-id=b1fb0fb9-8b3e-80e3-8008-d3a32c9d22c7)은 연출 중 정상 입력과 두 동전을 유지하는 편집 원본이다. [겹친 음료 배출](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&layout=layers&board-id=51ff814c-57a3-802e-8008-d25b5355961f)도 같은 페이지에서 편집한다.

[귀·호흡·파지 보완 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=f128a085-12ce-8061-8008-da6496c95969)은 기본 손님의 조작 피부·귀 추출 파츠, 호흡 전후 견본, 원본의 음료 쥔 수령 자세를 담는다. 보행·외형 공통 파츠는 위 원본을 유지하고 보완 파츠를 함께 사용한다. 사용자가 이 보완 미리보기의 게임 적용을 승인했다.

[손님 4종 승인 동작 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=78528b83-c102-8057-8008-cec032c8f181&layout=layers&board-id=f128a085-12ce-8061-8008-da762abc6bce)은 기본 01과 추가 02·03·08의 연결된 상체·하체 파츠, 보행·정지·조작·줍기·수령·퇴장 견본을 담는다. 팔꿈치·무릎 분할 회전 없이 그림을 교체하며, 호흡은 공유 정점 메시로 상체를 변형하고 발을 고정한다. 기본 6보행은 기존 승인 원본을 유지한다.

음료 구매의 [획득 단계](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=51ff814c-57a3-802e-8008-d25b59048df7)와 [능력 버튼 강조 복귀 단계](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=b1fb0fb9-8b3e-80e3-8008-d3a32e8c5197)는 상단 획득 배너를 사용하지 않는다. 황금 음료에도 같은 기준을 적용하며 골드 부족 안내와 능력 버튼 강조는 유지한다.

[구매하지 않는 행인 통과](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=f6962d3e-df95-808a-8008-dc89cf2e13a7)는 01 게임 화면의 편집 가능한 이동 견본이다. 왼쪽·오른쪽 진입 → 자판기 통과 → 반대편 퇴장을 걷는 속도에 맞춘 시간으로 번갈아 재생하며 자판기 앞에서도 멈춤·조작·수령을 넣지 않는다. 구매 손님도 같은 보행·수령 원본과 반대편 퇴장을 사용하며, 구매 손님 원본의 저장 확인은 아래 대기 항목을 따른다. 기존 4종 외형과 빈손 보행은 `customer_animation.gd`·`customer_frames.tres`를 재사용하고, 별도 등장·퇴장은 `src/features/facilities/effects/customer_flow.gd`가 담당한다. 구매 손님의 생산 연동과 보상은 유지한다.

## 퀘스트 UI

[순차 진행·보상 수령 시연](https://design.penpot.app/#/view?file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&section=interactions&frame-id=790bd3fd-c08b-804e-8008-dc86c6a2af83&zoom=fit)에서 동전 진행 → 동전 받기 → 빈캔 진행 → 빈캔 받기 → HUD 숨김을 확인한다. [동전 보상 가능 화면](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=790bd3fd-c08b-804e-8008-dc86ccd331b6&layout=layers)은 같은 공통 HUD의 연결 인스턴스다. 진행 화면의 자동 전환은 시연용이며 실제 게임은 누적 진행과 수동 수령을 따른다.

우측 상단의 304×44 한 줄에 현재 퀘스트 한 개만 표시한다. 공통 코인·빈캔 아이콘, 짧은 목표명, 현재/목표를 묶고 달성 후 ‘받기’를 표시한다. 동전 → 빈캔 순서로 수령 후 다음 미수령 목표로 교체하며 모두 수령하면 HUD를 숨긴다. 메모지 열기 버튼·목록창·배경 음영·퀘스트 모달은 사용하지 않는다. 기존 크림 패널·픽셀 버튼·공유 글자 스타일을 재사용하며 글자는 네이티브 Text로 유지한다. 게임 적용은 `src/features/quests/hud_design.tscn`·`hud_row_design.tscn`과 `quest_hud.gd`를 따른다. 목표·보상 수치는 기존 구현의 임시 견본이다.

중앙 상단 퀘스트 달성 카드는 제거한다. 이전 카드 원본·사용 인스턴스는 숨기고 관련 시연은 [중앙 알림 없는 보상 가능 화면](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=f9a292a6-d0a9-8009-8008-dca1ee034db6&layout=layers)으로 변경한다. 기존 골드 폭발 → 바닥 낙하·대기 → 골드 HUD 흡입은 유지하며 상시 HUD와 연출은 배경 수색·구매·피버를 차단하지 않는다.

시설 보상 연출은 손님 발밑을 기준으로 한다. 골드는 기존 수색 동전 아트와 금액 표기로 튀어오르며 각 생산분만 자동 수령한다. 빈캔은 발밑 높이의 바닥에 떨어져 한 번 튄 뒤 옆으로 굴러 누우며 직접 클릭해 수령한다. 바닥 빈캔은 그림·클릭 영역을 2배로 확대하고 호버·누름 반응과 간헐적인 픽셀 반짝임을 표시한다. 착지 후 그림만 잔잔하게 부유하며 클릭 영역은 고정한다. 모션 감소 시 같은 2배 착지 상태와 밝기 반응을 유지하고 부유·반복 반짝임·호버 크기 변화는 끈다. [부유·상호작용 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=cebe859c-7117-8010-8008-e9a41a108d65)은 기존 Currency 연결 인스턴스로 작성하며 상승·정점·하강·호버·누름·모션 감소·수령 완료를 포함한다. 원본의 단계별 재생과 게임의 연속 보간을 구분한다. 일시정지·모달 입력 차단·15초 소멸·쓰레기통 자동 수집 규칙을 유지한다.

## 음료 선택·관리 UI 통일

2026-11-06 사용자가 시안 적용과 UI 통일 구현을 승인했다. [채택 음료 시안](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=55aeaacb-aa46-80be-8008-cdca4fa29ef0&board-id=0411243f-ff8c-8001-8008-e6ee0a6746a4)에서 선택과 자물쇠의 독립 표시, 400×430 상세 패널, 의미→확률 행→조건 배치를 편집한다. 이전 상세 상태 견본의 좁은 배치는 새 기준으로 사용하지 않는다. 게임은 `src/features/drinks/drink_screen.gd`와 `src/data/drink_catalog.gd`를 사용한다.

시설·설정·일시정지는 기존 청색 패널과 버튼을 유지하고 Noto 본문18/보조16 및 같은 역할의 정렬을 통일했다. 원본은 기존 01 설정·일시정지와 02의 시설 구매·자동/쓰레기통 강화 컴포넌트다. 게임은 기존 `src/features/{facilities,settings,pause}/*_design.tscn`과 공유 `src/shared/ui/themes/play_theme.tres`의 MenuPanel/MenuBody/MenuCaption을 사용한다. 새 테마나 런타임 에셋 복사본은 만들지 않았다.

Penpot의 이전 부분 시안이 존재함을 확인하여 새 화면을 중복 생성하지 않고 수정했다. 음료 상세 그림40×60·상태·선택, 설정/일시정지19개·시설46개 텍스트 스타일, 설정/일시정지24개·시설11개 정렬/외곽선 변경의 편집 응답을 받았다. Chrome 새로고침·MCP 재연결 후 채택 보드 이름·상세 그림 크기·상태 문구·음량18·시설 단계16/다음 값18과 좌표를 재조회해 저장을 확인했다. 음료 및 시설 원본을 내보내 검수했다. 다만 원본의 자판기 표면은 아래 11월5일 미동기화 항목을 계속 따른다. 이 작업의 UI 저장 확인을 자판기 원화 전체 동기화 완료로 확대하지 않는다.

## 모션 비교 시안

[현재·개선안 비교 재생](https://design.penpot.app/#/view?file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=fd623fec-3fc4-8008-8008-e6ff661fcc7b&section=interactions&frame-id=fd623fec-3fc4-8008-8008-e70129738f41&zoom=fit) · [편집 가능한 원본](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=fd623fec-3fc4-8008-8008-e6ff661fcc7b&board-id=fd623fec-3fc4-8008-8008-e70129738f41).

2026-11-06 요청한1·2·4번(음료 구매·펀치·동전/빈캔)의 검토 원본이다. `03 · 모션 비교 · 2026-11-06` 페이지의 시작 안내에서 항목을 고른 뒤 ‘비교 재생’을 누르면 왼쪽 비교 기준과 오른쪽 대안이 함께 재생된다. 1번은 오른쪽을 채택해 게임에 적용했고 왼쪽은 변경 전 비교 기준이다. 2번은 기존 유지다. 4번은 재시안의 오른쪽 모션을 채택해 일반 수색 코인과 시설 빈캔에 적용했다. 1·2번은 ‘처음으로’, 4번은 ‘멈춤’으로 시작 화면에 돌아가며 ‘비교 목록’으로 항목을 바꾼다. 기존 채택 화면과 분리된 검토 페이지이며 새 에셋 마스터는 만들지 않았다.

- 음료 구매:40개 표본, 총2.34초. 변경 전의 크기 확대·튐·높은 궤적·한 바퀴 회전·잔상을 기준으로 개선안의 배출·확인·낮은 흡수 궤적을 비교한다.
- 펀치:31개 표본,100ms 간격5회,0.60초 구간을4배 느리게 보여준다. 같은 입력 방향으로 원위치 재시작과 이어지는 반동을 비교한다.
- 수색 동전·빈캔 채택 모션:각20개 핵심 시점으로1.20초 구간을 비교한다. 위쪽은 양쪽 모두2.5배, 아래쪽은 원래 크기다. 양쪽의 경과 시간은 같으며 마지막에서0.9초 쉰 뒤 반복한다. ‘멈춤’은 시작 화면으로 돌아간다. 동전은 낮은 상승 뒤 큰 튐→작은 튐→감속→멈춤을 거쳐1.20초에 소멸한다. 빈캔은 기존의 추가 한 바퀴 회전 대신 짧게 튀며 옆으로 넘어지고 두 번 흔들린 뒤0.84초에 바닥에 정착한다. 기존 쪽의 동작·소멸 시간은 바꾸지 않았다.
- 손님 동작의 의도적인 끊김은 사용자가 허용했다. 해당 동작은 개선안에 포함하지 않는다.

왼쪽 비교 기준은 시안 작성 당시 `coin_insert_fx.gd`·`drink_dispense_fx.gd`·Play의 펀치/수색 동전·facility_world의 빈캔 연출에서 주요 시간·이동·회전을 재현한다. Penpot의 기존 음료·자판기·Currency 연결 인스턴스를 재사용하고, 랜덤값은 비교용으로 고정했다. 게임 녹화나 엔진 재생을 대체하지 않으며 키프레임 사이 보간·음향·전체 장면의 동시 효과는 검수 범위 밖이다. 오른쪽의1·4번을 채택했다. 2번 오른쪽은 미채택 시안이다. 일반 수색 코인은 기존 좌우 방향과45~90px 무작위 거리를 전체 궤적에 비례 적용하고 굴림 회전을 실제 이동 거리에 맞춘다. 피버 코인은 기존 모션을 유지한다. 시설 골드와 빈캔 착지 이후의 현재 동작은 위 시설 보상 원본을 따른다.

최초 비교는 네 항목의 시작→중간 경과→마지막 프레임과 목록 복귀를 확인했다. 재시안은 저장본을 새로 불러와 동전·빈캔의 확대/원래 크기,1.20초 도달 후 반복,멈춤과 목록 복귀를 다시 확인했다. 원본의111개 시간 표본, 시작4개와 안내1개, 총116개 보드에 편집 가능한 위치·크기·회전·문구·자동 전환이 저장되어 있다. 1번은 기존 `src/features/play/effects/drink_dispense_fx.gd`에 반영했다. 기존 음료 아트를 재사용하며 투입·배출의 전체 시간과 겹친 구매 완료 계약을 유지한다. 4번은 기존 `src/features/play/play.gd`의 일반 수색 분기와 `src/features/facilities/facility_world.gd`에 반영했다. 같은 코인·빈캔 그림을 재사용하고 실제 빈캔 아이콘 비율로 회전 접지를 계산한다. 보상·클릭 수령·소멸/자동 수집 규칙은 유지한다. 2·3번 게임 모션은 변경하지 않았다.

## 미동기화·검수 대기

2026-11-08 시설 골드의 선명한 대기와 빈캔 부유 원본을 01에 반영했다. 기존 미동기화였던 빈캔의 2배 크기·반짝임·호버·누름·고정 클릭 영역·모션 감소·수령 상태도 같은 Currency 연결 인스턴스로 작성했다. 저장 후 편집 탭을 다시 불러왔고 새 보기 탭의 부유 단계 재생을 확인했다. 보기 탭의 클릭 수령 최종 확인은 브라우저 도구 응답 지연으로 미완료다. 실제 게임에서는 GPU 렌더와 클릭 수령을 검증했다. 03의 기존 비교는 낙하·굴림·0.84초 정착 구간이며 현재 착지 후 상태는 위 01 원본을 따른다. 이 확인을 아래 자판기 표면·손님 보행의 기존 대기 항목 해결로 확대하지 않는다.

2026-11-05 자판기 표면·진열 조명: 게임에는 승인 원화와 접지 그림자 강도를 반영했다. Penpot의 위 본체·그림자 원본 수정, 연결 인스턴스 전파와 ‘자판기 표면·진열 조명 통합 2026-11-05’ 버전 저장 응답을 받았다. 그러나 Computer Use로 Chrome 편집 탭을 활성화·재로딩한 화면은 이전 원화를 표시했고, Connect here 이후 MCP가 다시 suspended 오류를 반환했다. 저장된 이미지의 표시 일치 확인은 미완료다. 연결 복구 시 본체의 이미지 채우기와 빨간 면 마스크, 공통 접지 그림자 및 01 화면을 다시 확인해야 하며, 로컬 결과를 원본 동기화 완료로 간주하지 않는다.

2026-10-31 보행 속도·좌우 등장: 01의 행인 통과 왼쪽·오른쪽 원본과 지연 연결은 새 편집 탭에서 저장을 확인했다. 구매 손님 원본의 같은 변경은 MCP 편집 응답 후 연결이 끊겼으며, 새 편집 탭에서는 저장된 변경을 확인하지 못했다. 기존 탭·새 Chrome 편집 탭과 Connect here로 재연결을 시도했으나 MCP가 연결되지 않아 구매 손님 동기화와 보기 재생 검수는 대기다. 대상은 01의 기존 ‘손님 이용’ 진입·음료 보행·퇴장 보드와 좌우 재생 연결이다. 로컬 구현과 요약을 Penpot 원본으로 간주하지 않는다.

연결 복구 후 순차 퀘스트 공통 원본·플레이/애니메이션의 한 줄 HUD와 중앙 카드·목표 상세 패널 제거를 저장했다. 새 보기 탭에서 동전 → 빈캔 → 모두 완료 후 HUD 숨김을 확인했으며 이전 독립 수령 시연은 대체했다.

지난 재화 통일 작업의 전체 사용처 시각 전수 대조는 별도 대기다. 대상은 연결 파일 `cd444aaf-0d8c-801b-8008-cda246e18650`의 01 게임 화면·02 재화 공통 원본이며, 이번 퀘스트 저장·동작 확인을 재화 전체 사용처의 시각 검수 완료로 확대하지 않는다.
