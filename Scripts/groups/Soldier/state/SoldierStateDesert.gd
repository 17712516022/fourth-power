class_name SoldierStateDesert extends SoldierState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var mutiny_yvzhi : float = StateChangeData.soldierDesertMutinyTransportNeed
var normal_yvzhi : float = StateChangeData.soldierDesertNormalTransportNeed

# 溃散：人跑了，枪还扔在营里。
func enter(_prev : SoldierState) -> void:
	# 只有常态能走到这里：心气散了，队伍打散。
	EventBus.material_news_requested.emit(NewsData.NewsType.SoldierDesert)

# 出口两条：乐再掉下去就哗变（升级，先判），乐回来了就重新收拢。
func next_state(attribute : Dictionary) -> SoldierState:
	if attribute["happy"] < mutiny_yvzhi:
		return state_machine.MutinyState
	elif attribute["happy"] > normal_yvzhi:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 两条线都归"乐"。
func commit_push(push : Dictionary) -> void:
	mutiny_yvzhi = clampf(mutiny_yvzhi + push["happy"], 0.05, 0.95)
	normal_yvzhi = clampf(normal_yvzhi + push["happy"], 0.05, 0.95)



# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.soldierDesertStabilityCoef
