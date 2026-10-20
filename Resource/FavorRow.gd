class_name FavorRow extends RichTextLabel

# 好感那一行 —— **一片叶子，不是面板的一部分**。

# 图标抽成常量只是因为路径长，换图标不用翻代码。
const ICON : String = "res://asserts/图标包/no-padding/64px/white/1-game/heart.png"

func _ready() -> void:
	EventBus.game_start.connect(refresh)
	EventBus.government_favor_changed.connect(refresh)
	refresh()

func refresh() -> void:
	text = Texts.PANEL_FAVOR % [ICON, _color().to_html(false), roundi(GovernmentFavor.favor)]

# 好感高低的颜色：和四家那五行同一套语义色（好话绿、警告橙、坏话红）。
func _color() -> Color:
	match GovernmentFavor.level():
		GovernmentFavor.LEVEL_HOSTILE:
			return UiColors.EXTREME
		GovernmentFavor.LEVEL_COLD:
			return UiColors.OPEN
		GovernmentFavor.LEVEL_WARM, GovernmentFavor.LEVEL_CLOSE:
			return UiColors.SAFE
	return UiColors.NORMAL
