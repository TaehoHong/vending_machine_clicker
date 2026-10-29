# HUD 간격·아이콘 통일

사용자 요청: HUD 여백과 아이콘 크기를 통일한다. 기존 디자인의 16px 여백·56×56 공통 프레임과 병/시설 아이콘의 표시 높이를 기준으로 정리한다. 명시적 구현 요청을 이 범위의 쓰기 승인으로 기록하며 차단 결정은 없다.

## 범위·기존 소유자

- owner-found: Play의 `_position_coin_slot`, `_layout_quests`가 HUD 배치를 소유한다. 이동된 능력·메뉴 버튼은 size만 확대하여 자식 아트가 확대되지 않는 결함을 같은 소유자에서 수정한다.
- owner-found: `play_design.tscn`, `quests/hud_design.tscn`, 공유 `56x56_normal.svg`, `PixelButton` 상태·테마를 재사용한다. 기본 프레임도 공통 SVG로 연결해 상태별 경계 차이를 제거한다. 새 런타임 파일·테마·매니저는 추가하지 않는다.
- 기준: 1152×648에서 보이는 프레임 외곽의 가장자리/버튼 사이 간격 16px, 정사각 버튼 외곽 44.8px(투명 여백 포함 54.4px), 동작 아이콘의 보이는 높이 24px. 메모지·일시정지만 기존 병·시설에 맞추고 재화 아이콘도 24px 높이로 균등 축소한다. 20초 달성 카드·목록·보상 동작은 유지한다.
- 파일: play.gd, play_design.tscn, quests/hud_design.tscn, 기존 quest_screen_test.gd, DESIGN.md, design/README.md, 필요시 docs/07-codebase-guide.md. Penpot 공통 HUD 원본과 채택 플레이/퀘스트 화면을 동기화한다. 새 기획 동작이 없어 PRODUCT·Notion 기획 변경은 없다.
- Test Value Gate: 기존 resize 회귀에 네 HUD의 실제 전역 프레임·입력 영역이 같은 배율인지 추가한다. 기존 코드에서는 메뉴/능력의 자식 아트만 크기가 고정되어 실패해야 한다. 정적 좌표를 모두 복제하는 테스트는 추가하지 않는다.
- 검증: Godot 4.7 import/parse; quest_screen, drink_screen, facilities, menu, coin_effect; git diff --check. 실제 Metal 렌더링 1152×648·1280×720·1600×900·비16:9에서 간격·아이콘·호버/포커스·클릭 확인.
- Git: 기능과 관련 문서를 함께 커밋하고 깨끗한 로컬 main에 반영 후 quest_screen 통합 검사. 이번 요청에는 별도 push가 없어 원격 푸시는 수행하지 않는다.

## 체크리스트

- [x] resize 결함 회귀 재현
- [ ] Penpot 원본·채택 화면 업데이트
- [x] 기존 HUD 소유자에 프레임·아이콘·간격·배율 적용
- [x] 관련 검사·실제 화면·diff·코드 품질·Knowledge Delta 확인
- [ ] 임시 파일 정리·기능 커밋·로컬 main 반영·통합 검증

## 검증·남은 외부 동기화

- Red: 기존 코드에서 1280·1600 해상도의 메뉴/능력 아트 고정과 입력 영역 불일치로 8개 실패를 재현했다. 실제 소유자 범위로 탐색을 좁힌 뒤의 결과이며 최초 탐색 범위 오류는 수정했다.
- Green: Godot 4.7 import/parse, quest_screen·drink_screen·facilities·menu·coin_effect 5개 회귀, git diff --check 통과. 실제 Metal 1152×648·1280×720·1600×900·1440×900과 메뉴 포커스를 확인했다. 고정 배율·입력 영역 회귀는 기존 quest_screen 검사에 포함했다.
- 품질: 기존 Play·PixelButton·공통 SVG·테마·메모지 에셋 재사용. 중복 프레임 조각 연결을 공통 프레임 하나로 대체했으며 새 런타임 파일·공유 매니저·테마는 없다. 기존 에셋 파일은 다른 화면에서도 사용하므로 삭제하지 않는다.
- Penpot: 연결 파일 ID를 UI에서 확인했고 기본 플레이의 세 버튼 위치를 실제 입력으로 저장했다. MCP heartbeat·플러그인 재실행 오류와 네이티브 편집기의 컨테이너/내부 벡터 크기 불일치로 02 아이콘 및 01 퀘스트/골드 상태 전체 동기화는 미완료다. 내부 그림이 함께 줄지 않은 메모지·재화 컨테이너 변경은 복원했다. 로컬 디자인 문서에 대상과 사유를 명시했으며 외부 동기화 완료로 보고하지 않는다.
- Knowledge Delta: HUD 공통 SVG 재사용·Play에서 reparent된 버튼의 size 유지/scale 확대 계약과 4개 해상도 회귀를 코드 안내에 반영했다. 제품 진행·보상 규칙은 그대로라 Notion/PRODUCT 변경은 없다. 일시적 MCP 오류는 원인이 검증되지 않아 별도 문제 해결 문서로 승격하지 않는다.
