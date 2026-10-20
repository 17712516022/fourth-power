class_name Ui extends CanvasLayer

const RAW_MATERIAL = preload("res://Scene/RawMaterial.tscn")
const DAY_PASS = preload("res://Scene/DayPassAnimation.tscn")
const ENDING_PANEL = preload("res://Scene/EndingPanel.tscn")

@onready var pressure: PressureUi = %pressure
@onready var raw_material_factory: RawMaterialFactory = $RawMaterialFactory
@onready var attribute_ui: AttributeUi = %AttributeUi
@onready var fake_new_popmenu: FakeNewPopMenu = %FakeNewPopmenu
@onready var fake_news_list: FakeNewsList = %FakeNewsList
@onready var world: World = $World
@onready var government_messager: GovernmentMessager = $GovernmentMessager
@onready var toast: Toast = %Toast
@onready var message_panel: NewsMessagePanel = $MessagePanel

func _ready() -> void:
	# 局内音乐：从菜单进来时把菜单曲换掉。
	AudioManager.play_music()

	# 过天的过场：盖一层 CanvasLayer 压在 Ui 之上。
	add_child(DAY_PASS.instantiate())
	# 终刊号压在过场之上；添在读档之前——读档可能当场结算（政府已经崩了）。
	add_child(ENDING_PANEL.instantiate())
	raw_material_factory.SetUp(pressure.news_container)
	attribute_ui.SetUp(world)
	# 悬停面板的账单要读"四家现在在哪一档"。
	message_panel.SetUp(world)
	# 结局要看政府和四家：世界只交给它一次，之后判定自己读。
	EndingManager.SetUp(world)
	# 世界与面板交给存档：存档键、读档都靠它。
	SaveManager.Bind(self, world, attribute_ui, raw_material_factory, fake_news_list,
		government_messager)
		# 装配完了，宣布一局开始。
	EventBus.game_start.emit()
	# 如果是"继续游戏"进来的，把存档灌进去——覆盖掉上面那半天的新局初始化。
	SaveManager.apply_pending_load()
	attribute_ui.need_save.connect(_on_save)
	EventBus.fake_news_confirmed.connect(_on_fake_news_confirmed)

# 右上角那枚软盘：把此刻的世界收成一份存档，成没成都要给个回声。
func _on_save() -> void:
	var ok : bool = SaveManager.save_game()
	toast.pop(Texts.PANEL_SAVE_DONE if ok else Texts.PANEL_SAVE_FAILED)

# 确认做假：照着档案里那条，往素材池里放一张假的（红色）。
func _on_fake_news_confirmed(res : NewsResource) -> void:
	# 这一声是"造假成立"：铅笔在纸上写。
	AudioManager.play(AudioManager.Sound.FAKE_NEWS)
	var fake : RawMaterial = RAW_MATERIAL.instantiate()
	fake.is_fake = true
	fake.setup(res)
	pressure.news_container.add_child(fake)
	RawMaterialAnimation.play(fake, pressure.news_container)
