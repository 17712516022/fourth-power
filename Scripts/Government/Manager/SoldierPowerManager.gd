class_name SoldierPowerManager extends RefCounted

# ============================================================
# 在册能调的兵
#
# **这不是存量，是镜像。**
#
# 政府不拥有军队——它每天照抄一遍士兵自己的组织度。
# 士兵散了，政府就空了。所谓"发饷"，本质就是往士兵身上灌数，
# 第二天这里自然就跟着高。
#
# 所以这个类里**故意没有"增减"方法**：mirror() 是覆盖，不是加减。
#
# 坑在这里：如果哪天有人写一个 wear_army() 去减 value，
# 当天就被下一天的 mirror() 抹平——看起来能用，实际无效。
# 镇压真正磨兵的地方在 Government._execute()：
# 它直接削士兵本人的 attribute["power"]，那才是真的削减。
# ============================================================

var value : float = 0.60


# 照抄。不是积累。
func mirror(soldier_power : float) -> void:
	value = soldier_power
