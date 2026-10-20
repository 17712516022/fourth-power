class_name MerchantStateHollow extends MerchantState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var normal_happy_yvzhi : float = StateChangeData.merchantHollowNormalHappyNeed
var normal_fear_yvzhi : float = StateChangeData.merchantHollowNormalFearNeed

# 蛀空：仓里有货，铺前无人——铺子被自己蛀空了。

func enter(_prev : MerchantState) -> void:
	# 只有投机能走到这里：货压在仓里，人不再上门。
	EventBus.material_news_requested.emit(NewsData.NewsType.MerchantHollowStart)

# 回常态：两条一起成立——乐回来了、怕也回来了（都回到常态那两条线上）。
func next_state(attribute : Dictionary) -> MerchantState:
	if attribute["happy"] > normal_happy_yvzhi and attribute["fear"] > normal_fear_yvzhi:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 两条退线各吃自己那一维的 push。
func commit_push(push : Dictionary) -> void:
	normal_happy_yvzhi = clampf(normal_happy_yvzhi + push["happy"], 0.05, 0.95)
	normal_fear_yvzhi = clampf(normal_fear_yvzhi + push["fear"], 0.05, 0.95)

func tax_multiple() -> float:
	return StateChangeData.merchantHollowYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.merchantHollowStabilityCoef
