class_name GovernmentStateConservative extends GovernmentState

var normal_belligerence : float = StateChangeData.governmentConservativeNormalBelligerenceNeed
var incompetent_belligerence : float = StateChangeData.governmentConservativeIncompetentBelligerenceNeed

# 保守：想让一步，花钱买平安。
func enter(_prev : GovernmentState) -> void:
	pass

# 再软下去就是无能；硬回来就回常态。
func next_state(asset : GovernmentAsset) -> GovernmentState:
	if asset.belligerence.value < incompetent_belligerence:
		return state_machine.IncompetentState
	if asset.belligerence.value > normal_belligerence:
		return state_machine.NormalState
	return state_machine.current_state


# 我这一档能动的手：**按群体分档**，而且样样是"让"——减租、优惠、救援、和解，。
func available_actions(groups : Node) -> Array[Callable]:
	var pool : Array[Callable] = []
	
	for node in groups.get_children():
		var hand : Callable = GovernmentActions.conservative_against(node)
		if hand.is_valid():
			pool.append(hand)
	
	pool.append(GovernmentActions.conciliate)
	pool.append(GovernmentActions.relief)
	pool.append(GovernmentActions.invest)
	
	return pool
