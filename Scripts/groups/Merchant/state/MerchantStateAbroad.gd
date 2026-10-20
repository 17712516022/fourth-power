class_name MerchantStateAbroad extends MerchantState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var normal_yvzhi : float = StateChangeData.merchantAbroadNormalTransportNeed

# 国外：人和钱一起走了，这个埠上没什么可收的税。

func enter(_prev : MerchantState) -> void:
	# 只有常态能走到这里：人和钱一起走了。
	EventBus.material_news_requested.emit(NewsData.NewsType.MerchantAbroad)

# 只有一条出口：怒退回去，资本回埠。
func next_state(attribute : Dictionary) -> MerchantState:
	if attribute["angry"] < normal_yvzhi:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

func commit_push(push : Dictionary) -> void:
	normal_yvzhi = clampf(normal_yvzhi + push["angry"], 0.05, 0.95)

func tax_multiple() -> float:
	return StateChangeData.merchantAbroadYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.merchantAbroadStabilityCoef
