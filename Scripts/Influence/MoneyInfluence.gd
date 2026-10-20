class_name MoneyInfluence extends RefCounted

# 国库 -> 各个群体

# 国库见底时每天的增量：兵有多怒（欠饷）、穷人有多难过（赈济停、工钱欠）。
const SOLDIER_ANGRY : float = 0.01
const SOLDIER_HAPPY : float = -0.01

# 国库充盈时兵的那一笔：饷不跟着涨，愁反倒慢慢攒起来（满仓的兵不会更高兴）。
const SOLDIER_ANGRY_HIGH : float = -0.005
const SOLDIER_HAPPY_HIGH : float = -0.005
const POOR_HAPPY    : float = -0.012
const POOR_ANGRY    : float = 0.01
const POOR_FEAR     : float = 0.012
const HIGH_MOOD     : float = 0.01

# 士兵
static func soldier(money : MoneyManager) -> Dictionary:
	match money.state:
		MoneyManager.MoneyState.Low:
			return {"angry" : SOLDIER_ANGRY, "happy" : SOLDIER_HAPPY}
		MoneyManager.MoneyState.High:
			return {"angry" : SOLDIER_ANGRY_HIGH, "happy" : SOLDIER_HAPPY_HIGH}
		_:
			return {}

# 农民
static func farmer(money : MoneyManager) -> Dictionary:
	match money.state:
		MoneyManager.MoneyState.Low:
			return {"happy" : POOR_HAPPY, "angry" : POOR_ANGRY}
		MoneyManager.MoneyState.High:
			return {"happy" : -HIGH_MOOD, "angry" : HIGH_MOOD}
		_:
			return {}

# 工人
static func worker(money : MoneyManager) -> Dictionary:
	match money.state:
		MoneyManager.MoneyState.Low:
			return {"happy" : POOR_HAPPY, "angry" : POOR_ANGRY, "fear" : POOR_FEAR}
		MoneyManager.MoneyState.High:
			return {"happy" : -HIGH_MOOD, "angry" : HIGH_MOOD, "fear" : HIGH_MOOD}
		_:
			return {}

# 商人
const MERCHANT_ANGRY : float = 0.005

static func merchant(money : MoneyManager) -> Dictionary:
	match money.state:
		MoneyManager.MoneyState.High:
			return {"angry" : MERCHANT_ANGRY}
		_:
			return {}
