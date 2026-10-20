class_name GovernmentState extends Node

var state_machine : GovernmentStateMachine

func SetUp(p_state_machine) -> void:
	state_machine = p_state_machine

# 进入这个状态时喊一声。
func enter(_prev : GovernmentState) -> void:
	pass

# 我在这儿，能去哪儿。
func next_state(_asset : GovernmentAsset) -> GovernmentState:
	return state_machine.current_state

# 离开这个状态时喊一声。
func exit() -> void:
	pass


# 我这一档能动的手
func available_actions(_groups : Node) -> Array[Callable]:
	return []
