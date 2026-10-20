class_name BelligerenceManager extends RefCounted

# 好战度 —— 政府的脾气
var value : float = 0.5


# 每天照一遍。
func mirror(soldier_power : float, money : float) -> void:
	# 兵与钱的差本来只有 ±0.05（两边都顶在 1.0 附近），除以 2 之后几乎不动，
	# 政府永远卡在 0.5 的中性档。这里做两件事：
	#   1) 把差放大两倍，同样的差能真正推过 0.55 / 0.45；
	#   2) 每天只朝目标走三成，政策倾向是"拐"过去的，不是每天跳。
	var target : float = clampf(0.5 + (soldier_power - money) * 2.0, 0.0, 1.0)
	value = lerpf(value, target, 0.30)
