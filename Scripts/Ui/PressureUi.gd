class_name PressureUi extends Control

# 把素材退回池子时要新做一张卡片。
const RAW_MATERIAL = preload("res://Scene/RawMaterial.tscn")

@onready var slot_container: Control = %SlotsContainer
@onready var decide_button: Button = $PanelContainer/DecideButton
@onready var news_container: HBoxContainer = %NewsContainer

# 只拖 RawMaterial。
var dragging_new : RawMaterial = null
var _origin_index : int = -1

# 光标现在压着的那张素材卡（没有就是 null）。
var _hovered : RawMaterial = null

func _ready() -> void:
	decide_button.pressed.connect(_on_button_pressed)
	EventBus.day_passed.connect(_on_day_passed)
	EventBus.detail_closed.connect(_on_detail_closed)
	# 开局先把版位清一遍（见 _clear_slots）。
	EventBus.game_start.connect(_clear_slots)
	# 开局先把键摆成"还缺版面"的样子：_process 第一帧也会调到，。
	_refresh_decide_button()

func _on_button_pressed() -> void:
	# 禁用的按钮根本发不出 pressed，这里是兜底：键盘 / 手柄的"确认"
	if not _slots_filled():
		return
	AudioManager.play(AudioManager.Sound.CLICK)
	EventBus.paper_need_create.emit()

# 版面填满了吗

# 五个版位全排上了才算一份完整的报纸。
func _slots_filled() -> bool:
	for i in slot_container.get_children():
		if not (i is RawMaterialSlot):
			continue
		var slot : RawMaterialSlot = i
		if not slot.visible:
			continue
		if slot.res == null:
			return false
	return true

# 决定键的亮灭。
func _refresh_decide_button() -> void:
	var want_disabled : bool = not _slots_filled()
	if decide_button.disabled == want_disabled:
		return
	decide_button.disabled = want_disabled

# 卡片和版位都不是 1:1 显示的（身上有缩放），而 get_global_rect() **不乘缩放。
func _visual_rect(c : Control) -> Rect2:
	return c.get_global_transform() * Rect2(Vector2.ZERO, c.size)

func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	
	var mouse : InputEventMouseButton = event as InputEventMouseButton
	
	if mouse.button_index == MOUSE_BUTTON_MIDDLE:
		return
	
	# 光标底下那张卡。
	var card : RawMaterial = _card_under_mouse()
	
	if mouse.button_index == MOUSE_BUTTON_LEFT:
		if mouse.pressed:
			if card != null:
				drag(card)
		elif dragging_new != null:
			if not _drop(dragging_new):
				# 没放进版面，就退回素材池，而且回到它原来那一格。
				AudioManager.play(AudioManager.Sound.RETURN_CARD)
				dragging_new.reparent(news_container)
				news_container.move_child(dragging_new, _origin_index)
			dragging_new = null
	
	elif mouse.button_index == MOUSE_BUTTON_RIGHT and dragging_new == null:
		if card != null:
			# 翻看一条素材：小动作，给一声轻的就行。
			AudioManager.play(AudioManager.Sound.CLICK)
			EventBus.need_show_detail.emit(card.res, card.is_fake, EventBus.DETAIL_PREVIEW)

func _process(_delta: float) -> void:
	# 版面（版位）的账每帧对一次——手上拖着卡的那几帧也算，。
	_refresh_decide_button()

	if dragging_new != null:
		dragging_new.global_position = get_global_mouse_position()
		# 手上拖着卡的时候不弹悬停面板：纸已经在光标底下了，再糊一块上去只会挡着看。
		_set_hovered(null)
		return
	_set_hovered(_card_under_mouse())

# 光标底下是哪张素材卡（没有就是 null）。
func _card_under_mouse() -> RawMaterial:
	# 别的东西盖住池子的时候不算悬停（假新闻列表、设置、弹窗、详情面板、过天黑幕）
	var over : Control = get_viewport().gui_get_hovered_control()
	if over != null and over != self and not is_ancestor_of(over):
		return null

	var at : Vector2 = get_global_mouse_position()
	for i in news_container.get_children():
		if not (i is RawMaterial):
			continue
		var card : RawMaterial = i
		if _visual_rect(card).has_point(at):
			return card
	return null

# 悬停的那张变了才发信号——鼠标每帧都在动，不拦一下就是每帧一条信号。
func _set_hovered(card : RawMaterial) -> void:
	if card == _hovered:
		return
	_hovered = card
	EventBus.hover_on_news.emit(card.res if card != null else null, card != null)

# 详情面板刚关掉：把悬停状态清掉，下一帧重新判一次。
func _on_detail_closed(_source : int) -> void:
	_hovered = null

func drag(new : RawMaterial) -> void:
	# 从池子里抽起一张纸。
	AudioManager.play(AudioManager.Sound.PICK_CARD)
	_origin_index = new.get_index()
	new.reparent(self)
	dragging_new = new

# 版位本身也是 RawMaterial，它那个 res 就是"这一格排的是哪条新闻"。
func _drop(source : RawMaterial) -> bool:
	for i in slot_container.get_children():
		# 版面下挂的是版位（RawMaterialSlot），不是素材卡片（RawMaterial）。
		if not (i is RawMaterialSlot):
			continue
		var slot : RawMaterialSlot = i
		# 藏起来的版位**不接卡**，判据要和 _slots_filled() 保持一致。
		if not slot.visible:
			continue
		if not _visual_rect(slot).has_point(get_global_mouse_position()):
			continue
		
		# 这一格已经排着东西了：把里面那条**换下来**，退回素材池。
		if slot.res != null:
			_return_to_pool(slot)
		
		# 贴上版面：一声"啪"（贴上去的那一下）。
		AudioManager.play(AudioManager.Sound.PLACE_CARD)
		slot.setup(source.res, source.is_fake)
		source.queue_free()
		return true
	return false

# 把版位上排着的那条素材还给素材池（换下来）。
func _return_to_pool(slot : RawMaterialSlot) -> void:
	# 被换下来的那张，在飞去池子的路上就该有声音——不然它像是凭空飘走的。
	AudioManager.play(AudioManager.Sound.RETURN_CARD)
	var card : RawMaterial = RAW_MATERIAL.instantiate()
	card.is_fake = slot.is_fake
	card.setup(slot.res)
	news_container.add_child(card)
	# 原来的位置可能已经超出现在的长度（拖走一张，后面那些都往前挪了），夹紧。
	if news_container.get_child_count() > 1:
		news_container.move_child(card, clampi(_origin_index, 0, news_container.get_child_count() - 1))
	
	RawMaterialAnimation.play_back(card, news_container,
		_visual_rect(slot).get_center(), slot.get_global_transform().get_scale())

# 清空前一天的版面。
func _on_day_passed(_newspaper : NewsPaper) -> void:
	# 手上还拖着的那张卡不属于任何一天：直接丢掉。
	if dragging_new != null:
		dragging_new.queue_free()
		dragging_new = null
	
	_clear_slots()

# 把五个版位全部清空（setup(null)）。
func _clear_slots() -> void:
	for i in slot_container.get_children() :
		# 版面下挂的是版位（RawMaterialSlot），不是素材卡片（RawMaterial）。
		if not (i is RawMaterialSlot):
			continue
		var slot : RawMaterialSlot = i
		slot.setup(null , false)
