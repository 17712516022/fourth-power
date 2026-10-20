class_name EndingPanel extends Control

# 终刊号：这一局最后印出来的那张头版。
# 过场还在跑的时候先等着——滚筒抬起来，它才压上来。

const START_MENU_SCENE : String = "res://Scene/start_menu.tscn"

@onready var masthead : Label = %Masthead
@onready var headline : Label = %Headline
@onready var body : RichTextLabel = %Body
@onready var world : RichTextLabel = %World
@onready var stats : RichTextLabel = %Stats
@onready var restart_button : Button = %RestartButton

# 过场正在跑：终刊号得等它抬完。
var _pass_running : bool = false


func _ready() -> void:
	hide()
	restart_button.text = Texts.ENDING_RESTART
	restart_button.pressed.connect(_on_restart_pressed)
	EventBus.paper_ready.connect(_on_paper_ready)
	EventBus.day_pass_finished.connect(_on_day_pass_finished)
	EventBus.ending_reached.connect(_on_ending_reached)


func _on_paper_ready(_newspaper : NewsPaper) -> void:
	_pass_running = true


func _on_day_pass_finished() -> void:
	_pass_running = false


func _on_ending_reached(id : int) -> void:
	# 这一天还在印：等滚筒抬起来再摊开，别把过场切成两半。
	if _pass_running:
		await EventBus.day_pass_finished
	_show(id)


func _show(id : int) -> void:
	masthead.text = Texts.ENDING_MASTHEAD % mini(EndingManager.day, EndingManager.TOTAL_DAYS)
	headline.text = EndingData.headline_of(id)
	body.text = EndingData.body_of(id, EndingManager.TOTAL_DAYS)

	# 无主之城 / 乡野新序 本身就是领地的结局：不再接领地段。
	var has_world : bool = EndingData.uses_world_end(id)
	world.visible = has_world
	world.text = EndingData.world_body_of(EndingManager.world_state()) if has_world else ""

	stats.text = EndingManager.stats_text()

	show()
	AudioManager.play(AudioManager.Sound.ENDING)
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.9)


func _on_restart_pressed() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	get_tree().change_scene_to_file(START_MENU_SCENE)
