class_name RawMaterialDetail extends Panel

var res : NewsResource

# 现在这一张是从哪儿来的（EventBus.DETAIL_QUEUE / DETAIL_PREVIEW）。
var _source : int = EventBus.DETAIL_PREVIEW

@onready var raw_material_detail_label: Label = %RawMaterialDetailLabel
@onready var raw_material_detail_rich_text_label: RichTextLabel = %RawMaterialDetailRichTextLabel
@onready var raw_material_detail_texture_rect: TextureRect = %RawMaterialDetailTextureRect
@onready var iknow_button: Button = %IknowButton
@onready var is_fake_detail: Control = %IsFakeDetail

func _ready() -> void:
	is_fake_detail.hide()
	hide()
	# 场景里那个键的字已清空（唯一来源是 Texts）。
	iknow_button.text = Texts.RAW_IKNOW
	EventBus.need_show_detail.connect(_on_need_show)
	iknow_button.pressed.connect(_on_i_konw)

func _on_need_show(new_res : NewsResource, isfake : bool, source : int) -> void:
	if new_res == null:
		return
		# 队列里那一张**必须看完**，右键翻看不能把它顶掉。
	if visible and _source == EventBus.DETAIL_QUEUE:
		return
	_source = source
	# 大新闻队列那一声由工厂在弹之前放过（见 RawMaterialFactory._show_next_big），
	# 右键预览这条路没人配音，补在这儿。
	if source == EventBus.DETAIL_PREVIEW:
		AudioManager.play(AudioManager.Sound.DETAIL, -4.0)
	res = new_res
	raw_material_detail_label.text = res.headline
	raw_material_detail_rich_text_label.text = res.body
	raw_material_detail_texture_rect.texture = res.image
	is_fake_detail.visible = isfake
	show()

func _on_i_konw() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	hide()
	# 唯一的关闭入口就在这里，所以"看完了"只认这一个动作。
	EventBus.detail_closed.emit(_source)
