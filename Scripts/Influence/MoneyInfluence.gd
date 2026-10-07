class_name MoneyInfluence extends RefCounted

# ============================================================
# 国库 -> 各个群体
#
# 钱袋子瘪下去，最先感觉到的是两种人：
#   士兵  ——军饷发不出来
#   穷人  ——赈济停了
#
# 而商人不在名单里。国库空对商人**不是坏事**——政府买不起东西的时候，
# 让价的反而是卖方。这一栏空着，是有意的。
#
# 这里只做"国库 -> 心情"。不做"心情 -> 行为"。
# ============================================================

# 国库低于这条线，就算见底了。
const TIGHT : float = 0.30


static func lack(money : MoneyManager) -> float:
	return maxf(TIGHT - money.value, 0.0)


# --- 士兵 ---
#
# **欠饷。** 政府没钱的时候，兵是最先知道的——因为他们的饷银按月发，
# 而别的东西还能拖。所以这里给的是怒，不是怕：
# 拿不到钱的人不会怕，会火。
static func soldier(money : MoneyManager) -> Dictionary:
	return {"angry" : lack(money) * 0.008}


# --- 农民 / 工人 ---
#
# 赈济停了。国库空的时候，义仓、施粥、平粜这些最先被砍掉——
# 而这些东西平时没什么用，一到荒年就是穷人的命。
static func poor(money : MoneyManager) -> Dictionary:
	return {"happy" : -lack(money) * 0.006}
