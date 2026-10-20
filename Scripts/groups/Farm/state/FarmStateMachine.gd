class_name FarmStateMachine extends Node

var ResistState : FarmerStateResist = FarmerStateResist.new()
var NormalState : FarmerStateNormal = FarmerStateNormal.new()
var FleeState : FarmerStateFlee = FarmerStateFlee.new()
var UpRisingState : FarmerStateUpRising = FarmerStateUpRising.new()
var SlowDownState : FarmerStateSlowdown = FarmerStateSlowdown.new()

var current_state : FarmerState

# 不能用 _ready()**：这个机器由 Farmers 用 .new() 建出来、不进场景树，。
func _init() -> void:
	for state in [NormalState, SlowDownState, ResistState, FleeState, UpRisingState]:
		state.SetUp(self)
	current_state = NormalState

# 把今天的报纸并进各状态的阈值。
func commit_push(push : Dictionary) -> void:
	for state in [NormalState, SlowDownState, ResistState, FleeState, UpRisingState]:
		state.commit_push(push)

# 决定今天去哪个状态。
func change_state(attribute : Dictionary) -> void:
	var next : FarmerState = current_state.next_state(attribute)
	if next == null or next == current_state:
		return
	
	var prev : FarmerState = current_state
	prev.exit()
	current_state = next
	next.enter(prev)
	EventBus.group_state_changed.emit(GroupData.READERS.FARMER, prev, next)
