class_name Farmers extends Group

# 纯逻辑对象，不进场景树——它不需要树的任何东西，add_child 反而会。
var state_machine : FarmStateMachine = FarmStateMachine.new()

# 它是谁
func initial_attribute() -> Dictionary:
	return {"happy" : 0.875,
	 "angry" : 0.225,
	 "fear" : 0.225,
	 "power" : 0.5}

func my_kind() -> GroupData.READERS:
	return GroupData.READERS.FARMER

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
	# 先摇今天的骰子：四个属性各飘一点。
	_drift()

# 世界落在我头上：遍历所有影响源，把增量打进四维属性。
func resource_influence() -> void:
	if government == null:
		return
	var asset : GovernmentAsset = government.asset
	var effects : Array[Dictionary] = [
		StabilityInfluence.all(asset.stability),
		MoneyInfluence.farmer(asset.money),
		SoldierPowerInfluence.farmer(asset.army),
		IndustryPowerInfluence.farmer(asset.industry)
	]
	for effect in effects:
		_absorb(attribute, effect)
	
