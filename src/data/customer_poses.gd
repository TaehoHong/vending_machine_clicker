extends RefCounted

# Penpot 손님 조합 원본의 관절·파츠. 위치는 192×248 공통 좌표다.
const DATA: Dictionary = {
	1: {
		1: {
			"far_leg": {
				"pivot": Vector2(103.0, 150.0),
				"rotation": 20,
				"walk_target": 12,
				"texture": preload("res://assets/penpot/customers/customer_01_01_far_leg.png"),
			},
			"near_leg": {
				"pivot": Vector2(87.0, 150.0),
				"rotation": 340,
				"walk_target": 348,
				"texture": preload("res://assets/penpot/customers/customer_01_01_near_leg.png"),
			},
			"pelvis": {
				"pivot": Vector2(93.5, 141.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_01_01_pelvis.png"),
			},
			"far_arm": {
				"pivot": Vector2(127.452, 101.5),
				"rotation": 14,
				"walk_target": 9,
				"texture": preload("res://assets/penpot/customers/customer_01_01_far_arm.png"),
			},
			"torso": {
				"pivot": Vector2(94.25, 153.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_01_01_torso.png"),
			},
			"head": {
				"pivot": Vector2(97.25, 88.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_01_01_head.png"),
			},
			"near_arm": {
				"pivot": Vector2(64.548, 101.5),
				"rotation": 346,
				"walk_target": 351,
				"texture": preload("res://assets/penpot/customers/customer_01_01_near_arm.png"),
			},
		},
		3: {
			"far_leg": {
				"pivot": Vector2(108.25, 142.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_01_03_far_leg.png"),
			},
			"near_leg": {
				"pivot": Vector2(87.75, 142.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_01_03_near_leg.png"),
			},
			"pelvis": {
				"pivot": Vector2(100.25, 142.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_01_03_pelvis.png"),
			},
			"far_arm": {
				"pivot": Vector2(74.0, 109.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_01_03_far_arm.png"),
			},
			"torso": {
				"pivot": Vector2(96.25, 155.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_01_03_torso.png"),
			},
			"head": {
				"pivot": Vector2(96.0, 87.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_01_03_head.png"),
			},
			"near_arm": {
				"pivot": Vector2(118.0, 109.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_01_03_near_arm.png"),
			},
		},
	},
	2: {
		1: {
			"far_leg": {
				"pivot": Vector2(103.0, 150.0),
				"rotation": 20,
				"walk_target": 12,
				"texture": preload("res://assets/penpot/customers/customer_02_01_far_leg.png"),
			},
			"near_leg": {
				"pivot": Vector2(87.0, 150.0),
				"rotation": 340,
				"walk_target": 348,
				"texture": preload("res://assets/penpot/customers/customer_02_01_near_leg.png"),
			},
			"pelvis": {
				"pivot": Vector2(93.5, 141.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_02_01_pelvis.png"),
			},
			"far_arm": {
				"pivot": Vector2(127.452, 101.5),
				"rotation": 14,
				"walk_target": 9,
				"texture": preload("res://assets/penpot/customers/customer_02_01_far_arm.png"),
			},
			"torso": {
				"pivot": Vector2(94.25, 153.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_02_01_torso.png"),
			},
			"head": {
				"pivot": Vector2(97.25, 88.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_02_01_head.png"),
			},
			"near_arm": {
				"pivot": Vector2(64.548, 101.5),
				"rotation": 346,
				"walk_target": 351,
				"texture": preload("res://assets/penpot/customers/customer_02_01_near_arm.png"),
			},
		},
		3: {
			"far_leg": {
				"pivot": Vector2(108.25, 142.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_02_03_far_leg.png"),
			},
			"near_leg": {
				"pivot": Vector2(87.75, 142.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_02_03_near_leg.png"),
			},
			"pelvis": {
				"pivot": Vector2(100.25, 142.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_02_03_pelvis.png"),
			},
			"far_arm": {
				"pivot": Vector2(74.0, 109.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_02_03_far_arm.png"),
			},
			"torso": {
				"pivot": Vector2(96.25, 155.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_02_03_torso.png"),
			},
			"head": {
				"pivot": Vector2(96.0, 87.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_02_03_head.png"),
			},
			"near_arm": {
				"pivot": Vector2(118.0, 109.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_02_03_near_arm.png"),
			},
		},
	},
	3: {
		1: {
			"far_leg": {
				"pivot": Vector2(103.0, 150.0),
				"rotation": 20,
				"walk_target": 12,
				"texture": preload("res://assets/penpot/customers/customer_03_01_far_leg.png"),
			},
			"near_leg": {
				"pivot": Vector2(87.0, 150.0),
				"rotation": 340,
				"walk_target": 348,
				"texture": preload("res://assets/penpot/customers/customer_03_01_near_leg.png"),
			},
			"pelvis": {
				"pivot": Vector2(93.5, 141.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_03_01_pelvis.png"),
			},
			"far_arm": {
				"pivot": Vector2(127.452, 101.5),
				"rotation": 14,
				"walk_target": 9,
				"texture": preload("res://assets/penpot/customers/customer_03_01_far_arm.png"),
			},
			"torso": {
				"pivot": Vector2(94.25, 153.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_03_01_torso.png"),
			},
			"head": {
				"pivot": Vector2(97.25, 88.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_03_01_head.png"),
			},
			"near_arm": {
				"pivot": Vector2(64.548, 101.5),
				"rotation": 346,
				"walk_target": 351,
				"texture": preload("res://assets/penpot/customers/customer_03_01_near_arm.png"),
			},
		},
		3: {
			"far_leg": {
				"pivot": Vector2(108.25, 142.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_03_03_far_leg.png"),
			},
			"near_leg": {
				"pivot": Vector2(87.75, 142.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_03_03_near_leg.png"),
			},
			"pelvis": {
				"pivot": Vector2(100.25, 142.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_03_03_pelvis.png"),
			},
			"far_arm": {
				"pivot": Vector2(74.0, 109.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_03_03_far_arm.png"),
			},
			"torso": {
				"pivot": Vector2(96.25, 155.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_03_03_torso.png"),
			},
			"head": {
				"pivot": Vector2(96.0, 87.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_03_03_head.png"),
			},
			"near_arm": {
				"pivot": Vector2(118.0, 109.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_03_03_near_arm.png"),
			},
		},
	},
	4: {
		1: {
			"far_leg": {
				"pivot": Vector2(103.0, 150.0),
				"rotation": 20,
				"walk_target": 12,
				"texture": preload("res://assets/penpot/customers/customer_04_01_far_leg.png"),
			},
			"near_leg": {
				"pivot": Vector2(87.0, 150.0),
				"rotation": 340,
				"walk_target": 348,
				"texture": preload("res://assets/penpot/customers/customer_04_01_near_leg.png"),
			},
			"pelvis": {
				"pivot": Vector2(93.5, 141.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_04_01_pelvis.png"),
			},
			"far_arm": {
				"pivot": Vector2(127.452, 101.5),
				"rotation": 14,
				"walk_target": 9,
				"texture": preload("res://assets/penpot/customers/customer_04_01_far_arm.png"),
			},
			"torso": {
				"pivot": Vector2(94.25, 153.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_04_01_torso.png"),
			},
			"head": {
				"pivot": Vector2(97.25, 88.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_04_01_head.png"),
			},
			"near_arm": {
				"pivot": Vector2(64.548, 101.5),
				"rotation": 346,
				"walk_target": 351,
				"texture": preload("res://assets/penpot/customers/customer_04_01_near_arm.png"),
			},
		},
		3: {
			"far_leg": {
				"pivot": Vector2(108.25, 142.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_04_03_far_leg.png"),
			},
			"near_leg": {
				"pivot": Vector2(87.75, 142.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_04_03_near_leg.png"),
			},
			"pelvis": {
				"pivot": Vector2(100.25, 142.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_04_03_pelvis.png"),
			},
			"far_arm": {
				"pivot": Vector2(74.0, 109.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_04_03_far_arm.png"),
			},
			"torso": {
				"pivot": Vector2(96.25, 155.5),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_04_03_torso.png"),
			},
			"head": {
				"pivot": Vector2(96.0, 87.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_04_03_head.png"),
			},
			"near_arm": {
				"pivot": Vector2(118.0, 109.0),
				"rotation": 0,
				"walk_target": 0,
				"texture": preload("res://assets/penpot/customers/customer_04_03_near_arm.png"),
			},
		},
	},
}
