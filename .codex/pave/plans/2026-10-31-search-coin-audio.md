# 수색 성공 코인 획득음

## 범위·승인
- 사용자 확정: 제공한 mixkit-coins-handling-1939.wav를 수색으로 코인을 획득할 때 재생한다. 일반 수색/수색 피버의 양수 결과에 한 번 재생하고 진행 클릭·꽝·펀치·시설/퀘스트 보상에는 적용하지 않는다. 원음 기준으로 기존 Effects/Master 설정을 따른다.
- 사용자가 “승인, 코인 획득음 적용”으로 코드·검사·노션 반영을 통합 승인했다. 입력 파일은 44.1kHz/16-bit stereo, 50352 frames(약 1.142초)다. 기존 수색 클릭음과 BGM은 유지한다.

## 기존 소유자·구현·원본
- owner-found: play.gd _on_earn_button_pressed의 session.search 양수 분기가 재생 위치다. _show_coin_reward는 펀치와 공유하므로 그 함수에 사운드를 연결하지 않는다. 실제 지급/저장/확률은 변경하지 않는다.
- owner-found: play.tscn SearchClick과 동일한 전용 AudioStreamPlayer 방식으로 SearchCoin을 추가하며 Effects 버스·최대 8개 중첩을 사용한다. 클릭음과 획득음을 구분하고 새 관리자/설정은 만들지 않는다.
- 새 파일 assets/audio/mixkit_coins_handling_1939.wav와 import 메타데이터는 실제 재생 자산으로 필요하다. 원본 PCM은 변경하지 않고 반복 없이 가져온다. 기존 assets/audio/LICENSES.md에 동일 Mixkit 효과음 라이선스·출처를 추가한다.
- tests/features/search_test.gd는 진행/꽝/공유 시각효과 호출의 무재생, 실제 성공 재생, 차단/펀치 무재생을 보호한다. 수색/수색피버/펀치/설정 검사를 실행하고 필요 시 오디오 믹서 종료 수명을 정리한다.
- Notion/PRODUCT와 코드 안내에 채택 사운드·정확한 트리거를 동기화한다. 시각 디자인 변경은 없어 Penpot 수정은 해당하지 않는다. 접근 실패는 미동기화로 기록한다.

## 체크리스트
- [x] PRODUCT/PAVE/코드 안내/구조/품질 규칙·공유 보상 호출·실제 WAV 확인.
- [x] 코드·테스트·노션 통합 승인.
- [x] 채택 WAV/import·전용 플레이어·수색 양수 분기·기존 출처 문서 추가.
- [x] 수색/꽝/차단/펀치·피버/설정 회귀, import/editor parse·diff/스타일 검사.
- [x] Notion/PRODUCT/코드 안내 동기화, 검증된 Knowledge Delta 평가.
- [x] 이번 변경만 커밋·로컬 main 머지, 기존 변경 보존, push 없음.


## 검증·Knowledge Delta
- 기존 수색의 양수 분기에만 재생 호출 1줄을 추가했다. 공유 _show_coin_reward·펀치·시설·퀘스트 경로는 변경하지 않았다. 전용 SearchCoin은 기존 SearchClick과 같은 AudioStreamPlayer/Effects 버스/최대 8개 중첩을 사용한다. 별도 관리자·설정·보상 원장은 없다.
- 원본과 런타임 WAV의 SHA256는 28b8e52a2ec8504d98ce112c48ae9a6781951dd4b63ff233c44e791aa6895090로 동일하다. 44.1kHz/16-bit stereo·50352 frames이며 PCM·정규화 없음·반복 비활성화로 가져왔다. 기존 라이선스 문서에 출처/동일 Mixkit 조건을 추가했다.
- Godot 4.7.2의 search_test(진행/꽝/공유 연출 무재생, 성공 재생, 차단/펀치 무재생), search_fever_test, punch_fever_test, settings_test, menu_test를 모두 통과했다. import/reimport와 editor parse/resource 검사, git diff --check, 추가 GDScript 타입·탭/LF·100자 및 실제 diff 소유자 검토를 완료했다. 전체 회귀/실제 청취 검수를 했다고 주장하지 않는다. 자동 린터/릴리스 빌드는 기존 미설정이다.
- Notion 화면과 보상 표현에 코인 획득음 항목을 추가하고 새로고침 후 저장 문구를 확인했다. PRODUCT와 코드 안내에 정확한 수색 트리거·자산·회귀 계약만 갱신했다. 시각 디자인 변경이 없어 Penpot 수정은 해당하지 않는다.
- Knowledge Delta는 수색 전용 성공음의 소유자/공유 연출과 분리된 트리거를 기존 코드 안내에 반영했다. 단순 효과음 연결 때문에 별도 troubleshooting 문서는 만들지 않았다. 새 파일은 실제 채택 WAV/import와 PAVE 계획뿐이다. 기존 main.tscn/customer_frames.tres/play_theme.tres 변경은 보존하고 이번 커밋에 포함하지 않는다.
