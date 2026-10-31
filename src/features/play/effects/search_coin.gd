extends Control

const TEXTURES = [
	preload("res://src/shared/ui/icons/coin_bronze.svg"),
	preload("res://src/shared/ui/icons/coin_silver.svg"),
	preload("res://src/shared/ui/icons/coin_gold.svg"),
	preload("res://src/shared/ui/icons/coin_emerald.svg"),
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
	draw_texture_rect(TEXTURES[clampi(tier, 0, 3)], Rect2(Vector2.ZERO, size), false)
