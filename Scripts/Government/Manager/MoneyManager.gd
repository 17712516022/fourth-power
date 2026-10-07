class_name MoneyManager extends RefCounted

# ============================================================
# 国库
#
# 钱只有一个来源：**收税**。而税收自税基——各家还在不在干活。
#
# 以前它是"每天 +0.008"，凭空长的；现在挂在税基上，
# 于是政府第一次被自己的工业拖住：
#   工业力跌 → 收上来的税少 → 抚不动 → 只能压 → 又逼走人
# ============================================================

var value : float = 0.60


# 税基满格时，每天收上来多少。
const TAX_RATE : float = 0.010


# 收税。
#
# 加法写在明面上：以后接农业税、商税，就是下面多一行。
# **外部要把税基算好再传进来**——因为税基的构成会越来越多，
# 而"今天有什么可税"是政府看世界的结果，不属于国库自己。
func update(industrial_power : float) -> void:
	var tax_base : float = 0.0
	
	tax_base += industrial_power        # 工商税：厂在转，才有税可征
	# tax_base += ...                   # 农业税：还没接。要接得先问农民状态
	# tax_base += ...                   # 商业税：还没接。要接得先问商人状态
	
	value = clampf(value + tax_base * TAX_RATE, 0.0, 1.0)


# 花掉一笔钱。安抚走这里。
func spend(amount : float) -> void:
	value = clampf(value - amount, 0.0, 1.0)
