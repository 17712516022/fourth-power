extends Node


# 各本账的每日速率系数

# 粮仓
var yield_modifer : float = 1.0

# 消耗：多少张嘴在吃。
var eaten_modifer : float = 1.0

# 国库
var tax_modifer : float = 1.0

# 支出：日常开销膨胀得多快。
var spend_modifer : float = 1.0

# 工业力
var industry_modifer : float = 1.0

# 磨损：设备和人手散得有多快。
var industry_wear_modifer : float = 1.0


# 开新局：把系数拨回"不加不减"。
func reset() -> void:
	yield_modifer = 1.0
	eaten_modifer = 1.0
	tax_modifer = 1.0
	spend_modifer = 1.0
	industry_modifer = 1.0
	industry_wear_modifer = 1.0
