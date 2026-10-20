extends Node

# 声音（自动加载，名就叫 AudioManager）。

enum Sound {
	CLICK,
	PICK_CARD,
	PLACE_CARD,
	RETURN_CARD,
	DETAIL,
	DAY_PASS,
	ROLLER_DOWN,
	ROLLER_UP,
	CARD_APPEAR,
	SETTLE_GOOD,
	SETTLE_BAD,
	FAKE_NEWS,
	REFUSE,
	ENDING,
}

# 预加载：开局前就把这几条装好，第一次播不会卡一下。
const SFX_MAP : Dictionary = {
	Sound.CLICK       : preload("res://asserts/音效包/Other/finger_click.wav"),
	Sound.PICK_CARD   : preload("res://asserts/音效包/Materials/paper_move.wav"),
	Sound.PLACE_CARD  : preload("res://asserts/音效包/Other/paste.wav"),
	Sound.RETURN_CARD : preload("res://asserts/音效包/Materials/paper_sort.wav"),
	Sound.DETAIL      : preload("res://asserts/音效包/Musical Effects/harpsichord_chime_quick.wav"),
	Sound.DAY_PASS    : preload("res://asserts/音效包/Items/page_turn.wav"),
	Sound.ROLLER_DOWN : preload("res://asserts/音效包/Machines/hydraulic_down.wav"),
	Sound.ROLLER_UP   : preload("res://asserts/音效包/Machines/hydraulic_up.wav"),
	Sound.CARD_APPEAR : preload("res://asserts/音效包/Card and Board/card_draw_1.wav"),
	# 过场里"四个群体各说一句"的那 20 条人声**不在这张表里**：它们是。
	Sound.SETTLE_GOOD : preload("res://asserts/音效包/Musical Effects/harpsichord_chime_positive.wav"),
	Sound.SETTLE_BAD  : preload("res://asserts/音效包/Musical Effects/harpsichord_negative.wav"),
	Sound.FAKE_NEWS   : preload("res://asserts/音效包/Items/pencil_scribble.wav"),
	Sound.REFUSE      : preload("res://asserts/音效包/Materials/paper_scrunch.wav"),
	Sound.ENDING      : preload("res://asserts/音效包/Musical Effects/harpsichord_level_complete.wav"),
}

# 同时最多响几个。
const CHANNELS : int = 16

# 音效走哪条总线。
const BUS : String = "SFX"

# 音乐**单独一条总线**：界面上"音效"滑块一拉到底，音乐照样在响。
const BUS_MUSIC : String = "Music"

# 背景音乐：局内一首，菜单一首，换场景时换曲。
const MUSIC_PATH : String = "res://audio/Clockwork Lullaby.ogg"
const MENU_MUSIC_PATH : String = "res://audio/The Pressman's Lament.mp3"

# 比音效轻一档：过场里有液压、翻页、纸张和一整片人声，得给它们让路。
const MUSIC_DB : float = -8.0

var _players : Array[AudioStreamPlayer] = []
var _music : AudioStreamPlayer = null
var _music_path : String = ""
var _music_fade : Tween = null

func _ready() -> void:
	for i in CHANNELS:
		var player : AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = BUS
		add_child(player)
		_players.append(player)

	_music = AudioStreamPlayer.new()
	_music.bus = BUS_MUSIC
	add_child(_music)
	# 不在这里自动起播：菜单和局内是两首曲子，由各自的场景点名要哪一首。

# 起播或换曲。同一首正在响就直接返回，切场景时不会从头再来。
func play_music(path : String = MUSIC_PATH) -> void:
	if path == _music_path and _music.playing:
		return
	var stream : AudioStream = load(path)
	if stream == null:
		push_warning("找不到背景音乐：%s（Godot 扫一遍资源、导入之后就好了）" % path)
		return
	_music_path = path
	_music.stop()
	_music.stream = _looped(stream)
	# 从很轻的地方淡进来，换曲时不至于"啪"一下。
	_music.volume_db = MUSIC_DB - 30.0
	_music.play()
	_fade_music(MUSIC_DB, 0.7)

# 淡到某个音量。
func _fade_music(to_db : float, time : float) -> void:
	if _music_fade != null and _music_fade.is_valid():
		_music_fade.kill()
	_music_fade = create_tween()
	_music_fade.tween_property(_music, "volume_db", to_db, time)

# 把 loop 打开。
func _looped(stream : AudioStream) -> AudioStream:
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	return stream

# 放一条声音。
func play(sound : Sound, volume_db : float = 0.0, pitch_scale : float = 1.0) -> void:
	var player : AudioStreamPlayer = _take_player()
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.stream = SFX_MAP[sound]
	player.play()

# 放一条**不在 SFX_MAP 里**的声音（比如过场里那张"人群"表：四家各一句，。
func play_stream(stream : AudioStream, volume_db : float = 0.0, pitch_scale : float = 1.0) -> void:
	var player : AudioStreamPlayer = _take_player()
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.stream = stream
	player.play()

# 把某一条正在响的声音掐掉。
func stop_stream(stream : AudioStream) -> void:
	for player in _players:
		if player.playing and player.stream == stream:
			player.stop()

# 要一只播放器：先找空闲的。
func _take_player() -> AudioStreamPlayer:
	for player in _players:
		if not player.playing:
			return player
	
	var oldest : AudioStreamPlayer = _players[0]
	for player in _players:
		if player.get_playback_position() > oldest.get_playback_position():
			oldest = player
	oldest.stop()
	return oldest
