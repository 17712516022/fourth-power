class_name FarmerStateResist extends FarmerState

var enter_uprising_lvzhi : float = StateChangeData.farmerResistUpRisingTransportNeed
var enter_nomal_need : float = StateChangeData.farmerResistNormalTransportNeed

# 抗租：地还在种，只是不出力。
func enter(prev : FarmerState) -> void:
	EventBus.material_news_requested.emit(NewsData.NewsType.FarmerResistStart)

func next_state(attribute : Dictionary) -> FarmerState:
	if attribute["angry"] > enter_uprising_lvzhi:
		return state_machine.UpRisingState
	elif attribute["angry"] < enter_nomal_need:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 我这两条线都归"怒"（power 不参与农民判定了）。
func commit_push(push : Dictionary) -> void:
	enter_uprising_lvzhi = clampf(enter_uprising_lvzhi + push["angry"], 0.05, 0.95)
	enter_nomal_need = clampf(enter_nomal_need + push["angry"], 0.05, 0.95)

func yield_multiple() -> float:
	return StateChangeData.farmerResistYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.farmerResistStabilityCoef
