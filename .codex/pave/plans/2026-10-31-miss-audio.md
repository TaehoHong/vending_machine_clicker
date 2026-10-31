# 꽝 효과음 Losing bleeps

## 범위·승인·소유자
- 사용자 선택: Mixkit Losing bleeps(2026), 원음보다 20% 감소한 80% 선형 게인. 효과음/전체 음량·음소거를 추가로 따른다.
- Mixkit lose 페이지의 Losing bleeps Download Free SFX로 원본을 Downloads/mixkit-losing-bleeps-2026.wav에 다운로드했다.
- owner-found: Play의 _on_earn_button_pressed와 _on_punch_button_pressed에서 earned==0일 때만 새 MissResult AudioStreamPlayer를 단발 호출한다. 기존에는 이 재생기가 없으므로 play.tscn에 SearchCoin/PunchHit과 같은 Effects 버스 노드를 추가한다. _show_empty_search는 공용 시각 표현으로 남겨 테스트/그림 호출이 새 소리를 내지 않도록 한다.
- 원본을 assets/audio/mixkit_losing_bleeps_2026.wav에 런타임 에셋으로 두고 Godot import(반복/정규화/트림 끔, 필요 시 무압축 16비트 호환 변환)를 둔다. 새로운 오디오 관리자나 코드 파일은 없다.
- 기존 search_test/punch_fever_test에 진행/성공 무재생·꽝 재생·차단 무재생을 검사한다. 기존 회귀를 확장하고 별도 테스트 파일은 만들지 않는다.
- PRODUCT/Notion 사운드 목록과 기존 LICENSES/코드 안내를 갱신한다. 시각 디자인 변경 없음. 기존 main.tscn/customer_frames/play_theme 수정은 보존한다.
- 사용자가 “승인, 꽝 효과음 적용”으로 코드·검사·노션 반영을 통합 승인했다.

## 체크리스트
- [x] 문서/소유자/직접 호출·회귀·음원 다운로드 확인.
- [x] 통합 승인 후 씬·꽝 분기·음원과 검사 적용.
- [x] import/editor parse·search/punch/settings 회귀·diff/타입/탭/LF/책임 검사.
- [x] Notion 저장 후 재조회·PRODUCT/출처/코드 안내 동기화.
- [x] Knowledge Delta 평가와 작업만 로컬 커밋/main 병합. push 없음.

## 검증·동기화·Knowledge Delta
- WAV 원본과 게임 에셋의 바이트 동일성을 확인했다. 44.1kHz/16비트/스테레오, 실제 길이는 약 1.993초다. 원음 파일을 변경하지 않고 플레이어 게인만 linear_to_db(0.8)에 해당하는 약 -1.9382dB로 지정했다.
- Godot import/editor parse, search_test(0 failures), punch_fever_test, settings_test 모두 통과했다. git diff --check 및 추가 GDScript의 탭/LF/100자 길이 검사를 통과했다.
- 기존 Play 표현·Effects 버스를 재사용했고 별도 관리자/타이머/새 코드 파일은 추가하지 않았다. 보상·진행 규칙 변화 없음. 시각 표현 함수에 소리를 섞지 않았다.
- Notion 기존 사운드 목록에 80% 꽝 재생 규칙을 추가하고 reload 후 화면에서 내용 보존을 확인했다. .godot/test_artifacts/miss-audio-notion.png 증빙 저장. PRODUCT·LICENSES·코드 안내도 갱신했다.
- Knowledge Delta: 기존 코드 안내에 꽝 재생 소유자/재생 조건/회귀 위치를 반영했다. 별도 문제 해결 문서가 필요한 새로운 사고나 구조 변경은 없다.
