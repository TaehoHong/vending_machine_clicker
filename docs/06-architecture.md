# 06. 아키텍처

## 현재 구조 · repo fact

- 실행 진입은 `project.godot` → `main.tscn` / `main.gd` → `Game.tscn` / `game.gd`다. `CursorTheme`는 autoload다.
- `game.gd`가 진행 상태·수색·구매·보상·해금·피버·저장과 UI 연결을 소유한다. `main.gd`는 저장 존재 확인·새 게임 백업·불러오기 진입을 소유한다.
- `ui/drink_catalog.gd.DATA`는 런타임 상품 카탈로그다. `ui/skill_tree.gd`는 상품 선택·정보·요약을 표현하고 `unlock_requested`로 게임에 해금을 요청한다.
- `pause_menu.gd`는 일시정지·저장·종료 요청을 내보낸다. 시각 효과 모듈은 게임의 상태를 받아 표현한다. `game.gd`는 ConfigFile로 로컬 진행을 저장한다.
- 현재 별도 서버·DB·계정·네트워크 API·작업 큐는 확인되지 않았다. UI와 진행 코드가 이미 완전히 분리되었다는 뜻은 아니다.

## 프로젝트 경계 · user decision

SSOT인 Notion의 새 확정 절에 따라 현재 구조를 출발점으로 유지한다. 계정·저장 연동과 게임 진행의 경계를 구분하고 PC·모바일 진행을 분리한다. 초기화에서 리팩터링하거나 미래 제공자용 인터페이스를 미리 만들지 않는다.

진행 계산·저장은 기존 소유자에서 찾고 UI 안에 별도 구매·재화 원장을 만들지 않는다. 네트워크 제공자가 추가될 때 UI와 진행 코드에 인증 상태·외부 API를 산재시키지 않도록 기능 설계에서 경계를 검토한다. 상품 인덱스·키는 기존 저장에서 사용되므로 변경 시 마이그레이션을 함께 검토한다.

## 데이터·외부 시스템

진행 객체는 골드·음료 획득·해금·빈캔·퀘스트·구매 횟수다. 로컬 플레이어의 진행이 PC 저장 대상이며 Steam Cloud가 동기화 경계다. 후속 모바일은 별도 진행과 비회원·Google·Apple 경계를 사용한다. 토큰·자격 증명은 문서·로그·저장소에 남기지 않는다.

실시간 멀티플레이·채팅·거래·인앱결제·플레이 분석 수집은 첫 버전 범위 밖이다. 자동 자판기는 게임 내 역량이며 서버 잡·앱 종료 중 생산 방식은 확정되지 않았다.

## 결정 기록·미정 소유자

| 날짜 | 상태 | 결정 또는 남은 경계 | 근거 |
| --- | --- | --- | --- |
| 2026-10-20 | decided | 현재 Godot 구조에서 출발; 진행과 계정·저장 연동의 경계 구분 | 사용자 예시안 채택, Notion 새 확정 절 |
| 2026-10-20 | decided | PC 로컬+Steam Cloud; PC·모바일 진행 공유 제외 | 사용자 명시 지시, Notion |
| 2026-10-20 | deferred-to-feature-planning | 저장 경로·API·스키마·마이그레이션·충돌·복구 세부 | Notion 후속 저장 설계 절 |
| 2026-10-20 | unresolved-after-asking | 모바일 저장 제공자·운영 로그·릴리스 복구 절차 | 초기화 인터뷰에서 미확정, 03 참조 |

## Linked Sources

| Source | Owns | Not covered | Evidence paths |
| --- | --- | --- | --- |
| [Notion](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de) | 제품·플랫폼·저장 경계 SSOT | 상세 코드 의존성 | PRODUCT.md |
| [README.md](../README.md) | 기존 실행·저장 흐름 | 최신 시스템 경계·클라우드 | project.godot, main.gd, game.gd |
| [PRODUCT.md](../PRODUCT.md) | 원본 확인·구현 차이 요약 | 코드 구조 자체 | PRODUCT.md |
