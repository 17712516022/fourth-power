class_name SettingsPanel extends Panel

# 设置面板：三个音量（主 / 音效 / 音乐）、回主菜单、退出。
const START_MENU_SCENE : String = "res://Scene/start_menu.tscn"

# 拖音效滑块时的采样间隔：太密会糊成一片，太疏又听不出变化。
const TICK_GAP : float = 0.12

# 上一次采样是什么时候（秒）。
var _tick_at : float = -1.0

@onready var master_slider: HSlider = %MasterSlider
@onready var master_value: Label = %MasterValue
@onready var sfx_slider: HSlider = %SfxSlider
@onready var sfx_value: Label = %SfxValue
@onready var music_slider: HSlider = %MusicSlider
@onready var music_value: Label = %MusicValue
@onready var back_button: Button = %BackButton
@onready var quit_button: Button = %QuitButton
@onready var return_button: Button = %ReturnButton

# 这四条在场景里是写空的，唯一来源是 Texts（见 _ready）。
@onready var setting_title: Label = $PanelContainer/MarginContainer/VBoxContainer/TitlePanel/SettingTitle
@onready var master_name: Label = $PanelContainer/MarginContainer/VBoxContainer/TextPanel/MarginContainer/VolumeList/MasterRow/MasterName
@onready var sfx_name: Label = $PanelContainer/MarginContainer/VBoxContainer/TextPanel/MarginContainer/VolumeList/SfxRow/SfxName
@onready var music_name: Label = $PanelContainer/MarginContainer/VBoxContainer/TextPanel/MarginContainer/VolumeList/MusicRow/MusicName

func _ready() -> void:
	hide()
	# 场景里的字已经清空（唯一来源是 Texts）：标题、三个滑块名、三个按钮在这儿补上。
	setting_title.text = Texts.SET_TITLE
	master_name.text = Texts.SET_MASTER
	sfx_name.text = Texts.SET_SFX
	music_name.text = Texts.SET_MUSIC
	back_button.text = Texts.SET_BACK_MENU
	quit_button.text = Texts.SET_QUIT
	return_button.text = Texts.SET_BACK_GAME

	back_button.pressed.connect(_on_back_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	return_button.pressed.connect(_on_return_button_pressed)
	master_slider.value_changed.connect(_on_master_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	music_slider.value_changed.connect(_on_music_changed)
	EventBus.need_open_settings.connect(open)

func open() -> void:
	_sync_sliders()
	show()

# 把滑块摆到 Settings 现在的值上。
func _sync_sliders() -> void:
	master_slider.set_value_no_signal(Settings.master_volume * 100.0)
	sfx_slider.set_value_no_signal(Settings.sfx_volume * 100.0)
	music_slider.set_value_no_signal(Settings.music_volume * 100.0)
	_refresh_values()

func _on_master_changed(v : float) -> void:
	Settings.master_volume = v / 100.0
	_refresh_values()

func _on_sfx_changed(v : float) -> void:
	Settings.sfx_volume = v / 100.0
	_refresh_values()
	_preview_sfx()

# 拖音效滑块时给一声采样：听到的就是这个位置上的大小。
# 这一刻总线音量已经改过了，所以这里不再叠自己的 db。
func _preview_sfx() -> void:
	var now : float = Time.get_ticks_msec() / 1000.0
	if now - _tick_at < TICK_GAP:
		return
	_tick_at = now
	AudioManager.play(AudioManager.Sound.CLICK)

func _on_music_changed(v : float) -> void:
	Settings.music_volume = v / 100.0
	_refresh_values()

func _refresh_values() -> void:
	master_value.text = "%d%%" % roundi(master_slider.value)
	sfx_value.text = "%d%%" % roundi(sfx_slider.value)
	music_value.text = "%d%%" % roundi(music_slider.value)

# 回开始菜单＝重开一局：游戏本体那个场景整个被换掉，下一局从第一天重来。
func _on_back_pressed() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	get_tree().change_scene_to_file(START_MENU_SCENE)

func _on_quit_pressed() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	get_tree().quit()

func _on_return_button_pressed() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	self.hide()
