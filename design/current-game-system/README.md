# 게임 디자인 시스템 · 현재 원본 안내

디자인 SSOT는 Penpot이다. 다른 세션의 HUD A 채택본을 포함해 2026-10-20에 재정리했다. `00 · 디자인 시스템`에서 **채택 디자인(01–03) → 현재 구현(90–93) → 참고(98–99)** 순서로 확인한다.

| 보드 | 범위 |
| --- | --- |
| [01 / 파운데이션 · A 채택](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=438228d3-7709-80fa-8008-d11fbc46be89) | 승인 팔레트 24색·Cafe24 글꼴·6크기·5상태·입력 반응 |
| [02 / 버튼 · A 채택 · 메인 5종](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=d9c1a69c-6a27-809e-8008-d107e6137aa4) | 지도·능력·강화·자동화·메뉴의 5상태 |
| [03 / 버튼 · A 채택 · 공통 조작·비용·메뉴](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=d9c1a69c-6a27-809e-8008-d107e619a122) | 뒤로·닫기·이전/다음·탭·비용·계속하기·설정·타이틀 |
| [90 / 현재 구현 · Play 파운데이션](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=b3f38c37-8163-8042-8008-d100d2d53ef9) | 기존 Play 공통 색상 16개·글자 역할 6개·9분할 프레임 |
| [91 / 현재 구현 · Play 컴포넌트](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=b3f38c37-8163-8042-8008-d10122b08b05) | 능력·청록 버튼 4상태, 음료 상세·수집 목표·재화·가격 마스터 |
| [92 / 현재 구현 · 조합·상태·피드백](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=b3f38c37-8163-8042-8008-d100d704010a) | 해금 가능·재료 부족·HUD 조합·능력 획득 알림 |
| [93 / 현재 구현 · 메뉴·전용 값](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=b3f38c37-8163-8042-8008-d1013d32deb1) | 현재 메뉴·일시정지 테마와 화면 전용 크기 |
| [98 / 참고 · 기존 UI 검토안](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=6d00bd1a-d292-8094-8008-d0f9313fec88) | 기존 검토안·비교 자료 |
| [99 / 참고 · 가격 버튼 A 원형](https://design.penpot.app/#/workspace?team-id=ce180602-f36b-8035-8008-cda23f0a1b46&file-id=cd444aaf-0d8c-801b-8008-cda246e18650&page-id=490e660f-738c-80e7-8008-d0f0d410a6b5&layout=layers&board-id=6d00bd1a-d292-8094-8008-d0f8e64f5a10) | 기존 A 가격 기본형의 편집 원형·재사용 의존성 유지 |

## 채택된 A 버튼

원본·컴포넌트 ID와 출력 규격은 [HUD A 안내](../hud-buttons/README.md)와 해당 `penpot-manifest.json`을 따른다. 조립 마스터 79개와 기존 가격 기본형을 합쳐 16종 × 5상태다. 분리 원본 30프레임·14아이콘은 기존 `02 · 에셋`의 HUD A 보드에 있고, 연결된 조립 견본 18개를 유지한다.

`01`은 기존 `Clicker / UI / Pixel A / 승인 팔레트` 24색을 연결한 스와치다. 기본·호버·눌림·비활성의 면·빛·밑면·외곽과 문구·포커스·아이콘 색상을 구분한다. Cafe24 PRO UP Regular, 메인 28px·공통 28/24px·문구 외곽 2.2px를 기존 마스터에서 확인했다. 프레임 6크기와 normal·hover·pressed·disabled·focus, 호버 90ms·눌림 60ms/아래 4px·복귀 100ms·출력 여백 6px를 같은 보드에서 확인한다.

디자인 시트 채택과 게임 적용은 별개다. 게임용 SVG는 `src/shared/ui/icons/hud_buttons/`에 준비되어 있으나 게임 화면·테마 연결은 후속 작업이다. 기존 Play 스타일을 A로 일괄 교체한 상태로 간주하지 않는다.

## 현재 구현과 참고 자료

- `90`: 기존 `Clicker / CurrentGame / Core` 16색, `Type / Core` 6역할(30·23·18·16·26·28px), 프레임 9분할 L14/T14/R14/B18. 전용 15개 크기는 `93`에서 구분한다.
- `91`: 기존 능력·청록 액션 버튼 4상태, 음료 상세·수집 목표·재화 HUD·가격판. 네이티브 문구와 연결 인스턴스를 유지한다. HUD 아트는 기존 컴포넌트 `d7a10464-8e4d-803c-8008-ceb3277ad90a`를 재사용한다.
- `92`: 해금 가능·빈캔 부족, 재화·가격, 능력 획득 알림. `src/features/play/effects/ability_toast.gd`의 510×94, 제목 21·본문 18px, 1.0초 유지+0.6초 소멸을 표시한다. 예시 수치는 확정 기획이 아니다.
- `93`: 현재 메뉴·일시정지의 별도 테마·화면 전용 글자 크기. 맑은 고딕 400·700은 Penpot 미설치이며 안내용 Noto Sans KR과 구분한다. 다국어 대체 폰트 정책은 미확정이다.
- `98–99`: 검토안과 기존 가격 원형이다. 현재 채택·게임 적용의 근거로 혼동하지 않는다. A 가격 기본형의 마스터 참조는 유지한다.

수집 목표의 활성 마스터: `9a779784-0f70-804d-8008-d10bebded89b`, 컴포넌트 `9a779784-0f70-804d-8008-d10bfd5355f7`. 원본이 없는 이전 컴포넌트 `b3f38c37-8163-8042-8008-d1013cd498b1`는 참조가 없음을 확인하고 `Clicker / Archive / Missing main / QuestPanel · 원본 없음 · 사용 안 함`으로 격리했다. 이전 빈 항목의 삭제는 UI·공개 API에서 확인되지 않아 삭제 완료로 보고하지 않는다.

## 검수 범위

4개 페이지의 보드 구조를 확인했다. 게임 화면 6개·에셋 11개·보관함 16개 루트는 유지하고, 시스템 00만 위 9개 보드로 정리했다. Pixel A 라이브러리 컴포넌트 123개와 승인 색상 24개를 편집기에서 대조했다. 새 파운데이션은 기존 색상 참조를 사용하며 새 버튼·색상·타입 마스터는 만들지 않았다. 에셋 시트에서 떠 있던 제목·견본 설명은 네이티브 Text로 갱신했다. 저장 후 다시 열어 보드 순서·배치, 글자·스와치, 버튼 상태·참조를 검수했다.

이번 정리는 편집 원본과 안내 문서 변경이다. 게임 코드·적용 에셋·기획은 변경하지 않았으며 엔진 테스트는 수행하지 않았다. 작성 절차는 [DESIGN.md](../../DESIGN.md)에 두고 Penpot에는 작성 규칙 보드를 만들지 않는다.
