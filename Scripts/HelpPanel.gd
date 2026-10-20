class_name HelpPanel extends Control

# 帮助：点右上角那枚问号翻开的**分区指引**。

@onready var close_button: TextureButton = %CloseButton

func _ready() -> void:
	hide()
	close_button.pressed.connect(_on_close_pressed)
	EventBus.need_open_help.connect(open)

func open() -> void:
	show()

func _on_close_pressed() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	hide()
