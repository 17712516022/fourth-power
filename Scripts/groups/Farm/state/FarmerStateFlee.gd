class_name FarmerStateFlee extends FarmerState

var uprising_yvzhi : float = StateChangeData.farmerFleeUpRisingTransportNeed
var flee_out_yvzhi : float = StateChangeData.farmerFleeNormalTransportNeed

# 流亡：人走了，地荒了，只剩零星残耕。
func enter(_prev : FarmerState) -> void:
	EventBus.material_news_requested.emit(NewsData.NewsType.FarmerFlee)

func next_state(attribute : Dictionary) -> FarmerState:
	if attribute["angry"] > uprising_yvzhi:
		return state_machine.UpRisingState
	elif attribute["fear"] < flee_out_yvzhi:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 造反那条归"怒"，回村那条归"怕"。
func commit_push(push : Dictionary) -> void:
	uprising_yvzhi = clampf(uprising_yvzhi + push["angry"], 0.05, 0.95)
	flee_out_yvzhi = clampf(flee_out_yvzhi + push["fear"], 0.05, 0.95)

func yield_multiple() -> float:
	return StateChangeData.farmerFleeYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.farmerFleeStabilityCoef
