extends Control

var available: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var color := Color("ffe08b") if available else Color("bdc9d2")
	draw_rect(Rect2(2, 0, 12, 10), Color("12121d"))
	draw_rect(Rect2(5, 3, 6, 7), color, false, 2)
	draw_rect(Rect2(0, 8, 16, 13), Color("12121d"))
	draw_rect(Rect2(2, 10, 12, 9), color)
	draw_rect(Rect2(7, 12, 2, 4), Color("12121d"))
