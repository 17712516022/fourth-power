class_name GovernmentAsset extends RefCounted

# ============================================================
# 政府的家底 —— 集合
#
# 六项各由自己的 manager 管：怎么变写在各自那个文件里，
# **这里一个公式都没有**。这个类只负责把它们摆在一起，
# 以及决定"每天按什么顺序更新"。
#
# 为什么要有这一层：外部（状态机、群体、报纸）需要一次拿到全部家底，
# 而不是自己去 new 六个对象。所以它是个**把手**，不是个逻辑。
#
# 六项分三种性质，别混：
#
#   存量：会被花掉、会耗尽，全靠别人往里送
#         food / money / industry
#
#   镜像：政府不拥有它，只是每天照抄一遍别人的状态
#         army
#
#   状态：不消耗，只随局势涨落
#         stability / belligerence
# ============================================================

# --- 存量 ---
var food : FoodManager = FoodManager.new()
var money : MoneyManager = MoneyManager.new()
var industry : IndustrialPowerManager = IndustrialPowerManager.new()

# --- 镜像 ---
var army : SoldierPowerManager = SoldierPowerManager.new()

# --- 状态 ---
var stability : StabilityManager = StabilityManager.new()
var belligerence : BelligerenceManager = BelligerenceManager.new()


# 每天更新一次。
#
# **四个参数就是"政府今天从世界上读到的全部"。**
# 想知道政府靠什么活着，看这一行就够了：
#
#    threat        外面多乱 → 决定稳定度和脾气
#    farming       农民闹到第几级 → 决定粮食
#    worker_happy  工人心气 → 决定工业力
#    soldier_power 士兵的组织度 → 直接镜像过来
#
# 顺序有讲究，只有一处：**工业力必须排在收税之前**——
# 今天的税是按今天的产出收的。其余几项互不相干，先后随意。
func update(threat : float, farming : int, worker_happy : float, soldier_power : float) -> void:
	army.mirror(soldier_power)
	industry.update(worker_happy)
	food.update(farming)
	money.update(industry.value)      # 税基 = 工业力（农业税、商税还没接）
	stability.update(threat)
	belligerence.update(threat)
