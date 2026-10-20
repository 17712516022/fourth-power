class_name Soldier extends Group

# 纯逻辑对象，不进场景树——它不需要树的任何东西。
var state_machine : SoldierStateMachine = SoldierStateMachine.new()


# 它是谁

# 士兵的正常带（**方向与前三家相反：低了才出事**）
func initial_attribute() -> Dictionary:
	return {"happy" : 0.825, "angry" : 0.775, "fear" : 0.775, "power" : 0.5}

func my_kind() -> GroupData.READERS:
	return GroupData.READERS.SOLDIER


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
		FoodInfluence.soldier(asset.food),
		MoneyInfluence.soldier(asset.money),
		IndustryPowerInfluence.soldier(asset.industry),
	]
	for effect in effects:
		_absorb(attribute, effect)


# 外向
