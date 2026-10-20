class_name SoldierPowerInfluence extends RefCounted

# 在册兵力 -> 各个群体

# 治安崩掉时每天的增量。
const MERCHANT_FEAR : float = 0.012
const FARMER_FEAR   : float = 0.012

# 底气那一笔**不对称**：没人管的日子攒得起本钱（+0.03），。
const FARMER_POWER_GAIN : float = 0.03
const FARMER_POWER_LOSS : float = 0.002
const WORKER_POWER_GAIN : float = 0.03
const WORKER_POWER_LOSS : float = 0.002


# 商人
static func merchant(army : SoldierPowerManager) -> Dictionary:
	match army.state:
		SoldierPowerManager.SoldierPowerState.Low:
			return {"fear" : MERCHANT_FEAR}
		_:
			return {}


# 农民
static func farmer(army : SoldierPowerManager) -> Dictionary:
	match army.state:
		SoldierPowerManager.SoldierPowerState.Low:
			return {"fear" : FARMER_FEAR, "power" : FARMER_POWER_GAIN}
		SoldierPowerManager.SoldierPowerState.High:
			return {"power" : -FARMER_POWER_LOSS}
		_:
			return {}

# 工人
static func worker(army : SoldierPowerManager) -> Dictionary:
	match army.state:
		SoldierPowerManager.SoldierPowerState.Low:
			return {"power" : WORKER_POWER_GAIN}
		SoldierPowerManager.SoldierPowerState.High:
			# 兵强马壮，街上有人管——工人那点胆又被压回去了。
			return {"power" : -WORKER_POWER_LOSS}
		_:
			return {}
