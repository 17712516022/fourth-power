class_name MerchantStateProsperity extends MerchantState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var speculate_yvzhi : float = StateChangeData.merchantProsperitySpeculateTransportNeed
var normal_yvzhi : float = StateChangeData.merchantProsperityNormalTransportNeed

# 繁荣：生意最好，税基最肥。

func enter(_prev : MerchantState) -> void:
	# 只有常态能走到这里：市面旺起来了。
	EventBus.material_news_requested.emit(NewsData.NewsType.MerchantProsperityStart)

# 出口两条：乐再往上就囤货惜售（升级，先判），乐退回来就照常开门。
func next_state(attribute : Dictionary) -> MerchantState:
	if attribute["happy"] > speculate_yvzhi:
		return state_machine.SpeculateState
	elif attribute["happy"] < normal_yvzhi:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 两条线都归"乐"。
func commit_push(push : Dictionary) -> void:
	speculate_yvzhi = clampf(speculate_yvzhi + push["happy"], 0.05, 0.95)
	normal_yvzhi = clampf(normal_yvzhi + push["happy"], 0.05, 0.95)

func tax_multiple() -> float:
	return StateChangeData.merchantProsperityYieldMultiple

# 稳定度系数：**负的**——铺面兴旺，世道也稳一点。
func stability_coef() -> float:
	return StateChangeData.merchantProsperityStabilityCoef
