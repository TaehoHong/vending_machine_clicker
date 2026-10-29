# 시설 빈캔 낙하·굴림 및 수색 클릭음 시안

## 요청·결정·승인
- 사용자 확정: BGM 작업 중지. 손님이 떨어뜨리는 빈캔을 더 아래로 굴러 떨어지게 한다. 수색 클릭음 3개 시안을 제작한다. 클릭음의 게임 적용은 아직 범위 밖이다.
- 사용자가 “승인, 코드·테스트·원본 반영 진행”으로 통합 승인했다. 빈캔 대상 확인과 구현 승인을 별도로 기록했다.
- 기존 빈캔 20% 드롭·15초 소멸·클릭 획득·쓰레기통 수집·골드 자동 획득과 저장은 유지한다.

## 소유자·디자인·범위
- owner-found: facility_world.gd refresh의 기존 Button·아이콘·낙하 tween을 확장한다. 기존 y432에서 약 50px 낮은 바닥으로 내려오고 약간 튀며 옆으로 굴러 눕는다. item pivot을 중심에 맞추고 실제 클릭 영역도 함께 회전한다. reduce_motion이면 바로 최종 상태를 표시한다. 새 효과 매니저·런타임 파일은 추가하지 않는다.
- owner-found: 시설 골드 발밑 좌표는 customer_flow.reward_origin이 소유한다. 표현 변경에 따라 경제/저장 규칙을 복제하지 않는다.
- owner-found: tests/features/facilities_test.gd의 기존 물품 클릭·자동 수집 회귀를 확장해 최종 착지 위치/회전과 이동 후 클릭 획득을 확인한다. 시설 규칙/손님/저장 검사는 기존 계약 보호에 사용한다.
- Penpot 지정 파일의 기존 빈캔 원본을 재사용해 낙하·착지·굴림 상태를 연결된 인스턴스로 반영한다. Notion/PRODUCT/DESIGN/design README는 해당 연출 규칙만 갱신한다. 연결 실패는 미동기화로 명시한다.
- 수색 클릭음은 외부 음원 없이 직접 합성한 3개 WAV와 비교용 반복 재생 WAV를 visualization 산출물로 제공한다. BGM은 새로 만들거나 게임에 적용하지 않는다.

## 체크리스트
- [x] PRODUCT/PAVE/코드 안내·시설 표현/손님·직접 회귀·디자인/구조 규칙 확인.
- [x] 코드·테스트 통합 승인.
- [x] 기존 시설 표현에서 빈캔 낙하/굴림 수정 및 회귀 검사.
- [x] 실제 GPU 화면·착지 후 클릭·pause·reduce motion 확인.
- [x] 시설/손님/저장 검사, editor parse, git diff --check, 실제 diff 중복/책임/스타일 검토.
- [x] Penpot/Notion 및 해당 로컬 요약 동기화.
- [x] 클릭음 3개 생성·파일/클리핑 검증·비교용 오디오 제공.
- [x] Knowledge Delta 평가 및 검증된 변경 로컬 main 반영. push 없음.


## 검증·원본 반영·Knowledge Delta
- 기존 facility_world의 아이콘·Button·세션 클릭 수령을 그대로 사용한다. 새 런타임 파일/경제 규칙/테마는 없다. customer_flow.reward_origin의 발밑 높이를 재사용해 최종 수평 캔의 하단을 바닥에 맞춘다. 0.28초 낙하→0.16초 튐→0.32초 회전/굴림을 item 소유 tween으로 표현하며 제거/일시정지 수명을 따른다.
- facilities_test는 실제 회전 중심을 변환한 좌표에 입력을 보내 착지 후 클릭 수령·중복 무지급을 보호한다. 착지 위치/회전, pause 정지, reduce_motion 즉시 착지를 검사했다. 기존 저장/골드 자동 수령 회귀도 통과했다.
- Godot 4.7.2 headless facilities_test 및 실제 GPU facilities_test 통과. customer_animation_test, facility_rules_test, progress_store_test 통과. 공식 Godot editor parse/resource check와 git diff --check 통과. 추가 코드 LF/100자 한도와 실제 diff 책임/기존 자원 재사용을 확인했다. 자동 린터/릴리스 빌드는 기존 미설정이다.
- Notion 기존 시설 최종 문단 수정 후 새로고침하여 실제 새 문구를 읽었다. Penpot 지정 파일 02의 기존 빈캔 컴포넌트로 연결 인스턴스 3개(낙하 전/바닥 충돌/굴림 완료)를 구성한 편집 보드를 저장하고 새로고침 후 레이어/배치를 확인했다. 보드 68eb829b-cdce-8021-8008-dd690d4e7ae2이며 3포즈 원본이다. 실제 시간 연출은 게임 tween에서 검증했다.
- Knowledge Delta: 시설 낙하 소유자/착지/모션 감소/회전 클릭 계약만 코드 안내에 갱신하고 PRODUCT/DESIGN/design README의 기존 문단과 링크를 수정했다. 일회성 GPU 캡처·오디오 실험 때문에 새 장기 문서를 만들지 않았다.
- BGM 추가 작업은 중지했다. 수색음은 바닥 탭(0.15초), 픽셀 클릭(0.10초), 금속 탭(0.18초)을 직접 합성했으며 외부 음원·샘플을 사용하지 않았다. 각 단발 WAV와 3.1초 반복 비교 WAV, 합성 소스/메타데이터는 visualization 산출물로 제공한다. stereo 44.1kHz/16bit·피크 약 -4.15dBFS·클리핑 없음 검사를 마쳤다. 게임 사운드 연결은 미진행이며 선택 전 제안이다.
