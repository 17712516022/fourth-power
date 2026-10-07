class_name AttributeUi extends VBoxContainer

# 世界。只读它的状态机——这里只管显示，不碰任何逻辑。
# 由 Ui 装配时注入（SetUp），UI 自己不去场景树里到处摸。
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
var day: int = 1

signal need_open_fake_new_list

# --- 状态分级配色：正常白、暗流黄、明面橙、极端红 ---
const COLOR_NORMAL  : Color = Color(1, 1, 1)
const COLOR_HIDDEN  : Color = Color(1, 0.85, 0.3)
const COLOR_OPEN    : Color = Color(1, 0.55, 0.2)
const COLOR_EXTREME : Color = Color(1, 0.3, 0.3)

func _ready() -> void:
	create_fake_button.pressed.connect(_on_create_fake_button)
	EventBus.game_start.connect(_on_game_start)
	EventBus.action_end.connect(_on_action_end)
	EventBus.influence_changed.connect(_on_influence_changed)

# Ui 装配时注入世界，顺手把五个对象认齐。
# 按类型认而不是按节点名——改名字不连累这里。
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

func _on_game_start() -> void:
	day = 1
	_refresh()

func _on_action_end() -> void:
	day += 1
	_refresh()

# 造假新闻扣影响力发生在一天中间，等不到过天，得单独听。
func _on_influence_changed() -> void:
	_refresh_influence()

func _refresh() -> void:
	time_ui.text = "[br][b][u]DAY %d[/u][/b]" % day
	_refresh_influence()
	_refresh_states()

func _refresh_influence() -> void:
	news_paper_inflence_ui.text = "[b][u]报纸影响力 [color=red]%d[/color][/u][/b]" % NewsPaperManager.get_influence()

# --- 五行状态：状态只在每天 tick 时才会变，过天时拉取一遍就够 ---

func _refresh_states() -> void:
	# SetUp 还没被调用（一局还没装配完）：保持默认字，别报错。
	if _farmers == null:
		return
	_set_line(farmer_state_ui, "农民", _farmer_state())
	_set_line(worker_state_ui, "工人", _worker_state())
	_set_line(merchant_state_ui, "商人", _merchant_state())
	_set_line(soldier_state_ui, "士兵", _soldier_state())
	_set_line(government_state_ui, "政府", _government_state())

func _set_line(label : RichTextLabel, who : String, state : Dictionary) -> void:
	label.text = "%s：[color=#%s]%s[/color]" % [who, state["color"].to_html(false), state["text"]]

func _farmer_state() -> Dictionary:
	match _farmers.state_machine.current_state:
		FarmStateMachine.FarmerState.Resist:
			return {"text" : "抗租", "color" : COLOR_HIDDEN}
		FarmStateMachine.FarmerState.Flee:
			return {"text" : "逃荒", "color" : COLOR_EXTREME}
		_:
			return {"text" : "正常", "color" : COLOR_NORMAL}

func _worker_state() -> Dictionary:
	match _workers.state_machine.current_state:
		WorkerStateMachine.WorkerState.Slowdown:
			return {"text" : "怠工", "color" : COLOR_HIDDEN}
		WorkerStateMachine.WorkerState.Strike:
			return {"text" : "罢工", "color" : COLOR_OPEN}
		_:
			return {"text" : "正常", "color" : COLOR_NORMAL}

func _merchant_state() -> Dictionary:
	match _merchants.state_machine.current_state:
		MerchantStateMachine.MerchantState.Hoard:
			return {"text" : "囤积", "color" : COLOR_HIDDEN}
		MerchantStateMachine.MerchantState.CloseShop:
			return {"text" : "罢市", "color" : COLOR_OPEN}
		MerchantStateMachine.MerchantState.Flight:
			return {"text" : "外逃", "color" : COLOR_EXTREME}
		_:
			return {"text" : "正常", "color" : COLOR_NORMAL}

func _soldier_state() -> Dictionary:
	match _soldier.state_machine.current_state:
		SoldierStateMachine.SoldierState.Slack:
			return {"text" : "消极", "color" : COLOR_HIDDEN}
		SoldierStateMachine.SoldierState.Mutiny:
			return {"text" : "哗变", "color" : COLOR_OPEN}
		SoldierStateMachine.SoldierState.Desert:
			return {"text" : "溃散", "color" : COLOR_EXTREME}
		_:
			return {"text" : "正常", "color" : COLOR_NORMAL}

# 政策不是"闹到第几级"，只分三档：观望白、安抚黄、弹压红。
func _government_state() -> Dictionary:
	match _government.policy_machine.current_policy:
		GovernmentStateMachine.Policy.Conciliate:
			return {"text" : "安抚", "color" : COLOR_HIDDEN}
		GovernmentStateMachine.Policy.Suppress:
			return {"text" : "弹压", "color" : COLOR_EXTREME}
		_:
			return {"text" : "观望", "color" : COLOR_NORMAL}

func _on_create_fake_button() -> void:
	need_open_fake_new_list.emit()
