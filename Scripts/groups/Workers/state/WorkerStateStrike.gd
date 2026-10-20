class_name WorkerStateStrike extends WorkerState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var march_yvzhi : float = StateChangeData.workerStrikeMarchTransportNeed
var normal_yvzhi : float = StateChangeData.workerStrikeNormalTransportNeed

# 停工：厂子停了，机器就转不动。

func enter(prev : WorkerState) -> void:
	if prev is WorkerStateNormal:
		# 停工。
		EventBus.material_news_requested.emit(NewsData.NewsType.WorkerStrikeStart)

# 出口两条：怒再往上就上街（升级，先判），怒退了就复工。
func next_state(attribute : Dictionary) -> WorkerState:
	if attribute["angry"] > march_yvzhi:
		return state_machine.MarchState
	elif attribute["angry"] < normal_yvzhi:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 两条线都归"怒"。
func commit_push(push : Dictionary) -> void:
	march_yvzhi = clampf(march_yvzhi + push["angry"], 0.05, 0.95)
	normal_yvzhi = clampf(normal_yvzhi + push["angry"], 0.05, 0.95)

func industry_multiple() -> float:
	return StateChangeData.workerStrikeYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.workerStrikeStabilityCoef
