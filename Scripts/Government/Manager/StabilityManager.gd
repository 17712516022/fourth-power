class_name StabilityManager extends RefCounted

# 稳定度

# 四家合起来最多扣 12。
const MAX_GROUPS : int = 4
const MAX_LEVEL  : int = 3
const MAX_VALUE  : int = MAX_GROUPS * MAX_LEVEL

# 乱世 / 太平 的分界线。
# Low 现在盖住了政府崩溃线 6.0：条子上报"乱世"的时候，崩溃确实可能发生。
const TIGHT : float = 8.0
const GOOD  : float = 10.0


enum StabilityState {
	High, Normal, Low
}

# 满值开局：四个群体都是正常状态。
var value : float = float(MAX_VALUE)
var state : StabilityState = StabilityState.Normal


func _init() -> void:
	update_state()


# 照抄四家今天各自的扣分（Government 算好的"系数 × power"），求和。
func mirror(costs : Array[float]) -> void:
	var penalty : float = 0.0
	for cost in costs:
		penalty += clampf(cost, -float(MAX_LEVEL), float(MAX_LEVEL))
	
	value = clampf(float(MAX_VALUE) - penalty, 0.0, float(MAX_VALUE))
	update_state()


func update_state() -> void:
	if value < TIGHT:
		state = StabilityState.Low
	elif value > GOOD:
		state = StabilityState.High
	else:
		state = StabilityState.Normal
