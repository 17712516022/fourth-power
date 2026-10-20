class_name StabilityInfluence extends RefCounted


# 乱世：人人怕、日子难过、**底气被熬干**（闹久了人也没力气了）。
const CHAOS_FEAR  : float = 0.015
const CHAOS_HAPPY : float = 0.015
const CHAOS_POWER : float = 0.02

const CALM_POWER  : float = 0.02

# 没有受益者
static func all(stability : StabilityManager) -> Dictionary:
	match stability.state:
		StabilityManager.StabilityState.Low:
			return {"fear" : CHAOS_FEAR, "happy" : -CHAOS_HAPPY, "power" : -CHAOS_POWER}
		StabilityManager.StabilityState.High:
			return {"power" : CALM_POWER}
		_:
			return {}
