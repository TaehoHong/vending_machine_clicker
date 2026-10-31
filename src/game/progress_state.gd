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
# 결제·지급은 완료됐으며 배출 연출만 남은 결과다. 저장 원장과 구분한다.
var pending_purchases: Dictionary = {}
var inserting_coin: bool:
	get:
		return not pending_purchases.is_empty()
var search_fever_remaining: float = 0.0
var search_fever_total: float = 10.0
var queued_search_fevers: int = 0
var queued_punch_fevers: int = 0
var punch_purchase_delay: float = 0.0
var search_fever_pending: bool:
	get:
		return queued_search_fevers > 0 or pending_purchases.values().has(6)
var punch_fever_remaining: float = 0.0
var punch_fever_total: float = 5.0
var punch_fever_pending: bool:
	get:
		return queued_punch_fevers > 0 or pending_purchases.values().has(14)

var facilities: Dictionary = {
	"alley": preload("res://src/game/automation/facility_rules.gd").DEFAULT.duplicate(true),
}
