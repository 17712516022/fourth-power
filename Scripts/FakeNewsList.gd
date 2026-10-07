class_name FakeNewsList extends PanelContainer

# 大新闻档案：每条大新闻（is_filler == false）第一次出现时，在这里留一份底。
# 以后玩家做假新闻，只能从这里面挑——没出现过的事，编不了。

const RAW_MATERIAL = preload("res://Scene/RawMaterial.tscn")

@onready var panel: HFlowContainer = %Panel
@onready var close_fake_new: TextureButton = %CloseFakeNew

# 点中了档案里哪条素材，把它带出去——弹窗、Ui 需要知道是谁在"被做假"。
signal pop_menu_need(raw : RawMaterial)

# 已记录的事件（NewsData.NewsType 的序号）。值暂时没用到，存 true。
var _recorded : Dictionary = {}

func _ready() -> void:
	clear()
	hide()
	close_fake_new.pressed.connect(_on_close_fake_new)
	EventBus.big_news_appeared.connect(_on_big_news_appeared)

func clear() -> void:
	_recorded.clear()
	for i in panel.get_children():
		i.queue_free()

func _on_big_news_appeared(res : NewsResource, event : int) -> void:
	if _recorded.has(event):
		return
	_recorded[event] = true
	
	var item : RawMaterial = RAW_MATERIAL.instantiate()
	item.setup(res)   # is_filler == false → is_important → 青色
	panel.add_child(item)

func _on_close_fake_new() -> void:
	hide()

func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	
	var mouse : InputEventMouseButton = event as InputEventMouseButton
	
	if mouse.button_index != MOUSE_BUTTON_LEFT:
		return
	
	if mouse.pressed:
		for i in panel.get_children():
			var raw : RawMaterial = i
			# get_global_rect：get_rect 是相对父节点的局部矩形，
			# 拿它对全局鼠标坐标，面板一挪就全对不上。
			if raw.get_global_rect().has_point(get_global_mouse_position()):
				pop_menu_need.emit(raw)
