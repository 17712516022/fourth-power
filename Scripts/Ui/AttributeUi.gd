class_name AttributeUi extends VBoxContainer

# 世界。
var _world : World = null

var _farmers : Farmers = null
var _workers : Workers = null
var _merchants : Merchants = null
var _soldier : Soldier = null
var _government : Government = null

@onready var time_ui: RichTextLabel = %TimeUi
@onready var news_paper_inflence_ui: RichTextLabel = %NewsPaperInflenceUi
@onready var farmer_state_ui: RichTextLabel = %FarmerStateUi
@onready var worker_state_ui: RichTextLabel = %WorkerStateUi
@onready var merchant_state_ui: RichTextLabel = %MerchantStateUi
@onready var soldier_state_ui: RichTextLabel = %SoldierStateUi
@onready var government_state_ui: RichTextLabel = %GovernmentStateUi
@onready var create_fake_button: Button = %CreateFakeButton
@onready var help_button: Button = %HelpButton
@onready var setting_button: Button = %SettingButton
@onready var save_button: Button = %SaveButton
@onready var government_button: TextureRect = %GovernmentButton

# 稳定度那条是**独立场景**（Scene/StabilityBar.tscn，脚本 Scripts/Ui/StabilityBar.gd）
@onready var stability_bar: StabilityBar = %StabilityBar

var day: int = 1

signal need_save
signal need_open_government

# 昨天政府的档位名。
var _government_state_yesterday : String = ""

func _ready() -> void:
	# 场景里的字已经清空（唯一来源是 Texts / Texts.gd）：按钮上的字在这儿补上。
	create_fake_button.text = Texts.PANEL_FAKE_BUTTON
	help_button.tooltip_text = Texts.PANEL_HELP_TOOLTIP
	setting_button.tooltip_text = Texts.PANEL_SETTING_TOOLTIP
	save_button.tooltip_text = Texts.PANEL_SAVE_TOOLTIP

	# 这五行 + 稳定度条是"可以问为什么的"：悬停就把解释交给那张说明卡。
	_note_on(farmer_state_ui, func(): return Explain.group_report(_farmers))
	_note_on(worker_state_ui, func(): return Explain.group_report(_workers))
	_note_on(merchant_state_ui, func(): return Explain.group_report(_merchants))
	_note_on(soldier_state_ui, func(): return Explain.group_report(_soldier))
	_note_on(government_state_ui, func(): return Explain.government_report(_government))
	_note_on(stability_bar, func(): return Explain.stability_report(_government, _world.groups))

	create_fake_button.pressed.connect(_on_create_fake_button)
	help_button.pressed.connect(_on_help_button)
	setting_button.pressed.connect(_on_setting_button)
	save_button.pressed.connect(_on_save_button)
	government_button.gui_input.connect(_on_government_input)
	EventBus.game_start.connect(_on_game_start)
	EventBus.action_end.connect(_on_action_end)
	EventBus.influence_changed.connect(_on_influence_changed)

# Ui 装配时注入世界，顺手把五个对象认齐。
func SetUp(p_world : World) -> void:
	_world = p_world
	for i in _world.groups.get_children():
		if i is Farmers:
			_farmers = i as Farmers
		elif i is Workers:
			_workers = i as Workers
		elif i is Merchants:
			_merchants = i as Merchants
		elif i is Soldier:
			_soldier = i as Soldier
	_government = _world.government

# 悬停问一句"为什么"：文字现算（档位每天都可能变），画面交给说明卡。
# 不用 tooltip_text：原生 tooltip 是灰底系统字，跟报纸主题对不上。
func _note_on(control : Control, produce : Callable) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_STOP
	# 子控件别抢鼠标：稳定度条里那根进度条会把母控件的 mouse_entered 挡掉。
	_ignore_mouse_deep(control)
	control.mouse_entered.connect(func(): _show_note(produce.call()))
	control.mouse_exited.connect(func(): EventBus.explain_hide.emit())

func _show_note(text : String) -> void:
	# 世界还没装配完（或这一家暂时没话可说）：别弹一块空面板。
	if text.strip_edges() == "":
		return
	var parts : Dictionary = Explain.split_title(text)
	EventBus.explain_show.emit(parts["title"], parts["body"])

func _ignore_mouse_deep(node : Node) -> void:
	for child in node.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
			_ignore_mouse_deep(child)

func _on_game_start() -> void:
	day = 1
	# 开局先把"昨天"清掉：第一天本来就全是正常，但清了以后不必依赖这件事成立。
	_government_state_yesterday = ""
	# 红点账目的清零**不在这里**：那要看"是新局还是读档"，只有 SaveManager 分得清。
	_refresh()

func _on_action_end() -> void:
	day += 1
	_refresh()

# 存档：把天数摆到读回来的那一天，并整体刷一遍面板。
func set_day(p_day : int) -> void:
	day = p_day
	_refresh()

# 造假新闻扣影响力发生在一天中间，等不到过天，得单独听。
func _on_influence_changed() -> void:
	_refresh_influence()

func _refresh() -> void:
	time_ui.text = "[br][u]Day %s[/u]" % day
	_refresh_influence()
	_refresh_states()
	_refresh_stability()

func _refresh_influence() -> void:
	news_paper_inflence_ui.text = Texts.PANEL_INFLUENCE % NewsPaperManager.get_influence()

# 稳定度那条是**独立组件**（Scene/StabilityBar.tscn，脚本在 Scripts/Ui/）
func _refresh_stability() -> void:
	if _government == null:
		return
	stability_bar.refresh(_government.asset.stability)

# 五行状态：状态只在每天 tick 时才会变，过天时拉取一遍就够 ---。
func _refresh_states() -> void:
	# SetUp 还没被调用（一局还没装配完）：保持默认字，别报错。
	if _farmers == null:
		return
	_set_line(farmer_state_ui, Texts.PANEL_HEAD_FARMER,
		StateText.of(_farmers.state_machine.current_state))
	_set_line(worker_state_ui, Texts.PANEL_HEAD_WORKER,
		StateText.of(_workers.state_machine.current_state))
	_set_line(merchant_state_ui, Texts.PANEL_HEAD_MERCHANT,
		StateText.of(_merchants.state_machine.current_state))
	_set_line(soldier_state_ui, Texts.PANEL_HEAD_SOLDIER,
		StateText.of(_soldier.state_machine.current_state))
		# 政府那一行取一次，两处用：填进去、以及下面判红点。
	var gov_line : Dictionary = _government_line()
	_set_line(government_state_ui, Texts.PANEL_HEAD_GOVERNMENT, gov_line)

	# 政府换了一手：记一笔，红点由总账点亮。
	var today : String = gov_line["text"]
	if _government_state_yesterday != "" and today != _government_state_yesterday:
		BadgeManager.push("government")
	_government_state_yesterday = today

func _set_line(label : RichTextLabel, who : String, state : Dictionary) -> void:
	label.text = Texts.PANEL_ROW % [who, state["color"].to_html(false), state["text"]]

# 政府那一行的内容。
func _government_line() -> Dictionary:
	return StateText.of(_government.policy_machine.current_state)

func _on_create_fake_button() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	EventBus.need_open_fake_list.emit()

func _on_help_button() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	EventBus.need_open_help.emit()

func _on_setting_button() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	EventBus.need_open_settings.emit()

func _on_save_button() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	need_save.emit()

# 点那枚按钮：把"政府"这一层记为看过（红点自己就灭了），再请上层去开政府面板。
func _on_government_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb : InputEventMouseButton = event
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			AudioManager.play(AudioManager.Sound.CLICK)
			BadgeManager.mark_seen("government")
			need_open_government.emit()
