class_name GovernmentStateCollapse extends GovernmentState

# 崩溃：**终点状态**。
func enter(_prev : GovernmentState) -> void:
	pass

func next_state(_asset : GovernmentAsset) -> GovernmentState:
	return state_machine.current_state


# 我这一档能动的手：没有。
func available_actions(_groups : Node) -> Array[Callable]:
	return []
