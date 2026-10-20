class_name NewsMessagePanel extends Control

# 跟着光标弹出的说明卡：一块标题 + 一张账单。
#
# 两条来路共用这块面板（同一个场景，同一套主题，免得一个原生 tooltip 一个自绘）：
#   1) 悬停一张新闻素材 → 记者的口气 + 这一版登出去会把哪几条线挪到哪儿；
#   2) 悬停右侧四家 / 领地 / 稳定度 → 这一档是怎么来的、还差多少、该往哪推。

# 四家：十六个数里的前缀 + 面板上怎么叫它。
const GROUPS : Array = [
	["farmer", Texts.GROUP_FARMER],
	["worker", Texts.GROUP_WORKER],
	["merchant", Texts.GROUP_MERCHANT],
	["soldier", Texts.GROUP_SOLDIER],
]

# 小到什么程度就当"没什么动静"。
const NOTHING_MUCH : float = 0.0005

# 面板与光标之间的缝。
const CURSOR_GAP : Vector2 = Vector2(18, 18)

# 面板离屏幕边至少留这么宽，免得贴着边看不清。
const SCREEN_MARGIN : float = 8.0

@onready var _box : PanelContainer = $PanelContainer
# 标题也要能上色（"农夫 · 抗租"里的档位染红/绿），所以是 RichTextLabel 不是 Label。
@onready var _title : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var _divider : ColorRect = $PanelContainer/MarginContainer/VBoxContainer/Divider
@onready var _text : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/NewsMessage

# 世界：用来问"这一条登出去，各家现在的门槛会挪到哪儿"。
var _world : World = null

func _ready() -> void:
	hide()
	EventBus.hover_on_news.connect(_on_hover_on_news)
	# 右侧那几行的"为什么"也走这块面板。
	EventBus.explain_show.connect(_on_explain_show)
	EventBus.explain_hide.connect(_on_explain_hide)
	# 详情面板一开，这块跟着光标的就收起来：详情里写的是同一条，两份叠着只添乱。
	EventBus.need_show_detail.connect(_on_detail_opened)

# 由 Ui 装配时注入：没有世界就只报老那句模糊话，不至于报错。
func SetUp(p_world : World) -> void:
	_world = p_world

# 统一的显示入口：有标题就画标题栏和分隔线，没有就是一块纯文字。
func show_note(title : String, body : String) -> void:
	_title.text = title
	_title.visible = title != ""
	_divider.visible = title != ""
	_text.text = body
	# 先 show 再量：隐藏的控件量不出真实的最小尺寸。
	show()
	_place_near_cursor()

func _on_explain_show(title : String, body : String) -> void:
	show_note(title, body)

func _on_explain_hide() -> void:
	hide()

func _on_hover_on_news(res : NewsResource, entered : bool) -> void:
	if not entered or res == null:
		hide()
		return
	var note : Dictionary = _compose(res)
	show_note(note["title"], note["body"])

func _on_detail_opened(_res : NewsResource, _is_fake : bool, _source : int) -> void:
	hide()

# 悬停一张素材：标题 + 「记者口气 ‖ 账单」。
func _compose(res : NewsResource) -> Dictionary:
	var flavor : String = _flavor(res)
	if res == null or res.is_filler:
		return {"title" : "", "body" : flavor}
	var account : String = Explain.card_report(res, _world.groups if _world != null else null)
	if account == Texts.MSG_QUIET or account == "":
		return {"title" : "", "body" : flavor}
	return {
		"title" : Texts.EXPLAIN_CARD_TITLE,
		# 上面是记者的口气，空一行接账单：中间那条线留给标题栏，别画两条。
		"body" : flavor + "\n\n" + account,
	}

# 记者的口气：只说"要不要押一押"，不报数、不点名字（细节在下面的账单里）。
func _flavor(res : NewsResource) -> String:
	if res == null:
		return Texts.MSG_UNKNOWN
	if res.is_filler:
		return Texts.MSG_FILLER

	var src : Resource = res.big_effect if res.big_effect != null else PolicyPush.influence_preview(res)
	if src == null:
		return Texts.MSG_UNKNOWN

	var worst : float = _worst_badness(src)

	# 四家都"往稳里推"：这条没什么动静。
	if absf(worst) <= NOTHING_MUCH:
		return Texts.MSG_QUIET

	# 主要往坏的方向推：劝一句先押一押。
	if worst > 0.0:
		return Texts.MSG_PRESS

	# 四家都偏"稳"：这条对街面是安抚。
	return Texts.MSG_CALM

# 四家里最吃亏的那一家，坏处分量有多大。
func _worst_badness(src : Resource) -> float:
	var worst : float = _badness_of(src, GROUPS[0][0])
	for i in range(1, GROUPS.size()):
		worst = maxf(worst, _badness_of(src, GROUPS[i][0]))
	return worst

# 这条素材"让这一家更容易出事"的分量。
func _badness_of(src : Resource, who : String) -> float:
	return (-_value_of(src, who + "_angry")
		- _value_of(src, who + "_fear")
		- _value_of(src, who + "_power")
		+ _value_of(src, who + "_happy"))

# 取一个键的值。
func _value_of(src : Resource, key : String) -> float:
	var raw : Variant = src.get(key)
	return float(raw) if raw != null else 0.0

# 摆在哪儿

# 贴在光标右下；右边或下边放不下，就翻到左上。
func _place_near_cursor() -> void:
	var box : Vector2 = _box.get_combined_minimum_size()
	_box.size = box

	var mouse : Vector2 = get_viewport().get_mouse_position()
	var screen : Vector2 = get_viewport().get_visible_rect().size
	var at : Vector2 = mouse + CURSOR_GAP
	if at.x + box.x > screen.x - SCREEN_MARGIN:
		at.x = mouse.x - CURSOR_GAP.x - box.x
	if at.y + box.y > screen.y - SCREEN_MARGIN:
		at.y = mouse.y - CURSOR_GAP.y - box.y
		# 最后再夹一次：面板比屏幕还高的时候（很长的正文），至少保证左上角看得见。
	_box.position = Vector2(
		clampf(at.x, SCREEN_MARGIN, maxf(SCREEN_MARGIN, screen.x - SCREEN_MARGIN - box.x)),
		clampf(at.y, SCREEN_MARGIN, maxf(SCREEN_MARGIN, screen.y - SCREEN_MARGIN - box.y)))
