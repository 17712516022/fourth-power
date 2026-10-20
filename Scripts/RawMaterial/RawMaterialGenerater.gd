extends Node

# 今天世界上发生了哪些事。
var material_list : Array[NewsData.NewsType] = []

# 今天一共发生了几条**真新闻**（不是软新闻的那些）。
var real_news_count : int = 0

func _ready() -> void:
	EventBus.material_news_requested.connect(_on_material_news_requested)
	EventBus.game_start.connect(reset_events)

func get_material(event : NewsData.NewsType) -> void:
	material_list.append(event)
	# 政府动作刚改过属性：把那一笔折成这条新闻的阈值推量。
	PolicyPush.commit(event)

# 逻辑那头（群体状态…）现在用信号报"今天出了什么事"，不再直呼本模块。
func _on_material_news_requested(event : int) -> void:
	get_material(event)


# 大事件

# 每天开局摇一次：这么大的一件事，三成的日子会有。
const BIG_EVENT_CHANCE : float = 0.30

# 今天摇中的那一件（具体到哪一条资源）：由 fill_pool 摆进池子。
# 不能再往 material_list 里塞 NewsType 了——大事件同属一个序号，分不出是哪一件。
var scripted_big : Array[NewsResource] = []

# 昨夜那件大事件的编号：来信靠它认领，发完清空。
var last_event_id : String = ""

# 洗牌袋：同一局里一件事只出一次，顺序仍是随机的。
var _bag : Array = []

func roll_big_event() -> void:
	if randf() >= BIG_EVENT_CHANCE:
		return
	if _bag.is_empty():
		_bag = NewsData.BIG_EVENT.duplicate()
		_bag.shuffle()
	if _bag.is_empty():
		return
	var res : NewsResource = _bag.pop_back()
	if res == null:
		return
	scripted_big.append(res)
	last_event_id = res.event_id

# 开新一局：袋子重洗。
func reset_events() -> void:
	_bag.clear()
	scripted_big.clear()
	last_event_id = ""
