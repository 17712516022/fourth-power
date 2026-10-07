class_name Ui extends CanvasLayer

const RAW_MATERIAL = preload("res://Scene/RawMaterial.tscn")

@onready var pressure: PressureUi = %pressure
@onready var raw_material_factory: RawMaterialFactory = $RawMaterialFactory
@onready var attribute_ui: AttributeUi = %AttributeUi
@onready var fake_news_list: FakeNewsList = %FakeNewsList
@onready var popmenu: PopMenu = %Popmenu
@onready var world: World = $World

func _ready() -> void:
	raw_material_factory.SetUp(pressure.news_container)
	attribute_ui.SetUp(world)
	# 装配完了，宣布一局开始。
	# 需要做开局准备的模块自己去听——这里不认识它们。
	EventBus.game_start.emit()
	attribute_ui.need_open_fake_new_list.connect(_on_open_fake_new_list)
	fake_news_list.pop_menu_need.connect(_on_pop_menu_need)
	popmenu.determined.connect(_on_popmenu_determined)

func _on_open_fake_new_list() -> void:
	fake_news_list.show()

func _on_pop_menu_need(raw : RawMaterial) -> void:
	popmenu.pop_show(raw.res)

# 确认做假：照着档案里那条，往素材池里放一张假的（红色）。
# 是新实例——档案里那份要留着，以后还能再做。
func _on_popmenu_determined(res : NewsResource) -> void:
	var fake : RawMaterial = RAW_MATERIAL.instantiate()
	fake.is_fake = true      # 必须在 setup 之前：_apply 要读它来上色
	fake.setup(res)
	pressure.news_container.add_child(fake)
