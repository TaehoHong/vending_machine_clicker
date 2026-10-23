extends RefCounted

# 키·인덱스는 저장 호환 계약이다. 해금은 빈캔 비용만 확인하며 선행 음료 조건은 없다.
const DATA: Array[Dictionary] = [
	{
		"key": "Water",
		"name": "물",
		"asset": "res://assets/drinks/approved/water.png",
		"color": "#77CEE5",
		"cost": 0,
		"effect": "강화당 발견 골드 +1 (최대 +10)",
		"display_slot": 0,
		"max_enhancements": 10
	},
	{
		"key": "Tea",
		"name": "녹차",
		"asset": "res://assets/drinks/approved/green_tea.png",
		"color": "#B4D581",
		"cost": 0,
		"effect": "강화당 발견 골드 +3 (최대 +30)",
		"display_slot": 1,
		"max_enhancements": 10
	},
	{
		"key": "Ion",
		"name": "이온음료",
		"asset": "res://assets/drinks/approved/ion_drink.png",
		"color": "#B7B9FF",
		"cost": 5,
		"effect": "1 Gold −1%p → 5/10/50 Gold +0.6/0.3/0.1%p",
		"display_slot": 3,
		"max_enhancements": 5
	},
	{
		"key": "Vitamin",
		"name": "비타민 음료",
		"asset": "res://assets/drinks/approved/vitamin.png",
		"color": "#FFE475",
		"cost": 15,
		"effect": "3개마다 수색 클릭 −1 (6개에서 최대 −2회)",
		"display_slot": 10,
		"max_enhancements": 6
	},
	{
		"key": "Apple",
		"name": "사과 주스",
		"asset": "res://assets/drinks/approved/apple_juice.png",
		"color": "#F09589",
		"cost": 8,
		"effect": "1 Gold −2%p → 5/10/50 Gold +1.2/0.6/0.2%p",
		"display_slot": 4,
		"max_enhancements": 5
	},
	{
		"key": "Orange",
		"name": "오렌지 주스",
		"asset": "res://assets/drinks/approved/orange_juice.png",
		"color": "#FFBF70",
		"cost": 15,
		"effect": "펀치 피버 +1초 (최대 15초)",
		"display_slot": 9,
		"max_enhancements": 10
	},
	{
		"key": "Cola",
		"name": "콜라",
		"asset": "res://assets/drinks/approved/cola.png",
		"color": "#EF858D",
		"cost": 10,
		"effect": "획득 시 수색 피버 발동 · 반복 획득 가능",
		"display_slot": 13,
		"max_enhancements": 1
	},
	{
		"key": "Fanta",
		"name": "황금음료 · 오로라 골드",
		"asset": "res://assets/drinks/approved/golden.png",
		"color": "#D3A4FF",
		"cost": 30,
		"effect": "획득 시 주차장 해금 (최초 1회)",
		"display_slot": 12,
		"max_enhancements": 1
	},
	{
		"key": "Sprite",
		"name": "레몬라임 소다",
		"asset": "res://assets/drinks/approved/lime_soda.png",
		"color": "#92E7AE",
		"cost": 12,
		"effect": "클릭 2회 인정 확률 +8%p (최대 80%)",
		"display_slot": 7,
		"max_enhancements": 10
	},
	{
		"key": "Barley",
		"name": "보리차",
		"asset": "res://assets/drinks/approved/barley_tea.png",
		"color": "#D9A44A",
		"cost": 8,
		"display_slot": 2,
		"effect": "강화당 발견 골드 +5 (최대 +50)",
		"max_enhancements": 10
	},
	{
		"key": "Ginger",
		"name": "진저에일",
		"asset": "res://assets/drinks/approved/ginger_ale.png",
		"color": "#75BB6B",
		"cost": 10,
		"display_slot": 5,
		"effect": "골드 2배 확률 +2%p (최대 20%)",
		"max_enhancements": 10
	},
	{
		"key": "Lemonade",
		"name": "레모네이드",
		"asset": "res://assets/drinks/approved/lemonade.png",
		"color": "#F4DA52",
		"cost": 10,
		"display_slot": 6,
		"effect": "꽝 확률 −2%p (15% → 5%)",
		"max_enhancements": 5
	},
	{
		"key": "Peach",
		"name": "복숭아 주스",
		"asset": "res://assets/drinks/approved/peach_juice.png",
		"color": "#F7A1AC",
		"cost": 12,
		"display_slot": 8,
		"effect": "수색 피버 +1초 (최대 20초)",
		"max_enhancements": 10
	},
	{
		"key": "Melon",
		"name": "멜론 소다",
		"asset": "res://assets/drinks/approved/melon_soda.png",
		"color": "#9DDC68",
		"cost": 20,
		"display_slot": 11,
		"effect": "황금 등장 확률 +1%p (최대 10%)",
		"max_enhancements": 10
	},
	{
		"key": "Energy",
		"name": "에너지 드링크",
		"asset": "res://assets/drinks/approved/energy.png",
		"color": "#BCE638",
		"cost": 15,
		"display_slot": 14,
		"effect": "획득 시 펀치 피버 발동 · 타격 보상 3배",
		"max_enhancements": 1
	}
]
