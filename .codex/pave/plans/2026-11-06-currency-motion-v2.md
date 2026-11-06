# 수색 코인·빈캔 모션 적용

- 사용자 승인: 편집 가능한 비교 시안을 검토한 뒤 “4번도 디자인파일이랑 게임에 적용해”. 4A·4B v2의 적용 지시를 쓰기 승인으로 사용한다. 추가 결정 0개.
- owner-found: 일반 수색 코인은 Play._spawn_search_coin, 시설 빈캔은 facility_world._animate_can_drop. 기존 coin_*.svg·can_icon.svg와 현재 표현 소유자를 재사용한다. 새 런타임 파일·에셋 없음.
- 범위: 일반 수색 코인의 낮은 상승→큰 튐→작은 튐→감속→정지→1.20초 소멸, 빈캔의 짧은 튐·넘어짐·감쇠 흔들림·0.84초 정착. 피버·시설 골드·구매·손님은 유지한다.
- 캔 접지는 Button 크기 대신 실제 아이콘 비율을 따른다. 클릭 수령·15초 소멸·깜빡임·자동 수집·pause와 보상/저장 계약을 보존한다.
- 예상 변경: 기존 Play·facility_world, 해당 coin_effect/facilities 회귀, DESIGN.md·design/README.md. Penpot 03의 기존 v2 키프레임은 그대로 두고 채택 표기와 변경 전 비교 기준을 갱신한다.
- Test Value Gate: 코인의 조기 소멸 회귀와 캔 회전 중 바닥 관통/최종 부유를 검출하는 검사를 기존 회귀에 추가한다. 미세 시간식 전체를 테스트에 복제하지 않는다.
- 검증: Godot4.7 import/parse, coin_effect·facilities·search·search_fever·punch_fever·gameplay 및 실제 렌더 접지 대조, git diff --check. main 반영 후 좁은 통합 재검사.

- [x] 기존 소유자에 모션 적용·회귀 검증
- [x] Penpot 채택 상태 저장/재조회 및 로컬 문서 동기화
- [x] 실제 렌더·diff 검토·로컬 main 반영

## 검증 결과

- Godot4.7 import/parse, coin_effect·facilities·search·search_fever·punch_fever·gameplay 통과. 부모의 별도 coin_effect/facilities/search/punch_fever 재실행도 완료 문구·exit0을 확인했다. 기존 캔 회전 기대값의 실패를 확인한 뒤 과회전 제거와 실제 아트 꼭짓점의 회전 접지 검사로 교체했다.
- facilities 종료 시 AudioStreamWAV/AudioStreamPlaybackWAV 각1개의 해제 경고가 남았다. verbose에서 neon_stroll_loop.wav로 확인했다. 새 모션 Control의 누수로 확인된 것은 없고 오디오 코드는 변경하지 않았다.
- 실제 Metal1152×648에서0/0.12/0.28/0.38/0.48/0.60/0.72/0.84/1.14초를 렌더했다. 캔은 기존 아이콘·클릭 버튼으로 튀고 넘어져 접지하며, 코인은 두 번 튄 뒤 감속한다. 임시 렌더 스크립트와 캡처는 제거했다.
- Penpot 연결 파일 ID 대조, 기존4A·4B의42개 보드에서 채택/변경 전 문구168개와 시작 안내3개를 갱신했다.40개 키프레임의 포즈·자동 전환·공통 컴포넌트 연결은 유지했다. 새 보기 탭에서 저장된 채택 표기와 비교 재생을 확인했다.
- Knowledge Delta: 사용자 확정 채택 모션을 Penpot·DESIGN.md·design/README.md에 반영했다. 순수 시각 모션으로 제품/보상 규칙 변경이 없어 Notion/PRODUCT.md 변경 없음. 기존 소유 경계·검증 명령 변화가 없어 코드 안내 수정 없음.
