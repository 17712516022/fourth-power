extends Control

# 开始菜单。

const GAME_SCENE : String = "res://Scene/ui.tscn"
const ARCHIVE_PANEL = preload("res://Scene/ArchivePanel.tscn")

# 一、上层纸的胀缩

# 一个来回 30 秒。
const DRIFT_PERIOD : float = 30.0
const DRIFT_AMOUNT : float = 0.08

# 二、尘埃

# 一小撮一像素的点，各自以微小速度向上飘。多了会让版面显得吵。
const DUST_COUNT : int = 9

# 墨色：报头和按钮的字都走这一支。
const INK : Color = Color(0.16, 0.14, 0.11, 1)

# hover 时从左边画出来的那条线。
const LINK_DRAW_TIME : float = 0.12

# 三、打字机

# 菜单的背景是什么？是那个世界的一张报纸。


const CHAR_INTERVAL : float = 0.075
const LINE_PAUSE : float = 0.5
const RESTART_PAUSE : float = 3.5
const CURSOR_PERIOD : float = 0.8

var _blink : float = 0.0
var _typed : String = ""
var _line : int = 0
var _column : int = 0
var _char_timer : float = 0.0
var _restart_timer : float = 0.0
var _typing : bool = true


var _elapsed : float = 0.0
var _dust : Array[ColorRect] = []
var _dust_velocity : Array[Vector2] = []

@onready var drift_layer : TextureRect = %DriftLayer
@onready var dust_layer : Control = %DustLayer
@onready var type_text: Label = %TypeText
@onready var title_box : VBoxContainer = %TitleBox
@onready var seal : PanelContainer = %Seal
@onready var editorial_box : VBoxContainer = %EditorialBox
@onready var menu : VBoxContainer = %Menu
@onready var colophon : HBoxContainer = %Colophon

@onready var start_button : Button = %StartButton
@onready var continue_button : Button = %ContinueButton
@onready var archive_button : Button = %ArchiveButton
@onready var quit_button : Button = %QuitButton

# 图鉴只有这一个入口：菜单里点开，挂在菜单场景上。
var _archive : ArchivePanel = null

# 次级按钮底下那条墨线，hover 时才从左边画出去。
var _link_rules : Dictionary = {}

# 这几行字在场景里是写空的，唯一来源是 Texts（见 _ready）。
@onready var title_label : Label = %TitleLabel
@onready var subtitle_label : Label = %SubtitleLabel
@onready var editorial_label : Label = %EditorialLabel
@onready var issue_label : Label = %IssueLabel
@onready var version_label : Label = %Version

func _ready() -> void:
	# 菜单有自己的一首：进局内时由 Ui 换回常驻曲。
	AudioManager.play_music(AudioManager.MENU_MUSIC_PATH)

	# 场景里的字已经清空（唯一来源是 Texts）：报头、期号、按钮、版本号在这儿补上。
	title_label.text = Texts.MENU_TITLE
	subtitle_label.text = Texts.MENU_SUBTITLE
	editorial_label.text = Texts.MENU_EDITORIAL
	issue_label.text = Texts.MENU_ISSUE
	version_label.text = Texts.MENU_VERSION
	start_button.text = Texts.MENU_START
	archive_button.text = Texts.ARCHIVE_ENTRY
	quit_button.text = Texts.MENU_QUIT

	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	archive_button.pressed.connect(_on_archive_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# 图鉴只在菜单里开：装在这儿，默认藏着。
	_archive = ARCHIVE_PANEL.instantiate()
	add_child(_archive)

	# 没有存档就别装作能继续：把原因写进按钮，比单纯灰掉清楚。
	if SaveManager.has_save():
		continue_button.text = Texts.MENU_CONTINUE
	else:
		continue_button.text = Texts.MENU_CONTINUE + Texts.MENU_NO_SAVE
		continue_button.disabled = true

	_setup_link(start_button)
	_setup_link(continue_button)
	_setup_link(archive_button)
	_setup_link(quit_button)

	_build_dust()
	_intro()

func _process(delta : float) -> void:
	_elapsed += delta
	_drift()
	_update_dust(delta)
	_update_typewriter(delta)

# 纸在胀缩

func _drift() -> void:
	var k : float = 1.0 + DRIFT_AMOUNT * 0.5 * (1.0 - cos(TAU * _elapsed / DRIFT_PERIOD))
	drift_layer.pivot_offset = drift_layer.size * 0.5
	drift_layer.scale = Vector2(k, k)

# 尘埃在飘

func _build_dust() -> void:
	var area : Vector2 = get_viewport_rect().size
	for i in DUST_COUNT:
		var dot : ColorRect = ColorRect.new()
		dot.color = Color(1.0, 0.96, 0.88, randf_range(0.07, 0.24))
		dot.size = Vector2.ONE * randf_range(1.0, 2.0)
		dot.position = Vector2(randf() * area.x, randf() * area.y)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dust_layer.add_child(dot)
		_dust.append(dot)
		# 向上飘，横向带一点随机——像光柱里悬着的尘，不像雨。
		_dust_velocity.append(
			Vector2(randf_range(-2.0, 2.0), randf_range(-5.5, -1.5)))

func _update_dust(delta : float) -> void:
	var area : Vector2 = get_viewport_rect().size
	for i in _dust.size():
		var dot : ColorRect = _dust[i]
		dot.position += _dust_velocity[i] * delta

		# 飘出上边就从底下重来。
		if dot.position.y < -4.0:
			dot.position.y = area.y + 4.0
			dot.position.x = randf() * area.x
			_dust_velocity[i] = Vector2(
				randf_range(-2.0, 2.0), randf_range(-5.5, -1.5))
		elif dot.position.x < -4.0:
			dot.position.x = area.x + 4.0
		elif dot.position.x > area.x + 4.0:
			dot.position.x = -4.0

# 纸上在写字

func _update_typewriter(delta : float) -> void:
	# 光标独立闪，和打字速度无关——它是在"等"下一个字。
	_blink += delta
	var cursor : String = "_" if fmod(_blink, CURSOR_PERIOD) < CURSOR_PERIOD * 0.5 else " "

	if not _typing:
		# 整篇写完了。
		_restart_timer -= delta
		if _restart_timer <= 0.0:
			_restart_typing()
		return

	_char_timer += delta
	if _char_timer >= CHAR_INTERVAL:
		_char_timer = 0.0
		_type_next()
		if not _typing:
			return

	type_text.text = _typed + cursor

# 往前打一个字。
func _type_next() -> void:
	if _line >= Texts.MENU_TYPE_LINES.size():
		_typing = false
		_restart_timer = RESTART_PAUSE
		return

	var text : String = Texts.MENU_TYPE_LINES[_line]
	if _column >= text.length():
		_typed += "\n"
		_line += 1
		_column = 0
		# 负值 = 接下来这段时间都不够打字，得先把这个窟窿补上。
		_char_timer = -LINE_PAUSE
		return

	_typed += text[_column]
	_column += 1

func _restart_typing() -> void:
	# 不清空就重打会很突兀，所以先淡掉再换。
	_restart_timer = 999.0

	var tween : Tween = create_tween()
	tween.tween_property(type_text, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_reset_typing)
	tween.tween_property(type_text, "modulate:a", 1.0, 0.5)

func _reset_typing() -> void:
	_typed = ""
	_line = 0
	_column = 0
	_char_timer = 0.0
	_typing = true
	type_text.text = ""

# 入场

# 版面从上往下依次压印：报头、社论、目录、页脚。印章最后盖上去。
func _intro() -> void:
	await get_tree().process_frame

	var items : Array[Control] = [title_box, editorial_box]
	for i in menu.get_children():
		if i is Control:
			items.append(i as Control)
	items.append(colophon)

	for i in items.size():
		var item : Control = items[i]
		item.pivot_offset = item.size * 0.5
		item.modulate.a = 0.0
		item.scale = Vector2(1.03, 1.03)

		var tween : Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(item, "modulate:a", 1.0, 0.42).set_delay(i * 0.09)
		tween.tween_property(item, "scale", Vector2.ONE, 0.42)\
			.set_delay(i * 0.09)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)

	_stamp_seal()


# 印章比版面慢半拍，从大按到正常，像真按下去。
func _stamp_seal() -> void:
	seal.pivot_offset = seal.size * 0.5
	seal.modulate.a = 0.0
	seal.scale = Vector2(1.45, 1.45)

	var tween : Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(seal, "modulate:a", 1.0, 0.18).set_delay(0.55)
	tween.tween_property(seal, "scale", Vector2.ONE, 0.26)\
		.set_delay(0.55)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)


# 次级按钮：底下挂一条墨线，hover 时从左往右画出来。
func _setup_link(button : Button) -> void:
	var rule : ColorRect = ColorRect.new()
	rule.color = INK
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rule.anchor_left = 0.0
	rule.anchor_right = 1.0
	rule.anchor_top = 1.0
	rule.anchor_bottom = 1.0
	rule.offset_left = 0.0
	rule.offset_right = 0.0
	rule.offset_top = -6.0
	rule.offset_bottom = -4.0
	rule.scale = Vector2(0.0, 1.0)
	button.add_child(rule)

	_link_rules[button] = rule
	button.mouse_entered.connect(_on_link_hover.bind(button, true))
	button.mouse_exited.connect(_on_link_hover.bind(button, false))


func _on_link_hover(button : Button, on : bool) -> void:
	# 灰掉的按钮不该有反馈。
	if button.disabled:
		return

	var rule : ColorRect = _link_rules.get(button) as ColorRect
	if rule == null:
		return

	var tween : Tween = create_tween()
	tween.tween_property(rule, "scale:x", 1.0 if on else 0.0, LINK_DRAW_TIME)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

# 按钮

func _on_start_pressed() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	# 开新局：先让存档把跨场景活着的几笔账拨回起点，再落一个第一天的档。
	SaveManager.new_game()
	# 菜单只是入口，游戏本体在另一个场景。
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_archive_pressed() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	if _archive != null:
		_archive.open()

# 继续：读存档，交给 Ui 装配完再灌进世界（见 Ui._ready 里的 apply_pending_load）。
func _on_continue_pressed() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	SaveManager.request_load()

func _on_quit_pressed() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	get_tree().quit()
