class_name IndustryPowerInfluence extends RefCounted

# 工业力 -> 各个群体

# 工业力跌进 Low 时，士兵每天掉多少 power。
const SOLDIER_POWER_LOSS : float = 0.02
const FARMER_ANGRY_DELTA : float = 0.012

static func farmer(industry : IndustrialPowerManager) -> Dictionary:
	match industry.get_state():
		IndustrialPowerManager.IndustrialPowerState.Low:
			return {"angry" : FARMER_ANGRY_DELTA}
		IndustrialPowerManager.IndustrialPowerState.High:
			# 厂子兴旺，**乡里没有份**——机器是别人的，地还是那块地。
			return {}
		_:
			return {}
			# 士兵
static func soldier(industry : IndustrialPowerManager) -> Dictionary:
	match industry.get_state():
		IndustrialPowerManager.IndustrialPowerState.Low:
			return {"power" : -SOLDIER_POWER_LOSS}
		IndustrialPowerManager.IndustrialPowerState.High:
			# 兵工厂供得上装备，底气就足一点。
			return {"power" : SOLDIER_POWER_LOSS}
		_:
			return {}

# 商人
const MERCHANT_HAPPY_DELTA : float = 0.030
const MERCHANT_FEAR_DELTA  : float = 0.012

static func merchant(industry : IndustrialPowerManager) -> Dictionary:
	match industry.get_state():
		IndustrialPowerManager.IndustrialPowerState.Low:
			return {"happy" : -MERCHANT_HAPPY_DELTA, "fear" : MERCHANT_FEAR_DELTA}
		IndustrialPowerManager.IndustrialPowerState.High:
			return {"happy" : MERCHANT_HAPPY_DELTA, "fear" : -MERCHANT_FEAR_DELTA}
		_:
			return {}
