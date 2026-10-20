class_name Merchants extends Group

# 纯逻辑对象，不进场景树——它不需要树的任何东西。
var state_machine : MerchantStateMachine = MerchantStateMachine.new()


# 它是谁

# 商人的正常带：乐 <= 0.65（否则繁荣）· 怒 <= 0.65（否则外逃）·。
func initial_attribute() -> Dictionary:
	return {"happy" : 0.325, "angry" : 0.325, "fear" : 0.825, "power" : 0.5}

func my_kind() -> GroupData.READERS:
	return GroupData.READERS.MERCHANT


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
		FoodInfluence.merchant(asset.food),
		MoneyInfluence.merchant(asset.money),
		IndustryPowerInfluence.merchant(asset.industry),
		SoldierPowerInfluence.merchant(asset.army),
	]
	for effect in effects:
		_absorb(attribute, effect)


# 外向
