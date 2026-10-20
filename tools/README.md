# 개발 도구

`build_scenes.py`는 이전 레이아웃의 검토용 출력만 `.godot/scene_previews/`에 쓴다. 현재 앱을 빌드하거나 채택된 씬·공통 테마를 갱신하는 명령이 아니다.

입력은 `design/penpot-ui/tokens.json`과 Godot이 읽은 `src/data/drink_catalog.gd.DATA`다. 별도 상품 JSON 원본을 유지하지 않는다. `export_catalog.gd`로 실제 런타임 카탈로그를 내보내므로 GDScript를 Python에서 따로 파싱하지 않는다. 생성기를 사용할 때는 `GODOT_BIN`에 실행 파일 경로를 지정하거나 PATH의 `godot`을 사용한다.

게임 실행에는 Python이 필요하지 않다. 현재 실행 진입은 `src/app/main.tscn`, 실제 기능 씬은 `src/features/`다.
