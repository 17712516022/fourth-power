class_name StabilityManager extends RefCounted

# ============================================================
# 稳定度
#
# 不消耗，只随局势涨落：骚乱在削它，太平时它自己长回来。
# 平衡点大约在 threat = 0.6——比这乱，它跌；比这太平，它涨。
#
# 目前**没有任何地方读它**。它的下游（崩了会怎样、低了会触发什么）
# 还没接。这一点写在注释里，免得以后有人以为它已经在起作用。
# ============================================================

var value : float = 0.80

const DECAY   : float = 0.010   # 骚乱每天削掉多少
const RECOVER : float = 0.006   # 太平每天长回多少


func update(threat : float) -> void:
	value = clampf(value - threat * DECAY + RECOVER, 0.0, 1.0)
