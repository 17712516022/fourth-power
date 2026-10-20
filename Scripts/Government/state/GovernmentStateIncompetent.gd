class_name GovernmentStateIncompetent extends GovernmentState

var conservative_belligerence : float = StateChangeData.governmentIncompetentConservativeBelligerenceNeed
var collapse_stability : float = StateChangeData.governmentCollapseStabilityNeed

# 无能：想管也管不动——不动作。
func enter(_prev : GovernmentState) -> void:
	pass

# 先判崩溃：心气没了、世道又跌破底线，这届政府就到此为止。
func next_state(asset : GovernmentAsset) -> GovernmentState:
	if asset.stability.value < collapse_stability:
		return state_machine.CollapseState
	if asset.belligerence.value > conservative_belligerence:
		return state_machine.ConservativeState
	return state_machine.current_state


# 我这一档能动的手：**按群体分档**，但每一只都透着"懒得管 / 管不了"——。
func available_actions(groups : Node) -> Array[Callable]:
	var pool : Array[Callable] = []
	
	for node in groups.get_children():
		var hand : Callable = GovernmentActions.incompetent_against(node)
		if hand.is_valid():
			pool.append(hand)
	
	return pool
