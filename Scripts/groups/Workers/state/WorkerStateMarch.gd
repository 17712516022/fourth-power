class_name WorkerStateMarch extends WorkerState

# 阈值 = 起点（住在 StateChangeData）+ 报纸历次推的量。
var up_rising_yvzhi : float = StateChangeData.workerMarchUpRisingTransportNeed

# 回常态要**三条一起成立**（和动乱那三条是同一套数，两边各自吃自己那一维的 push）。
var normal_happy_yvzhi : float = StateChangeData.workerMarchNormalHappyNeed
var normal_fear_yvzhi : float = StateChangeData.workerMarchNormalFearNeed
var normal_angry_yvzhi : float = StateChangeData.workerMarchNormalAngryNeed

# 示威：上街了，厂子还没全停。

func enter(_prev : WorkerState) -> void:
	# 只有停工能走到这里：结队上街。
	EventBus.material_news_requested.emit(NewsData.NewsType.WorkerMarchStart)

func next_state(attribute : Dictionary) -> WorkerState:
	if attribute["angry"] > up_rising_yvzhi:
		return state_machine.UpRisingState
	elif (attribute["happy"] > normal_happy_yvzhi
			and attribute["fear"] < normal_fear_yvzhi
			and attribute["angry"] < normal_angry_yvzhi):
		return state_machine.NormalState
	return state_machine.current_state

func exit() -> void:
	pass

# 四条线：升级那条归"怒"，回常态那三条各归自己。
func commit_push(push : Dictionary) -> void:
	up_rising_yvzhi = clampf(up_rising_yvzhi + push["angry"], 0.05, 0.95)
	normal_happy_yvzhi = clampf(normal_happy_yvzhi + push["happy"], 0.05, 0.95)
	normal_fear_yvzhi = clampf(normal_fear_yvzhi + push["fear"], 0.05, 0.95)
	normal_angry_yvzhi = clampf(normal_angry_yvzhi + push["angry"], 0.05, 0.95)

func industry_multiple() -> float:
	return StateChangeData.workerMarchYieldMultiple

# 稳定度系数（扣分 = 系数 × 本群体的 power）。
func stability_coef() -> float:
	return StateChangeData.workerMarchStabilityCoef
