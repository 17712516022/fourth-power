class_name GovernmentStateNormal extends GovernmentState

# 两条线都住在 StateChangeData（政府没有 push，所以是常量）。
var hardline_belligerence : float = StateChangeData.governmentNormalHardlineBelligerenceNeed
var conservative_belligerence : float = StateChangeData.governmentNormalConservativeBelligerenceNeed

# 常态：照章办事，不额外动手。
func enter(_prev : GovernmentState) -> void:
	pass

# 好战涨过上面那条线就强硬，跌破下面那条线就保守；两条之间就待着。
func next_state(asset : GovernmentAsset) -> GovernmentState:
	if asset.belligerence.value > hardline_belligerence:
		return state_machine.HardlineState
	if asset.belligerence.value < conservative_belligerence:
		return state_machine.ConservativeState
	return state_machine.current_state


# 我这一档能动的手：**按群体分档**。
func available_actions(groups : Node) -> Array[Callable]:
	var pool : Array[Callable] = []
	
	# 四家各一只：哪家现在有对策就添哪只（还没填的档会被跳过）。
	for node in groups.get_children():
		var hand : Callable = GovernmentActions.normal_against(node)
		if hand.is_valid():
			pool.append(hand)
	
	# 不分对象的底子。
	pool.append(GovernmentActions.tax)
	pool.append(GovernmentActions.invest)
	pool.append(GovernmentActions.relief)
	pool.append(GovernmentActions.recruit)
	pool.append(GovernmentActions.requisition)
	
	return pool
