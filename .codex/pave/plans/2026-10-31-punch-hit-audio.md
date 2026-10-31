# 펀치 피버 자판기 타격음

## 범위·결정·승인
- 사용자 파일 mixkit-soft-quick-punch-2151.wav를 펀치 피버의 허용된 자판기 타격마다 단발 재생한다. 꽝도 타격이므로 재생한다. 일반 수색/구매·피버 자동 발동·차단된 입력은 재생하지 않는다.
- 원음 볼륨으로 기존 Effects/Master 볼륨·음소거를 따르며, 기존 수색음처럼 빠른 클릭의 중첩 8개를 허용한다. 반복 재생은 끈다. 기존 수색·코인음은 유지한다.
- 사용자가 “승인, 펀치 타격음 적용”으로 통합 승인했다. 기존 main.tscn/customer_frames.tres/play_theme.tres 사용자 수정은 제외한다.

## 소유자·변경 경계
- owner-found: play.gd _on_punch_button_pressed의 차단 검사 다음에만 재생한다. play.tscn의 SearchClick/SearchCoin와 같은 AudioStreamPlayer 패턴으로 PunchHit 노드를 추가한다. 새 오디오 관리자·세션 보상/시간 변경 없음.
- assets/audio/mixkit_soft_quick_punch_2151.wav는 실제 사용하는 사용자 제공 원본 에셋으로 새로 필요하다. Godot import 메타데이터는 원음 게인·반복 없음으로 둔다. 기존 LICENSES.md에 출처를 추가한다.
- 기존 punch_fever_test.gd에서 실제 본체 타격/꽝·rapid 입력·차단/비피버 무재생 및 오디오 계약을 보호한다. 별도 테스트 파일은 만들지 않는다.
- PRODUCT/Notion에는 펀치 타격음 사용 규칙을 반영하며 코드 안내의 기존 오디오 소유자 안내를 갱신한다. 시각 디자인 변경 없음.

## 검증
- [x] 문서·기존 오디오·타격 소유자/호출자·회귀·첨부 WAV 확인.
- [x] 코드·테스트·원문 동기화 통합 승인.
- [x] 에셋·씬·허용 타격 연결 및 기존 회귀 확장.
- [x] Godot import/editor parse, punch_fever/search/settings 회귀, git diff --check와 타입/탭/LF/변경 책임 검토.
- [x] Notion/PRODUCT·출처·코드 안내 동기화 및 Knowledge Delta 평가.
- [x] 작업 파일만 커밋·로컬 main 머지, 기존 수정 보존, push 없음.

## 검증 결과·Knowledge Delta
- 사용자 원본 24비트 WAV가 Godot import에서 미지원 형식 오류를 내어 16비트 표준 PCM으로 변환했다. 44.1kHz/스테레오/0.480초 및 게인은 유지하며 import의 normalize/trim/loop는 끄고 압축하지 않는다. 다운로드 원본은 수정하지 않았다.
- import/editor parse, punch_fever_test/search_test/settings_test 및 git diff --check 통과. 처음 펀치 검사는 이전 타격의 재생 상태를 새 구매 재생과 혼동해 실패하여 구매 전 재생을 멈추고 새 호출의 무재생을 검사하도록 격리한 뒤 통과했다.
- 기존 Play의 입력 차단·AudioStreamPlayer·Effects 버스 패턴을 재사용했다. 새 런타임 구현 파일/관리자 없음. 새 에셋과 import는 실제 사용하는 음원의 필수 런타임 리소스다.
- Notion의 기존 사운드 목록에 타격음 규칙을 추가하고 reload 후 내용 보존을 확인했다. 증빙: .godot/test_artifacts/punch-hit-notion.png. PRODUCT/출처/코드 안내 갱신.
- Knowledge Delta: 코드 안내에 펀치음의 소유자·호출 위치·회귀 계약을 추가했다. 포맷 호환 문제는 해당 에셋의 출처 및 이 계획에 변환 근거를 기록하며 별도 범용 문서는 만들지 않는다.
