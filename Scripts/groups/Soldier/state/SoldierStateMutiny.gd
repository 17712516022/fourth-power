class_name SoldierStateMutiny extends SoldierState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var normal_happy_yvzhi : float = StateChangeData.soldierMutinyNormalHappyNeed
var normal_fear_yvzhi : float = StateChangeData.soldierMutinyNormalFearNeed
var normal_angry_yvzhi : float = StateChangeData.soldierMutinyNormalAngryNeed

# 兵变：枪口掉过来了。
func enter(_prev : SoldierState) -> void:
	# 从溃散（人散了）或扰民（没人管）上来，说法一样。
	EventBus.material_news_requested.emit(NewsData.NewsType.SoldierMutinyStart)

# 三条一起回来才算完：不是被打散，是重新有了心气。
func next_state(attribute : Dictionary) -> SoldierState:
	if (attribute["happy"] > normal_happy_yvzhi
			and attribute["fear"] > normal_fear_yvzhi
			and attribute["angry"] > normal_angry_yvzhi):
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 三条退线各吃自己那一维的 push。
func commit_push(push : Dictionary) -> void:
	normal_happy_yvzhi = clampf(normal_happy_yvzhi + push["happy"], 0.05, 0.95)
	normal_fear_yvzhi = clampf(normal_fear_yvzhi + push["fear"], 0.05, 0.95)
	normal_angry_yvzhi = clampf(normal_angry_yvzhi + push["angry"], 0.05, 0.95)



# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.soldierMutinyStabilityCoef
