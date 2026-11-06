# Plan: 음료 선택 시안 적용·UI 통일

## 범위·승인

- user-confirmed: 배경·오브젝트의 구분을 유지한다. 원화·모션·게임 수치·저장 규칙은 이번 범위에서 제외한다.
- 최초 요청은 선택 시안·UI 통일 계획·타이포 조절이었으며 후속 “시안대로 적용하고, UI 통일 계획도 진행해.”를 구체적인 시안과 통일안의 구현 승인으로 사용했다.
- 음료 상세 → 시설 → 설정/일시정지 순서로 적용한다. 새 메뉴·필터·번역·키보드 기능은 추가하지 않는다.

## 소유자·구현

- owner-found: drink_screen.gd의 _ready/_refresh_selection/_label과 drink_catalog.DATA. 의미 설명을 카탈로그에 추가하고 기존 수치 문구를 행으로 나눠 표시한다. 게임 계산은 기존 game 소유자를 유지한다.
- owner-found: play_theme.tres의 InfoPanel/InfoTitle/InfoBody와 pause_panel, 기존 Noto/Cafe24 및 버튼 frame family. MenuPanel/MenuBody/MenuCaption을 같은 테마에 추가하여 시설·설정·일시정지의 중복 스타일을 대체했다.
- 담당: 부모 음료·카탈로그·공유 테마·원본·문서, design_a 시설3씬, design_b 설정·일시정지7씬. 기존 모듈을 수정했고 새 런타임 파일·테마·에셋 복사본은 없다.
- 상세와 요약은400×430/내부24px, 선택 음료는 선명하게 표시하되 자물쇠를 유지한다. 제목·주요 버튼 Cafe24, 본문 Noto18, 상태·조건 Noto16을 사용한다.

## 체크리스트

- [x] 음료 시안: 선택 모서리·상태, 상세/요약 배치, 의미→수치→조건, 긴 이름·확률표 적용.
- [x] 시설: 공유 청색 패널, 본문/단계 크기, 뒤로 정렬, 현재→다음 기준선 통일.
- [x] 설정·일시정지: 공유 패널·본문/상태, 제목·뒤로 정렬, 입력·프레임 상태 유지.
- [x] 검증: drink_screen, drink_unlock_screen, settings, menu, facilities 회귀. Godot4.7 parse 및 git diff --check.
- [x] 시각 검수:1152×648/1280×720, 선택·미해금·해금·획득·최대·부족·긴 제목, 시설 상태 및 설정/일시정지 오류.
- [x] Penpot: 기존 부분 시안 재사용·수정, 설정/일시정지19개·시설46개 텍스트와 관련 정렬 반영. Chrome 새로고침 후 저장본 재조회.
- [x] DESIGN.md·design/README.md 및 공유 소유자/카탈로그 표시 계약의 코드 안내 갱신.
- Git 완료 기준: 기능별 커밋 후 로컬 main에 같은 변경이 포함되는지 최종 명령으로 확인한다. push·PR은 요청 범위가 아니다.

## 검증·한계

- 공식 /Applications/Godot.app/Contents/MacOS/Godot 4.7.stable.official.5b4e0cb0f 사용. 실제 렌더는 네이티브 창 실행 권한으로 수행했다.
- drink_screen 회귀에 선택/잠금 동시 표시·선택 이동 후 흐림 복귀·확률 행 분할 검사를 추가했다. 스타일값 복제 테스트는 추가하지 않았다.
- 초기 타입 추론 및 원본 Label 조회 오류를 고친 후 관련 테스트를 재실행했다. 최종 drink_screen/drink_unlock/menu/settings는 스크립트 오류 없이 통과했다.
- facilities assertions는 통과했으나 종료 시 ObjectDB2개·사용 중 리소스1개 경고가 남았다. 시설 단독 렌더는 경고 없이 끝났으며 누수 원인을 이번 UI 변경의 원인으로 단정하지 않는다.
- 최종 parse는 오류 없이 종료했다. 릴리스 export·자동 formatter/linter·별도 단위테스트 러너는 저장소에 설정되지 않았다.
- Penpot 음료/시설 내보내기와 저장본의 대표 글꼴·좌표·상태를 확인했다. 기존 자판기 원화의 표시 불일치는11월5일 대기 항목이며 이번 UI 동기화 완료와 구분한다.
- 기획 계산·저장 계약 변경이 없어 Notion 기획 변경은 없다. Knowledge Delta는 승인된 UI 규칙과 검증된 공유 스타일/카탈로그 표시 계약만 관련 문서에 반영했다. 별도 회고·트러블슈팅 문서는 만들지 않았다.
