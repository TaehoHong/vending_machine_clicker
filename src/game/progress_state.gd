extends RefCounted

# 진행은 게임 세션 한 곳에서 소유한다. 화면은 이 객체를 복제해 원장으로 쓰지 않는다.
var money: int = 0
var click_stack: int = 0
var quest_clicks: int = 0
var quest_reward_claimed: bool = false
var can_quest_reward_claimed: bool = false
var drinks: int = 0
var purchase_count: int = 0
var water_count: int = 0
var green_tea_count: int = 0
var ion_count: int = 0
var ion_unlocked: bool = false
var extra_counts: Dictionary = {}
var unlocked_drinks: Array[int] = []
var last_drink: int = 0
var cans: int = 0
var machine_level: int = 0
var inserting_coin: bool = false
var search_fever_remaining: float = 0.0
var search_fever_total: float = 10.0
var search_fever_pending: bool = false
var punch_fever_remaining: float = 0.0
var punch_fever_total: float = 5.0
var punch_fever_pending: bool = false
