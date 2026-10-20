class_name WorkerStateDepression extends WorkerState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var up_rising_yvzhi : float = StateChangeData.workerDepressionUpRisingTransportNeed
var normal_yvzhi : float = StateChangeData.workerDepressionNormalTransportNeed

# 低效：厂区冷清，人不敢上工。

func enter(_prev : WorkerState) -> void:
	# 从常态或怠工来，说法一样：厂区冷落，机器停了过半。
	EventBus.material_news_requested.emit(NewsData.NewsType.WorkerDepressionStart)

# 出口两条：怒到这份上就举事（升级，先判），怕退了就回厂。
func next_state(attribute : Dictionary) -> WorkerState:
	if attribute["angry"] > up_rising_yvzhi:
		return state_machine.UpRisingState
	elif attribute["fear"] < normal_yvzhi:
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

func commit_push(push : Dictionary) -> void:
	up_rising_yvzhi = clampf(up_rising_yvzhi + push["angry"], 0.05, 0.95)
	normal_yvzhi = clampf(normal_yvzhi + push["fear"], 0.05, 0.95)

func industry_multiple() -> float:
	return StateChangeData.workerDepressionYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.workerDepressionStabilityCoef
