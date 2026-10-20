class_name Group extends Node

# 真相：他们实际处在什么境地。
var attribute : Dictionary = {}

# 每天的随机扰动幅度：(randf() − 0.5) / 10 = **±0.05**（均匀分布，见 _drift）。
const RANDOM_CHANGE : int = 10

var push : Dictionary = {
	"happy" : 0.0,
	"fear" : 0.0,
	"angry" : 0.0,
	"power" : 0.0,
}

# 政府。
var government : Government = null

# 在 _init 里就备好，比等到 _ready 更稳（万一以后有游离不进树的群体）。
func _init() -> void:
	attribute = initial_attribute()

func step(newspaper : NewsPaper) -> void:
	read_newspaper(newspaper)

func read_newspaper(_newspaper : NewsPaper) -> void:
	pass

# 我是谁。
func my_kind() -> GroupData.READERS:
	return GroupData.READERS.FARMER

# 这个群体的初值。
func initial_attribute() -> Dictionary:
	return {"happy" : 0.0, "angry" : 0.0, "fear" : 0.0, "power" : 0.0}
	# 子类重写

# 报纸：推阈值 + 大事件改四维
func _read_paper(newspaper : NewsPaper) -> void:
	if newspaper == null:
		return

	# 一份报纸说的话有多少分量，取决于它自己有多少信誉。
	var weight : float = NewsPaperManager.get_influence() / 100
	for i in newspaper.events.size():
		var item : NewsResource = newspaper.events[i]
		if item == null:
			continue

		# 第一格是大版位，读者注意力更集中——效果整体翻倍，其他按 1.0。
		var mult : float = 2.0 if i == 0 else 1.0

		# 大事件：**只改四维，不推阈值**（它的推量四条应留 0）。
		if item.big_effect != null:
			var eff : BigEventEffect = item.big_effect
			var who : String = _who_am_i()
			attribute["happy"] = clampf(attribute["happy"] + float(eff.get(who + "_happy")) * mult, 0.0, 1.0)
			attribute["fear"]  = clampf(attribute["fear"]  + float(eff.get(who + "_fear"))  * mult, 0.0, 1.0)
			attribute["angry"] = clampf(attribute["angry"] + float(eff.get(who + "_angry")) * mult, 0.0, 1.0)
			attribute["power"] = clampf(attribute["power"] + float(eff.get(who + "_power")) * mult, 0.0, 1.0)

		for k in push.keys():
			push[k] += _push_of(item,k) * weight * mult

# 今天的报纸已经并进各状态的阈值了：push 归零。
func _clear_push() -> void:
	for key in push.keys():
		push[key] = 0.0

# 每天的随机扰动
const MOOD_KEYS : Array[String] = ["happy", "angry", "fear", "power"]

# 从今天这一个随机数，派生四个互不相同的扰动。
func _drift() -> void:
	for i in MOOD_KEYS.size():
		var key : String = MOOD_KEYS[i]
		attribute[key] = clampf(
			attribute[key] + (randf()-0.5) / RANDOM_CHANGE, 0.0, 1.0)

# 读一条消息，返回**我这个群体**被推多少。
func _push_of(item : NewsResource , push_name : String) -> float:
	var influence_group : InfluenceGroup = PolicyPush.influence_of(item)
	if influence_group == null:
		return 0.0
	return float(influence_group.get("%s_%s" % [_who_am_i(), push_name]))


# 我在那十六条里叫什么。
func _who_am_i() -> String:
	match my_kind():
		GroupData.READERS.WORKER:
			return "worker"
		GroupData.READERS.MERCHANT:
			return "merchant"
		GroupData.READERS.SOLDIER:
			return "soldier"
		_:
			return "farmer"

# 把一组增量打进属性表。
func _absorb(target : Dictionary, effects : Dictionary) -> void:
	for key in effects:
		target[key] = clampf(target[key] + effects[key], 0.0, 1.0)

func resource_influence() -> void:
	pass
