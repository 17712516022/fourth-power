class_name IndustrialPowerManager extends RefCounted

# 工业力
var value : float = 0.60


# 两个基础速率。
const YIELD : float = 0.070
const WEAR  : float = 0.067


# 低效 / 兴旺 的分界线。
const TIGHT : float = 0.40
const GOOD : float = 0.70


enum IndustrialPowerState {
	High, Normal, Low
}

var state : IndustrialPowerState = IndustrialPowerState.Normal

func _init() -> void:
	update_state()


func update() -> void:
	var final_yield : float = YIELD * Modifer.industry_modifer
	var final_wear : float = WEAR * Modifer.industry_wear_modifer
	var delta : float = final_yield - final_wear
	
	value = clampf(value + delta, 0.0, 1.0)
	
	update_state()


func update_state() -> void:
	if value < TIGHT:
		state = IndustrialPowerState.Low
	elif value > GOOD:
		state = IndustrialPowerState.High
	else:
		state = IndustrialPowerState.Normal


func get_state() -> IndustrialPowerState:
	return state


# 进一笔 / 退一笔，正负都行。
func add(amount : float) -> void:
	value = clampf(value + amount, 0.0, 1.0)
	update_state()
