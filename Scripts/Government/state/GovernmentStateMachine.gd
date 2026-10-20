class_name GovernmentStateMachine extends Node

var NormalState : GovernmentStateNormal = GovernmentStateNormal.new()
var HardlineState : GovernmentStateHardline = GovernmentStateHardline.new()
var TerrorState : GovernmentStateTerror = GovernmentStateTerror.new()
var ConservativeState : GovernmentStateConservative = GovernmentStateConservative.new()
var IncompetentState : GovernmentStateIncompetent = GovernmentStateIncompetent.new()
var CollapseState : GovernmentStateCollapse = GovernmentStateCollapse.new()

var current_state : GovernmentState

# 不能用 _ready()**：这个机器由 Government 用 .new() 建出来、不进场景树，。
func _init() -> void:
	for state in [NormalState, HardlineState, TerrorState,
			ConservativeState, IncompetentState, CollapseState]:
		state.SetUp(self)
	current_state = NormalState

# 决定今天走哪一步。
func change_state(asset : GovernmentAsset) -> void:
	var next : GovernmentState = current_state.next_state(asset)
	if next == null or next == current_state:
		return
	
	var prev : GovernmentState = current_state
	prev.exit()
	current_state = next
	next.enter(prev)
	EventBus.government_state_changed.emit(prev, next)
