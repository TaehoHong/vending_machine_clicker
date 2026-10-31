# 네온 산책 BGM 반복 적용

## 범위·결정·승인
- 사용자 확정: 제공한 02_neon_stroll.wav를 반복되게 게임에 적용한다. BGM 중지 지시를 이 트랙 적용 요청으로 갱신한다. 미결 수색 클릭음 볼륨/게임 적용은 이번 범위 밖이다.
- 원본 SHA256가 이전 생성 파일과 같고 92 BPM/32박 음악 및 잔향을 포함한 22.3695초 stereo PCM임을 확인했다. 32박(20.8696초) 뒤 잔향을 첫 구간에 겹쳐 원래 음악을 유지한 루프 자산을 만들었다. 외부 음원은 사용하지 않는다.
- 사용자 승인 구현: 메인 메뉴부터 Play 전환/설정/ESC에서도 하나의 BGM이 계속 반복한다. 기존 Music/Master 설정·음소거를 사용한다. 볼륨 추가 감쇠는 요청하지 않았으므로 원본 수준을 유지하고 설정이 적용된다.
- 사용자가 “승인, BGM 적용 진행”으로 코드·회귀·노션 반영을 통합 승인했다. 기존 미커밋 main.tscn/customer_frames.tres/play_theme.tres와 이전 수색음 계획은 건드리거나 커밋하지 않는다.

## 소유자·새 경로·검증
- owner-found: src/app/main.gd는 메뉴/Play 수명을 소유한다. 같은 루트의 전용 AudioStreamPlayer 하나로 반복하며 화면마다 다시 생성하지 않는다. main.tscn의 사용자 변경을 피하고 기존 main.gd 초기화에 연결한다.
- owner-found: Preferences의 Music/Master 버스와 슬라이더/음소거를 그대로 사용한다. 별도 설정/오디오 관리자/저장 필드는 추가하지 않는다.
- owner-absent: 런타임 음악 자산이 없으므로 실제 사용 파일 assets/audio/neon_stroll_loop.wav와 Godot import 메타데이터를 추가한다. 반복 메타데이터는 에셋 import가 소유하며 멜로디를 재작성하지 않는다. 비교 미리보기는 visualization에만 둔다.
- 기존 tests/features/menu_test.gd에 BGM 단일성/재생/루프 경계/메뉴→Play 및 pause 지속을 추가한다. settings_test로 기존 버스 설정을 보호하고 Godot import/editor parse, git diff --check를 실행한다. 테스트를 위한 음악 관리자나 무관한 회귀 수정은 만들지 않는다.
- Notion과 PRODUCT에 채택 트랙·반복·설정 규칙을 동기화하고 코드 안내에 소유자/검증을 갱신한다. 시각 디자인 변경은 없어 Penpot 시각 에셋 수정은 해당하지 않는다. 접근 실패는 미동기화로 명시한다.

## 체크리스트
- [x] PRODUCT/PAVE/코드 안내/구조·에셋 규칙과 소유자·입력 파일 확인, 루프 미리보기 작성.
- [x] 코드·테스트·기획 반영 통합 승인.
- [x] 실제 루프 WAV/import 및 앱 루트의 BGM 연결.
- [x] 메뉴/Play/일시정지/반복·설정 회귀와 import/editor parse·diff 검사.
- [x] Notion/PRODUCT/코드 안내 동기화와 Knowledge Delta 평가.
- [x] 검증된 변경만 커밋·로컬 main 머지, 기존 사용자 변경 보존, push 없음.


## 검증·Knowledge Delta
- main.gd의 기존 앱 소유자에 AudioStreamPlayer 하나를 추가했다. 새 런타임 스크립트/설정/관리자는 없다. 실제 재생 파일과 import 설정만 assets/audio에 추가했으며 원본 음량·기존 Music/Master 버스를 재사용한다.
- WAV는 44.1kHz/16-bit stereo, 920348 frames, 약 20.86957초다. 피크 약 -2.158dBFS로 클리핑이 없고 반복 경계 차이는 좌/우 각각 약 -0.00412/-0.00272이다. 원본 파일은 변경하지 않았다. 끝 잔향만 첫 구간에 겹쳐 음악/템포를 유지했다.
- Godot WAV import의 forward 항목 edit/loop_mode=2를 사용하고 PCM으로 가져와 손실 압축 없이 재생한다. 이 값은 런타임 AudioStreamWAV.LOOP_FORWARD로 불러오는 것을 실제 검사했다. 참고 원문: https://docs.godotengine.org/en/latest/classes/class_resourceimporterwav.html
- Godot 4.7.2의 import 및 editor parse/resource 검사 통과. menu_test는 headless와 실제 D3D12/오디오 환경 모두 통과했다. 실제 루프 끝으로 seek한 뒤 경계 통과·단일 플레이어 유지·ESC 중 재생 시간 진행을 확인했다. settings_test의 Music 음소거/40% 게인 및 gameplay_test도 통과했다. git diff --check와 추가 GDScript의 타입·LF·100자 검사를 통과했다.
- AudioStreamPlayer의 첫 play가 믹서에 반영된 뒤 seek하도록 회귀의 초기화를 기다리고, 앱 free 후 믹서의 재생기 참조가 정리되도록 테스트 종료를 기다린다. 검사 기대를 완화하거나 런타임에 중복 루프 코드를 추가하지 않았다.
- Notion의 화면과 보상 표현에 BGM 항목을 추가하고 새로고침 후 문구를 확인했다. PRODUCT와 코드 안내에 검증된 트랙/소유자/설정/회귀 계약만 반영했다. 시각 디자인는 바뀌지 않아 Penpot 에셋 수정은 해당하지 않는다. Knowledge Delta는 코드 안내에 통합하고 별도 troubleshooting 문서는 만들지 않았다.
- main.tscn/customer_frames.tres/play_theme.tres의 기존 미커밋 변경과 수색음 미결 계획은 이번 커밋에서 제외한다. 린터/릴리스 빌드는 기존 미설정이며 전체 회귀를 실행했다고 주장하지 않는다.
