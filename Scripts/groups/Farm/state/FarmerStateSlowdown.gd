class_name FarmerStateSlowdown extends FarmerState

var enter_flee_lvzhi : float = StateChangeData.farmerSlowdownFleeTransportNeed
var enter_nomal_lvzhi : float = StateChangeData.farmerSlowdownNormalTransportNeed

func enter(prev : FarmerState) -> void:
	EventBus.material_news_requested.emit(NewsData.NewsType.FarmerSlowDown)

# 出口两条：怕了就逃走（升级），乐回来了就复耕（回程）。
func next_state(attribute : Dictionary) -> FarmerState:
	if attribute["fear"] > enter_flee_lvzhi:
		return state_machine.FleeState
	elif attribute["happy"] > enter_nomal_lvzhi:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

func commit_push(push : Dictionary) -> void:
	enter_flee_lvzhi = clampf(enter_flee_lvzhi + push["fear"], 0.05, 0.95)
	enter_nomal_lvzhi = clampf(enter_nomal_lvzhi + push["happy"], 0.05, 0.95)

func yield_multiple() -> float:
	return StateChangeData.farmerSlowdownYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.farmerSlowdownStabilityCoef
