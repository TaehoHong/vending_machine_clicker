# 시설 생산 타이머·골드 저장 수정

사용자 직접 수정 지시: 시설 생산 남은 시간은 저장하지 않고 로드 시 전체 주기로 시작한다. 골드의 로드 전용 10억 제한을 제거한다.

기존 소유자 재사용(`owner-found`): progress_store.write/load_into, facility_rules.normalize. 직접 호출자 game_session/app과 기존 저장·시설 회귀를 확인했다. 새 런타임 파일은 필요 없다.

## 범위

- 현재 스테이지 시설 생산 타이머를 저장에서 제외하고 기존 저장의 remaining도 무시한다. 주기 강화는 유지한다.
- 보유 골드·시설 미수령 골드는 유효한 64비트 정수를 보존한다. 음수/타입 검증은 유지한다.
- 이미 생산한 골드·물품과 바닥 물품 소멸 시간은 유지한다. 다른 스테이지의 미해석 데이터는 보존한다.
- 황금 추첨·타격·종료·UI는 이번 수정 범위 밖이다.
- PRODUCT.md와 Notion 원문, 코드 안내에 변경 계약을 반영한다.

## 체크리스트

- [x] 기존 facility_rules_test에 타이머 제외 저장·기본/강화 주기 재시작·이전 저장 호환 검사를 추가하고 실패 확인.
- [x] progress_store와 facility_rules에 타이머 변경 반영, 관련 문서 동기화, 좁은 검사 후 기능 커밋.
- [x] progress_store_test에 큰 골드의 정확한 왕복 검사를 추가하고 실패 확인.
- [x] 같은 저장 소유자에서 골드 상한 제거, 관련 문서 동기화, 좁은 검사 후 기능 커밋.
- [x] Godot 4.7 import/parse, progress_store·facility_rules·customer_animation·menu·gameplay·purchase_price 및 git diff --check 확인.
- [x] 실제 diff 품질 검토 후 로컬 main 통합 및 재검증. 기존 시설 UI 작업은 별도 유지한다.

검증 기준: 저장 중 플레이 타이머는 바뀌지 않고 저장 파일에 생산 remaining이 없다. 로드 시 기본 10초/최대 강화 5초부터 시작하며 이미 생산한 자산을 보존한다. 10억 초과·부동소수점 정밀도 경계 초과 골드를 정수 그대로 복원한다.

검증 결과: 별도 작업 트리의 선언된 관련 7개 회귀(시설 UI 포함)·import/parse·공백 검사 통과. main에 e94d4ef, 0f62d92를 fast-forward 통합 후 progress_store·facility_rules·customer_animation 3개를 재검증했다. 기존 작업 트리의 진행 중인 시설 UI 수정은 포함하지 않았다. 새 런타임 파일은 없고 기존 소유자를 확장했다. Notion 기획과 PRODUCT·코드 안내에 사용자 확정 규칙을 반영했으며 별도 트러블슈팅 문서는 만들지 않았다.
