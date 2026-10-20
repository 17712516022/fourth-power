class_name FakeNewsList extends PanelContainer

# 大新闻档案：每条大新闻（is_filler == false）第一次出现时，在这里留一份底。

const RAW_MATERIAL = preload("res://Scene/RawMaterial.tscn")

@onready var panel: HFlowContainer = %Panel
@onready var close_fake_new: TextureButton = %CloseFakeNew

# 已记录的事件（NewsData.NewsType 的序号 -> 那条素材的 .tres 路径）。
var _recorded : Dictionary = {}

func _ready() -> void:
	clear()
	hide()
	close_fake_new.pressed.connect(_on_close_fake_new)
	EventBus.big_news_appeared.connect(_on_big_news_appeared)
	EventBus.need_open_fake_list.connect(open)

# 谁想翻这块档案，发一声就行——不用认识本面板。
func open() -> void:
	show()

func clear() -> void:
	_recorded.clear()
	for i in panel.get_children():
		i.queue_free()

func _on_big_news_appeared(res : NewsResource, event : int) -> void:
	if _recorded.has(event):
		return
	_recorded[event] = res.resource_path if res != null else ""
	_add_card(res)

# 存档

# 档案不是"今天的事"，是这一局攒下的底：没出现过的事，编不了假新闻。
func snapshot() -> Dictionary:
	var out : Dictionary = {}
	for event in _recorded:
		out[str(event)] = str(_recorded[event])
	return out

func restore(data : Dictionary) -> void:
	clear()
	for k in data:
		var event : int = int(k)
		var path : String = String(data[k])
		var res : NewsResource = null
		if path != "" and ResourceLoader.exists(path):
			res = load(path) as NewsResource
		if res == null:
			res = NewsData.pick(event)
		if res == null:
			continue
		_recorded[event] = res.resource_path
		_add_card(res)

func _add_card(res : NewsResource) -> void:
	var item : RawMaterial = RAW_MATERIAL.instantiate()
	item.setup(res)
	panel.add_child(item)

func _on_close_fake_new() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	hide()

# 卡片有缩放，而 get_global_rect() 不乘缩放——按变换推"看得见的那块"。
func _visual_rect(c : Control) -> Rect2:
	return c.get_global_transform() * Rect2(Vector2.ZERO, c.size)

func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	
	var mouse : InputEventMouseButton = event as InputEventMouseButton
	
	if mouse.button_index != MOUSE_BUTTON_LEFT:
		return
	
	if mouse.pressed:
		for i in panel.get_children():
			if not (i is RawMaterial):
				continue
			var raw : RawMaterial = i
			if _visual_rect(raw).has_point(get_global_mouse_position()):
				# 信号上带的是**那条新闻**（NewsResource），不是这张卡片。
				if raw.res == null:
					continue
				AudioManager.play(AudioManager.Sound.CLICK)
				EventBus.need_show_popmenu.emit(raw.res)
