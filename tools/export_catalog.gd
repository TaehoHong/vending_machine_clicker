extends SceneTree

const CATALOG = preload("res://src/data/drink_catalog.gd")


func _initialize() -> void:
	var output_path: String = OS.get_cmdline_user_args()[0]
	var output := FileAccess.open(output_path, FileAccess.WRITE)
	if output == null:
		push_error("카탈로그 미리보기 입력을 쓰지 못했습니다.")
		quit(1)
		return
	output.store_string(JSON.stringify(CATALOG.DATA, "\t"))
	quit()
