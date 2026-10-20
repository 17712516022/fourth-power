class_name SoldierPowerManager extends RefCounted

# 在册能调的兵
var value : float = 0.60


# 兵力空虚 / 充盈 的分界线。
const TIGHT : float = 0.40
const GOOD : float = 0.70


enum SoldierPowerState {
	High, Normal, Low
}

var state : SoldierPowerState = SoldierPowerState.Normal


func _init() -> void:
	update_state()


# 照抄。
func mirror(soldier_power : float) -> void:
	value = soldier_power
	update_state()


func update_state() -> void:
	if value < TIGHT:
		state = SoldierPowerState.Low
	elif value > GOOD:
		state = SoldierPowerState.High
	else:
		state = SoldierPowerState.Normal
