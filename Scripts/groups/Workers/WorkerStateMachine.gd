class_name WorkerStateMachine extends Node

enum WorkerState {
	Normal,
	Slowdown,
	Strike,
}

const SLOWDOWN_IN  : float = 0.45
const SLOWDOWN_OUT : float = 0.35
const STRIKE_IN    : float = 0.55
const STRIKE_OUT   : float = 0.30
const FEAR_OUT     : float = 0.60   # 怕超过这个 -> 认了，回厂上班
const POWER_MIN    : float = 0.20   # 底气不到这个数，想动也动不起来

var current_state : WorkerState = WorkerState.Normal

# 属性是读进来的，状态机不持有它；push 是报纸把门槛推到哪。
# **两者不混**：报纸改不了他们有多怒，只能改他们要多怒才敢动手。
func change_state(attribute : Dictionary, push : Dictionary) -> void:
	var next : WorkerState = _next_state(attribute, push)
	if next == current_state:
		return

	var prev : WorkerState = current_state
	current_state = next
	_report(prev, next)

# 当前状态决定能去哪。互斥由 match 保证，不靠函数调用顺序。
# push 正 = 退（抬怒线、压怕线），负 = 进。
func _next_state(attribute : Dictionary, push : Dictionary) -> WorkerState:
	var angry : float = attribute["angry"]
	var fear  : float = attribute["fear"]
	var power : float = attribute["power"]
	
	match current_state:
		WorkerState.Normal:
			if angry > SLOWDOWN_IN + push["angry"] and power > POWER_MIN:
				return WorkerState.Slowdown
	
		WorkerState.Slowdown:
			if angry > STRIKE_IN + push["angry"]:
				return WorkerState.Strike
			if angry < SLOWDOWN_OUT - push["angry"] * 0.5 or power <= 0.0:
				return WorkerState.Normal
	
		WorkerState.Strike:
			# 怕的门槛：push 正（退）压低了它，于是更容易"认了"
			if fear > FEAR_OUT - push["fear"]:
				return WorkerState.Normal      # 怕了
			if angry < STRIKE_OUT - push["angry"] * 0.5:
				return WorkerState.Normal      # 气出了
			if power <= 0.0:
				return WorkerState.Normal      # 没钱了
	
	return current_state

# 状态变了，把这条**转移**报出去。
#
# 报的是"从哪来到哪去"，不是"进入了什么状态"或"离开了什么状态"。
# 一条边 = 一个 (prev, next) 组合，单看一头会丢信息：
#   Slowdown -> Strike 时工人并没有"结束怠工"，他是升级了。
#   只看"离开了 Slowdown"就会白发一条 WorkerSlowdownEnd，而报纸无法分辨。
func _report(prev_state : WorkerState, next_state : WorkerState) -> void:
	match prev_state:
		WorkerState.Normal:
			if next_state == WorkerState.Slowdown:
				RawMaterialGenerater.get_material(NewsData.NewsType.WorkerSlowdownStart)

		WorkerState.Slowdown:
			if next_state == WorkerState.Normal:
				RawMaterialGenerater.get_material(NewsData.NewsType.WorkerSlowdownEnd)
			elif next_state == WorkerState.Strike:
				RawMaterialGenerater.get_material(NewsData.NewsType.WorkerStrikeStart)

		WorkerState.Strike:
			if next_state == WorkerState.Normal:
				RawMaterialGenerater.get_material(NewsData.NewsType.WorkerStrikeEnd)
