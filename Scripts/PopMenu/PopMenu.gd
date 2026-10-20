class_name PopMenuBase extends Control

# 弹窗的共用壳子 —— 只管两件事：**藏起来**、**滑出来 / 滑回去**。

# 滑一趟多久。
const SLIDE_TIME : float = 0.25

# 收起来时停在屏幕上方多高的地方。
const PARK_ABOVE : float = 735.0

# 滑出、滑回各配一声纸：有动作就该有声，但压在按钮那声 CLICK 底下，别抢。
const POP_SHOW_DB : float = -5.0
const POP_HIDE_DB : float = -7.0

func _ready() -> void:
	hide()

# 滑到屏幕正中。
func pop_show() -> void:
	AudioManager.play(AudioManager.Sound.PICK_CARD, POP_SHOW_DB)
	show()
	var center : Vector2 = get_viewport_rect().size * 0.5
	position = Vector2(center.x, -PARK_ABOVE)
	var tween : Tween = create_tween()
	tween.tween_property(self, "position", center, SLIDE_TIME)

# 滑回屏幕上方外，到了才 hide。
func pop_hide() -> void:
	AudioManager.play(AudioManager.Sound.RETURN_CARD, POP_HIDE_DB)
	var center_x : float = get_viewport_rect().size.x * 0.5
	var tween : Tween = create_tween()
	tween.tween_property(self, "position", Vector2(center_x, -PARK_ABOVE), SLIDE_TIME)
	await tween.finished
	hide()
