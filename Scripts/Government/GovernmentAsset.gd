class_name GovernmentAsset extends RefCounted

# 政府的家底 —— 集合

# 存量
var food : FoodManager = FoodManager.new()
var money : MoneyManager = MoneyManager.new()
var industry : IndustrialPowerManager = IndustrialPowerManager.new()
var stability : StabilityManager = StabilityManager.new()
var belligerence : BelligerenceManager = BelligerenceManager.new()


# 镜像
var army : SoldierPowerManager = SoldierPowerManager.new()


# 每天更新一次。
func update(soldier_power : float, stability_costs : Array[float]) -> void:
	army.mirror(soldier_power)
	stability.mirror(stability_costs)
	
	food.update()
	industry.update()
	money.update()
	# 脾气排在最后：它照的是**上一天过完时**的兵和钱——本函数现在跑在一天的开头，。
	belligerence.mirror(army.value, money.value)
