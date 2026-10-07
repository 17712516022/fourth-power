class_name RawMaterialDetail extends Panel

var res : NewsResource
@onready var raw_material_detail_label: Label = %RawMaterialDetailLabel
@onready var raw_material_detail_rich_text_label: RichTextLabel = %RawMaterialDetailRichTextLabel
@onready var raw_material_detail_texture_rect: TextureRect = %RawMaterialDetailTextureRect
@onready var iknow_button: Button = %IknowButton

func _ready() -> void:
	hide()
	EventBus.need_show_detail.connect(_on_need_show)
	iknow_button.pressed.connect(_on_i_konw)

func _on_need_show(new_res : NewsResource) -> void:
	if new_res == null:
		return
	res = new_res
	raw_material_detail_label.text = res.headline
	raw_material_detail_rich_text_label.text = res.body
	raw_material_detail_texture_rect.texture = res.image
	show()

func _on_i_konw() -> void:
	hide()
