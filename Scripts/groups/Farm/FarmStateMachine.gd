class_name FarmStateMachine extends Node

enum FarmerState {
	Normal,
	Resist,
	Flee,
}

const RESIST_IN  : float = 0.45   # 怒超过这个 -> 想动
const RESIST_OUT : float = 0.35   # 怒跌破这个 -> 收手（迟滞，别和上面用同一个数）
const POWER_MIN  : float = 0.10   # 底气不到这个数，想动也动不起来
const FLEE_IN    : float = 0.40   # 怕超过这个 -> 跑
const FLEE_OUT   : float = 0.25   # 怕跌回这个以下 -> 陆续回来（迟滞：回来比走难得多）

var current_state : FarmerState = FarmerState.Normal

# 读进来的是**真相**，外加报纸今天把门槛推到哪。
func change_state(attribute : Dictionary, push : Dictionary) -> void:
	var next : FarmerState = _next_state(attribute, push)
	if next == current_state:
		return
	
	var prev : FarmerState = current_state
	current_state = next
	_report(prev, next)

# 当前状态决定能去哪。互斥由 match 保证，不靠函数调用顺序。
func _next_state(attribute : Dictionary, push :Dictionary) -> FarmerState:
	match current_state:
		FarmerState.Normal:
			if attribute["fear"] > FLEE_IN - push["fear"]:
				return FarmerState.Flee
			if attribute["angry"] > RESIST_IN + push["angry"] and attribute["power"] > POWER_MIN:
				return FarmerState.Resist
	
		FarmerState.Resist:
			# 退的时候更容易跑（怕线被压低）
			if attribute["fear"] > FLEE_IN - push["fear"]:
				return FarmerState.Flee
			# 进的时候更撑得住（怒线被压低，不容易退出）
			if attribute["angry"] < RESIST_OUT - push["angry"] * 0.5:
				return FarmerState.Normal
	
		FarmerState.Flee:
			# **这里不是终局。** 人走了，风声过了还会有人回来。
			if attribute["fear"] < FLEE_OUT - push["fear"]:
				return FarmerState.Normal

	return current_state

# 状态变了，把这条**转移**报出去。
func _report(prev_state : FarmerState, next_state : FarmerState) -> void:
	# 终局只有一条：两条边通向这里，分开写会抄两遍。
	if next_state == FarmerState.Flee:
		RawMaterialGenerater.get_material(NewsData.NewsType.FarmerFlee)
		return
	
	# 反过来这一条同样只有一条：Flee 唯一的出边就是回乡。
	# 它和"抗租结束"完全不是一回事——那边是人还在，这边是人回来了。
	if prev_state == FarmerState.Flee:
		RawMaterialGenerater.get_material(NewsData.NewsType.FarmerReturn)
		return
	
	match prev_state:
		FarmerState.Normal:
			if next_state == FarmerState.Resist:
				RawMaterialGenerater.get_material(NewsData.NewsType.FarmerResistStart)
	
		FarmerState.Resist:
			if next_state == FarmerState.Normal:
				RawMaterialGenerater.get_material(NewsData.NewsType.FarmerResistEnd)
