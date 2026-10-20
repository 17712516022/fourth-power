class_name MerchantStateMachine extends Node

var NormalState : MerchantStateNormal = MerchantStateNormal.new()
var ProsperityState : MerchantStateProsperity = MerchantStateProsperity.new()
var InvestState : MerchantStateInvest = MerchantStateInvest.new()
var SpeculateState : MerchantStateSpeculate = MerchantStateSpeculate.new()
var HollowState : MerchantStateHollow = MerchantStateHollow.new()
var AbroadState : MerchantStateAbroad = MerchantStateAbroad.new()

var current_state : MerchantState

# 不能用 _ready()**：这个机器由 Merchants 用 .new() 建出来、不进场景树，。
func _init() -> void:
	for state in [NormalState, ProsperityState, InvestState, SpeculateState, HollowState, AbroadState]:
		state.SetUp(self)
	current_state = NormalState

# 把今天的报纸并进各状态的阈值。
func commit_push(push : Dictionary) -> void:
	for state in [NormalState, ProsperityState, InvestState, SpeculateState, HollowState, AbroadState]:
		state.commit_push(push)

# 决定今天去哪个状态。
func change_state(attribute : Dictionary) -> void:
	var next : MerchantState = current_state.next_state(attribute)
	if next == null or next == current_state:
		return
	
	var prev : MerchantState = current_state
	prev.exit()
	current_state = next
	next.enter(prev)
	EventBus.group_state_changed.emit(GroupData.READERS.MERCHANT, prev, next)
