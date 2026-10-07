class_name Soldier extends Group

# 纯逻辑对象，不进场景树——它不需要树的任何东西。
var state_machine : SoldierStateMachine = SoldierStateMachine.new()


# --- 它是谁 ---

func initial_attribute() -> Dictionary:
	# power 唯一一个初值不是 0 的：编制是现成的，
	# 不需要像农民那样从零攒底气。这是士兵最刺眼的一处差异，也是刻意的。
	return {"happy" : 0.3, "angry" : 0.30, "fear" : 0.0, "power" : 0.60}

func my_kind() -> GroupData.READERS:
	return GroupData.READERS.SOLDIER

func finale_type() -> int:
	return NewsData.NewsType.SoldierDesert


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
	
	_read_world()                                                  # 世道乱，谁都怕
	
	# 欠饷。政府没钱的时候，兵最先知道——他们的饷银按月发，别的东西还能拖。
	# 注意给的是**怒**不是怕：拿不到钱的人不会怕，会火。
	_absorb(attribute, MoneyInfluence.soldier(government.asset.money))


# --- 外向：以后这里要发出事件让世界看见。现在只做对自己那部分 ---
#
# 这里只剩下"哪个状态有代价"。代价是多少在 Modifer 里。
func _act() -> void:
	match state_machine.current_state:
		SoldierStateMachine.SoldierState.Slack:
			_absorb(attribute, Modifer.soldier_slack())
	
		SoldierStateMachine.SoldierState.Mutiny:
			_absorb(attribute, Modifer.soldier_mutiny())
		_:
			pass
