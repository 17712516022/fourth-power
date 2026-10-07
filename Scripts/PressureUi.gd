class_name PressureUi extends Control

@onready var slot_container: Control = %SlotsContainer
@onready var decide_button: Button = $PanelContainer/DecideButton
@onready var news_container: HBoxContainer = %NewsContainer

# 只拖 RawMaterial。普通 TextureRect 身上没有 res，
# 拖过去也带不走"这是哪条新闻"这个信息。
var dragging_new : RawMaterial = null
var _origin_index : int = -1

func _ready() -> void:
	decide_button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	EventBus.paper_need_create.emit()

func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	
	var mouse : InputEventMouseButton = event as InputEventMouseButton
	
	if mouse.button_index == MOUSE_BUTTON_MIDDLE:
		return
	
	if mouse.button_index == MOUSE_BUTTON_LEFT: #左键拖拽
		if mouse.pressed:
			for i in news_container.get_children():
				if not (i is RawMaterial):
					continue
				var new : RawMaterial = i
				if new.get_global_rect().has_point(get_global_mouse_position()):
					drag(new)
					return
		else:
			if dragging_new != null:
				if not _drop(dragging_new):
					# 没放进版面，就退回素材池，而且回到它原来那一格
					dragging_new.reparent(news_container)
					news_container.move_child(dragging_new, _origin_index)
				dragging_new = null
	
	elif mouse.button_index == MOUSE_BUTTON_RIGHT and dragging_new == null: #右键查看
		for i in news_container.get_children():
				if not (i is RawMaterial):
					continue
				var new : RawMaterial = i
				if new.get_global_rect().has_point(get_global_mouse_position()):
					EventBus.need_show_detail.emit(new.res)
					return

func _process(_delta: float) -> void:
	if dragging_new == null :
		return
	dragging_new.global_position = get_global_mouse_position()

func drag(new : RawMaterial) -> void:
	_origin_index = new.get_index()
	new.reparent(self)
	dragging_new = new

# 版位本身也是 RawMaterial，它那个 res 就是"这一格排的是哪条新闻"。
# 所以放下这一步只要把 res 递过去——不用 metadata，也不用作任何节点替换。
func _drop(source : RawMaterial) -> bool:
	for i in slot_container.get_children():
		# 版面下挂的是版位（RawMaterialSlot），不是素材卡片（RawMaterial）。
		# 这两个类没有继承关系，用错了会一个版位都匹配不上。
		if not (i is RawMaterialSlot):
			continue
		var slot : RawMaterialSlot = i
		if slot.get_global_rect().has_point(get_global_mouse_position()):
			slot.setup(source.res)
			source.queue_free()          # 素材是用掉的，不是借的
			return true
	return false
