class_name SoldierStateMachine extends Node

var NormalState : SoldierStateNormal = SoldierStateNormal.new()
var DesertState : SoldierStateDesert = SoldierStateDesert.new()
var RampageState : SoldierStateRampage = SoldierStateRampage.new()
var CorruptState : SoldierStateCorrupt = SoldierStateCorrupt.new()
var MutinyState : SoldierStateMutiny = SoldierStateMutiny.new()

var current_state : SoldierState

# 不能用 _ready()**：这个机器由 Soldier 用 .new() 建出来、不进场景树，。
func _init() -> void:
	for state in [NormalState, DesertState, RampageState, CorruptState, MutinyState]:
		state.SetUp(self)
	current_state = NormalState

# 把今天的报纸并进各状态的阈值。
func commit_push(push : Dictionary) -> void:
	for state in [NormalState, DesertState, RampageState, CorruptState, MutinyState]:
		state.commit_push(push)

# 决定今天去哪个状态。
func change_state(attribute : Dictionary) -> void:
	var next : SoldierState = current_state.next_state(attribute)
	if next == null or next == current_state:
		return
	
	var prev : SoldierState = current_state
	prev.exit()
	current_state = next
	next.enter(prev)
	EventBus.group_state_changed.emit(GroupData.READERS.SOLDIER, prev, next)
