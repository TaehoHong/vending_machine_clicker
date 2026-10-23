# 음료 해금 순서 제거

## Scope / 승인 상태

2026-10-23 사용자 요청: 음료 해금 순서 무관, 빈캔만 충분하면 해금. 정보창의 먼저 전단계 음료 해금 문구 삭제.
2026-10-23 사용자 통합 작성 승인 완료. 추가 승인: 콜라 빈캔10개·에너지 드링크15개로 인하.
모든 유료 해금 음료(황금 포함)에 적용하며 콜라10·에너지15로 변경하고 나머지 음료 비용은 유지한다. 황금은 빈캔30개 해금 후 기존 등장 확률·완료 보장을 유지한다. 이미 해금한 음료·획득 기록·저장 형식은 유지한다.

## 소유자·설계

- owner-found: src/game/game_session.gd unlock의 비용+선행 검사에서 선행 검사만 제거. 잔액 부족·중복 해금·잘못된 인덱스 방어와 차감/기록 소유권 유지.
- owner-found: src/features/drinks/drink_screen.gd _refresh_selection의 선행 버튼 비활성화와 먼저 음료 해금 분기 제거. 미해금 설명은 기존 해금 후 자판기에서 등장 문구 사용.
- owner-found: src/data/drink_catalog.gd의 parent는 위 두 곳에서만 사용됨. 폐기한 선행 메타데이터를 제거해 유효한 규칙처럼 남기지 않음. 비용·key/index·배치 순서는 유지.
- UI는 기존 play_theme 및 PixelButton/공통 패널·타이포그래피 재사용. 임의 스타일·색·크기 변경 없음. Penpot 파일 ID cd444aaf-0d8c-801b-8008-cda246e18650의 채택 상세 상태를 확인하고 문구/해금 가능 상태만 동기화.
- 직접 호출자 Play의 해금 요청/상태 갱신·세션 facade 및 관련 기존 회귀 확인. 새 런타임/테스트 파일 불필요.

## 체크리스트

- [x] PRODUCT/PAVE/개발·구조·코드·디자인 안내 및 현재 main/관련 소유자 확인, 작업 폴더 clean.
- [x] 통합 작성 승인.
- [x] 카탈로그/세션/UI의 선행 규칙 제거, 빈캔 비용만으로 버튼/실제 해금 동작.
- [x] 기존 drink_screen, drink_unlock_screen, expanded_skills, vending_display의 선행 기대값을 새 규칙으로 수정. 선행 미해금 상태에서 오렌지/황금 해금 성공, 부족·중복 차감 방지 및 저장 호환을 검증.
- [x] Notion 최신 규칙·PRODUCT·Penpot 편집 원본 및 관련 안내 동기화. 원본 접근 불가 시 미동기화 대상/사유 기록.
- [x] 선언된 drink_screen/drink_unlock_screen/expanded_skills/skill_tree/vending_display/gameplay/progress_store 회귀, 실제 렌더러 오렌지 선택 화면 검수, git diff --check.
- [x] 실제 diff 소유권·중복·타입/탭/LF/100자·기존 UI 스타일 재사용 검토. 코드 안내의 해금 계약 갱신(Knowledge Delta).
- [x] 검증한 변경만 작업 브랜치 커밋·로컬 main 머지·통합 확인. push/PR 없음.

Test Value Gate: 실제 세션 해금과 UI 버튼이 불일치하거나 기존 선행 검사가 남는 회귀, 음수 빈캔/중복 차감/저장 재로드 경계를 보호한다. 같은 구조를 복제한 새 테스트 파일은 만들지 않는다. 릴리스 export/자동 formatter·lint는 미설정이므로 실행 성공으로 보고하지 않는다.

## 검증·완료 전 품질 검사

- Godot4.7.2 official에서 선언된 drink_screen/drink_unlock_screen/expanded_skills/skill_tree/vending_display/gameplay/progress_store 7개 통과(종료0·오류0). 모든 유료 음료를 새 세션에서 cost−1 실패/cost 성공/중복 실패로 검증하고 콜라10·에너지15를 직접 확인. 역순 해금 진열·저장 복원도 검증.
- 실제 D3D12/RTX4070Ti SUPER 렌더러 drink_screen 실행 통과. 오렌지 미해금·레몬라임 잠금 상태에서 15개로 추가 버튼 활성·선행 안내 없음 캡처 검수. Godot editor --headless --path . --quit 파싱 통과. 로그/캡처는 .godot/test_artifacts/에 임시 보관.
- 기존 소유자만 수정: 카탈로그의 폐기된 parent 전부 제거, 세션 해금은 비용만 검사, UI는 비용/기존 해금만 표시. 새 런타임/테스트/테마 파일 없음. key/index/display_slot/저장 형식 유지. 테스트 출력의 수정된 긴 줄도100자 이내로 분리. git diff --check 및 변경 GDScript LF/탭/추가줄100자 검토.
- Notion의 황금 선행 조건을 같은 자리에서 수정하고 최신 독립 해금·콜라10·에너지15 절 추가/재로딩 확인. Penpot 연결 파일ID 대조 후 01의 기존 선행 조건 상태를 순서 없는 해금 · 콜라로 변경. 선행 문구를 해금 후 자판기에서 등장으로, 비용을10개로 변경. 빈캔8개 부족 예시로 기존 disabled 공유 버튼 상태 재사용. 해당 편집 가능한 원본과 화면 캡처를 확인했다.
- Penpot 이름 입력 시 stale 대상 때문에 자동 승인 검토가 포커스 없는 Ctrl+A 입력을 차단함. 쓰기를 반복하지 않고 새 AX로 대상·이름 입력란 포커스를 확인한 뒤 해당 locator에만 입력해 해결. 미동기화 항목 없음.
- Knowledge Delta: 코드 안내에 선행 없는 세션/UI/카탈로그 해금 계약·회귀 위치 갱신. 별도 장애 문서는 재현 제품 결함이 없어 추가하지 않음. PRODUCT와 기존 원본 링크/작성 안내 갱신. 자동 formatter/linter·릴리스 export는 미설정으로 실행하지 않음.
