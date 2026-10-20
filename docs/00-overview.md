# 00. 프로젝트 안내

기획·제품 정책의 SSOT는 [Notion](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de), 디자인 SSOT는 [Penpot](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650)이다. PAVE 문서는 원본을 찾아가는 운영·코드 안내다. 확정 기획을 별도로 복제해 관리하지 않는다.

## 온보딩

1. [AGENTS.md](../AGENTS.md)와 [PRODUCT.md](../PRODUCT.md)의 원본 링크·확인 시점·미동기화 상태를 읽는다.
2. 작업과 관련된 기획은 Notion, 디자인은 Penpot에서 확인한다. 접근 불가를 최신 확인으로 취급하지 않는다.
3. [코드 안내](07-codebase-guide.md)에서 소유 모듈·검증 경로를 찾고 현재 소스로 확인한다.
4. 사용자가 제품·디자인·플레이를 최종 검수하고 에이전트가 구현한다. 기능 상세 설계는 해당 기능 기획에서 한다.

## 초기화 근거 · 2026-10-20

- `user decision`: 인터뷰 예시안을 채택했고, 중국어 간체·번체 모두 지원, PC·모바일 진행 공유 제외, 일반적인 Steam 로컬+클라우드 저장, Notion/Penpot SSOT를 명시했다. 세부 방향은 Notion의 `2026-10-20 · 프로젝트 방향 · 사용자 확정` 절을 따른다.
- `repo fact`: `project.godot`는 Godot 4.7을 선언한다. GDScript·씬·리소스 기반 프로젝트이며 Node/Python은 게임 런타임 의존성이 아니다. 로컬 저장은 ConfigFile이다.
- `unsupported assumption`: 클라우드·로그인·다국어·자동화가 이미 구현되어 있다는 해석은 근거가 없으므로 채택하지 않는다.

## 문서 발견·감사 기록

수정일은 초기화 전 로컬 파일의 mtime이며 외부 원본의 갱신일을 뜻하지 않는다.

| Source | 담당 주제 / PAVE 연결 | 확인한 수정일 | 분류·주의 |
| --- | --- | --- | --- |
| Notion / PRODUCT.md | 제품·범위·로드맵·정책 → 00, 01, 03, 04, 06 | 로컬 2026-10-20 | Notion이 SSOT, PRODUCT는 부분 요약 |
| Penpot / DESIGN.md / design/README.md | 디자인 원본·적용 상태 → 04 | 로컬 2026-10-20 | Penpot이 SSOT, 시안·구현 캡처를 구분 |
| README.md | 실행·검증·과거 구현 → 02, 05, 07 | 로컬 2026-10-18 | `stale statement`: 고정 100 Gold·가지형 스킬트리 설명은 현재 코드와 다름 |
| design/planning/stages-2026-10-18.md | 지역 확장 검토 → 01 | 로컬 2026-10-18 | `stale statement`: 빈캔으로 주차장 해금은 현재 Notion의 황금 음료수 규칙과 다름 |
| ui/fonts/README.md / ui/fonts/Cafe24PROUP-SOURCE.md | 글꼴·출처 → 04 | 초기화 시 파일 존재 확인 | 글꼴 적용·권리 근거를 개별 확인 |
| project.godot / tests/ / ui/*.tres | 기술·실행·검증 → 05, 06, 07 | 초기화 시 현재 파일 확인 | 실행 가능한 근거이며 출시 설정은 아님 |

## 결정 영역 커버리지

`decided`는 방향 확정이며 기능 구현 완료가 아니다. 미정 세부를 기본값으로 구현하지 않는다.

| 영역 | 상태 | 근거·남은 범위 |
| --- | --- | --- |
| 목적·이용자·포지셔닝 | decided | Notion의 새 확정 절 |
| 성공 수치 | deferred-by-user | 예시안의 수익·다운로드 목표 보류 채택; 플레이 검수 기준은 확정 |
| 역량·우선순위·비목표 | decided | 01의 역량 맵과 Notion |
| 시스템 경계·공유 소유권·의존성 | decided | 현재 구조 출발, 진행과 계정·저장 연동 경계 구분; 06 |
| 계정·API·실시간·호환 | decided | Steam PC와 후속 모바일 분리, 멀티플레이 제외; 세부 API는 기능 기획 |
| 데이터·보안·프라이버시 | decided | 로컬+클라우드, 분석 수집 제외; 계정별 경로·복구 상세는 저장 기능 기획 |
| 모더레이션 | not-applicable-with-reason | 첫 버전 채팅·거래·멀티플레이가 없어 사용자 게시물 운영 영역 없음 |
| 과금·크레딧 | decided | 첫 버전 광고·인앱결제 제외; 게임 판매 가격은 unresolved-after-asking |
| 자동화·연동·제공자 | decided | Steam Cloud, 후속 Google/Apple; 자동화는 게임 내 기능. 모바일 저장 제공자는 unresolved-after-asking |
| 배포·관측·복구 운영 | unresolved-after-asking | Windows Steam·로컬 백업 방향은 확정. 배포 계정·릴리스 절차·로그 보존·복구 운영 상세는 미확정 |
| 디자인·접근성·기기 | decided | Notion의 출시 목표, 디자인 SSOT Penpot; 04 |
| 품질·검증 | decided | 자동 검증+사람 검수; 실행 도구 부재는 설정 공백, 05 |
| 온보딩·검수 소유권 | decided | 사용자 최종 검수, 에이전트 구현 |
| 기능별 수치·화면·저장 충돌 상세 | deferred-to-feature-planning | 초기화에서 상세 동작·스키마·레이아웃·테스트 케이스를 확정하지 않음 |

## Linked Sources

| Source | Owns | Not covered | Evidence paths |
| --- | --- | --- | --- |
| [Notion](https://app.notion.com/p/3fcb6b9ead24800aa7bce8a1e1b045de) | 기획 SSOT | 코드 탐색·실행 환경 | PRODUCT.md, AGENTS.md |
| [로컬 요약](../PRODUCT.md) | 원본 링크·확인 기록 | 독립 기획 원본 | PRODUCT.md |
| [자료 안내](../design/README.md) | Penpot 링크·산출물 위치 | 원본 디자인 자체 | DESIGN.md, design/README.md |

## 문서 색인

- [로드맵·역량 맵](01-roadmap.md)
- [개발 규칙](02-development-rules.md)
- [배포·저장 운영](03-deployment-rules.md)
- [디자인 규칙](04-design-rules.md)
- [품질·검증](05-quality-rules.md)
- [아키텍처](06-architecture.md)
- [코드 안내](07-codebase-guide.md)

## 초기화 완료 범위 · 2026-10-20

- PAVE 런타임, Codex·Claude 어댑터, 루트 작업 지침과 위 문서 8개의 초기 구성을 확인했다. 기존 원본 문서를 연결하고 사용자 결정·저장소 사실·미확정·기능 기획 이관을 구분했다.
- 초기화 헬퍼를 덮어쓰기 옵션 없이 재실행해 기존 파일이 모두 보존되고 내장 검증을 통과한 것을 확인했다. 문서 8개의 로컬 링크 49개와 선언된 테스트 대상 5개의 존재, `git diff --check`도 통과했다. 게임 코드·테스트·에셋의 구현 변경은 하지 않았다.
- Godot 실행 환경·export·CI·Steamworks 설정은 [품질 안내](05-quality-rules.md)와 [배포 안내](03-deployment-rules.md)의 설정 공백으로 남긴다. 초기화 완료를 게임 실행·출시 준비 완료로 해석하지 않는다.
- 판매 가격, 모바일 저장 제공자, 릴리스·진단 로그 운영과 성능 목표는 위 결정 영역 표의 미확정 상태를 유지한다. 관련 기능·출시 준비를 시작할 때 사용자와 확정하며 임의의 기본값을 구현하지 않는다.
- Penpot 페이지·에셋 정리는 별도 작업에서 진행한다. 이 초기화의 완료 범위에는 그 작업의 원본 검수·로컬 산출물 동기화가 포함되지 않는다.
