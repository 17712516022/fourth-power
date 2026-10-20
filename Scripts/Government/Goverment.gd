class_name Government extends Node

# 拆开之后这里只做两件事
var asset : GovernmentAsset = GovernmentAsset.new()

var policy_machine : GovernmentStateMachine = GovernmentStateMachine.new()


# 今天从世界上读到的东西
var _soldier_power : float = 0.0
var _stability_costs : Array[float] = []


# 行动的价码
func step(groups : Node) -> void:
	_perceive(groups)
	asset.update(_soldier_power, _stability_costs)
	policy_machine.change_state(asset)
	_execute(groups)

# 看
func _perceive(groups : Node) -> void:
	_stability_costs.clear()
	
	for node in groups.get_children():
		_stability_costs.append(_stability_cost_of(node))
		
		if node is Soldier:
			# 政府士兵自己的组织度。
			_soldier_power = node.attribute["power"]


# 一个群体今天扣稳定度多少分：状态系数 × 它自己的 power。
func _stability_cost_of(node : Node) -> float:
	return _coef_of(node) * _power_of(node)


# 这个群体当前状态的稳定度系数（
func _coef_of(node : Node) -> float:
	var state : Variant = _state_of(node)
	if state == null:
		return 0.0
	return state.stability_coef()


# 这个群体当下。
func _power_of(node : Node) -> float:
	if not ("attribute" in node):
		return 0.0
	var attr : Dictionary = node.get("attribute")
	return attr["power"]


# 状态机里的当前状态。
func _state_of(node : Node) -> Variant:
	if not ("state_machine" in node):
		return null
	var machine : Variant = node.get("state_machine")
	if machine == null or not ("current_state" in machine):
		return null
	return machine.get("current_state")


# 做
func _execute(groups : Node) -> void:
	var pool : Array[Callable] = policy_machine.current_state.available_actions(groups)
	if pool.is_empty():
		return
	PolicyPush.begin()
	pool.pick_random().call(groups, asset)
