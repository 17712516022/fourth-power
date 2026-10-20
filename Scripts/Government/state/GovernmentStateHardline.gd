class_name GovernmentStateHardline extends GovernmentState

var normal_belligerence : float = StateChangeData.governmentHardlineNormalBelligerenceNeed
var terror_belligerence : float = StateChangeData.governmentHardlineTerrorBelligerenceNeed

# 强硬：开始动手弹压。
func enter(_prev : GovernmentState) -> void:
	pass

# 再硬下去就是恐怖；软回来就回常态。
func next_state(asset : GovernmentAsset) -> GovernmentState:
	if asset.belligerence.value > terror_belligerence:
		return state_machine.TerrorState
	if asset.belligerence.value < normal_belligerence:
		return state_machine.NormalState
	return state_machine.current_state


# 我这一档能动的手：**按群体分档**（形状和常态一样），但对策完全不同——。
func available_actions(groups : Node) -> Array[Callable]:
	var pool : Array[Callable] = []
	
	for node in groups.get_children():
		var hand : Callable = GovernmentActions.hardline_against(node)
		if hand.is_valid():
			pool.append(hand)
	
	pool.append(GovernmentActions.suppress)
	pool.append(GovernmentActions.martial_law)
	pool.append(GovernmentActions.tax)
	pool.append(GovernmentActions.recruit)
	pool.append(GovernmentActions.requisition)
	
	return pool
