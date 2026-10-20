class_name MerchantStateSpeculate extends MerchantState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var hollow_yvzhi : float = StateChangeData.merchantSpeculateHollowTransportNeed

# 投机：货压在手里等价钱（原来的"囤积"）。

func enter(_prev : MerchantState) -> void:
	# 从繁荣（乐太高）或投资（怕太低）上来，说法一样：囤货惜售。
	EventBus.material_news_requested.emit(NewsData.NewsType.MerchantSpeculateStart)

# 只有一条出口：怕低到这份上，铺子就空了。
func next_state(attribute : Dictionary) -> MerchantState:
	if attribute["fear"] < hollow_yvzhi:
		return state_machine.HollowState
	return state_machine.current_state

func exit() -> void:
	pass

func commit_push(push : Dictionary) -> void:
	hollow_yvzhi = clampf(hollow_yvzhi + push["fear"], 0.05, 0.95)

func tax_multiple() -> float:
	return StateChangeData.merchantSpeculateYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.merchantSpeculateStabilityCoef
