# 기존 동작 유지 · 런타임 구조 전환

## 결과

- `src/app`이 메뉴·Play·세션·저장소를 연결한다. 게임 진행·구매/수색/해금/퀘스트·피버는 `src/game`, 화면·연출은 `src/features`, 파일 I/O·이전 저장 변환은 `src/integrations/saves`로 분리했다.
- 단일 세션이 진행을 소유한다. 화면의 별도 진행 원장과 중복 금액 포맷·카탈로그 JSON 원본을 두지 않는다. 공통 테마·아이콘과 데이터·개발 도구·검증을 승인한 실제 경로에 배치했다.
- `user://progress.cfg`의 형식·정규화·백업, 상품 인덱스·가격·보상·입력·pause·연출을 보존했다. 이번 작업에서 기획·디자인은 변경하지 않았다.
- 동시 HUD 작업의 main `1f7926f`를 merge로 보존했다. 분리 SVG 44개를 `src/shared/ui/icons/hud_buttons/`로 그대로 이동하고 안내 링크를 갱신했다. 화면 적용은 여전히 미적용이다.

## 검증

공식 SHA512와 일치한 임시 Godot `4.7.stable.official.5b4e0cb0f`로 실행했다. 시스템/PATH 설치와 배포 검증은 별도다.

| 검사 | 결과 |
| --- | --- |
| `godot --headless --editor --path . --import` / `--quit` | 통합 상태 모두 통과; 스크립트·리소스 오류 없음 |
| `docs/05-quality-rules.md`의 독립 회귀 16개 | 16/16 통과; 실제 사용자 저장 대신 임시 저장 사용 |
| 저장 필드 누락 mutation | `extra_counts` 쓰기를 누락시키면 assertion 2개 실패; 원복 후 통과 |
| 실제 렌더러 전후 비교 | 같은 viewport·애니메이션 위상의 메뉴·Play·음료 초기/선택·요약·pause 6개 화면 픽셀 동일 |
| 이미지·SVG·폰트·라이선스 보존 | 이전 파일 53개와 동시 HUD SVG 44개 byte 동일; 신규 SVG XML 파싱 통과 |
| 경로·의존성·diff 검토 | 런타임 리소스 경로 유효; game의 화면/I/O 의존과 features의 직접 I/O 없음 |
| 포맷·공백 | 수정 코드/테스트/도구 29개 `gdformat -l 100 --check` 통과, `git diff --check` 통과 |
| 미리보기 생성기 | 실제 단일 카탈로그로 실행; 채택 씬/테마 해시 불변, 임시 출력 리소스 경로 유효 |

원본 `34cff7c`의 테스트는 11/15였다. 입력 실패 2개는 원본 생산 코드에 viewport 로컬 좌표 플래그만 명시해 같은 assertion의 통과를 확인했다. 표시 실패 2개는 이미 교체된 이전 UI를 검사하므로 채택된 화면의 실제 선택·요약·잠금 표시로 검사 대상을 바꿨다. 가격·차감·보상·저장 기대값을 완화하지 않았다.

실행 로그와 비교 이미지는 이번 호스트의 `/private/tmp/clicker-refactor-final/`, `/private/tmp/clicker-refactor-baseline-results/`, `/private/tmp/clicker-render-baseline/`, `/private/tmp/clicker-render-modern/`에 있다. 임시 검증 자료이므로 저장소에는 넣지 않았다.

## 남은 경계

- Windows 실제 배포·전체 지원 언어·플레이 감각의 사람 검수는 수행하지 않았다. export/Steamworks·CI·고정 포매터/린터 설정은 기존 setup gap이다.
- 기존 `design/page-organization/README.md` 링크 3개는 main에 대상 파일이 없어 남아 있다. 별도 Penpot 작업의 미커밋 파일을 가져오거나 원본 동기화 완료로 처리하지 않았다. 구조 전환이 만든 링크 결함은 아니다.
- 공유 체크아웃과 별도 디자인 작업의 미커밋 변경은 건드리지 않았다. 불필요한 기존 파일 삭제·미래 플랫폼 폴더·SDK·추상 계층을 추가하지 않았다.

## Knowledge Delta

검증된 실제 모듈 경계·상태 소유자·공유 예시·리소스/테스트 경로·입력 좌표 규칙을 `docs/06-architecture.md`, `docs/07-codebase-guide.md`, `docs/05-quality-rules.md`와 관련 안내에 반영했다. 개별 실행 이력이나 임시 가설을 별도 규칙으로 승격하지 않았다. 테스트 harness 원인과 회귀 보호가 위 문서에 남아 있어 중복 troubleshooting 문서는 만들지 않았다.

## Git

- 구현: `cc360a6`.
- 최신 main 반영: `2b05179`가 `1f7926f`의 HUD 작업을 보존한다.
- 통합 검증까지 완료했다. 최종 로컬 main 머지는 승인 범위의 마지막 단계다.
