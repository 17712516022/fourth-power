class_name Workers extends Group

# 纯逻辑对象，不进场景树——它不需要树的任何东西。
var state_machine : WorkerStateMachine = WorkerStateMachine.new()


# --- 它是谁 ---

func initial_attribute() -> Dictionary:
	return {"happy" : 0.3, "angry" : 0.30, "fear" : 0.0, "power" : 0.0}

func my_kind() -> GroupData.READERS:
	return GroupData.READERS.WORKER

# 工人没有终局——离厂就没饭吃，他们哪儿也去不了。
# 所以 finale_type() 用基类的 -1：永远不会走进"同类走了"那条路。


# 每天被 World 调用一次
func read_newspaper(newspaper : NewsPaper) -> void:
	_live()                            # 过日子：真相在变
	_read_paper(newspaper)                # 报纸：只改门槛，碰不到 attribute
	state_machine.change_state(attribute, push)   # 决定：真相 + 报纸推的门槛
	_act()                                # 行动：行动反过来改真相


# --- 内向：不改世界，只改自己 ---
func _live() -> void:
	# 先摇今天的骰子：四个属性各飘一点。
	_drift()
	
	# 上面几行是"我自己过日子"，下面几行是"外面的东西落在我头上"。
	# 两者都在改 attribute，但来源不同：上面是内生的，下面是世界给的。
	if government == null:
		return
	
	_read_world()                                                    # 世道乱，谁都怕
	
	# 粮荒是工人的日子。系数在 FoodInfluence.worker()——
	# 那里和商人的版本并排摆着：同一个粮仓，他高兴，我难过。
	_absorb(attribute, FoodInfluence.worker(government.asset.food))
	
	# 赈济停了。工人离厂就没饭吃，所以那口施粥对他们尤其要紧。
	_absorb(attribute, MoneyInfluence.poor(government.asset.money))


# --- 外向：以后这里要发出事件让世界看见。现在只做对自己那部分 ---
#
# 这里只剩下"哪个状态有代价"。代价是多少在 Modifer 里。
func _act() -> void:
	match state_machine.current_state:
		WorkerStateMachine.WorkerState.Slowdown:
			_absorb(attribute, Modifer.worker_slowdown())
	
		WorkerStateMachine.WorkerState.Strike:
			_absorb(attribute, Modifer.worker_strike())
		_:
			pass
