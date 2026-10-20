class_name RawMaterialSlot extends PanelContainer

# 版位：版面上固定的一格。
var res : NewsResource

# 这一格排的是不是假新闻。
var is_fake : bool = false

# 每一栏能装多少字，单位是**字**。

# 大版位 RawMaterialSlot.tscn（四栏）
const CAPACITY_LARGE : Array[int] = [220, 99, 99, 220]

# 小版位 RawMaterialSlotSmall.tscn（两栏）
const CAPACITY_SMALL : Array[int] = [117, 72]

# 认不出的栏数（以后再加版位）兜底：宁可少放字，也别看不见。
const CAPACITY_FALLBACK : int = 156

# 要单独改某一格的容量，在 Inspector 里填这里（留空 = 按上面的表自动取）。
@export var column_capacity : Array[int] = []

# 打字速度：每个字停留多久。
const CHAR_INTERVAL : float = 0.03

@onready var slot_texture : TextureRect = %SlotTexture
@onready var slot_columns: Control = %SlotColumns
@onready var title_slot_label: Label = %TitleSlotLabel

var _typing : bool = false
var _elapsed : float = 0.0
var _shown : int = 0
var _longest : int = 0

func _ready() -> void:
	# 默认不跑 _process。
	set_process(false)

func setup(p_res : NewsResource, p_fake : bool = false) -> void:
	res = p_res
	is_fake = p_fake
	if is_node_ready():
		_apply()
	else:
		ready.connect(_apply, CONNECT_ONE_SHOT)

# 内容
func _apply() -> void:
	if slot_texture != null:
		slot_texture.texture = res.image if res != null else null
	if slot_columns == null:
		return
	title_slot_label.text = res.headline if res != null else ""
	
	var parts : Array[String] = _split(res.body if res != null else "")
	var longest : int = 0
	for i in slot_columns.get_child_count():
		var label : Label = slot_columns.get_child(i) as Label
		label.text = parts[i] if i < parts.size() else ""
		longest = maxi(longest, label.text.length())
	
	# 重新开始打。
	_shown = 0
	_elapsed = 0.0
	_longest = longest
	_typing = longest > 0
	_refresh_visible()
	set_process(_typing)

# 这一格有哪几栏、每栏装多少字。
func _capacity() -> Array[int]:
	if not column_capacity.is_empty():
		return column_capacity
	var count : int = slot_columns.get_child_count()
	match count:
		2:
			return CAPACITY_SMALL
		4:
			return CAPACITY_LARGE
	push_warning("版位有 %d 栏，容量表里没有——先按每栏 %d 字算（要写准就再加一组常量）"
		% [count, CAPACITY_FALLBACK])
	var fallback : Array[int] = []
	fallback.resize(count)
	fallback.fill(CAPACITY_FALLBACK)
	return fallback

# 按容量切分。正文不够长就首尾相接循环着往下取，直到每栏都填满。
# 注意是**整条正文当一条循环串**切，不是每栏从头再来——接缝才落在栏中间，看不出重复。
func _split(body : String) -> Array[String]:
	var caps : Array[int] = _capacity()
	var parts : Array[String] = []
	var total : int = body.length()
	if total == 0:
		return parts
	
	var need : int = 0
	for cap in caps:
		need += cap
	
	# 拼成足够长的循环串；正文够长就原样用，超出的部分照旧丢掉。
	var looped : String = body
	while looped.length() < need:
		looped += body
	
	var at : int = 0
	for cap in caps:
		parts.append(looped.substr(at, cap))
		at += cap
	return parts

# 文本在 setup 时就**整段塞进 Label 了**，这里只改 visible_characters——。
func _process(delta : float) -> void:
	_elapsed += delta
	var want : int = int(_elapsed / CHAR_INTERVAL)
	if want <= _shown:
		return
	
	_shown = want
	_refresh_visible()
	
	if _shown >= _longest:
		_typing = false
		set_process(false)

func _refresh_visible() -> void:
	for i in slot_columns.get_child_count():
		var label : Label = slot_columns.get_child(i) as Label
		label.visible_characters = mini(_shown, label.text.length())
