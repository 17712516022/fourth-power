class_name GovernmentMessagePopMenu extends PopMenuBase

# 政府来信弹窗 —— 把一封信摆出来。
# 只有一个"知道了"：好感不在这里动，它只在结账的时候动（见 GovernmentJudge.settle）。

enum Answer { ACK }

signal answered(answer : int)

@onready var rich_text_label: RichTextLabel = %GMPopRichTextLabel
@onready var refuse_button: Button = %GMPopRefuseButton
@onready var determine_button: Button = %GMPopDetermineButton

func _ready() -> void:
	super._ready()
	# "拒绝"那个键不用了：节点还留在场景里，一直按下去。
	refuse_button.visible = false
	determine_button.pressed.connect(_on_determine_pressed)

# 信是 {title, body, news, fake, type}，这里只吃 title 和 body。
func pop_show_message(msg : Dictionary) -> void:
	rich_text_label.text = Texts.POP_BODY % [
		String(msg.get("title", Texts.POP_TITLE_FALLBACK)),
		String(msg.get("body", "")),
	]
	# 字色由场景给（米白卡片上的墨色），这里不再用 modulate 碰它。
	refuse_button.visible = false
	determine_button.text = Texts.POP_ACK
	pop_show()

# 就这一个键：看完收起来。
func _on_determine_pressed() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	pop_hide()
	answered.emit(Answer.ACK)
