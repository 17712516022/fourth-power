extends Node

# 政府好感度 —— 自动加载，名叫 GovernmentFavor。

# 取值范围。
const MIN : float = 0.0
const MAX : float = 100.0
const START : float = 50.0

# 一件事的价（要调手感，只动这几行）
# 请求：顺着他给得多，顶回去罚得轻（他话是说软的）。
const GAIN_OBEY : float = 10.0
const LOSS_DEFY : float = 5.0
# 威胁：顺着他给得少，顶回去罚得重。
const GAIN_OBEY_THREAT : float = 5.0
const LOSS_DEFY_THREAT : float = 10.0

# 两档门槛
const LOW : float = 30.0
const HIGH : float = 70.0

# 履约 / 违约，报纸影响力跟着动（见 GovernmentJudge.settle）。
const KEEP_INFLUENCE : float = 10.0
const BREACH_INFLUENCE : float = 10.0

var favor : float = START

# 对外

# 加减。
func add(value : float) -> void:
	if is_zero_approx(value):
		return
	favor = clampf(favor + value, MIN, MAX)
	EventBus.government_favor_changed.emit()

# 读档：直接摆回存档里的那个数。
func restore(value : float) -> void:
	favor = clampf(value, MIN, MAX)
	EventBus.government_favor_changed.emit()

# 开新一局：拨回中立。
func reset() -> void:
	restore(START)

# 分档：0 = 敌意 … 4 = 亲近。
const LEVEL_HOSTILE : int = 0
const LEVEL_COLD : int = 1
const LEVEL_NEUTRAL : int = 2
const LEVEL_WARM : int = 3
const LEVEL_CLOSE : int = 4

func level() -> int:
	if favor <= 15.0:
		return LEVEL_HOSTILE
	if favor < LOW:
		return LEVEL_COLD
	if favor >= 85.0:
		return LEVEL_CLOSE
	if favor >= HIGH:
		return LEVEL_WARM
	return LEVEL_NEUTRAL
