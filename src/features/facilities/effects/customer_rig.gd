extends Node2D

const POSES = preload("res://src/data/customer_poses.gd").DATA
const DRINK = preload("res://src/data/drink_catalog.gd").DATA[0].asset
const PARTS: Array[String] = [
	"far_leg", "near_leg", "pelvis", "far_arm", "torso", "head", "near_arm",
]
var variant: int = 1
var view: int = 0
var joints: Dictionary = {}
var arm: String = "near_arm"
var drink: Sprite2D
var carrying: bool = false


func configure(kind: int) -> void:
	variant = kind
	set_view(1)


func set_view(next: int) -> void:
	if view == next:
		return
	view = next
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	joints.clear()
	var data: Dictionary = POSES[variant][view]
	# 상체에 속하는 머리·팔은 같은 몸통 관절을 따라간다.
	var torso := Node2D.new()
	torso.name = "Torso"
	torso.position = data.torso.pivot
	add_child(torso)
	joints.torso = torso
	for i in PARTS.size():
		var key: String = PARTS[i]
		var part: Dictionary = data[key]
		var joint: Node2D = torso if key == "torso" else Node2D.new()
		if key != "torso":
			joint.name = key.to_pascal_case()
			var upper: bool = key in ["head", "far_arm", "near_arm"]
			(torso if upper else self).add_child(joint)
			joint.position = part.pivot - (data.torso.pivot if upper else Vector2.ZERO)
		joint.z_index = i - 4 if key in ["head", "far_arm", "near_arm"] else i
		var rest := Node2D.new()
		rest.rotation = -deg_to_rad(float(part.rotation))
		joint.add_child(rest)
		var artwork := Sprite2D.new()
		artwork.texture = part.texture
		artwork.centered = false
		artwork.scale = Vector2(0.5, 0.5)
		artwork.position = Vector2(-64, -64) - part.pivot
		artwork.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		rest.add_child(artwork)
		joint.rotation = deg_to_rad(float(part.rotation))
		joints[key] = joint
	arm = "near_arm"
	drink = Sprite2D.new()
	drink.texture = load(DRINK)
	drink.scale = Vector2.ONE * (12.0 / drink.texture.get_width())
	drink.position = Vector2(8, 58)
	if view == 1:
		# 원본 측면 음료 보행의 소품 중심(82, 160)을 같은 손 관절에 연결한다.
		drink.position = (Vector2(82, 160) - data.near_arm.pivot).rotated(
			-deg_to_rad(float(data.near_arm.rotation))
		)
	drink.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	joints[arm].add_child(drink)
	drink.visible = carrying


func walk(time: float) -> void:
	var data: Dictionary = POSES[variant][view]
	var phase: float = (sin(time * TAU * 1.7) + 1.0) * 0.5
	for key: String in PARTS:
		var part: Dictionary = data[key]
		joints[key].rotation = lerp_angle(
			deg_to_rad(float(part.rotation)), deg_to_rad(float(part.walk_target)), phase
		)
	drink.visible = carrying


func use_machine(payment: float, reach: float) -> void:
	var data: Dictionary = POSES[variant][view]
	for key: String in PARTS:
		joints[key].rotation = deg_to_rad(float(data[key].rotation))
	joints[arm].rotation -= 2.47 * payment + 0.25 * reach
	joints.torso.rotation += 0.12 * reach
	joints.head.rotation -= 0.06 * reach
	drink.visible = carrying
