class_name PopMenu extends Control

# Determine 按下：玩家确认要把弹窗对应的素材做成假新闻。
# 弹窗自己不认识素材池，只负责把"是哪条"带回去——往哪儿加、怎么加，听的人说了算。
signal determined(res : NewsResource)

const CONFIRM_TEXT : String = "你确定吗"
const WARN_TEXT : String = "影响力不够"
const WARN_TIME : float = 1.2

@onready var refuse_button: TextureButton = %RefuseButton
@onready var determine_button: TextureButton = %DetermineButton
@onready var confirm_label: RichTextLabel = %RichTextLabel

# 这次弹窗是为哪条素材弹的。
var _res : NewsResource = null
var _warn_tween : Tween = null

func _ready() -> void:
	hide()
	refuse_button.pressed.connect(pop_hide)
	determine_button.pressed.connect(_on_determine_pressed)

func pop_show(p_res : NewsResource) -> void:
	_res = p_res
	show()
	var tween : Tween = create_tween()
	tween.tween_property(self, "position",Vector2(576 , 0) ,0.2)

func _on_determine_pressed() -> void:
	if _res == null:
		pop_hide()
		return

	# 钱不够：不关窗、不扣钱、不给做，把"你确定吗"换成提示。
	if not NewsPaperManager.can_afford_fake_news():
		_show_warn()
		return

	# 先把 res 摘下来再动：pop_hide 是异步的（等 tween），中间不该再被人改状态。
	var res : NewsResource = _res
	_res = null
	NewsPaperManager.spend_fake_news()   # 确认的瞬间一手交钱
	pop_hide()
	determined.emit(res)

# "你确定吗" -> "影响力不够"，红一下，一会儿换回来。
# 连点 Determine 就重起一个 tween，旧的作废——文字不会被抢着复原。
func _show_warn() -> void:
	confirm_label.text = WARN_TEXT
	confirm_label.modulate = Color(0.9, 0.3, 0.3)
	if _warn_tween != null:
		_warn_tween.kill()
	_warn_tween = create_tween()
	_warn_tween.tween_interval(WARN_TIME)
	_warn_tween.tween_callback(_restore_text)

func _restore_text() -> void:
	confirm_label.text = CONFIRM_TEXT
	confirm_label.modulate = Color.WHITE

func pop_hide() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "position",Vector2(576 , -735) ,0.2)
	await tween.finished
	hide()
