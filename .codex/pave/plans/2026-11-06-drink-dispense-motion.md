# 구매 배출 모션 적용

- 사용자 승인: Penpot 비교를 본 뒤 “1번 적용, 2번 기존대로”. 1번의 구체적인 게임 적용 지시를 승인으로 사용한다. 추가 결정 0개.
- owner-found: drink_dispense_fx.gd의 begin/advance/_draw, Play의 _start_purchase_effect/_position_purchase_effect 호출. 기존 음료 아트와 기존 FX를 확장하고 새 런타임 파일은 만들지 않는다.
- 1번: 배출 시 0.9 고정 배율과 가림, 0.2초 정지, 70px 곡선과 부드러운 진행, 90→0도 회전, 잔상 제거. 총2.34초(투입1.02+배출1.32)는 유지한다.
- 2번 펀치 및 3번 손님 유지. 4번은 체감 차이가 불충분하여 적용 보류. 경제·보상·저장·타이밍 계약 변경 없음.
- 예상 변경: 기존 FX와 Play의 잔상 색상 전달 인자 제거, DESIGN.md, design/README.md. Penpot 03 비교 페이지의 채택 상태만 갱신. 검증·소유 경계는 기존 코드 안내 그대로다.
- 새 자동 테스트는 미세 모션 수치 복제를 피한다. 기존 drink_dispense/purchase_area/gameplay 검사가 겹침·완료·pause·resize를 보호한다. 실제 렌더에서 배출·정지·이동·마지막과 대표 음료를 확인한다.

- [x] FX 적용 및 실제 화면 검수
- [x] Godot4.7 parse, drink_dispense_test, purchase_area_test, gameplay_test, git diff --check
- [x] Penpot/로컬 디자인 문서 동기화, diff 검토 및 로컬 main 반영

## 검증 결과

- Godot4.7 실제 렌더에서 배출0/0.14/0.38초 및 이동0.9초 확인. 검사 스크립트와 시간별 임시 캡처 제거 완료.
- drink_dispense_test, purchase_area_test, gameplay_test의 동작 검사가 통과했다. 최종 단일 인자 호출로 drink_dispense_test 재검사 통과.
- 첫 sandbox 실행은 사용자 로그/설정 저장 제한으로 중단되었고 정상 실행 권한으로 재실행했다. 최종 editor parse와 git diff --check 통과.
- 구매 회귀 종료 시 AudioStreamWAV/AudioStreamPlaybackWAV 각3개의 해제 경고가 남았다. verbose로 whoosh/punch/miss WAV임을 확인했으며 배출 Control 누수로 확인된 것은 없다. 이번 범위 밖 오디오 코드는 변경하지 않았다.
- Penpot 연결 파일 ID 확인,115개 비교 보드의 채택 상태 재조회, 시작 안내 PNG에서 표시 확인. 구매41개 채택, 펀치32개 미채택, 동전/빈캔 각21개 보류.
- 기존 FX와 음료 에셋 재사용, 새 런타임 파일 없음. 가격/보상/저장 규칙 변경이 없어 Notion 변경 없음. Knowledge Delta: 사용자 채택/유지 기준을 DESIGN.md와 디자인 안내 및 Penpot에 반영. 소유 경계/검증 명령 변화가 없어 코드 안내 수정 없음.
