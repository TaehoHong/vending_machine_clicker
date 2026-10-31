# 사용자 지정 수색 클릭음 적용

## 사용자 확정·승인
- 2026-10-31 사용자가 제공한 mixkit-arrow-whoosh-1491.wav를 수색 클릭음으로 채택했다. 이전 합성 1번/20% 볼륨 제안은 미확정 상태였으며 이 파일로 대체한다. 새 파일은 원음 게인으로 사용하고 기존 Effects/Master 설정이 적용된다.
- 사용자가 “승인, 수색 클릭음 적용”으로 코드·회귀·노션 반영을 통합 승인했다. 실제 입력 WAV는 44.1kHz/16-bit stereo, 약 1.099초다. BGM은 이미 채택된 재생을 유지한다.

## 소유자·경로·범위
- owner-found: play.gd _on_earn_button_pressed에서 허용된 수색 클릭마다 전용 AudioStreamPlayer를 재생한다. 정보/퀘스트/시설/결과창·일시정지로 거절되거나 펀치로 전환된 클릭에서는 수색음을 재생하지 않는다. 구매/보상/저장 규칙은 바꾸지 않는다.
- owner-found: Preferences가 Effects/Master 버스·음소거·볼륨을 소유한다. 기존 버스를 사용하고 새 관리자/설정 항목은 만들지 않는다.
- owner-absent: 수색 오디오 재생기는 없다. play.tscn에 SearchClick 노드를 추가하고 assets/audio/mixkit_arrow_whoosh_1491.wav 및 해당 import 메타데이터를 사용한다. 반복하지 않고 최대 8개 중첩으로 빠른 클릭의 연속음을 허용한다. 실제 채택 에셋만 보관한다.
- assets/audio/LICENSES.md는 이번에 도입한 제삼자 오디오의 원본 파일명·Mixkit 라이선스 링크·이용 조건·수정 여부를 기록하기 위해 필요하다. 별도 음악 카탈로그/시스템 문서는 만들지 않는다.
- tests/features/search_test.gd에서 실제 허용 클릭 재생과 차단/펀치 입력 무재생을 검증하고 기존 settings/search/피버 회귀 및 import/editor parse·diff 검사를 실행한다. 테스트만을 위한 재생 카운터는 만들지 않는다.
- Notion/PRODUCT에 채택 사운드와 설정 규칙을 동기화하고 코드 안내에 소유자·회귀를 갱신한다. 시각 변경이 없어 Penpot 에셋 수정은 해당하지 않는다. 원문 접근 실패는 미동기화로 명시한다.

## 체크리스트
- [x] PRODUCT/PAVE/코드 안내/구조·에셋 규칙·기존 입력과 버스·원본 WAV·Mixkit 공식 라이선스 확인.
- [x] 코드·회귀·노션 통합 승인.
- [x] 실제 효과음/출처/import·전용 노드·허용 수색 입력 연결.
- [x] 수색/차단/펀치·설정/피버 검사·import/editor parse·실제 diff/스타일 검토.
- [x] 노션/PRODUCT/코드 안내 동기화와 Knowledge Delta 평가.
- [x] 작업 변경만 커밋·로컬 main 머지. 기존 변경 보존, push 없음.


## 검증·원본·Knowledge Delta
- 기존 Play 입력 소유자에 재생 호출 1줄과 씬의 전용 AudioStreamPlayer를 추가했다. Effects/Master 버스·현재 차단/펀치 분기를 재사용하고 별도 오디오 관리자·카운터·경제/저장 규칙은 만들지 않았다. 실제 참조 음원 및 출처 기록만 새 자산으로 보관한다.
- 원본/런타임 WAV의 SHA256는 C9AA08DE97E5A1235F9B2B4EB7A1096F2FE09586995859E46AA83E9066BADCA2로 동일하다. 44.1kHz/16-bit stereo 48482 frames(약 1.099초)를 손실 압축/정규화/잘라내기 없이 PCM으로 가져오고 반복을 명시적으로 비활성화했다.
- search_test에서 수색 전 무재생·허용된 빠른 클릭 재생·Effects 버스·단발 재생·pause/정보창/펀치 무재생을 확인했다. search_fever_test, punch_fever_test, settings_test, menu_test도 통과했다. 수색 피버 회귀는 종료 직전 재생기를 free하므로 믹서 정리를 위한 0.15초를 기다리게 했다. 기대값을 완화하거나 런타임에 중복 정리 시스템을 추가하지 않았다.
- Godot 4.7.2 import/reimport 및 editor parse/resource check, git diff --check 통과. 새 GDScript의 타입·탭/LF·100자와 실제 diff의 소유자 재사용·책임을 검토했다. 전체 회귀/실제 청취 검수를 했다고 주장하지 않는다. 자동 린터/릴리스 빌드는 기존 미설정이다.
- Mixkit 공식 Sound Effects Free License를 확인하고 assets/audio/LICENSES.md에 출처·상업 게임 end product 이용·단독/소스 배포 등의 제한을 기록했다. Notion 화면과 보상 표현에 수색 클릭음 항목을 추가하고 새로고침 후 문구를 확인했다. PRODUCT와 코드 안내는 같은 규칙/실제 소유자/회귀를 반영했다. 시각 디자인 변화가 없어 Penpot 편집은 해당하지 않는다.
- Knowledge Delta는 검증된 SearchClick/Effects/차단 입력 계약과 테스트 믹서 수명만 코드 안내에 반영했다. 별도 troubleshooting 문서는 만들지 않았다. 기존 main.tscn/customer_frames.tres/play_theme.tres 변경은 이번 커밋에서 제외해 보존한다.
