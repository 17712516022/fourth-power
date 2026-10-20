class_name WorkerStateUpRising extends WorkerState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var normal_happy_yvzhi : float = StateChangeData.workerUpRisingNormalHappyNeed
var normal_fear_yvzhi : float = StateChangeData.workerUpRisingNormalFearNeed
var normal_angry_yvzhi : float = StateChangeData.workerUpRisingNormalAngryNeed

# 动乱：厂里没人了。

func enter(_prev : WorkerState) -> void:
	# 从低效或示威上来，说法一样：占据厂屋。
	EventBus.material_news_requested.emit(NewsData.NewsType.WorkerUpRisingStart)

# 三条一起成立才散：乐回来了、怕退了、怒也消了。
func next_state(attribute : Dictionary) -> WorkerState:
	if (attribute["happy"] > normal_happy_yvzhi
			and attribute["fear"] < normal_fear_yvzhi
			and attribute["angry"] < normal_angry_yvzhi):
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 三条退线各吃自己那一维的 push。
func commit_push(push : Dictionary) -> void:
	normal_happy_yvzhi = clampf(normal_happy_yvzhi + push["happy"], 0.05, 0.95)
	normal_fear_yvzhi = clampf(normal_fear_yvzhi + push["fear"], 0.05, 0.95)
	normal_angry_yvzhi = clampf(normal_angry_yvzhi + push["angry"], 0.05, 0.95)

func industry_multiple() -> float:
	return StateChangeData.workerUpRisingYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.workerUpRisingStabilityCoef
