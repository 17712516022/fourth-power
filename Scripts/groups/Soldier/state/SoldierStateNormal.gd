class_name SoldierStateNormal extends SoldierState

# 阈值 = 起点（住在 StateChangeData，只有一份）+ 报纸历次推的量（永久累积）。
var corrupt_yvzhi : float = StateChangeData.soldierNormalCorruptTransportNeed
var rampage_yvzhi : float = StateChangeData.soldierNormalRampageTransportNeed
var desert_yvzhi : float = StateChangeData.soldierNormalDesertTransportNeed

func enter(prev : SoldierState) -> void:
	if prev is SoldierStateDesert:
		# 残部重新收拢。
		EventBus.material_news_requested.emit(NewsData.NewsType.SoldierRally)
	elif prev is SoldierStateRampage:
		# 收了枪，归营。
		EventBus.material_news_requested.emit(NewsData.NewsType.SoldierRampageEnd)
	elif prev is SoldierStateCorrupt:
		# 饷银补上，营里重新点数。
		EventBus.material_news_requested.emit(NewsData.NewsType.SoldierCorruptEnd)
	elif prev is SoldierStateMutiny:
		# 兵变后回到正常 = 编制散了，再也组织不起来（和"收拢残部"不是一回事）。
		EventBus.material_news_requested.emit(NewsData.NewsType.SoldierDisband)

# 三个出口，**怒先判**（枪口对内最急），怕次之，乐最后。
func next_state(attribute : Dictionary) -> SoldierState:
	if attribute["angry"] < corrupt_yvzhi:
		return state_machine.CorruptState
	elif attribute["fear"] < rampage_yvzhi:
		return state_machine.RampageState
	elif attribute["happy"] < desert_yvzhi:
		return state_machine.DesertState
	return state_machine.current_state

func exit() -> void:
	pass

# 我这三条线：腐败归"怒"、扰民归"怕"、溃散归"乐"。
func commit_push(push : Dictionary) -> void:
	corrupt_yvzhi = clampf(corrupt_yvzhi + push["angry"], 0.05, 0.95)
	rampage_yvzhi = clampf(rampage_yvzhi + push["fear"], 0.05, 0.95)
	desert_yvzhi = clampf(desert_yvzhi + push["happy"], 0.05, 0.95)


# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.soldierNormalStabilityCoef
