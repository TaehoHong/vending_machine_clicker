# Plan: 확정 디자인의 코드 적용

## 요청과 현재 상태

- 사용자 요청: Penpot 디자인을 코드에 적용한다. 확정된 부분부터 진행하고 애니메이션 방식·자판기 위치 등 결정이 필요한 부분은 사용자에게 묻는다.
- 조사·승인: 2026-10-26. 사용자의 “진행해”로 1차 구현 계약을 승인받았다. 정적 카드 적용과 아래 검증을 마쳤다.
- Penpot 파일 `cd444aaf-0d8c-801b-8008-cda246e18650`를 Chrome 편집 화면의 URL과 채택 보드로 확인했다. MCP는 연결된 인스턴스가 없으며 기존 플러그인 열기도 오류가 발생했다. 원본 확인은 브라우저의 실제 렌더링과 SVG DOM을 사용했다.
- Notion 기획을 연결 도구로 읽었다. 기존 재화·해금·저장 계약을 유지한다. 사용자 추가 확정인 스테이지별 자판기 종류·판매 물품 차이를 Notion과 PRODUCT.md에 동기화했다. Notion을 다시 읽어 두 대상 문구 외 원문 변경이 없음을 확인했다.
- 기존 `DESIGN.md`의 손님 파츠 검수 규칙 수정과 `.DS_Store` 파일은 다른 작업으로 보존한다. 구현 브랜치는 `codex/drink-info-design`이다.
- 2026-10-21 음료 상세 패널 계획은 당시 파란 패널 시안 조사 기록이다. 이번 작업은 현재 크림색 채택 보드를 기준으로 하며 이전 제안을 구현 근거로 사용하지 않는다.

## 범위와 결정 장부

| ID | 범위 | 근거·상태 | 처리 |
| --- | --- | --- | --- |
| D1 | 1차 포함 | user-confirmed / active | 확정된 음료 상세·능력 요약 카드의 정적 UI부터 적용한다. |
| D2 | 디자인 근거 | externally-evidenced / active | 획득 상세 보드 `51ff814c-57a3-802e-8008-d25b1da5805d`, 능력 요약 보드 `51ff814c-57a3-802e-8008-d25b248dc0ad`의 크림색 면 `#FFF2D9`, 짙은 글자 `#132433`, Cafe24 PRO UP 제목·수량, Noto Sans KR 설명 본문을 따른다. |
| D3 | 유지 | repo-evidenced / active | 현재 자판기·전체 캔버스·카드의 화면 위치와 크기, 배경, 재화 HUD, 상단 버튼의 외형·입력, 선택·해금·구매·저장·피버 동작을 유지한다. |
| D4 | 후속 결정 | recommended-unconfirmed / deferred | 자판기 위치·크기와 전체 화면 배치는 변경 직전에 사용자에게 확인한다. 현재 Penpot 위치를 게임의 새 위치로 조용히 확정하지 않는다. |
| D5 | 후속 결정 | recommended-unconfirmed / deferred | 새 애니메이션의 방식·시간·경로·겹침·손님 움직임은 해당 작업 직전에 확인한다. 기존 구매 겹침과 보상 지급 계약은 유지한다. |
| D6 | 후속 작업 | repo-evidenced / deferred | 시설 구매·설치·생산·수집·손님은 설치 정책과 수치가 미정이므로 이번 코드 적용에 넣지 않는다. |
| D7 | 쓰기 승인 | user-confirmed / active | 사용자의 “진행해”로 이 계획의 1차 구현 범위를 승인받았다. |
| D8 | 확장 경계 | user-confirmed / active | 게임에 여러 스테이지가 있고 스테이지마다 자판기 종류와 판매 물품 구성이 다르다. 첫 스테이지의 음료 목록·진열을 전체 게임의 고정 계약으로 확대하지 않는다. |
| D9 | 후속 결정 | recommended-unconfirmed / deferred | 상세 스테이지·자판기별 상품 배정과 스테이지 전환 시 재화·강화·시설 유지 범위는 해당 동작을 구현하기 전에 확인한다. |

1차 범위의 미해결 디자인 결정은 0개다. D4~D6은 1차 작업을 막지 않는다. 새 화면 설정·언어 선택·오디오 기능·등급 표시·메뉴 전체 교체도 이번 범위 밖이다.

## 스테이지·자판기·판매 상품의 확장 경계

- 근거는 사용자의 스테이지별 구성 차이 확정(D8)이다. 현재 비용은 기존 데이터·화면·저장 경계를 확인하고 카드 표시를 기존 카탈로그의 선택 상품 데이터에 연결하는 범위다. 이후 다른 상품 때문에 카드·재화·저장 구현을 복제하는 일을 피한다.
- 후속 런타임 확장에서는 스테이지 구성, 자판기 종류·외형·진열, 상품 정의를 구분하고 명시적인 식별자로 연결한다. 스테이지·자판기 구성이 판매 상품을 참조하며 상품 정의를 화면에 복제하지 않는다. 정확한 데이터 형식과 저장 전환은 해당 구현 계약에서 정한다.
- 이번 정적 카드 작업은 현재 음료 화면 소유자를 확장하고 선택한 상품의 이름·이미지·효과·획득/강화 정보를 기존 카탈로그·세션에서 받는다. 새 카드 안에 음료 15종 분기나 고정 상품 그림·효과·비용을 다시 작성하지 않는다. 5×3 진열과 빈캔 해금은 현재 음료 자판기의 규칙이며 다른 자판기의 공통 규칙으로 승격하지 않는다.
- 현재 `drink_catalog.DATA`는 상품 정의와 `display_slot`을 함께 가지며 `drink_rules`·`drink_screen`이 직접 참조한다. 저장소는 일부 개별 필드와 상품 인덱스를 보존한다. 스테이지 전환을 위해 같은 배열을 다른 상품 목록으로 덮어쓰거나 기존 인덱스를 재사용하지 않는다. 실제 저장 형식 변경·마이그레이션은 이번 범위 밖이다.
- 미정인 후속 스테이지·자판기·상품을 채운 설정 파일, 빈 폴더, 범용 상품 엔진·공급자 등록소는 만들지 않는다. 첫 스테이지의 정적 UI는 D9를 결정하지 않아도 진행할 수 있다.

## 1차 구현 계약

플레이어가 기존 능력 버튼으로 화면을 열고 음료를 선택하거나 능력 요약을 열었을 때, 현재 기능을 유지하면서 채택 원본의 카드 외형·텍스트 계층·음료 그림을 확인할 수 있어야 한다.

- 상세·요약 카드만 크림색 정보 패널로 전환한다. 재화 HUD와 다른 화면의 파란 패널은 그대로 유지한다.
- 상세 헤더에 선택한 음료의 기존 카탈로그 이미지를 표시하고, 제목·획득/강화 수량·효과·해금 상태의 계층을 원본에 맞춘다. 원본의 `추후 확정` 견본 문구 대신 현재 확정된 실제 기획 정보를 표시한다.
- 본문은 Noto Sans KR과 외곽선 없는 짙은 글자를 사용하고 제목·수량·버튼은 Cafe24 PRO UP을 재사용한다.
- UI 상태는 기본·선택·미해금·빈캔 부족·해금 완료·강화 한도·요약·닫기·resize를 검수한다. 선택/hover는 재화를 차감하지 않고 해금 버튼만 세션에 요청한다.
- 전역 테마의 기본값을 바꾸지 않고 `play_theme.tres`에 원본의 정보 패널·본문 변형을 추가해 기존 화면 소유자에서 참조한다. 기존 `pixel_button.gd`, ActionButton, PixelIconButton과 카탈로그를 재사용한다. 새로 디자인한 색상·컴포넌트는 없다.
- 구현 시 외부 작업은 공식 배포처의 Noto Sans KR 폰트·라이선스 다운로드뿐이다. Penpot 원본은 이번에 재설계하지 않는다. 스테이지 구성에 대한 사용자 확정은 코드 승인과 별개로 Notion과 PRODUCT.md에 먼저 동기화한다.

## 기존 소유자와 파일 경계

- owner-found: `src/features/drinks/drink_screen.gd:34`의 `_ready`, `_panel`, `_label`, `_button`, `_refresh_selection`. 코드 안내와 `select_drink`/`update_state` 호출·관련 테스트를 대조했다.
- owner-found: `src/shared/ui/themes/play_theme.tres`의 공통 스타일·글꼴·변형, `src/shared/ui/pixel_button.gd`의 버튼 입력/피드백. `docs/04-design-rules.md:3`을 디자인 정책으로 사용한다.
- owner-found: `src/data/drink_catalog.gd.DATA.asset`의 음료 그림. 별도 상품 정의나 이미지 복제본을 만들지 않는다.
- 직접 호출자: Play의 `_on_skill_button_pressed`, `_refresh_skill_tree`, `_on_unlock_drink_requested`. 세션 요청·스냅샷 전달을 변경하지 않는다.
- owner-absent: 런타임의 크림색 카드·Noto Sans KR 본문 스타일. 테마/화면의 `Noto Sans KR`, `fff2d9`, `132433` 검색 및 `_panel`/`_label` 사용처 확인 결과 기존 재사용 변형이 없다. 기존 공유 테마에 추가하며 두 번째 테마나 새 스크립트는 만들지 않는다.

예상 수정 파일:

- `src/features/drinks/drink_screen.gd`: 현재 카드의 스타일·텍스트 역할·카탈로그 이미지 연결.
- `src/shared/ui/themes/play_theme.tres`: 채택 정보 패널·본문·짙은 제목의 테마 변형. 전역 기본값은 유지.
- `tests/features/drink_screen_test.gd`: 상세 카드가 QuestPanel과 같은 스타일이어야 한다는 낡은 가정 제거. 기존 입력·재화·resize 검증은 보존.
- `assets/fonts/README.md`: 추가 폰트의 출처·라이선스 안내.
- `docs/07-codebase-guide.md`: 검증 후 새 공유 테마 변형의 소유자와 사용 예시만 갱신.
- 이 계획 파일: 승인·검증 상태만 갱신.

새 파일은 `assets/fonts/NotoSansKR.ttf`, `assets/fonts/NotoSansKR-OFL.txt` 및 Godot 생성 import 메타데이터다. 로컬 게임이 사용해야 하므로 폰트 바이너리와 라이선스를 기존 폰트 폴더에 둔다. 화면 스크립트·카탈로그·테마를 복제하지 않는다. 디자인 상세/적용 상태 표를 DESIGN.md나 design/README.md에 복제하지 않는다.

## 검증과 체크리스트

- [x] 프로젝트 지침·PRODUCT·디자인 규칙·아키텍처·관련 코드 안내와 소유자 확인.
- [x] Penpot 획득 상세·능력 요약·기본 플레이의 실제 렌더링과 텍스트 스타일 확인.
- [x] 변경 전 `drink_screen_test`, `drink_unlock_screen_test`, `vending_display_test` 통과.
- [x] 스테이지별 자판기·판매 물품 차이를 기획 원본과 로컬 요약에 동기화하고 확장 경계를 계획에 반영. 코드·테스트·런타임 에셋 diff가 없고 문서 공백 검사를 통과했음을 확인.
- [x] 1차 구현 통합 승인.
- [x] 승인 후 작업 브랜치에서 기존 테마/화면 소유자를 확장해 정적 UI 적용.
- [x] import·parse와 관련 회귀 검증, 실제 렌더러에서 긴 문구·부족/완료·요약·resize 확인.
- [x] 실제 diff의 중복·임의 스타일·책임 위반·다른 작업 변경 혼입 검사.
- [ ] 검증한 공유 UI 소유권만 코드 안내에 반영하고 로컬 커밋·main 머지 및 포함 여부 확인.

Godot은 `/private/tmp/clicker-godot-4.7/Godot.app/Contents/MacOS/Godot` (`4.7.stable.official.5b4e0cb0f`)를 사용한다. 기본 user 로그 경로는 sandbox에서 열리지 않아 최초 실행이 충돌했다. `--log-file /private/tmp/<개별 로그 이름>.log`를 명시하자 세 회귀가 완료됐다. macOS 시스템 인증서 조회 경고가 있으며 스크립트 오류·assertion·리소스 오류는 없었다.

승인 후 실행할 명령은 위 Godot 경로를 사용한 다음 선언 명령이다. sandbox 로그 경로만 명시한다.

```sh
godot --headless --editor --path . --import
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/features/drink_screen_test.gd
godot --headless --path . --script res://tests/features/drink_unlock_screen_test.gd
godot --headless --path . --script res://tests/features/vending_display_test.gd
godot --headless --path . --script res://tests/features/menu_test.gd
godot --headless --path . --script res://tests/features/drink_dispense_test.gd
git diff --check
```

새 테스트 파일이나 색상·폰트 이름을 복제하는 상수 검사는 추가하지 않는다. 기존 회귀는 실제 클릭·선택·중복 차감 방지·ESC·resize를 보호한다. 카드가 다른 공유 스타일과 반드시 같아야 한다는 구현 결합 assertion을 제거하되 행동 assertion을 완화하지 않는다. 실제 렌더링·가독성·문구 넘침은 화면 캡처로 검수한다. Windows 배포·전체 지원 언어·플레이 감각의 최종 사람 검수는 별도이며 완료로 주장하지 않는다.

### 1차 검증 결과

- 선택 음료 그림 회귀는 구현 전에 `Selected drink must appear in the detail header` assertion으로 실패했고, 구현 후 콜라에서 물로 실제 선택을 바꿔 이미지 전환을 확인했다. 기존 재화·해금·저장·입력 assertion은 유지했다.
- Godot import·parse와 `drink_screen_test`, `drink_unlock_screen_test`, `vending_display_test`, `menu_test`, `drink_dispense_test`를 통과했다. 음료 화면은 Metal Forward+ 렌더러에서도 실제 입력 회귀를 통과했다.
- 실제 렌더링에서 획득 상세·미해금·독립 해금·요약·빈캔 부족·긴 황금음료 이름·강화 상한/10억 획득 기록·800×600 창을 검수했다. 임시 출력은 `.godot/test_artifacts/drink_screen_test/`에 두며 디자인 원본으로 승격하지 않는다.
- 가변 글꼴은 OpenType wght 정수 태그로 지정하고 렌더러의 실제 좌표가 400임을 확인했다. 문자열 태그 지정 때 기본 100으로 표시되던 현상은 검수 중 수정했다.
- sandbox에서 실제 렌더러 실행은 권한 확장이 필요했다. 편집기 import의 설정 저장 오류는 임시 Godot 바이너리 옆 `_sc_` 파일로 독립 설정 경로를 사용해 해결했다. 재실행에서 설정 저장 오류·스크립트 오류·assertion·리소스 오류가 없었다. headless의 기존 macOS 인증서 조회 경고는 남는다.
- `git diff --check`를 통과했다. 다른 작업의 `DESIGN.md` 수정은 작업 시작 때와 동일한 해시이며 커밋에서 제외한다. 새 파일은 승인한 폰트·라이선스·import 메타데이터뿐이며 새 스크립트·카탈로그·상태 원장은 없다.

## Knowledge Delta

사용자가 확정한 스테이지별 자판기 종류·판매 물품 차이는 Notion 기획과 PRODUCT.md에 반영되어 있다. 검증된 InfoPanel·InfoTitle·InfoBody의 소유자와 선택 그림 회귀를 코드 안내에 갱신했다(repo-evidenced). 아직 구현되지 않은 스테이지 구조를 현재 아키텍처나 코드 안내의 구현 사실로 기록하지 않는다. 폰트 출처·라이선스·굵기는 기존 폰트 안내에 기록했다. 환경 권한·임시 폰트 설정 문제는 별도 프로젝트 장애로 승격하지 않는다.
