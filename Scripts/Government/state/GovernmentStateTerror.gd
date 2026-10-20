class_name GovernmentStateTerror extends GovernmentState

var hardline_belligerence : float = StateChangeData.governmentTerrorHardlineBelligerenceNeed
var collapse_stability : float = StateChangeData.governmentCollapseStabilityNeed

# 恐怖：弹压拉到最狠（力度暂与强硬相同，等你的数）。
func enter(_prev : GovernmentState) -> void:
	pass

# 先判崩溃**：世道已经跌破底线，枪再硬也压不住——这一步踏出去就回不来了。
func next_state(asset : GovernmentAsset) -> GovernmentState:
	if asset.stability.value < collapse_stability:
		return state_machine.CollapseState
	if asset.belligerence.value < hardline_belligerence:
		return state_machine.HardlineState
	return state_machine.current_state


# 我这一档能动的手：**按群体分档**，而且每一只都是全套里最重的。
func available_actions(groups : Node) -> Array[Callable]:
	var pool : Array[Callable] = []
	
	for node in groups.get_children():
		var hand : Callable = GovernmentActions.terror_against(node)
		if hand.is_valid():
			pool.append(hand)
	
	pool.append(GovernmentActions.martial_law)
	pool.append(GovernmentActions.requisition)
	
	return pool
