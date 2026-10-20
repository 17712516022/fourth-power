class_name FarmerState extends Node

var state_machine : FarmStateMachine

func SetUp(p_state_machine) -> void:
	state_machine = p_state_machine

# 进入这个状态时喊一声。
func enter(prev : FarmerState) -> void:
	pass

# 我在这儿，能去哪儿。
func next_state(attribute : Dictionary) -> FarmerState:
	return state_machine.current_state

# 离开这个状态时喊一声。
func exit() -> void:
	pass


# 报纸
func commit_push(_push : Dictionary) -> void:
	pass


# 状态对外报的两个数

# 这个状态给粮仓的产出倍数。
func yield_multiple() -> float:
	return 1.0

# 稳定度按它扣分：**扣分 = 这个系数 × 本群体的 power**（见 Government._perceive）。
func stability_coef() -> float:
	return 0.0
