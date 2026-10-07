class_name SoldierPowerInfluence extends RefCounted

# ============================================================
# 在册兵力 -> 各个群体
#
# **兵少了，街上就没人管。**
#
# 这条线是政府镇压能力的另一面：它不只是"政府压不动了"，
# 还是"没人压了"。同一件事，从政府的账本上看是"打光了"，
# 从百姓的日子里看是"土匪来了"。
#
# 受影响的是有东西可丢的人：商人的货、农民的地。
# 工人两手空空，这一栏没他的份；士兵自己更是另一回事
# （那是镜像的来源，不是受体）。
# ============================================================

# 在册兵力低于这条线，治安就算崩了。
const TIGHT : float = 0.30


static func weakness(army : SoldierPowerManager) -> float:
	return maxf(TIGHT - army.value, 0.0)


# --- 商人 ---
#
# 货和人都要靠路上太平。兵一散，最先收摊的就是商户。
# 给的是怕——**商人不是不怕死，是怕货丢了**。
static func merchant(army : SoldierPowerManager) -> Dictionary:
	return {"fear" : weakness(army) * 0.006}


# --- 农民 ---
#
# 乡间没有兵，溃兵和土匪就是同一批人。
# 农民给的是怕，但比商人轻——他们没多少可抢的，跑得也快。
static func farmer(army : SoldierPowerManager) -> Dictionary:
	return {"fear" : weakness(army) * 0.004}
