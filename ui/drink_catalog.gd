extends RefCounted

# 해금 비용과 순서는 플레이 테스트용 임시값. 기존 인덱스는 저장 호환을 위해 유지한다.
const DATA: Array[Dictionary] = [
  {
    "key": "Water",
    "name": "물",
    "asset": "res://images/drinks/approved/water.png",
    "color": "#77CEE5",
    "cost": 0,
    "parent": -1,
    "effect": "물 3개마다 수색 클릭 -1",
    "display_slot": 0
  },
  {
    "key": "Tea",
    "name": "녹차",
    "asset": "res://images/drinks/approved/green_tea.png",
    "color": "#B4D581",
    "cost": 0,
    "parent": -1,
    "effect": "마실 때마다 발견 금액 +1 Gold",
    "display_slot": 1
  },
  {
    "key": "Ion",
    "name": "이온음료",
    "asset": "res://images/drinks/approved/ion_drink.png",
    "color": "#B7B9FF",
    "cost": 5,
    "parent": -1,
    "effect": "마실 때마다 발견 금액 +2 Gold",
    "display_slot": 3
  },
  {
    "key": "Vitamin",
    "name": "비타민 음료",
    "asset": "res://images/drinks/approved/vitamin.png",
    "color": "#FFE475",
    "cost": 15,
    "parent": 12,
    "effect": "꽝 확률 -0.5%p (최소 2%)",
    "display_slot": 10
  },
  {
    "key": "Apple",
    "name": "사과 주스",
    "asset": "res://images/drinks/approved/apple_juice.png",
    "color": "#F09589",
    "cost": 8,
    "parent": 2,
    "effect": "마실 때마다 발견 금액 +3 Gold",
    "display_slot": 4
  },
  {
    "key": "Orange",
    "name": "오렌지 주스",
    "asset": "res://images/drinks/approved/orange_juice.png",
    "color": "#FFBF70",
    "cost": 15,
    "parent": 8,
    "effect": "최종 발견 금액 +1% · 펀치 피버 +1초 (최대 15초)",
    "display_slot": 9
  },
  {
    "key": "Cola",
    "name": "콜라",
    "asset": "res://images/drinks/approved/cola.png",
    "color": "#EF858D",
    "cost": 20,
    "parent": 3,
    "effect": "획득 시 수색 피버 발동 · 발견 골드 +5 유지",
    "display_slot": 13
  },
  {
    "key": "Fanta",
    "name": "황금음료 · 오로라 골드",
    "asset": "res://images/drinks/approved/golden.png",
    "color": "#D3A4FF",
    "cost": 30,
    "parent": 14,
    "effect": "마실 때마다 최종 발견 금액 +2%",
    "display_slot": 12
  },
  {
    "key": "Sprite",
    "name": "레몬라임 소다",
    "asset": "res://images/drinks/approved/lime_soda.png",
    "color": "#92E7AE",
    "cost": 12,
    "parent": 10,
    "effect": "4개마다 수색 클릭 -1 (최소 3회)",
    "display_slot": 7
  },
  {
    "key": "Barley",
    "name": "보리차",
    "asset": "res://images/drinks/approved/barley_tea.png",
    "color": "#D9A44A",
    "cost": 8,
    "parent": 2,
    "display_slot": 2,
    "effect": "획득 시 빈캔 +1"
  },
  {
    "key": "Ginger",
    "name": "진저에일",
    "asset": "res://images/drinks/approved/ginger_ale.png",
    "color": "#75BB6B",
    "cost": 10,
    "parent": 9,
    "display_slot": 5,
    "effect": "획득 시 빈캔 +1"
  },
  {
    "key": "Lemonade",
    "name": "레모네이드",
    "asset": "res://images/drinks/approved/lemonade.png",
    "color": "#F4DA52",
    "cost": 10,
    "parent": 4,
    "display_slot": 6,
    "effect": "획득 시 빈캔 +1"
  },
  {
    "key": "Peach",
    "name": "복숭아 주스",
    "asset": "res://images/drinks/approved/peach_juice.png",
    "color": "#F7A1AC",
    "cost": 12,
    "parent": 11,
    "display_slot": 8,
    "effect": "수색 피버 지속 시간 +1초 (최대 20초)"
  },
  {
    "key": "Melon",
    "name": "멜론 소다",
    "asset": "res://images/drinks/approved/melon_soda.png",
    "color": "#9DDC68",
    "cost": 20,
    "parent": 5,
    "display_slot": 11,
    "effect": "획득 시 빈캔 +1"
  },
  {
    "key": "Energy",
    "name": "에너지 드링크",
    "asset": "res://images/drinks/approved/energy.png",
    "color": "#BCE638",
    "cost": 25,
    "parent": 6,
    "display_slot": 14,
    "effect": "획득 시 펀치 피버 발동 · 타격 보상 수색 골드의 3배"
  }
]
