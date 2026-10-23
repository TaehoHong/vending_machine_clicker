# 로컬 게임과 GitHub 동기화

## 범위와 승인

- 사용자 승인: 로컬 테마·문서·계획과 옛 씬을 정리하고 실행·테스트 후 GitHub에 반영한다.
- 신규 기능·기획·디자인 변경은 없다. 대기 중인 상세 패널·일시정지 구현은 포함하지 않는다.
- owner-found: 실행 진입점은 `src/app/main.tscn`, 공통 테마는 `src/shared/ui/themes/play_theme.tres`다.
- 테마 변경은 기존 Theme와 공식 폰트의 UID 메타데이터 2줄이며 외형·참조 경로는 유지한다.
- 루트 `Game.tscn`·`main.tscn`은 미추적 옛 씬이다. 삭제된 `game.gd`·`images/`·`ui/`를 참조한다.
- 활성 `src/`·`tests/`·`project.godot`은 두 루트 씬을 참조하지 않는다.
  과거 `design/coin-insert-concept/preview.gd`의 참조는 현재 앱 진입점이 아니다.
- 두 씬은 `.godot/local-backup-before-sync-2026-10-23/`에 백업하며 Git에는 추가하지 않는다.
- 디자인 안내의 중복 대기 기록은 제거하고 두 기존 계획에 미구현·재확인 필요 상태를 보존한다.
- 새 런타임 파일·테스트는 없다. 작업 계획만 추가한다.

## 검증

- [x] 로컬 변경·실행 진입점·씬 참조·원격 커밋 확인
- [x] 작업 브랜치에서 옛 씬 백업과 문서 정리
- [x] Godot import·parse 및 headless 앱 시작 확인
- [x] 메뉴·음료 화면·구매 가격·게임플레이·저장 호환 회귀
- [x] diff·공백·비밀정보·남은 파일 확인
- [ ] 로컬 main 반영·GitHub push·커밋 일치 확인

## 지식 반영

기존 아키텍처·소유권·기획·디자인은 변경하지 않아 별도 원본 동기화나 코드 안내 갱신은 불필요하다.
검증 결과는 아래에 기록하며 화면 외형의 신규 승인이나 출시 검증을 뜻하지 않는다.

## 검증 결과 · 2026-10-23

- Godot 4.7.2: import·editor quit·headless 기본 진입점 시작(`--quit-after 5`) 통과.
- `menu_test`, `drink_screen_test`, `purchase_price_test`, `gameplay_test`,
  `progress_store_test`가 각 독립 프로세스에서 오류 없이 완료되었다.
- 최초 샌드박스 import의 safe-save 권한 오류는 권한을 갖춘 재실행으로 해결했다.
- 테마의 기존 폰트 경로와 UID는 `assets/fonts/Cafe24PROUP.ttf.import`와 일치한다.
- `git diff --check` 통과. 새 비밀정보 패턴 없음. 옛 씬 백업 두 개는 Git 제외 경로에 보존했다.
- 실제 화면의 신규 디자인 검수·출시 빌드는 이번 동기화 검증 범위 밖이다.
- 마지막 main/push 항목은 이 문서 커밋 이후 실행하며 최종 Git ref 일치로 확인한다.
