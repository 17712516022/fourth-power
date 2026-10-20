class_name StabilityBar extends PanelContainer

# 稳定度那条 —— **0~12 的刻度写在场景里**（Scene/StabilityBar.tscn 的 Bar 节点）。

# 世界终结线：与 EndingData.STABILITY_LINE、政府崩溃线是同一个数。
const DANGER_LINE : float = 6.0
const DANGER_LINE_WIDTH : float = 2.0

@onready var _bar : TextureProgressBar = $MarginContainer/Bar
@onready var particle_texture_bar: Sprite2D = %ParticleTextureBar
@onready var danger_line : ColorRect = %DangerLine

func _ready() -> void:
	tooltip_text = Texts.PANEL_STABILITY_TOOLTIP
	# 布局是容器定的，_ready 这一刻宽度还没定稿：宽度一变就重算一次。
	_bar.resized.connect(_place_marker)
	_place_marker()

func refresh(stability : StabilityManager) -> void:
	if stability == null:
		return
	_bar.value = stability.value
	_place_marker()

# 标记压在**版条填充的前沿**上；终结线钉在刻度上，不随填充动。
func _place_marker() -> void:
	var start : Vector2 = _bar.global_position - global_position
	particle_texture_bar.position.x = start.x + _bar.size.x * (_bar.value / _bar.max_value)

	# 6.0 那条：压到这里，这一局就快到头了。
	if danger_line != null:
		danger_line.position = Vector2(_bar.size.x * (DANGER_LINE / _bar.max_value), 0.0)
		danger_line.size = Vector2(DANGER_LINE_WIDTH, _bar.size.y)
