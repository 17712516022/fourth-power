class_name WorkerStateNormal extends WorkerState

# 阈值 = 起点（住在 StateChangeData，只有一份）+ 报纸历次推的量（永久累积）。
var strike_yvzhi : float = StateChangeData.workerNormalStrikeTransportNeed
var depression_yvzhi : float = StateChangeData.workerNormalDepressionTransportNeed
var slow_down_yvzhi : float = StateChangeData.workerNormalSlowdownTransportNeed

# 正常：照常上工，机器全速转。

func enter(prev : WorkerState) -> void:
	if prev is WorkerStateSlowdown:
		# 不磨洋工了。
		EventBus.material_news_requested.emit(NewsData.NewsType.WorkerSlowdownEnd)
	elif prev is WorkerStateDepression:
		# 厂门重开。
		EventBus.material_news_requested.emit(NewsData.NewsType.WorkerDepressionEnd)
	elif prev is WorkerStateStrike:
		# 复工。
		EventBus.material_news_requested.emit(NewsData.NewsType.WorkerStrikeEnd)
	elif prev is WorkerStateMarch:
		# 示威散了，各回本厂。
		EventBus.material_news_requested.emit(NewsData.NewsType.WorkerMarchEnd)
	elif prev is WorkerStateUpRising:
		# 工潮平息。
		EventBus.material_news_requested.emit(NewsData.NewsType.WorkerUpRisingEnd)

# 三个出口。
func next_state(attribute : Dictionary) -> WorkerState:
	if attribute["angry"] > strike_yvzhi:
		return state_machine.StrikeState
	elif attribute["fear"] > depression_yvzhi:
		return state_machine.DepressionState
	elif attribute["happy"] < slow_down_yvzhi:
		return state_machine.SlowdownState
	return state_machine.current_state

func exit() -> void:
	pass

# 我这三条线：停工归"怒"、低效归"怕"、怠工归"乐"。
func commit_push(push : Dictionary) -> void:
	strike_yvzhi = clampf(strike_yvzhi + push["angry"], 0.05, 0.95)
	depression_yvzhi = clampf(depression_yvzhi + push["fear"], 0.05, 0.95)
	slow_down_yvzhi = clampf(slow_down_yvzhi + push["happy"], 0.05, 0.95)

func industry_multiple() -> float:
	return StateChangeData.workerNormalYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.workerNormalStabilityCoef
