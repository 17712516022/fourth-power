class_name FoodInfluence extends RefCounted

# 粮仓 -> 各个群体

# 粮荒时每天的增量：商人多高兴、工人多难过。
const MERCHANT_HAPPY : float = 0.015
const MERCHANT_POWER : float = 0.02
const WORKER_HAPPY   : float = -0.015
const WORKER_ANGRY   : float = 0.015

# 好账（满仓那一支）减半、压到底线**：仓里满着这件事，比不上一个荒年重。
const HIGH_MOOD  : float = 0.01
const HIGH_POWER : float = 0.020


# 商人
static func merchant(food : FoodManager) -> Dictionary:
	match food.state:
		FoodManager.FoodState.Low:
			return {"happy" : MERCHANT_HAPPY, "power" : MERCHANT_POWER}
		FoodManager.FoodState.High:
			# 谷贱也伤囤货的：仓里的货不值钱了。
			return {"happy" : -HIGH_MOOD, "power" : -HIGH_POWER}
		_:
			return {}

# 工人
static func worker(food : FoodManager) -> Dictionary:
	match food.state:
		FoodManager.FoodState.Low:
			return {"happy" : WORKER_HAPPY, "angry" : WORKER_ANGRY}
		FoodManager.FoodState.High:
			return {"happy" : HIGH_MOOD, "angry" : -HIGH_MOOD}
		_:
			return {}

# 士兵
const SOLDIER_HAPPY : float = -0.015
const SOLDIER_FEAR  : float = -0.015
const SOLDIER_ANGRY : float = 0.015

# 满仓对兵只是"管得住"（怕涨、火降），不额外添高兴——否则士兵的 happy 会被顶死在 1.0。
const SOLDIER_HIGH_HAPPY : float = 0.0

static func soldier(food : FoodManager) -> Dictionary:
	match food.state:
		FoodManager.FoodState.Low:
			return {"happy" : SOLDIER_HAPPY, "fear" : SOLDIER_FEAR, "angry" : SOLDIER_ANGRY}
		FoodManager.FoodState.High:
			# 仓里满的时候反过来：吃得饱、管得住、也懒得动火（同样减半）。
			return {"happy" : SOLDIER_HIGH_HAPPY, "fear" : HIGH_MOOD, "angry" : -HIGH_MOOD}
		_:
			return {}
