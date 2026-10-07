class_name RawMaterial extends PanelContainer

var res : NewsResource
@onready var raw_material_texture_rect: TextureRect = %RawMaterialTextureRect
@onready var raw_material_label: Label = %RawMaterialLabel
@onready var is_fake_label: RichTextLabel = %IsFake
var is_fake : bool = false
var is_important : bool = false

const NORMAL_COLOR : Color = Color(1,1,1)
const BIG_NEW_COLOR : Color = Color(0.2,1,1)
const FAKE_NEW_COLOR : Color = Color(0.9,0.3,0.3)

func setup(p_res : NewsResource) -> void:
	res = p_res
	is_important = not res.is_filler
	if is_node_ready():
		_apply()
	else:
		ready.connect(_apply, CONNECT_ONE_SHOT)#CONNECT_ONE_SHOT连接后自动断开

func _apply() -> void:
	raw_material_texture_rect.texture = res.image if res != null else null
	raw_material_label.text = res.headline if res != null else ""
	
	is_fake_label.visible = is_fake
	# 一句话只能一个颜色：假的（红）最特殊，压过大新闻（青）。
	if is_fake:
		self_modulate = FAKE_NEW_COLOR
	elif is_important:
		self_modulate = BIG_NEW_COLOR
	else:
		self_modulate = NORMAL_COLOR
