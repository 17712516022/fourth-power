class_name FarmerStateUpRising extends FarmerState

# 回常态：三条一起成立——乐高、怕低、怒低。
var exit_happy_lvzhi : float = StateChangeData.farmerUpRisingNormalHappyNeed
var exit_fear_lvzhi : float = StateChangeData.farmerUpRisingNormalFearNeed
var exit_angry_lvzhi : float = StateChangeData.farmerUpRisingNormalAngryNeed

# 动乱：地里没人了。
func enter(prev : FarmerState) -> void:
	EventBus.material_news_requested.emit(NewsData.NewsType.FarmerUpRisingStart)

# 三条一起成立才散：乐回来了、怕退了、怒也消了。
func next_state(attribute : Dictionary) -> FarmerState:
	if (attribute["happy"] > exit_happy_lvzhi
			and attribute["fear"] < exit_fear_lvzhi
			and attribute["angry"] < exit_angry_lvzhi):
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 三条退线各吃自己那一维的 push。
func commit_push(push : Dictionary) -> void:
	exit_happy_lvzhi = clampf(exit_happy_lvzhi + push["happy"], 0.05, 0.95)
	exit_fear_lvzhi = clampf(exit_fear_lvzhi + push["fear"], 0.05, 0.95)
	exit_angry_lvzhi = clampf(exit_angry_lvzhi + push["angry"], 0.05, 0.95)

func yield_multiple() -> float:
	return StateChangeData.farmerUpRisingYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.farmerUpRisingStabilityCoef
