# Terra 직접 사용자 테스트 결과

최신 결과는 아래 [수정 후 Terra 직접 재검수](#수정-후-terra-직접-재검수--2026-10-30)와 [수정 검증 인수](#수정-검증-인수)에 있다. F-01~03을 수정했고 자동 회귀 21개를 통과했다. Terra는 자동 지급·재진입과 콜라 가독성을 직접 확인했으며, 짧은 연출 중 종료 등 확보하지 못한 직접 검수는 별도 표시했다. 그 앞의 발견 사항·Sol 판정은 수정 전 이력이다.

최초 대상 `a2823521b63aa95c856c99e5028dce13614f9442`, 2026-10-30, 검수자 GPT-6.1 Terra. macOS 26.5.1, Apple M4 Pro, Godot 4.7.stable.official.5b4e0cb0f, Metal 4.0 Forward+. CUA 네이티브 입력 및 화면 관찰. 창 스크린샷 1152×712(제목 표시줄 포함), 게임 콘텐츠 1152×648. 2차에는 `--resolution 1280x720`으로 콘텐츠 1280×720을 확인했다. 1600×900과 비16:9는 미검증이다.

임시 복사 `/private/tmp/clicker-terra-project`는 `project.godot`의 이름만 `TerraQATest_20261030`으로 바꾸었고 `HOME=/private/tmp/clicker-terra-home`으로 실행했다. import가 해당 HOME의 `Library/Application Support/Godot/app_userdata/TerraQATest_20261030`을 생성했고 실제 진행 저장도 그곳에서 확인했다. 기존 BackstreetClicker의 progress.cfg와 settings.cfg는 시작·종료 전후 SHA-256 비교 결과 동일하다. 사용자 저장 내용은 열람하거나 기록하지 않았다. 자연 새 게임에서 시작했고 1차는 fixture 없이 진행했다. 2차 fixture E1은 10,000 Gold, 빈캔 50, 구매 20, 물·녹차 각 10, 에너지(index 14) 해금, 다른 음료 미해금, 시설 미보유로 시작했다. 게임 프로세스는 종료했다.

GUI 샌드박스 내 실행은 출력 없이 exit 134였으며 권한 상승 후 실행됐다. CUA 앱 경로 선택은 응답하지 않았지만 bundle ID `org.godotengine.godot`로 연결했다. 초기 메뉴는 새 게임 활성, 이어하기 비활성 및 저장 없음이었다. 입력을 제한한 동안의 경과를 포함해 자연 플레이 3분 이상과 시설 설치 후 90초 이상 관찰했으나 모든 애니메이션 프레임을 연속적으로 확인하지는 못했다. 스크린샷은 `.godot/test_artifacts/terra-user-test/` 아래에 로컬 보존하며 Git에는 포함하지 않는다.

## 발견 사항

- **F-02 / P2 / 기획 불일치:** 최신 Notion은 시설 골드의 짧은 튀어오름 후 자동 획득을 명시한다. 실제로 생산량 20 Gold/10초 강화 상태에서 HUD 2,536이 10초 이상 유지되었고 생산물 클릭 후 2,616으로 증가했다. 누적 수동 수령을 1회 직접 확인했으며 2회 재현은 하지 않았다. [수령 전](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-overlap.png), [후](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-gold-click.png). 로컬 PRODUCT 및 구현은 수동 수령을 기술하므로 최신 원문과 별개로 판정한다. 관련 `src/features/facilities/facility_world.gd`. Sol 재검토로 P1에서 P2로 조정했다. 수동으로 전액 수령할 수 있고 미수령액은 저장되므로 생산 중단·진행 손실로 분류하지 않는다.
- **F-01 / P2 / UX·시각:** 시설·음료 화면에서 시설 생산 골드·빈캔이 버튼 위에, 행인이 확대 진열대 앞에 나타난다. 재현: 자동 자판기 설치 후 생산물이 남은 상태에서 시설창 또는 음료창을 연다. 시설 목록의 쓰레기통 버튼 위 골드, 콜라 해금 카드 위 골드·빈캔, 음료 자판기 위 행인을 관찰했다. 두 화면에서 2/2 확인. [시설](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-overlap.png), [음료](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-cola.png). 클릭 차단과 행인의 상세 본문 가림은 입증되지 않았다. Sol은 동일 canvas의 시설·음료 화면보다 골드·물품 z_index 20과 행인 z_index 1이 앞서는 구조를 확인했다. 별도 CanvasLayer를 사용하는 ESC 일시정지 화면까지 일반화하지 않는다.
- **F-03 / P3 / 가독성:** 콜라 상세의 ‘반복 획득 가능’이 어색하게 나뉜다. 미해금 화면은 ‘능’만 다음 줄에 남고, 해금 직후 화면은 ‘득 가능’이 다음 줄로 밀려 상태 안내와의 간격이 좁다. 미해금 상태는 1152×648과 1280×720에서 확인했다. [해금 전](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-cola.png), [후](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-cola-unlock.png), [1280](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/cola-1280.png). 글자 잘림이나 글자끼리의 겹침은 확인되지 않았다. Sol 재검토로 P2에서 P3로 조정했다. 관련 소유 경로는 `src/features/drinks/drink_screen.gd`의 상세 effect/status 레이블이며 구체적 수정안은 미확정이다.

## 기능 여정

PASS는 해당 행의 전 조건 전체를 검증한 경우만 사용한다. 부분 관찰은 OBSERVED이며 나머지 조건은 미검증이다.

| ID | 판정 | 실제 절차와 범위 |
| --- | --- | --- |
| TC-01 | OBSERVED | 새 저장 없음, 새 게임 진입, 0 Gold·0캔·첫 가격 100. 오류 없이 진입. 이어하기 비활성. |
| TC-02 | OBSERVED | 숙련 에이전트의 모의 초심자 플레이. 하단 손 표시를 보고 클릭했으나 본체 하단 500/520에서는 무반응으로 망설였고 바닥 550에서 수색 확인. 정확한 시간 측정은 안 함. |
| TC-03 | OBSERVED | 바닥 연속 클릭으로 재화와 진행 확인. 경계별 정량 비교 및 10단계 밝기 확인은 미실행. |
| TC-04 | OBSERVED | 수색 반복 후 0→1→62→75 Gold; 개별 성공·꽝 전후와 동전은 분리 관찰하지 못함. |
| TC-05 | OBSERVED | 0에서 본체 연타 후 가격 100과 잔액 유지. 알림 3건 순서 미확인. 이후 5회 구매 5,075→4,552, 캔 0→5, 다음 가격 111. 각 결제 순간과 저장 개별 확인 미실행. |
| TC-06 | OBSERVED | 5연속 구매 후 여러 음료가 화면에 겹쳐 배출됨. 가격·캔과 합산 차감 확인. 배출 중 수색·창 열기는 분리 검증하지 못함. [증거](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-five-purchases.png). |
| TC-07 | OBSERVED | 잠긴 이온 선택에서 0캔 그대로, 부족 문구. 콜라 선택은 10캔 유지, 해금은 10→0, 획득 대상 표시. 에너지·황금·중복 및 hover 미검증. |
| TC-08 | OBSERVED | 물·녹차 기본, 잠긴 이온과 콜라 상세 관찰; 콜라 본문 줄바꿈 F-03. 전체 음료·최대 상태 미검증. |
| TC-09 | OBSERVED | 물·녹차 20개까지 구매 후 추가 연타에서 캔 20과 가격 149 유지, 두 음료 진열 유지. 후보 없음 차감 없음의 개별 수치 및 황금 조건 미검증. |
| TC-10 | OBSERVED | 물·녹차 최대 후 콜라 해금, 유일 후보 구매 2,776→2,627, 캔 0→1, 다음 가격 152. 배출 후 수색 피버 및 Gold×2 HUD 확인. 10초·필요 클릭·종료 복귀 정량 미검증. [피버](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-fever.png). |
| TC-11 | OBSERVED | E1에서 에너지 구매 10,000→9,851, 캔 50→51, 다음 가격 152. 이후 재구매 뒤 펀치 HUD 4.7초·Gold×3 확인. 3회 타격 후 잔액 증가·가격 158 유지. 종료 후 일반 구매 복귀는 뒤에 다시 구매된 사실로 관찰했으나 정확한 5초는 미측정. [타격](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/punch-hit.png). |
| TC-12 | OBSERVED | E1 펀치 발동 직후 음료창을 4초 이상 열고 닫았을 때 3.8초가 남아 정지·재개를 관찰했다. 열기 직전 정확한 값, 배경 클릭 및 다른 창·ESC는 미검증. [재개](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/punch-resume.png). |
| TC-13 | NOT RUN | 동시 피버 및 배출 중첩 상태 미준비. |
| TC-14 | OBSERVED | 수색 10회 목표 달성 카드에서 5,000 수령 75→5,075. 캔 5개 목표는 목록에서 100 수령 2,676→2,776, 두 행 수령 완료 및 위치 유지. 중복 클릭·재화 소비 후 진행 별도 비교 미실행. [목록](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-quest-claimed.png). |
| TC-15 | OBSERVED | 첫 카드, 다음 캔 카드 순서로 출현, 수령 후 사라짐. 20초 대기·정보창 보류는 측정하지 못함. |
| TC-16 | OBSERVED | 5,000 수령 즉시 잔액 증가, 다수 동전 바닥 낙하 관찰. 흡입 끝·동시 수색·모션 감소 비교는 미실행. [연출](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-quest-fx.png). |
| TC-17 | OBSERVED | 캔 20에서 자동 자판기 구매 후 10, 즉시 설치; 쓰레기통은 15 필요·5 부족 비활성. 다른 경계값·중복·그림 선택 미검증. |
| TC-18 | OBSERVED | 자동 자판기 골드 생산량 100 Gold 강화: 2,636→2,536, 0/5→1/5, 10→20, 다음 비용 200. 나머지 항목·최대 미검증. |
| TC-19 | FAIL | 20 Gold/10초 강화 상태로 여러 주기 방치해 잔액 2,536 유지, 클릭 시 2,616. 현 구현의 수동 수령은 관찰됐으나 최신 Notion 자동 획득과 다름(F-02). 기본 10 Gold 조건은 미실행. |
| TC-20 | NOT RUN | 빈캔 개별 낙하·반복 클릭·15초 만료 및 쓰레기통 자동 수집을 확실히 추적하지 못함. |
| TC-21 | OBSERVED | 설치 후 90초 이상 경과하며 여러 손님·행인, 정지/등돌림/수령·퇴장과 통과 장면 관찰. 개별 인물의 전체 경로와 보상 독립성은 연속 추적하지 못함. |
| TC-22 | OBSERVED | E1 구매·타격 후 프로세스 종료·이어하기에서 9,509 Gold, 캔 54, 다음 가격 161과 에너지 진열이 그대로였고 추가 지급은 보이지 않았다. 시설·퀘스트 수령 flag는 이 재실행에서 미검증. [재진입](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/reload.png). |
| TC-23 | NOT RUN | 연출 중 종료·재진입과 백업 미검증. |
| TC-24 | NOT RUN | 지정 잔액 fixture와 tooltip 미준비. |
| TC-25 | NOT RUN | 설정 변경·재진입 및 모션 감소 미검증. |
| TC-26 | OBSERVED | 1152×648과 1280×720에서 F-01/F-03 재현. 1600×900·비16:9 미실행. [1280 시설](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/overlap-1280.png), [콜라](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/cola-1280.png). |
| TC-27 | OBSERVED | ESC로 음료 닫기, 시설 강화→목록→게임 복귀 확인. Tab·Enter·포커스 전체 미검증. |
| TC-28 | OBSERVED | 연속 구매 배출 및 손님과 생산물 겹침 관찰; 모달 시각 겹침 F-01. 모든 FX 동시 중첩과 FPS 미검증. |

## 시각·애니메이션

| ID | 판정 | 관찰 또는 미실행 사유 |
| --- | --- | --- |
| VA-01 | OBSERVED | 중앙 자판기와 하단 손 표시가 주 행동을 안내하나 초기에 실제 클릭 위치를 찾는 데 시행착오가 있었다. |
| VA-02 | OBSERVED | 픽셀 버튼과 크림 카드가 구분되며 콜라 본문 줄바꿈 F-03. hover·pressed·focus 전체 비교 미실행. |
| VA-03 | OBSERVED | 반복 수색에 잔액이 증가했다. 단계별 빛과 희귀/꽝의 시작·끝은 분리 관찰하지 못함. |
| VA-04 | OBSERVED | 연속 구매에서 여러 음료가 공중에 동시에 보였다. 개별 투입→배출 전체 궤적·잔상 종료는 미확인. |
| VA-05 | OBSERVED | 콜라의 수색 피버와 E1의 펀치 이름·잔여 시간·배율·타격 후 골드 증가를 관찰했다. 펀치 중 음료창 정지·재개와 일반 구매 복귀도 확인했다. 두 피버 동시 연출과 정확한 종료 시점은 미검증. |
| VA-06 | OBSERVED | 서로 다른 머리·의상 손님들이 보행하는 것을 봄. 4종별 접지·관절·깊이는 프레임 단위 검증하지 못함. |
| VA-07 | OBSERVED | 구매자 후면 대기와 음료 파지 및 행인 통과 장면을 봄. 전환 순서와 0.36초, 빈손 숙임 여부는 미측정. |
| VA-08 | OBSERVED | 음료를 든 후면 손님 관찰. 4px 호흡·2.4초·첫 숙임부터 파지는 미측정. |
| VA-09 | OBSERVED | 골드가 자동 수령되지 않고 클릭 대기(F-02). 빈캔 낙하·바운스·구르기·소멸 연속 관찰 미실행. |
| VA-10 | OBSERVED | 퀘스트 수령 동전 다수가 바닥에 퍼지는 장면과 즉시 지급을 봄. 전체 흡입 및 모션 감소 비교 미실행. |

직접 관찰한 장점은 다음과 같다.

- 초기 손 모양 안내와 첫 구매 가격이 행동 목표를 제공한다.
- 퀘스트가 즉시 잔액을 갱신하고 수령 후 행을 유지한다.
- 연속 구매에서 복수 음료를 동시에 보여준다.

### 모션 보강 제안 · 시설 골드 자동 획득

현재 생산 아이콘이 고정 대기하고 직접 클릭해야 하는 상태(F-02)를 최신 기획에 맞추는 것이 우선이다. Sol 재검토에서 짧은 튀어오름 뒤 자동 획득은 이미 확정된 요구이며, 아래 HUD 이동 방식과 시간·강도는 미확정 선택안임을 확인했다.

- **효과:** 자동화로 생긴 보상이 지급됐음을 클릭 없이 이해하게 한다.
- **발생 조건·재사용:** 시설 생산 시 기존 골드 아트와 `facility_world.gd`의 표현 책임을 사용한다. 지급은 기존 세션·저장 소유 경계를 따른다.
- **동작:** 생산 → 짧게 튀어오름 → 골드 HUD로 이동 → 종료·정리.
- **중첩·정보창:** 기존 `collect_gold`는 미수령액 전부를 비운다. 여러 생산 연출이 겹칠 때 먼저 끝난 연출이 뒤 생산분까지 수령하지 않도록, 지급 시점과 연출별 금액의 대응을 기존 세션 소유자에서 정해야 한다. 정보창 위 가림은 캔·행인 계층도 함께 확인한다.
- **저장·복구:** 원문은 연출 중 종료 시 미수령 골드 보존과 재진입 한 번 자동 수령까지 요구한다. 자동 수령 후 늘어난 money와 비워진 pending gold를 함께 저장해야 한다. 기존 미수령 저장과 생산 주기 재시작 계약도 유지한다.
- **모션 감소 선택안:** 짧은 이동 또는 즉시 표시로 같은 지급 정보를 전달한다. 원문의 즉시 착지 표시는 빈캔 문맥이며 골드의 특정 대체 동작까지 확정한 것은 아니다.
- **재검수:** 기본·강화 상태 각각 3주기 무입력 잔액 증가, 생산 중첩, 연출 중 종료, 기존 pending 저장 로드, 반복 재진입, 10억 초과 금액에서 중복·손실 없음을 확인한다. 정보창·감소 모드와 캔의 별도 수집도 회귀 확인한다.

손님 캡처는 0/5/10초 시점의 서로 다른 인물이어서 한 사람의 전 동작을 판정할 수 없다. 손님 모션의 새 변경 제안은 보류한다.

## 실행과 한계

격리 복사 import는 exit 0, 로그 `/private/tmp/clicker-terra-import.log`; GUI는 Metal 출력 후 실행, 종료 exit 0, `/private/tmp/clicker-terra-gui.log`. 인증서 조회 `get_system_ca_certificates` 오류는 import의 환경 경고다. 부모가 별도로 이번 실행한 import/parse와 21개 회귀는 모두 exit 0·완료 문구 확인, SCRIPT ERROR/Parse Error/Assertion failed 없음: `/private/tmp/clicker-terra-regression-20261030/results.json` 및 개별 로그. 자동 검사는 위 미실행 수동 항목의 통과를 뜻하지 않는다. Penpot 연결은 heartbeat 오류로 직접 대조하지 못했다. 지시서의 HUD 미동기화는 baseline 당시 기록이며 이후 main에 문서 동기화 커밋이 있다는 부모 확인을 받았다. Windows, 출시 빌드, 전체 언어, 1600 이상과 비16:9는 검증하지 않았다. 변경 산출물은 이 보고서와 무시되는 캡처뿐이다.

2차는 별도 임시 HOME과 프로젝트 복사본에서 E1 저장을 작성해 실행했으며 구매 후 정상 종료·재실행했다. 1280 캡처와 0/5/10초 관찰은 위 증거 폴더에 보존한다. 모션 감소와 1600×900은 시간상 미실행이다. 2차 GUI 로그는 `/private/tmp/clicker-terra-gui2.log`, 재실행 로그는 `/private/tmp/clicker-terra-reload.log`이다.

## 메인 에이전트의 인수 확인

- 지시서와 결과표의 TC-01~28·VA-01~10이 각각 중복 없이 존재하고 모든 증거 링크의 대상 파일이 존재함을 확인했다. 부분 관찰과 미실행을 통과로 합산하지 않았다.
- 시설창/음료창 겹침, 1280 콜라 상세, 펀치 타격, 재실행 캡처를 직접 열어 보고서 내용과 대조했다. 원본 저장의 전후 해시 기록도 비교해 동일함을 확인했다.
- 기존 전체 회귀 21개와 import/parse는 메인 에이전트가 독립 실행했다. 각 완료 문구·종료 0과 스크립트/파싱/assertion 오류 없음을 확인했다. 모든 프로세스에 나타난 macOS 인증서 조회 엔진 오류는 별도로 남겼으며 원인 해결을 주장하지 않는다.
- 이번 저장소 변경은 요청한 검수 지시서와 결과 문서다. 게임 소스·테스트·에셋은 실행 기준 커밋과 동일하다. 모션 보강 방향은 미확정 제안이며 Notion·Penpot에 새 디자인 결정으로 반영하지 않았다.
- Knowledge Delta: 검수 결과와 재현 증거를 요청 산출물로 보존했다. 제품·디자인·아키텍처의 새 규칙이나 코드 소유권 변화는 없어 정규 문서·코드 안내에 추가 승격하지 않았다.

## GPT-6.1 Sol 독립 재검토 · 2026-10-30

사용자 요청으로 다른 모델인 GPT-6.1 Sol이 Terra의 세 지적과 개선안을 읽기 전용으로 재판정했다. 결론은 **수정 후 채택**이다. 위 발견 사항과 제안에는 이 판정을 반영했다. 이 재검토 당시 게임 코드는 Terra 실행 기준 `a282352`와 동일했다. 아래 소스 위치는 해당 커밋의 과거 위치다.

| 항목 | 재판정 | 근거·보완 |
| --- | --- | --- |
| F-01 | 확인 · P2 유지 | PNG에서 시설·음료 화면의 시각 겹침을 확인했다. `a282352`의 `facility_world.gd:18,66`(골드/캔 z), `customer_flow.gd:70`(행인 z), `facilities_screen.tscn:6`·`play.tscn:231`(기본 canvas)을 대조했다. `pause_menu.tscn:6`은 별도 layer 20이다. 클릭 영향은 별도 입력 검증이 필요하다. |
| F-02 | 확인 · P1 → P2 | [Notion 원문](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de)을 직접 재조회했다. `a282352`의 `facility_rules.gd:118`은 pending을 누적하고 `:79`의 collect_gold에서 잔액을 늘린다. 호출자는 `facility_world.gd:26`의 Button.pressed다. 자동 획득 기획과 다르지만 당시 증거는 계산 오류·진행 손실을 보이지 않았다. |
| F-03 | 표현 수정 · P2 → P3 | 미해금·해금 직후 PNG를 구분해 ‘능’/‘득 가능’ 줄바꿈을 확인했다. 잘림·글자 겹침은 아니다. `a282352`의 `drink_screen.gd:84`(상세 레이아웃)·`:229`(상태별 16/18px)가 관련 소유자다. |
| 모션 보강안 | 저장 계약 보완 후 채택 | 자동 획득·종료 후 한 번 복구는 확정 요구, HUD 이동은 선택안이다. `a282352`의 `facility_world.gd:19`(골드 아트), `play.gd:255`(수색 튀어오름), `reward_fx.gd:53`(퀘스트 HUD 이동)이 재사용 근거다. 범용 효과 프레임워크나 퀘스트의 대량 폭발·바닥 대기를 그대로 복제할 근거는 없다. |

Sol은 기존 PNG 5개를 직접 보고 소스·호출자·저장·기존 회귀의 기대를 읽었으며 Notion 연결 도구로 2회 조회했다. 반환 원문의 마지막 편집은 `2026-10-29T16:51:28.864Z`다. GUI 재실행·자동 테스트·클릭 재현·Penpot 재조회는 수행하지 않았다. 이 검토를 Terra가 미검증으로 남긴 동작의 통과 근거로 사용하지 않는다.

메인 에이전트도 표시 계층·수령 호출 경로·저장 코드와 해금 직후 캡처를 대조했다. 새 기획·디자인을 확정하거나 제품 코드를 수정한 작업은 아니므로, HUD 이동 선택안은 사용자 채택과 원본 디자인 반영 전까지 미확정으로 유지한다.

## 수정 후 Terra 직접 재검수 · 2026-10-30

대상은 `codex/sol-review-fixes`의 HEAD `87c04c0` 위 수정된 작업 트리이며, 재검수한 런타임 소스는 이후 커밋 `2cac822`·`e540d4a`와 같다. 위 기존 결과는 수정 전 기준으로 보존한다. GPT-6.1 Terra가 macOS 26.5.1, Godot 4.7.stable, Metal Forward+에서 CUA로 조작했다. 임시 프로젝트 `/private/tmp/terra-fix-project`는 현재 작업 트리 복사본에서 프로젝트 이름만 `TerraFixQA`로 변경했고 `HOME=/private/tmp/terra-fix-home`으로 격리했다. 저장 fixture F1은 1,000 Gold, 미수령 시설 골드 123, 자동 자판기 보유, 기본 생산 10 Gold/10초, 캔 50, 물·녹차 각 10, 구매 20, 다른 음료 미해금이다. 이후 재화와 상태는 실제 GUI 조작·생산으로 바뀌었다. F2는 기존 저장을 다시 1,000 Gold·미수령 123으로 준비하고 모션 감소를 켠 상태다. 실제 사용자 데이터는 내용 열람 없이 전후 SHA-256이 같았다.

| 재검수 | 판정 | 직접 확인 및 미검증 범위 |
| --- | --- | --- |
| 1. 무입력 생산 | PASS | F1 이어하기 후 무입력 관찰에서 1,143→1,163→1,173 Gold로 총 세 생산분이 자동 지급됐다. 고정 클릭 수령 아이콘은 관찰되지 않았고 저장 파일에서 이후 pending 0을 확인했다. 캡처 간격이 길어 짧은 튀어오름의 시작·끝은 직접 판정하지 못했다. [시작](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/auto-start.png), [12초](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/auto-12.png), [24초](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/auto-24.png). |
| 2. 기존 pending 복구 | PASS | F1 1,000+123→HUD 1,123을 확인했다. 저장은 다음 생산이 지나 1,133·pending 0으로 확인됐다. F2도 복구 후 생산과 콜라 해금을 거쳐 정상 종료 시 1,193이었고 다시 이어하기에서 1,193으로 시작해 123 중복 지급은 보이지 않았다. 10억 초과는 직접 미검증. [복구](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/pending.png), [재진입](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/reload-1193.png). |
| 3. 연출 중 종료 | NOT RUN | 0.5초 연출 중 종료를 직접 맞추지 못했다. 부모의 시설 자동회귀는 실제 tween 중 씬 해제→새 로드→반복 로드를 검증했으며 직접 플레이 증거와 구분한다. `/private/tmp/sol-review-fix-regression-20261030/results.json`. |
| 4. 정보창 계층·입력 | BLOCKED | 1152와 1280에서 시설 목록·강화·음료 상세를 열어 관찰한 캡처에는 골드·행인이 창 위에 나타나지 않았다. 1152 목록은 12초 이상 열어 두었고 1280 목록도 12초 이상 관찰했다. 각 창에서 2주기씩과 모달 뒤 빈캔 클릭 차단은 직접 검증하지 못해 전체 PASS로 판정하지 않는다. [1152 목록](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/facility-1152.png), [1280 목록](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/facility-1280.png). |
| 5. 음료 문구 | PASS | 1152와 1280에서 콜라 미해금·해금 직후·획득 상태의 효과가 의미 단위 두 줄로 나뉘고 상태 및 버튼과 간격을 유지했다. 1152 에너지 미해금 설명도 읽혔다. [1152 미해금](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/cola-locked-1152.png), [해금](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/cola-unlocked-1152.png), [획득](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/cola-acquired-1152.png), [1280 미해금](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/cola-locked-1280.png), [해금](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/cola-unlocked-1280.png), [획득](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/cola-acquired-1280.png), [에너지](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-sol-fixes/energy-1152.png). |
| 6. 모션 감소·일시정지·빈캔 | BLOCKED | F2 settings fixture에서 reduce_motion=true로 실행해 자동 지급과 정상 재진입을 확인했지만 0.15초 효과의 움직임을 직접 포착하지 못했다. ESC 일시정지는 열었으나 11초 대기·재개를 묶은 CUA 호출이 20초 제한으로 중단돼 전후 값 비교를 확보하지 못했다. 빈캔 직접 수령·15초 소멸도 미검증이다. |

새 결함은 직접 확인한 범위에서 발견하지 않았다. 모달 뒤 빈캔 입력, 생산 연출 중 종료, 감소 모드의 시각 연출은 미검증으로 남는다. 이 작업의 게임 GUI 프로세스들은 exit 0으로 종료했고 테스트 임시 프로젝트와 HOME을 정리했다. 증거는 `.godot/test_artifacts/terra-sol-fixes/`에 로컬 보존한다. import는 exit 0, `/private/tmp/terra-fix-import.log`; GUI 로그는 `/private/tmp/terra-fix-gui.log`, `/private/tmp/terra-fix-gui1280.log`, `/private/tmp/terra-fix-reduce.log`, `/private/tmp/terra-fix-reload.log`. 부모가 별도 실행한 전체 회귀 21개와 import/parse 성공은 자동 보조 증거이며 직접 미검증 항목을 대체하지 않는다.

## 수정 검증 인수

- F-02: 기존 `facility_rules.collect_gold`에 금액 한정 수령을 추가하고 `facility_world`가 기존 골드 아트의 0.22초 상승·0.28초 하강/페이드 완료 후 해당 생산분만 세션에 요청한다. 감소 모드는 이동 없이 0.15초 페이드다. 생산 시 pending을 저장하고, 완료 시 늘어난 잔액과 남은 pending을 함께 저장한다. Play 진입 때 이전 pending을 한 번 수령하고 즉시 저장한다. 별도 원장·저장 키·런타임 파일은 추가하지 않았다.
- F-01/F-03: 퀘스트의 z=100 모달 기준을 시설·음료 창에 적용했다. 음료 본문은 기존 스타일·패널 안에서 의미 단위 줄바꿈과 상태 영역 간격을 조정했다. 메인 에이전트도 수정 후 1280 시설·콜라 획득 캡처를 직접 열어 확인했다.
- 변경 전 facilities/menu/drink_screen 회귀에서 자동 지급·복구·영역 분리 실패를 확인한 뒤 수정 후 통과했다. 전체 21개 회귀와 import/parse는 `/private/tmp/sol-review-fix-regression-20261030/results.json`에 종료 0·완료 출력을 남겼다. macOS 인증서 조회의 기존 엔진 경고 외 SCRIPT ERROR·Parse Error·Assertion failed는 없었다.
- 자동 보강 검증은 직접 플레이와 구분한다. `facilities_test`는 연출 중 실제 씬 해제→새 앱 로드→반복 로드, 두 연출의 각각 20 Gold 수령과 pending 40→20→0, 시설창 뒤 빈캔 클릭 차단·닫은 뒤 수령을 통과했다. `menu_test`는 기존 pending 1,000,000,001의 잘림 없는 즉시 복구·저장·새 게임 백업을 통과했다. `facility_rules_test`는 요청액이 pending을 초과해도 남은 금액만 수령함을 검사한다.
- Terra의 미확보 범위를 보강해 감소 모드 자동 지급·씬 트리 pause 중 pending 유지·재개 후 한 번 지급 검사를 추가했고 `/private/tmp/sol-fix-pause-reduced.log`에서 통과했다. 짧은 tween의 시각적 매끄러움과 전체 창 장시간 직접 검수는 여전히 수동 확인 범위로 남긴다.
- Notion 원문은 연결 도구로 확인했으며 자동 수령·종료 후 한 번 복구는 이미 확정된 요구다. Penpot 파일 ID를 대조하고 음료 상세 채택 상태·시설 골드 세 키프레임을 편집했다. 별도 보기 모드에서 완료 상태 HUD 1,010까지 자동 전환을 확인했다. 원본 링크는 [디자인 안내](../design/README.md)에 있다.
- 코드 품질 검토에서 기존 규칙·저장·표현 책임을 재사용하고 임의 폰트/테마·중복 재화 규칙·새 런타임 파일이 없음을 확인했다. 수정한 GDScript의 100자 줄 길이와 공백, 보고서의 로컬 증거 링크 30개도 확인했다. 사용자 저장 전후 기록 `/private/tmp/terra-fix-before.txt`·`terra-fix-after.txt`는 동일했다.
- 기능별 커밋 `2cac822`(시설 자동 수령·저장 복구·모달 계층), `e540d4a`(음료 가독성)를 로컬 main에 fast-forward로 합쳤다. main에서 import/parse와 시설·메뉴·음료·시설 규칙·저장 호환 5개 통합 회귀를 다시 통과했다. `/private/tmp/sol-fixes-main-20261030/results.json`에 종료 0·완료 출력이 있다.
- Knowledge Delta: 검증된 자동 수령·기존 저장 복구 계약과 기존 소유자 확장을 PRODUCT·코드 안내·품질 문서에 반영했다. HUD 비행은 계속 미확정이며 구현하지 않았다. 화면·로그는 검수 증거로 로컬 보존하고 런타임 의존성으로 추가하지 않았다.
