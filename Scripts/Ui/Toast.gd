class_name Toast extends Control

# 一句话的提示：淡进来、停一会儿、淡出去。
# 单独做成场景，是为了用的人只管调一行 pop()，不用管怎么淡、摆在哪。

const HOLD : float = 1.15
const FADE : float = 0.26

@onready var message : Label = %Message

var _tween : Tween = null


func _ready() -> void:
	# 平时完全透明：站着不占视觉（场景里 mouse_filter 已经是 IGNORE，也不吃鼠标）。
	modulate.a = 0.0


# 换一句话再冒一次。连点同一个提示就从这一次重新计时，不会叠出两层。
func pop(text : String) -> void:
	message.text = text
	if _tween != null and _tween.is_valid():
		_tween.kill()
	modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, FADE)
	_tween.tween_interval(HOLD)
	_tween.tween_property(self, "modulate:a", 0.0, FADE)
