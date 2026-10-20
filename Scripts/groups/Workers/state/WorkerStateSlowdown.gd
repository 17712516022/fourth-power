class_name WorkerStateSlowdown extends WorkerState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var depression_yvzhi : float = StateChangeData.workerSlowdownDepressionTransportNeed
var normal_yvzhi : float = StateChangeData.workerSlowdownNormalTransportNeed

# 怠工：磨洋工，机器还转，只是出数掉下来。

func enter(_prev : WorkerState) -> void:
	EventBus.material_news_requested.emit(NewsData.NewsType.WorkerSlowdownStart)

# 出口两条：怕了就缩进低效（升级），乐回来了就照常上工（回程 = 进线的反面）。
func next_state(attribute : Dictionary) -> WorkerState:
	if attribute["fear"] > depression_yvzhi:
		return state_machine.DepressionState
	elif attribute["happy"] > normal_yvzhi:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

func commit_push(push : Dictionary) -> void:
	depression_yvzhi = clampf(depression_yvzhi + push["fear"], 0.05, 0.95)
	normal_yvzhi = clampf(normal_yvzhi + push["happy"], 0.05, 0.95)

func industry_multiple() -> float:
	return StateChangeData.workerSlowdownYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.workerSlowdownStabilityCoef
