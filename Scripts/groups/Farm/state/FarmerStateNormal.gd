class_name FarmerStateNormal extends FarmerState

# 阈值 = 起点（住在 StateChangeData，只有一份）+ 报纸历次推的量（永久累积）。
var resist_yvzhi : float = StateChangeData.farmerNormalResistTransportNeed
var flee_yvzhi : float = StateChangeData.farmerNormalFleeTransportNeed
var slow_down_yvzhi : float = StateChangeData.farmerNormalSlowdownTransportNeed

# 正常：地照种，粮全额。

func enter(prev : FarmerState) -> void:
	if prev is FarmerStateFlee:
		EventBus.material_news_requested.emit(NewsData.NewsType.FarmerReturn)
	elif prev is FarmerStateResist:
		EventBus.material_news_requested.emit(NewsData.NewsType.FarmerResistEnd)
	elif prev is FarmerStateSlowdown:
		EventBus.material_news_requested.emit(NewsData.NewsType.FarmerSlowDownEnd)
	elif prev is FarmerStateUpRising:
		EventBus.material_news_requested.emit(NewsData.NewsType.FarmerUpRisingEnd)

# 三个出口。
func next_state(attribute : Dictionary) -> FarmerState:
	if attribute["angry"] > resist_yvzhi:
		return state_machine.ResistState
	elif attribute["fear"] > flee_yvzhi:
		return state_machine.FleeState
	elif attribute["happy"] < slow_down_yvzhi:
		return state_machine.SlowDownState
	return state_machine.current_state

func exit() -> void:
	pass

# 我这三条线：抗租归"怒"、逃亡归"怕"、怠工归"乐"。
func commit_push(push : Dictionary) -> void:
	resist_yvzhi = clampf(resist_yvzhi + push["angry"], 0.05, 0.95)
	flee_yvzhi = clampf(flee_yvzhi + push["fear"], 0.05, 0.95)
	slow_down_yvzhi = clampf(slow_down_yvzhi + push["happy"], 0.05, 0.95)

func yield_multiple() -> float:
	return StateChangeData.farmerNormalYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.farmerNormalStabilityCoef
