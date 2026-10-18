extends Control

const PALETTES = [
	[Color("da9459"), Color("b96b38"), Color("ffcf97"), Color("784126")],
	[Color("e2edf2"), Color("a9bccb"), Color("ffffff"), Color("647d91")],
	[Color("ffcf55"), Color("edab36"), Color("fff1a6"), Color("b8672c")],
	[Color("63efbe"), Color("21b98b"), Color("ccffe7"), Color("08725c")]
]
var tier: int = 0

static func breakdown(amount: int) -> Array[int]:
	var remainder := maxi(0, amount)
	var emerald := remainder / 10000
	remainder %= 10000
	var gold := remainder / 1000
	remainder %= 1000
	var silver := remainder / 100
	remainder %= 100
	var bronze := maxi(1, remainder / 10) if remainder > 0 else 0
	return [bronze, silver, gold, emerald]

func _draw() -> void:
	var palette: Array = PALETTES[clampi(tier, 0, 3)]
	draw_rect(Rect2(7, 25, 18, 4), Color(0.08, 0.05, 0.02, 0.3))
	var edge := PackedVector2Array([Vector2(7, 1), Vector2(19, 1), Vector2(19, 4), Vector2(23, 4), Vector2(23, 20), Vector2(19, 20), Vector2(19, 23), Vector2(7, 23), Vector2(7, 20), Vector2(3, 20), Vector2(3, 4), Vector2(7, 4)])
	draw_colored_polygon(edge, Color("15151d"))
	draw_rect(Rect2(7, 4, 12, 16), palette[0])
	draw_rect(Rect2(5, 7, 16, 10), palette[1])
	draw_rect(Rect2(8, 5, 4, 13), palette[2])
	draw_rect(Rect2(17, 7, 3, 11), palette[3])
