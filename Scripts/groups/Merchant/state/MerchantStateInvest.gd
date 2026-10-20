class_name MerchantStateInvest extends MerchantState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var speculate_yvzhi : float = StateChangeData.merchantInvestSpeculateTransportNeed
var normal_yvzhi : float = StateChangeData.merchantInvestNormalTransportNeed

# 投资：钱压进产业里——不怕的人才敢投。

func enter(_prev : MerchantState) -> void:
	# 只有常态能走到这里：资本开始动了。
	EventBus.material_news_requested.emit(NewsData.NewsType.MerchantInvestStart)

# 出口两条：怕再退下去就囤货（升级，先判），怕回来了就收手。
func next_state(attribute : Dictionary) -> MerchantState:
	if attribute["fear"] < speculate_yvzhi:
		return state_machine.SpeculateState
	elif attribute["fear"] > normal_yvzhi:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 两条线都归"怕"。
func commit_push(push : Dictionary) -> void:
	speculate_yvzhi = clampf(speculate_yvzhi + push["fear"], 0.05, 0.95)
	normal_yvzhi = clampf(normal_yvzhi + push["fear"], 0.05, 0.95)

func tax_multiple() -> float:
	return StateChangeData.merchantInvestYieldMultiple

# 稳定度系数：**负的**——钱投进实业，世道反而更稳。
func stability_coef() -> float:
	return StateChangeData.merchantInvestStabilityCoef
