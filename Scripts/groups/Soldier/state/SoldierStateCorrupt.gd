class_name SoldierStateCorrupt extends SoldierState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var rampage_yvzhi : float = StateChangeData.soldierCorruptRampageTransportNeed
var normal_yvzhi : float = StateChangeData.soldierCorruptNormalTransportNeed

# 腐败：饷照领，事不办——怒没了，营里只剩人情与账目。
func enter(_prev : SoldierState) -> void:
	# 只有常态能走到这里：心气散了，账本厚了。
	EventBus.material_news_requested.emit(NewsData.NewsType.SoldierCorruptStart)

# 出口两条：怕一退就横着走（升级，先判——它会和"怒回来了"同时成立），。
func next_state(attribute : Dictionary) -> SoldierState:
	if attribute["fear"] < rampage_yvzhi:
		return state_machine.RampageState
	elif attribute["angry"] > normal_yvzhi:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 两条线各归自己那一维。
func commit_push(push : Dictionary) -> void:
	rampage_yvzhi = clampf(rampage_yvzhi + push["fear"], 0.05, 0.95)
	normal_yvzhi = clampf(normal_yvzhi + push["angry"], 0.05, 0.95)



# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.soldierCorruptStabilityCoef
