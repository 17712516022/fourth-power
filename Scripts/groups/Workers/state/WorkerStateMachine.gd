class_name WorkerStateMachine extends Node

var NormalState : WorkerStateNormal = WorkerStateNormal.new()
var SlowdownState : WorkerStateSlowdown = WorkerStateSlowdown.new()
var DepressionState : WorkerStateDepression = WorkerStateDepression.new()
var StrikeState : WorkerStateStrike = WorkerStateStrike.new()
var MarchState : WorkerStateMarch = WorkerStateMarch.new()
var UpRisingState : WorkerStateUpRising = WorkerStateUpRising.new()

var current_state : WorkerState

# 不能用 _ready()**：这个机器由 Workers 用 .new() 建出来、不进场景树，。
func _init() -> void:
	for state in [NormalState, SlowdownState, DepressionState, StrikeState, MarchState, UpRisingState]:
		state.SetUp(self)
	current_state = NormalState

# 把今天的报纸并进各状态的阈值。
func commit_push(push : Dictionary) -> void:
	for state in [NormalState, SlowdownState, DepressionState, StrikeState, MarchState, UpRisingState]:
		state.commit_push(push)

# 决定今天去哪个状态。
func change_state(attribute : Dictionary) -> void:
	var next : WorkerState = current_state.next_state(attribute)
	if next == null or next == current_state:
		return
	
	var prev : WorkerState = current_state
	prev.exit()
	current_state = next
	next.enter(prev)
	EventBus.group_state_changed.emit(GroupData.READERS.WORKER, prev, next)
