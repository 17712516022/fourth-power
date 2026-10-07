class_name RawMaterialSlot extends PanelContainer

# 版位：版面上固定的一格。
var res : NewsResource

# 四栏各自的容量，单位是**字**。
const COLUMN_CAPACITY : Array[int] = [312, 156, 156, 312]

# 打字速度：每个字停留多久。
const CHAR_INTERVAL : float = 0.03

@onready var slot_texture : TextureRect = %SlotTexture
@onready var slot_columns: Control = %SlotColumns

var _typing : bool = false
var _elapsed : float = 0.0
var _shown : int = 0        # 已经打出多少个字
var _longest : int = 0      # 最长那一栏有多少字——打到它满就算完

func _ready() -> void:
	# 默认不跑 _process。没东西可打的时候，每帧空转很浪费。
	set_process(false)

func setup(p_res : NewsResource) -> void:
	res = p_res
	if is_node_ready():
		_apply()
	else:
		ready.connect(_apply, CONNECT_ONE_SHOT)

# 外面的界面在动手之前可以问一句"写完了没"。
func is_typing() -> bool:
	return _typing

#  内容
func _apply() -> void:
	if slot_texture != null:
		slot_texture.texture = res.image if res != null else null
	if slot_columns == null:
		return
	
	var parts : Array[String] = _split(res.body if res != null else "")
	var longest : int = 0
	for i in slot_columns.get_child_count():
		var label : Label = slot_columns.get_child(i) as Label
		label.text = parts[i] if i < parts.size() else ""
		longest = maxi(longest, label.text.length())
	
	# 重新开始打。四栏都从空白起。
	_shown = 0
	_elapsed = 0.0
	_longest = longest
	_typing = longest > 0
	_refresh_visible()
	set_process(_typing)

# 按 COLUMN_CAPACITY 切分。
# 顺序填：第一栏装满就进第二栏，装满再进第三栏……
# 四栏都满了还有剩，剩下的就不要了——这就是"截断"。
func _split(body : String) -> Array[String]:
	var parts : Array[String] = []
	var at : int = 0
	var total : int = body.length()
	for cap in COLUMN_CAPACITY:
		if at >= total:
			break
		var end : int = mini(at + cap, total)
		parts.append(body.substr(at, end - at))
		at = end
	return parts

# 文本在 setup 时就**整段塞进 Label 了**，这里只改 visible_characters——
# 也就是"已经写进去，但先露出来几个字"。
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
