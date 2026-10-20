class_name AlertDot extends Panel

# 一枚红点。

@export var key : String = ""
@export var blink_period : float = 0.6

@onready var _mark : Label = $Mark

var _tween : Tween = null

func _ready() -> void:
	hide()
	modulate.a = 1.0
	if key == "":
		return
		# 这里**不能写成 BadgeManager 的类型**（自动加载名不能出现在类型位置），。
	if BadgeManager != null:
		BadgeManager.bind(key, self)

# 由总账调用：on = 有没有未读；unread = 未读件数（用来决定显示 ! 还是数字）。
func set_state(on : bool, unread : int = 0) -> void:
	visible = on
	if not on:
		_stop_blink()
		return
	_mark.text = "!" if unread <= 1 else str(unread)
	_start_blink()

func _start_blink() -> void:
	_stop_blink()
	if blink_period <= 0.0:
		modulate.a = 1.0
		return
		# 不动的红点很容易被当成界面上的装饰，所以默认让它呼吸。
	_tween = create_tween().set_loops()
	_tween.tween_property(self, "modulate:a", 0.35, blink_period)
	_tween.tween_property(self, "modulate:a", 1.0, blink_period)

func _stop_blink() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
	modulate.a = 1.0
