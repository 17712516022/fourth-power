class_name Workers extends Group

# 纯逻辑对象，不进场景树——它不需要树的任何东西。
var state_machine : WorkerStateMachine = WorkerStateMachine.new()


# 它是谁

# 工人的正常带：乐 >= 0.85（否则怠工）· 怒 <= 0.55（否则停工）· 怕 <= 0.70（否则低效）
func initial_attribute() -> Dictionary:
	return {"happy" : 0.925, "angry" : 0.275, "fear" : 0.35, "power" : 0.5}

func my_kind() -> GroupData.READERS:
	return GroupData.READERS.WORKER

# 工人的顶格是"动乱"，不是"外逃"——离厂就没饭吃，他们哪儿也去不了，。


# 每天被 World 调用一次
func read_newspaper(newspaper : NewsPaper) -> void:
	_live()
	resource_influence()
	_read_paper(newspaper)
	state_machine.commit_push(push)
	_clear_push()
	state_machine.change_state(attribute)


# 内向：不改世界，只改自己
func _live() -> void:
	_drift()


# 世界落在我头上：遍历所有影响源，把增量打进四维属性。
func resource_influence() -> void:
	if government == null:
		return
	var asset : GovernmentAsset = government.asset
	var effects : Array[Dictionary] = [
		StabilityInfluence.all(asset.stability),
		FoodInfluence.worker(asset.food),
		MoneyInfluence.worker(asset.money),
		SoldierPowerInfluence.worker(asset.army),
	]
	for effect in effects:
		_absorb(attribute, effect)


# 外向
