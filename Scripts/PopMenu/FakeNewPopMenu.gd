class_name FakeNewPopMenu extends PopMenuBase

# 造假确认弹窗 —— 档案里挑中一条，问一句"把这条做成假的？

# 「你确定吗」红了之后变回来的时间。
const WARN_TIME : float = 1.2

# 卡片是米白纸，字得用墨色；警告时换暗红。
# 不用 modulate：modulate 是乘算，乘在深色字上只会更黑，红不起来。
const INK : Color = Color(0.23137255, 0.18431373, 0.13333334, 1)
const WARN : Color = Color(0.6392157, 0.227451, 0.172549, 1)

@onready var rich_text_label: RichTextLabel = %FakeNewPopRichTextLabel
@onready var refuse_button: Button = %FakeNewPopRefuseButton
@onready var determine_button: Button = %FakeNewPopDetermineButton

# 这一次问的是哪条素材。
var res : NewsResource = null

var _warn_tween : Tween = null

func _ready() -> void:
	super._ready()
	refuse_button.pressed.connect(_on_refuse_pressed)
	determine_button.pressed.connect(_on_determine_pressed)
	EventBus.need_show_popmenu.connect(_on_need_show_popmenu)

# 档案里挑中了一条：把"是哪条"记住，文案复位，弹出来。
func _on_need_show_popmenu(p_res : NewsResource) -> void:
	res = p_res
	_restore_text()
	pop_show()

# 不了：关掉弹窗。
func _on_refuse_pressed() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	res = null
	pop_hide()

func _on_determine_pressed() -> void:
	# 钱不够：不关窗、不扣钱、不给做，把"你确定吗"换成提示。
	if not NewsPaperManager.can_afford_fake_news():
		# 做不了。
		AudioManager.play(AudioManager.Sound.REFUSE)
		_show_warn()
		return

	if res == null:
		pop_hide()
		return

	AudioManager.play(AudioManager.Sound.CLICK)
	# 先把 res 摘下来再动：pop_hide 是异步的（等 tween），中间不该再被人改状态。
	var confirmed : NewsResource = res
	res = null
	pop_hide()
	# 只报"他确认了"。
	EventBus.fake_news_confirmed.emit(confirmed)

# 「你确定吗」复位。
func _restore_text() -> void:
	rich_text_label.text = Texts.POP_CONFIRM
	_set_tone(INK)
	refuse_button.text = Texts.POP_REFUSE
	determine_button.text = Texts.POP_DETERMINE

# "你确定吗" -> "影响力不够"，红一下，一会儿换回来。
func _show_warn() -> void:
	rich_text_label.text = Texts.POP_WARN
	_set_tone(WARN)
	if _warn_tween != null:
		_warn_tween.kill()
	_warn_tween = create_tween()
	_warn_tween.tween_interval(WARN_TIME)
	_warn_tween.tween_callback(_restore_text)

# 字色：场景里那条墨色只是初始值，警告时得能改回来。
func _set_tone(tone : Color) -> void:
	rich_text_label.add_theme_color_override("default_color", tone)
