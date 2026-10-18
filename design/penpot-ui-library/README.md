# Penpot UI 에셋 적용

원본: Penpot 파일 cd444aaf-0d8c-801b-8008-cda246e18650 / 02 · 에셋 라이브러리.

- 재화 HUD: d7a10464-8e4d-803c-8008-ceb3277a6874
- 능력 구매: d7a10464-8e4d-803c-8008-ceb327ab813b
- 능력 강화: d7a10464-8e4d-803c-8008-ceb327efacc0
- 자판기 해금: d7a10464-8e4d-803c-8008-ceb327cdc3c8

원본 SVG는 이 폴더에 보관한다. ui/pixel/*_frame.svg는 원본 텍스트 그룹을 제거한 프레임과 아이콘이다. 게임의 실시간 금액·빈캔 수와 수정된 버튼 이름은 Godot Label/Button으로 표시한다. StyleBoxTexture로 테두리를 유지하며, 버튼의 hover/pressed/disabled와 키보드 포커스 상태를 제공한다.

게임 적용 문구: 100G / 능력 / 음료수 추가.
글꼴: Do Hyeon, https://github.com/google/fonts/tree/main/ofl/dohyeon
동봉 라이선스: ui/fonts/DoHyeon-OFL.txt.

검증: Godot 리소스 가져오기, 실제 플레이 화면·창 크기 변경 캡처, 두 탐색 버튼 연결 확인, abilities_test.gd 및 expanded_skills_test.gd 통과.
