class_name MerchantStateNormal extends MerchantState

# 阈值 = 起点（住在 StateChangeData，只有一份）+ 报纸历次推的量（永久累积）。
var abroad_yvzhi : float = StateChangeData.merchantNormalAbroadTransportNeed
var invest_yvzhi : float = StateChangeData.merchantNormalInvestTransportNeed
var prosperity_yvzhi : float = StateChangeData.merchantNormalProsperityTransportNeed

# 正常：铺子照开，税照交。

func enter(prev : MerchantState) -> void:
	if prev is MerchantStateProsperity:
		# 旺月过去了。
		EventBus.material_news_requested.emit(NewsData.NewsType.MerchantProsperityEnd)
	elif prev is MerchantStateInvest:
		# 不投了，钱撤回来。
		EventBus.material_news_requested.emit(NewsData.NewsType.MerchantInvestEnd)
	elif prev is MerchantStateSpeculate:
		# 放货了。
		EventBus.material_news_requested.emit(NewsData.NewsType.MerchantSpeculateEnd)
	elif prev is MerchantStateHollow:
		# 闭门的号重又开张。
		EventBus.material_news_requested.emit(NewsData.NewsType.MerchantHollowEnd)
	elif prev is MerchantStateAbroad:
		# 太平了，资本回埠。
		EventBus.material_news_requested.emit(NewsData.NewsType.MerchantReturn)

# 三个出口。
func next_state(attribute : Dictionary) -> MerchantState:
	if attribute["angry"] > abroad_yvzhi:
		return state_machine.AbroadState
	elif attribute["fear"] < invest_yvzhi:
		return state_machine.InvestState
	elif attribute["happy"] > prosperity_yvzhi:
		return state_machine.ProsperityState
	return state_machine.current_state

func exit() -> void:
	pass

# 我这三条线：外逃归"怒"、投资归"怕"、繁荣归"乐"。
func commit_push(push : Dictionary) -> void:
	abroad_yvzhi = clampf(abroad_yvzhi + push["angry"], 0.05, 0.95)
	invest_yvzhi = clampf(invest_yvzhi + push["fear"], 0.05, 0.95)
	prosperity_yvzhi = clampf(prosperity_yvzhi + push["happy"], 0.05, 0.95)

func tax_multiple() -> float:
	return StateChangeData.merchantNormalYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.merchantNormalStabilityCoef
