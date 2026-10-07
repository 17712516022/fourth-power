class_name SoldierStateMachine extends Node

enum SoldierState {
	Normal,
	Slack,
	Mutiny,
	Desert,
}

const SLACK_IN   : float = 0.45   # 怒超过这个 -> 消极执勤
const SLACK_OUT  : float = 0.35   # 怒跌破这个 -> 恢复正常
const MUTINY_IN  : float = 0.52   # 怒再高一点 -> 哗变
const MUTINY_OUT : float = 0.40   # 怒跌破这个 -> 收枪，退回消极
const DESERT_IN  : float = 0.55   # 怕超过这个 -> 溃散（逃兵是死罪，门槛最高）
const DESERT_OUT : float = 0.30   # 怕跌回这个以下 -> 重新收拢
const POWER_MIN  : float = 0.30   # 编制不到这个数，连哗变都组织不起来

var current_state : SoldierState = SoldierState.Normal

# 属性是读进来的，状态机不持有它；push 是报纸把门槛推到哪。
# **两者不混**：报纸改不了他们有多怒，只能改他们要多怒才敢动手。
func change_state(attribute : Dictionary, push : Dictionary) -> void:
	var next : SoldierState = _next_state(attribute, push)
	if next == current_state:
		return
	
	var prev : SoldierState = current_state
	current_state = next
	_report(prev, next)

# 当前状态决定能去哪。互斥由 match 保证，不靠函数调用顺序。
# push 正 = 退（抬怒线、压怕线），负 = 进。
func _next_state(attribute : Dictionary, push : Dictionary) -> SoldierState:
	var angry : float = attribute["angry"]
	var fear  : float = attribute["fear"]
	var power : float = attribute["power"]
	
	match current_state:
		SoldierState.Normal:
			if fear > DESERT_IN - push["fear"]:
				return SoldierState.Desert
			if angry > SLACK_IN + push["angry"] and power > POWER_MIN:
				return SoldierState.Slack
	
		SoldierState.Slack:
			if fear > DESERT_IN - push["fear"]:
				return SoldierState.Desert
			if angry > MUTINY_IN + push["angry"]:
				return SoldierState.Mutiny
			if angry < SLACK_OUT - push["angry"] * 0.5 or power < POWER_MIN:
				return SoldierState.Normal
	
		SoldierState.Mutiny:
			if fear > DESERT_IN - push["fear"]:
				return SoldierState.Desert
			if angry < MUTINY_OUT - push["angry"] * 0.5:
				return SoldierState.Slack
			if power < POWER_MIN:
				return SoldierState.Normal
	
		SoldierState.Desert:
			# **这里不是终局。** 溃散的兵会被重新收拢——但编制早就烧光了，
			# 所以回来时 power 很低，要从头攒，而且 POWER_MIN = 0.30 拦在前面，
			# 短期内组织不起第二次哗变。**回来不等于复原。**
			if fear < DESERT_OUT - push["fear"]:
				return SoldierState.Normal
	
	return current_state

# 状态变了，把这条**转移**报出去。
#
# 报的是"从哪来到哪去"，不是"进入了什么状态"或"离开了什么状态"。
# 这条在这里最关键：士兵有两条边都通向 Normal——
#   Slack  -> Normal 是"恢复执勤"
#   Mutiny -> Normal 是"编制散了，再也组织不起来"
# 只看"进入了 Normal"的话，这两件事会报成同一条。
func _report(prev_state : SoldierState, next_state : SoldierState) -> void:
	# 终局只有一条：三条边通向这里，分开写会抄三遍。
	if next_state == SoldierState.Desert:
		RawMaterialGenerater.get_material(NewsData.NewsType.SoldierDesert)
		return

	# 反过来：Desert 唯一的出边就是被重新收拢。
	if prev_state == SoldierState.Desert:
		RawMaterialGenerater.get_material(NewsData.NewsType.SoldierRally)
		return

	match prev_state:
		SoldierState.Normal:
			if next_state == SoldierState.Slack:
				RawMaterialGenerater.get_material(NewsData.NewsType.SoldierSlackStart)

		SoldierState.Slack:
			if next_state == SoldierState.Normal:
				RawMaterialGenerater.get_material(NewsData.NewsType.SoldierSlackEnd)
			elif next_state == SoldierState.Mutiny:
				RawMaterialGenerater.get_material(NewsData.NewsType.SoldierMutinyStart)

		SoldierState.Mutiny:
			if next_state == SoldierState.Slack:
				RawMaterialGenerater.get_material(NewsData.NewsType.SoldierMutinyEnd)
			elif next_state == SoldierState.Normal:
				RawMaterialGenerater.get_material(NewsData.NewsType.SoldierDisband)
