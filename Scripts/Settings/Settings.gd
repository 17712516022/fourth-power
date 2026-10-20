extends Node

# 设置（自动加载，名就叫 Settings）。

# 为什么要有这么一个自动加载，而不是把音量写在设置面板里。
const CONFIG_PATH : String = "user://settings.cfg"
const SECTION_AUDIO : String = "audio"

# 三条总线的名字，硬编码：布局改了这里会当场喊出来（见 _apply），。
const BUS_MASTER : String = "Master"
const BUS_SFX : String = "SFX"
const BUS_MUSIC : String = "Music"

# 0.0 ~ 1.0。
var master_volume : float = 1.0 : set = _set_master_volume
var sfx_volume : float = 1.0 : set = _set_sfx_volume
var music_volume : float = 1.0 : set = _set_music_volume

func _ready() -> void:
	_load()

func _set_master_volume(v : float) -> void:
	master_volume = clampf(v, 0.0, 1.0)
	_apply(BUS_MASTER, master_volume)
	_save()

func _set_sfx_volume(v : float) -> void:
	sfx_volume = clampf(v, 0.0, 1.0)
	_apply(BUS_SFX, sfx_volume)
	_save()

func _set_music_volume(v : float) -> void:
	music_volume = clampf(v, 0.0, 1.0)
	_apply(BUS_MUSIC, music_volume)
	_save()

# 线性 0~1 -> 总线音量。
func _apply(bus_name : String, volume : float) -> void:
	var index : int = AudioServer.get_bus_index(bus_name)
	if index < 0:
		push_warning("找不到音频总线「%s」——检查 res://default_bus_layout.tres" % bus_name)
		return
	AudioServer.set_bus_mute(index, volume <= 0.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(volume, 0.0001)))

func _save() -> void:
	var config : ConfigFile = ConfigFile.new()
	config.set_value(SECTION_AUDIO, "master_volume", master_volume)
	config.set_value(SECTION_AUDIO, "sfx_volume", sfx_volume)
	config.set_value(SECTION_AUDIO, "music_volume", music_volume)
	config.save(CONFIG_PATH)

# 第一次进游戏时这个文件还不存在——那不是错误，就是默认值。
func _load() -> void:
	var config : ConfigFile = ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		_apply(BUS_MASTER, master_volume)
		_apply(BUS_SFX, sfx_volume)
		_apply(BUS_MUSIC, music_volume)
		return
	
	master_volume = float(config.get_value(SECTION_AUDIO, "master_volume", master_volume))
	sfx_volume = float(config.get_value(SECTION_AUDIO, "sfx_volume", sfx_volume))
	music_volume = float(config.get_value(SECTION_AUDIO, "music_volume", music_volume))
