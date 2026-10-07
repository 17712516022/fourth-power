class_name IndustrialPowerManager extends RefCounted

# ============================================================
# 工业力
#
# **政府自己不会生产。** 工人在厂里出多少力，它就有多少。
#
# 这里没有公式，只有一行加法——因为来源全在 IndustryPowerInfluence 里。
# 加法特意留在明面上：以后接上"工厂停工""商人投资"，
# 就是下面多出来的一行，一眼看得出工业力现在靠几样东西撑着。
#
# 它现在有一个下游：税基。工业力跌 → 收上来的税少 → 抚不动 → 只能压。
# 这是政府被自己的工业拖住的那条线。
# ============================================================

var value : float = 0.60


func update(worker_happy : float) -> void:
	value = clampf(
		value + IndustryPowerInfluence.from_worker_mood(worker_happy),
		0.0, 1.0)
