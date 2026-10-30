# Terra 직접 사용자 테스트 결과

대상 `a2823521b63aa95c856c99e5028dce13614f9442`, 2026-10-30, 검수자 GPT-6.1 Terra. macOS 26.5.1, Apple M4 Pro, Godot 4.7.stable.official.5b4e0cb0f, Metal 4.0 Forward+. CUA 네이티브 입력 및 화면 관찰. 창 스크린샷 1152×712(제목 표시줄 포함), 게임 콘텐츠 1152×648. 2차에는 `--resolution 1280x720`으로 콘텐츠 1280×720을 확인했다. 1600×900과 비16:9는 미검증이다.

임시 복사 `/private/tmp/clicker-terra-project`는 `project.godot`의 이름만 `TerraQATest_20261030`으로 바꾸었고 `HOME=/private/tmp/clicker-terra-home`으로 실행했다. import가 해당 HOME의 `Library/Application Support/Godot/app_userdata/TerraQATest_20261030`을 생성했고 실제 진행 저장도 그곳에서 확인했다. 기존 BackstreetClicker의 progress.cfg와 settings.cfg는 시작·종료 전후 SHA-256 비교 결과 동일하다. 사용자 저장 내용은 열람하거나 기록하지 않았다. 자연 새 게임에서 시작했고 1차는 fixture 없이 진행했다. 2차 fixture E1은 10,000 Gold, 빈캔 50, 구매 20, 물·녹차 각 10, 에너지(index 14) 해금, 다른 음료 미해금, 시설 미보유로 시작했다. 게임 프로세스는 종료했다.

GUI 샌드박스 내 실행은 출력 없이 exit 134였으며 권한 상승 후 실행됐다. CUA 앱 경로 선택은 응답하지 않았지만 bundle ID `org.godotengine.godot`로 연결했다. 초기 메뉴는 새 게임 활성, 이어하기 비활성 및 저장 없음이었다. 입력을 제한한 동안의 경과를 포함해 자연 플레이 3분 이상과 시설 설치 후 90초 이상 관찰했으나 모든 애니메이션 프레임을 연속적으로 확인하지는 못했다. 스크린샷은 `.godot/test_artifacts/terra-user-test/` 아래에 로컬 보존하며 Git에는 포함하지 않는다.

## 발견 사항

- **F-02 / P1 / 기획 불일치:** 최신 Notion은 시설 골드의 짧은 튀어오름 후 자동 획득을 명시한다. 실제로 생산량 20 Gold/10초 강화 상태에서 HUD 2,536이 10초 이상 유지되었고 생산물 클릭 후 2,616으로 증가했다. 누적 수동 수령을 1회 직접 확인했으며 2회 재현은 하지 않았다. [수령 전](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-overlap.png), [후](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-gold-click.png). 로컬 PRODUCT 및 구현은 수동 수령을 기술하므로 최신 원문과 별개로 판정한다. 관련 `src/features/facilities/facility_world.gd`.
- **F-01 / P2 / UX·시각:** 시설 생산 골드·빈캔 및 행인이 정보 화면 앞으로 나타나 내용과 버튼을 가린다. 재현: 자동 자판기 설치 후 생산물이 남은 상태에서 시설창 또는 음료창을 연다. 시설 목록의 쓰레기통 버튼 위 골드, 콜라 해금 카드 위 골드·빈캔, 음료 자판기 위 행인을 관찰했다. 두 화면에서 2/2 확인. [시설](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-overlap.png), [음료](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-cola.png). 클릭 차단은 입증되지 않았다. 관련 소유 경로 `src/features/facilities/facility_world.gd`의 골드·물품 z_index 20, `src/features/facilities/effects/customer_flow.gd`의 actor z_index 1; 레이어 관계는 원인 후보이며 수정 전 확인 필요.
- **F-03 / P2 / 가독성:** 콜라 상세의 ‘반복 획득 가능’이 글자 단위로 줄바꿈되어 마지막 한 글자가 다음 줄로 밀리고, 해금 후에는 다음 안내와 수직으로 붙는다. 1152×648과 1280×720에서 확인했다. [해금 전](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-cola.png), [후](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/clicker-terra-cola-unlock.png), [1280](/Users/hongtaeho/clicker/.godot/test_artifacts/terra-user-test/cola-1280.png). 관련 소유 경로는 `src/features/drinks/drink_screen.gd`의 상세 effect/status 레이블이며 구체적 수정안은 미확정이다.

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

현재 생산 아이콘이 고정 대기하고 직접 클릭해야 하는 상태(F-02)를 최신 기획에 맞추는 것이 우선이다. 아래 HUD 이동 방식과 시간·강도는 미확정 제안이다.

- **효과:** 자동화로 생긴 보상이 지급됐음을 클릭 없이 이해하게 한다.
- **발생 조건·재사용:** 시설 생산 시 기존 골드 아트와 `facility_world.gd`의 표현 책임을 사용한다. 지급은 기존 세션·저장 소유 경계를 따른다.
- **동작:** 생산 → 짧게 튀어오름 → 골드 HUD로 이동 → 종료·정리.
- **중첩·정보창:** 여러 생산이 겹쳐도 각 지급은 한 번이며 정보창 위에 아트를 표시하지 않는다.
- **모션 감소:** 짧은 이동 또는 즉시 표시로 같은 지급 정보를 전달한다.
- **재검수:** 3주기 무입력 잔액 증가·중복 지급 없음·정보창과 감소 모드에서도 동일한 지급을 확인한다.

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
