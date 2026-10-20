class_name SoldierStateRampage extends SoldierState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var mutiny_yvzhi : float = StateChangeData.soldierRampageMutinyTransportNeed
var normal_yvzhi : float = StateChangeData.soldierRampageNormalTransportNeed

# 扰民：枪在手里，没人管——纪律本来就是靠"怕"压住的，怕没了就横着走。
func enter(_prev : SoldierState) -> void:
	# 从常态（纪律松了）或腐败（怕了才照章办事）来，说法一样。
	EventBus.material_news_requested.emit(NewsData.NewsType.SoldierRampageStart)

# 出口两条：怕再退下去就哗变（升级，先判），怕回来了就归营。
func next_state(attribute : Dictionary) -> SoldierState:
	if attribute["fear"] < mutiny_yvzhi:
		return state_machine.MutinyState
	elif attribute["fear"] > normal_yvzhi:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 两条线都归"怕"。
func commit_push(push : Dictionary) -> void:
	mutiny_yvzhi = clampf(mutiny_yvzhi + push["fear"], 0.05, 0.95)
	normal_yvzhi = clampf(normal_yvzhi + push["fear"], 0.05, 0.95)



# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.soldierRampageStabilityCoef
