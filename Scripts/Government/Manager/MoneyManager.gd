class_name MoneyManager extends RefCounted

# 国库
var value : float = 0.60


# 两个基础速率。
const TAX_RATE   : float = 0.020
const DAILY_COST : float = 0.018

# 见底 / 宽裕 的分界线。
const TIGHT : float = 0.40
const GOOD : float = 0.70

enum MoneyState {
	High, Normal, Low
}

var state : MoneyState = MoneyState.Normal


func _init() -> void:
	update_state()


# 收税、开销。
func update() -> void:
	var final_tax : float = TAX_RATE * Modifer.tax_modifer
	var final_cost : float = DAILY_COST * Modifer.spend_modifer
	var delta : float = final_tax - final_cost
	
	value = clampf(value + delta, 0.0, 1.0)
	
	update_state()


func update_state() -> void:
	if value < TIGHT:
		state = MoneyState.Low
	elif value > GOOD:
		state = MoneyState.High
	else:
		state = MoneyState.Normal


# 花掉一笔钱。
func spend(amount : float) -> void:
	value = clampf(value - amount, 0.0, 1.0)
	update_state()


# 进一笔 / 退一笔，正负都行。
func add(amount : float) -> void:
	value = clampf(value + amount, 0.0, 1.0)
	update_state()
