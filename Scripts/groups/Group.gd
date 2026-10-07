class_name Group extends Node

# 真相：他们实际处在什么境地。日子本身在改它，**报纸碰不到它**。
# 初值由子类的 initial_attribute() 提供
var attribute : Dictionary = {}

const RANDOM_CHANGE : int = 5
const BASE_PUSH : float = 0.05
var push : Dictionary = {
	"happy" : 0.0,
	"fear" : 0.0,
	"angry" : 0.0,
	"power" : 0.0,
}

# 政府。由 World 在开局时注入。
var government : Government = null

# 在 _init 里就备好，比等到 _ready 更稳（万一以后有游离不进树的群体）。
func _init() -> void:
	attribute = initial_attribute()

func step(newspaper : NewsPaper) -> void:
	read_newspaper(newspaper)

func read_newspaper(_newspaper : NewsPaper) -> void:
	pass #子类重写

# --- 子类只需要填这两个钩子 ---
# 这个群体的初值。
func initial_attribute() -> Dictionary:
	return {"happy" : 0.0, "angry" : 0.0, "fear" : 0.0, "power" : 0.0}
	#子类重写

# 他们走到极端（逃荒 / 外逃 / 溃散）时报的那条新闻。没有这一档的（工人）返回 -1。
func finale_type() -> int:
	return -1

# --- 报纸：只改门槛 ---
# 所以这里只碰 push，一个字典。状态机拿它去抬线或压线。
func _read_paper(newspaper : NewsPaper) -> void:
	# 先清零。
	for i in push.keys():
		push[i] = 0.0
	
	if newspaper == null:
		return
	
	# 一份报纸说的话有多少分量，取决于它自己有多少信誉。
	var weight : float = NewsPaperManager.get_influence() / 100
	for item in newspaper.events:
		if item == null :
			continue               # 天气、连载、漫画也改变任何人的想法
		
		for i in push.keys():
			push[i] += _push_of(item,i) * weight

# 每天读一遍"世界的公共部分"。
func _read_world() -> void:
	_absorb(attribute, StabilityInfluence.all(government.asset.stability))

# 每天的随机扰动
const MOOD_KEYS : Array[String] = ["happy", "angry", "fear", "power"]

# 从今天这一个随机数，派生四个互不相同的扰动。
func _drift() -> void:
	for i in MOOD_KEYS.size():
		var key : String = MOOD_KEYS[i]
		attribute[key] = clampf(
			attribute[key] + (randf()-0.5) / RANDOM_CHANGE, 0.0, 1.0)

# 读一条消息，返回它把 push 推多少。
func _push_of(item : NewsResource , push_name : String) -> float:
	var influence_group : InfluenceGroup = item.influnce
	match push_name:
		"happy" :
			return influence_group.happy_influnce
		"angry" :
			return influence_group.angry_influnce
		"fear" :
			return influence_group.fear_influnce
		_ :
			return influence_group.power_influnce

# 把一组增量打进某个属性表。
func _absorb(target : Dictionary, effects : Dictionary, weight : float = 1.0) -> void:
	for key in effects:
		target[key] = clampf(target[key] + effects[key] * weight, 0.0, 1.0)
