# 03. 배포·저장 운영

제품 정책은 Notion의 `2026-10-20 · 프로젝트 방향 · 사용자 확정` 절을 따른다. 이 문서는 운영 준비 상태와 후속 결정 위치를 기록한다.

## 확인된 현재 상태

- `project.godot`를 Godot에서 여는 로컬 개발 프로젝트다. Windows D3D12 설정이 있으나 배포 성공 증거는 아니다.
- `export_presets.cfg`, CI 워크플로, Steamworks App ID·클라우드 경로 설정은 저장소에서 확인되지 않았다. 릴리스 빌드 명령은 아직 선언할 수 없다.
- `main.gd`는 새 게임 전에 기존 저장을 `user://backups/`에 복사하고 실패 시 새 게임 진입을 막는다. `game.gd`는 `user://progress.cfg`를 읽고 쓴다. Steam Cloud 연동과 계정별 저장 격리는 아직 없다.
- 게임 플레이 분석 수집·서버 작업 스케줄러·모바일 인증 연동은 확인되지 않았다. 현재 자동화 기획을 서버 백그라운드 잡 또는 오프라인 생산 승인으로 확대 해석하지 않는다.

## 저장 경계

PC의 로컬 저장과 Steam Cloud 동기화, 모바일의 별도 계정·저장은 제품 방향상 분리된다. [Steam 공식 문서](https://partner.steamgames.com/doc/features/cloud)는 Auto-Cloud의 실행 전·종료 후 파일 동기화와 기기별 설정의 분리를 설명한다. 현재 코드에 맞는 우선 검토 후보이며, 연동 API·경로·충돌 상세는 기능 기획에서 정한다.

## 설정 공백·미확정

| 항목 | 상태 | 후속 확인 |
| --- | --- | --- |
| Godot 실행 파일·내보내기 템플릿 | setup gap | 4.7 실행 환경과 export 준비 |
| Steamworks·출시 환경 | setup gap | App ID·검증용 환경·배포 권한·저장 경로 설정 |
| 릴리스·업데이트·롤백 운영 | unresolved-after-asking | 사용자와 운영 담당·배포 절차 확정 |
| 로그·오류 관측·보존 | unresolved-after-asking | 분석 수집 제외 방침을 유지하며 진단 범위 결정 |
| 저장 호환·충돌·손상 복구 | deferred-to-feature-planning | 기존 데이터 보존을 검증하는 저장 기능 설계 |
| 모바일 저장 제공자 | unresolved-after-asking | 후속 모바일 계정·저장 기획 전에 제공자 결정 |
| 판매 가격 | unresolved-after-asking | 게임 판매 가격 확정; 인앱결제 도입으로 추정하지 않음 |

## Linked Sources

| Source | Owns | Not covered | Evidence paths |
| --- | --- | --- | --- |
| [Notion](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de) | 출시·저장·과금 범위 SSOT | Steamworks 실제 설정 | PRODUCT.md, project.godot |
| [README.md](../README.md) | 로컬 저장·백업 사용 안내 | 클라우드·배포 절차 | main.gd, game.gd, README.md |
