class_name StabilityInfluence extends RefCounted

# ============================================================
# 稳定度 -> 所有人
#
# 这是六个影响里**唯一一个不挑对象**的。
#
# 前面几个都要区分"这条对谁意味着什么"——粮荒商人笑工人哭、
# 兵少商人慌农民也慌。但"世道乱"这件事本身，对所有人体感是一样的：
# **外面不安全。**
#
# 所以它只有一条 all()，由 Group._read_world() 统一调用，
# 每个群体每天都读一遍，不需要各自写。
# ============================================================

# 稳定度低于这条线，就算乱世了。
const TIGHT : float = 0.40


# 谁都怕。这里的"都"是字面意思——不分群体、不分阶层。
# 乱世里没有受益者，只有跑得快和跑得慢的。
static func all(stability : StabilityManager) -> Dictionary:
	var chaos : float = maxf(TIGHT - stability.value, 0.0)
	return {"fear" : chaos * 0.006}
