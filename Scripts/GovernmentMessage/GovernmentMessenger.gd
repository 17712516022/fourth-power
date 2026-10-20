class_name GovernmentMessager extends Node

# 政府来信只跟大事件走：一件大事，两封备好的信（请求 / 威胁），按好感掷一封。出事的第二天早上到。
# 好感多少，就有多少成是"请"的口气；剩下的成数是威胁。

const KEY : String = "government/message"

@onready var attribute_ui: AttributeUi = %AttributeUi
@onready var popmenu: GovernmentMessagePopMenu = %GovernmentMessagePopmenu

# 没读的那封。
var _unread : Dictionary = {}

# 万一两封撞在一起：后到的排队，读完上一封再顶上来。
var _queued : Dictionary = {}

var judge : GovernmentJudge = GovernmentJudge.new()

func _ready() -> void:
	attribute_ui.need_open_government.connect(_on_open_government)
	EventBus.game_start.connect(_on_game_start)
	EventBus.paper_ready.connect(_on_paper_ready)
	# World 结算完才发这一声，此时"昨夜出了哪件大事"已经落定。
	EventBus.action_end.connect(_on_action_end)

# 有没有没读过的信（右上角那枚图标据此亮红点）。
func has_message() -> bool:
	return not _unread.is_empty() or not _queued.is_empty()

func take() -> Dictionary:
	var msg : Dictionary = _unread
	_unread = _queued
	_queued = {}
	return msg

func _on_game_start() -> void:
	_unread = {}
	_queued = {}
	judge.watch = {}

func _on_paper_ready(newspaper : NewsPaper) -> void:
	_deliver(judge.check_paper(newspaper))

# 昨夜出了件大事，今天就有一封信来问它。
func _on_action_end() -> void:
	var event_id : String = RawMaterialGenerater.last_event_id
	if event_id == "":
		return
	RawMaterialGenerater.last_event_id = ""
	_send_event_letter(event_id)

func _send_event_letter(event_id : String) -> bool:
	var pair : Array = GovernmentMessageData.EVENT_LETTERS.get(event_id, [])
	if pair.is_empty() or pair[0] == null:
		return false
	# 好感就是请求口吻的概率：好感 70 就有七成"请"，三成"威胁"。
	var ask_chance : float = GovernmentFavor.favor / GovernmentFavor.MAX
	var threat : bool = randf() >= ask_chance
	var msg : GovernmentMessageResource = pair[1] if threat and pair.size() > 1 else pair[0]
	_send(msg if msg != null else pair[0])
	return true

func _send(entry : GovernmentMessageResource) -> void:
	var msg : Dictionary = GovernmentLetter.fill(GovernmentLetter.to_dict(entry))
	# 从这封信起盯着：下一份报纸就是它的考期。
	judge.watch_letter(msg)
	_deliver(msg)

# 亮红点、响一声。
func _deliver(msg : Dictionary) -> void:
	if msg.is_empty():
		return
	# 手上还有一封没读：这一封先排队，别把上一封冲掉。
	if not _unread.is_empty():
		_queued = msg
		BadgeManager.push(KEY)
		return
	_unread = msg
	BadgeManager.push(KEY)
	AudioManager.play(AudioManager.Sound.DETAIL)

func _on_open_government() -> void:
	if not has_message():
		return
	_give_offer()
	popmenu.pop_show_message(take())

# Pick 那两档：面板一打开就把递来的稿子落进素材池。
func _give_offer() -> void:
	if not GovernmentMessageResource.is_pick(int(_unread.get("type", -1))):
		return
	var is_fake : bool = bool(_unread.get("fake", true))
	# 主线：信里直接挂了那张卡，取出来就用，不现抽。
	var path : String = String(_unread.get("offer", ""))
	if path != "":
		if ResourceLoader.exists(path):
			var res : NewsResource = load(path)
			if res != null:
				EventBus.government_offer_res.emit(res, is_fake)
		return
	# 老路：按 NewsType 从池子里现抽一条。
	var news : int = int(_unread.get("news", -1))
	if news < 0:
		return
	EventBus.government_offer_taken.emit(news, is_fake)

func snapshot() -> Dictionary:
	return {
		"unread" : _unread.duplicate(true),
		"queued" : _queued.duplicate(true),
		"watch" : judge.watch.duplicate(true),
	}

func restore(data : Dictionary) -> void:
	if data.is_empty():
		return
	_unread = GovernmentLetter.as_msg(data.get("unread", {}))
	_queued = GovernmentLetter.as_msg(data.get("queued", {}))
	judge.watch = GovernmentLetter.as_msg(data.get("watch", {}))
