class_name DayPassAnimation extends Control

# 过天的过场：印刷机的墨滚筒压过去，中段把今天这份报纸**一条一条**摆出来。

const ROLL_DOWN : float = 0.50
const ROLL_UP   : float = 0.50

# 每条新闻在卡上的停留：淡入 + 停 + 淡出 = 一条的总时长。
const CARD_FADE : float = 0.20
const CARD_HOLD : float = 0.80

# 每摆出一条新闻响一下（抽牌声）。
const CARD_SOUND_STEP : float = 0.04
const CARD_SOUND_MAX : float = 0.24
# 这声"纸"压在下面当垫底，人声在上面说话（-80 就等于关掉它）。
const CARD_TICK_DB : float = -6.0

# 人群反应：报纸摆到哪一条，被写到的那家就开口；每家最多两条，前后错开。
const VOICE_DELAY : Array[float] = [0.00, 0.06, 0.12]

# 同时说的人多，单条压一点，合起来才不会顶到爆。
const CROWD_DB : float = -5.0

# 人声按情绪分池：原来的 32 条混合池按目录拆开——同一句话不该在"怒"和"怕"里都出现。
# 配音包的目录本来就是情绪（1 Completion / 2 Confirmation / 3 Greeting /
# 5 Refusal / 7 Damage / 9 Grunting）。
# 10 - Shouting **整类不用**：那几条一开口就是一声大叫，会把过场压掉。
const VOICE_BY_MOOD : Dictionary = {
	# 称心、答应（2 - Confirmation + 1 - Completion）
	"happy" : [
		preload("res://asserts/语音包/2 - Confirmation/Female/Karen Cenon/confirmation_7_karen.wav"),
		preload("res://asserts/语音包/2 - Confirmation/Female/Karen Cenon/confirmation_9_karen.wav"),
		preload("res://asserts/语音包/2 - Confirmation/Female/Karen Cenon/confirmation_8_karen.wav"),
		preload("res://asserts/语音包/2 - Confirmation/Male/Alex Brodie/confirmation_8_alex.wav"),
		preload("res://asserts/语音包/2 - Confirmation/Male/Ian Lampert/confirmation_8_ian.wav"),
		preload("res://asserts/语音包/2 - Confirmation/Male/Ian Lampert/confirmation_5_ian.wav"),
		preload("res://asserts/语音包/1 - Completion/Female/Karen Cenon/completion_3_karen.wav"),
		preload("res://asserts/语音包/1 - Completion/Female/Meghan Christian/completion_2_meghan.wav"),
		preload("res://asserts/语音包/1 - Completion/Male/Alex Brodie/completion_4_alex.wav"),
		preload("res://asserts/语音包/1 - Completion/Male/Sean Lenhart/completion_6_sean.wav"),
	],
	# 上火、要闹（5 - Refusal）
	"angry" : [
		preload("res://asserts/语音包/5 - Refusal/Male/Alex Brodie/refusal_9_alex.wav"),
		preload("res://asserts/语音包/5 - Refusal/Male/Alex Brodie/refusal_7_alex.wav"),
		preload("res://asserts/语音包/5 - Refusal/Male/Sean Lenhart/refusal_9_sean.wav"),
		preload("res://asserts/语音包/5 - Refusal/Male/Sean Lenhart/refusal_7_sean.wav"),
		preload("res://asserts/语音包/5 - Refusal/Male/Ian Lampert/refusal_5_ian.wav"),
		preload("res://asserts/语音包/5 - Refusal/Male/Ian Lampert/refusal_7_ian.wav"),
		preload("res://asserts/语音包/5 - Refusal/Female/Karen Cenon/refusal_4_karen.wav"),
		preload("res://asserts/语音包/5 - Refusal/Female/Karen Cenon/refusal_9_karen.wav"),
	],
	# 发怵（7 - Damage + 9 - Grunting）
	"fear" : [
		preload("res://asserts/语音包/7 - Damage/Male/Sean Lenhart/damage_7_sean.wav"),
		preload("res://asserts/语音包/7 - Damage/Male/Sean Lenhart/damage_9_sean.wav"),
		preload("res://asserts/语音包/7 - Damage/Male/Ian Lampert/damage_6_ian.wav"),
		preload("res://asserts/语音包/7 - Damage/Male/Alex Brodie/damage_5_alex.wav"),
		preload("res://asserts/语音包/7 - Damage/Female/Karen Cenon/damage_7_karen.wav"),
		preload("res://asserts/语音包/9 - Grunting/Male/Ian Lampert/grunting_9_ian.wav"),
		preload("res://asserts/语音包/9 - Grunting/Male/Alex Brodie/grunting_10_alex.wav"),
		preload("res://asserts/语音包/9 - Grunting/Male/Sean Lenhart/grunting_3_sean.wav"),
	],
	# 来劲、叫好（3 - Greeting + 1 - Completion）
	"power" : [
		preload("res://asserts/语音包/3 - Greeting/Male/Alex Brodie/greeting_1_alex.wav"),
		preload("res://asserts/语音包/3 - Greeting/Male/Ian Lampert/greeting_3_ian.wav"),
		preload("res://asserts/语音包/3 - Greeting/Female/Karen Cenon/greeting_5_karen.wav"),
		preload("res://asserts/语音包/3 - Greeting/Female/Meghan Christian/greeting_2_meghan.wav"),
		preload("res://asserts/语音包/1 - Completion/Male/Alex Brodie/completion_8_alex.wav"),
		preload("res://asserts/语音包/1 - Completion/Female/Karen Cenon/completion_5_karen.wav"),
		preload("res://asserts/语音包/1 - Completion/Male/Sean Lenhart/completion_7_sean.wav"),
	],
	# 丧气（9 - Grunting + 7 - Damage）
	"sad" : [
		preload("res://asserts/语音包/9 - Grunting/Male/Alex Brodie/grunting_6_alex.wav"),
		preload("res://asserts/语音包/9 - Grunting/Male/Alex Brodie/grunting_4_alex.wav"),
		preload("res://asserts/语音包/9 - Grunting/Male/Ian Lampert/grunting_7_ian.wav"),
		preload("res://asserts/语音包/9 - Grunting/Male/Ian Lampert/grunting_4_ian.wav"),
		preload("res://asserts/语音包/9 - Grunting/Male/Sean Lenhart/grunting_10_sean.wav"),
		preload("res://asserts/语音包/7 - Damage/Male/Sean Lenhart/damage_10_sean.wav"),
	],
}

# 四家的嗓音：士兵压低、商人偏高。
# 顺序跟场景里剪影的摆放顺序一致（农民 · 工人 · 士兵 · 商人）。
const VOICE_PITCH : Array[float] = [1.00, 0.96, 0.88, 1.05]

# 剪影高亮：贴图是纯黑，modulate 只能压暗提不亮，只能靠 shader 换色
# （见 shaders/silhouette_flash.gdshader）。
const FLASH_SHADER : Shader = preload("res://shaders/silhouette_flash.gdshader")

# 假新闻的低频杂音：白噪声压低、降速，垫在人声下面当"不对劲"的底。
const FAKE_NOISE : AudioStream = preload("res://asserts/音效包/Other/white_noise_short.wav")
const FAKE_NOISE_DB : float = -16.0
const FAKE_NOISE_PITCH : float = 0.55

# "变天"横幅用项目自己的字体主题；最多四家 + 领地各一行。
const BANNER_THEME : Theme = preload("res://theme/font.tres")
const BANNER_LINES : int = 5

# 摆出来的这份报纸**要不要标出假新闻**。
const SHOW_FAKE_IN_CARD : bool = true

# 表面滚一格（64 px）用多久。
const SPIN_PERIOD : float = 0.71

# 城景各层的漂移：越靠前的层动得越明显，越远越接近静止。
const DRIFT_FAR : float = 1.5
const DRIFT_NEAR : float = 6.0
const DRIFT_PERIOD_FAR : float = 19.0
const DRIFT_PERIOD_NEAR : float = 9.0

# 四家站着的时候不是雕塑：各自轻微起伏。
const BREATHE_PERIOD : float = 3.2
const BREATHE_AMP : float = 2.0

# 滚筒压到底那一下，整块画面往下沉的幅度。
const THUMP_DROP : float = 7.0

# 墨 = 这个容器**裁出来的一条**（里面叠着新一天的那张底，见 _setup_layers）。
@onready var back_grond: Control = %BackGrond
@onready var _roller : Control = %Roller
@onready var _surface : TextureRect = %Surface
@onready var _shadow : TextureRect = %Shadow
@onready var _blocker : Control = %Blocker
@onready var _card : RawMaterial = %RawMaterialPreView
# 四家头顶的粒子发射器（脚本挂在 Silhouettes 上，见 EmojiParticles.gd）。
@onready var _emoji : EmojiParticles = _roller.get_node_or_null("Silhouettes")

# 今天这份报纸：排完版就交到这里，等墨铺满了再替它交给世界。
var _paper : NewsPaper = null
# 正在跑的时间线。
var _tween : Tween = null
var _spin : Tween = null
var _height : float = 648.0
# 滚筒多高、阴影多高：从场景里量，不是常量（见文件头）。
var _roller_h : float = 190.0
var _shadow_h : float = 32.0
# 这一场里放过的所有人声。
var _played : Array[AudioStream] = []

# 反应：每个剪影各一份（下标 = 场景里剪影的摆放顺序）。
# 群体枚举 → 剪影下标，由 _collect_silhouettes 按摆放顺序建表。
var _slot_of_reader : Dictionary = {}
var _react_mood : Array[String] = []
var _react_amount : Array[float] = []
var _react_progress : Array[float] = []
var _react_tweens : Array[Tween] = []

# 反应归属提示：原始缩放、每家的 flash shader 材质、正在跑的提示动画。
var _base_scale : Array[Vector2] = []
var _flash_mats : Array[ShaderMaterial] = []
var _fx_tweens : Array[Tween] = []

# 背景染色（重播时要能整体掐掉）。
var _tint_tween : Tween = null

# 错峰起手的等待 Tween：重播时先掐掉，否则上一场的人会在新一场里突然动一下。
var _stagger_tweens : Array[Tween] = []

# 抬滚筒之前那一段（可能包含"变天"）单独一条时间线。
var _tail_tween : Tween = null

# 这一晚收到的换档记录：[{reader, prev, next}]，reader = -1 表示领地。
var _state_changes : Array[Dictionary] = []

# "变天"横幅：几行 Label，运行时建，平时透明。
var _banner : Array[Label] = []
var _beat_tweens : Array[Tween] = []
# 卡片的位置 / 缩放 / 轴心**一律不动**：它们由 Scene/DayPassAnimation.tscn 摆好。
# （RawMaterial.tscn 的根节点带 offset_transform_scale = 0.5，加载出来 scale 就是 2.0；
#   任何改 pivot_offset 或写死 scale 的代码都会让它偏离原来的位置。）

# 漂移用：城景各层的引用，以及当前视口高度。
var _elapsed : float = 0.0
var _screen_h : float = 648.0
var _layers : Array[Control] = []

# 四个剪影和它们各自的站位（呼吸是在站位上做加减）。
var _breathers : Array[Sprite2D] = []
var _breathe_base : Array[Vector2] = []

func _ready() -> void:
	# 编辑器里什么都不做：就让场景照它摆的样子显示（停在中途），方便对着改。
	if Engine.is_editor_hint():
		return

	_roller_h = _roller.offset_bottom - _roller.offset_top
	_shadow_h = _shadow.offset_bottom - _shadow.offset_top
	_setup_layers()
	_collect_silhouettes()
	_park()
	_build_banner()

	# 这一晚有谁换档：World 在 day_passed 里同步发出来，这里先收着，抬滚筒前再演。
	EventBus.group_state_changed.connect(_on_group_state_changed)
	EventBus.government_state_changed.connect(_on_government_state_changed)

	# 表面的旋转：一直滚着。
	_spin = create_tween().set_loops()
	_spin.tween_property(_surface, "offset_top", -float(_surface.texture.get_height()), SPIN_PERIOD)\
		.from(0.0).set_trans(Tween.TRANS_LINEAR)

	# 听的是 paper_ready，不是 day_passed —— day_passed 现在由这里自己发，。
	EventBus.paper_ready.connect(_on_paper_ready)

func _process(delta : float) -> void:
	if Engine.is_editor_hint():
		return
	_elapsed += delta
	_drift_background()
	_breathe_silhouettes()

# 城景各层以不同幅度和周期缓慢起伏：远层几乎不动，近层像在呼吸。
func _drift_background() -> void:
	var n : int = _layers.size()
	if n == 0:
		return
	for i in n:
		var depth : float = float(i) / maxf(float(n - 1), 1.0)
		var amp : float = lerpf(DRIFT_FAR, DRIFT_NEAR, depth)
		var period : float = lerpf(DRIFT_PERIOD_FAR, DRIFT_PERIOD_NEAR, depth)
		var off : float = sin(TAU * _elapsed / period + depth * 1.7) * amp
		# 上下各留出 amp 的余量：摆动到两端也不会在裁剪框边上露出空隙。
		_layers[i].offset_top = -amp + off
		_layers[i].offset_bottom = _screen_h + amp + off

# 四家各自轻微起伏，相位错开，免得一起动像在点头。
# 反应的位移叠在呼吸上：Tween 只改 _react_progress，位置仍然由这里统一写，
# 免得两个东西抢同一个 position。
func _breathe_silhouettes() -> void:
	for i in _breathers.size():
		var phase : float = TAU * _elapsed / BREATHE_PERIOD + float(i) * 1.15
		var p : Vector2 = _breathe_base[i]
		_breathers[i].position = p + Vector2(0.0, sin(phase) * BREATHE_AMP) + _react_offset(i)

# 墨那一叠：容器只管"裁到多高"，画什么全交给里面那几层背景。
func _setup_layers() -> void:
	back_grond.clip_contents = true
	# 它只是块布：别在过场里替玩家吃掉鼠标（挡输入是 Blocker 的活）。
	back_grond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_grond.anchor_left = 0.0
	back_grond.anchor_right = 1.0
	back_grond.anchor_top = 0.0
	back_grond.anchor_bottom = 0.0
	back_grond.offset_left = -8.0
	back_grond.offset_right = 8.0
	back_grond.offset_top = 0.0
	_screen_h = get_viewport().get_visible_rect().size.y
	_layers.clear()
	for layer in back_grond.get_children():
		if layer is Control:
			var c : Control = layer as Control
			# TextureRect 默认 Keep Size：节点高度会被锁死在贴图高度上（360），。
			if c is TextureRect:
				(c as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			c.offset_top = 0.0
			c.offset_bottom = _screen_h
			_layers.append(c)


# 四个剪影：记下站位，之后每帧只在 y 上做加减；顺便建"群体 → 剪影下标"表。
func _collect_silhouettes() -> void:
	var holder : Control = _roller.get_node_or_null("Silhouettes")
	if holder == null:
		return

	# 场景里四个剪影的摆放顺序：农民 · 工人 · 士兵 · 商人。
	# **不是** GroupData.READERS 的枚举顺序（商人 2 / 士兵 3 在这里是反的），
	# 而且必须和 EmojiParticles.emitters() 的顺序一致。
	var order : Array[int] = [
		GroupData.READERS.FARMER,
		GroupData.READERS.WORKER,
		GroupData.READERS.SOLDIER,
		GroupData.READERS.MERCHANT,
	]

	_slot_of_reader.clear()
	_breathers.clear()
	_breathe_base.clear()
	_react_mood.clear()
	_react_amount.clear()
	_react_progress.clear()
	_react_tweens.clear()
	_base_scale.clear()
	_flash_mats.clear()
	_fx_tweens.clear()

	for child in holder.get_children():
		if child is Sprite2D:
			var sprite : Sprite2D = child as Sprite2D
			var slot : int = _breathers.size()
			_breathers.append(sprite)
			_breathe_base.append(sprite.position)
			_base_scale.append(sprite.scale)
			if slot < order.size():
				_slot_of_reader[order[slot]] = slot
			_react_mood.append("")
			_react_amount.append(0.0)
			_react_progress.append(0.0)
			_react_tweens.append(null)
			_fx_tweens.append(null)

			# 每家一个材质：高亮是 shader 换色，不是 modulate。
			var mat : ShaderMaterial = ShaderMaterial.new()
			mat.shader = FLASH_SHADER
			mat.set_shader_parameter("flash", 0.0)
			sprite.material = mat
			_flash_mats.append(mat)

# 回到"什么都没发生"的样子：滚筒整个躲到屏幕上沿外，墨是空的，卡片透明。
func _park() -> void:
	_lay_ink(-_roller_h)
	_card.modulate.a = 0.0

# 必须收下这个参数**：Godot 4 的脚本回调不做"丢参数"，。
func _on_paper_ready(newspaper : NewsPaper) -> void:
	play(newspaper)

func play(newspaper : NewsPaper) -> void:
	_paper = newspaper
	_height = get_viewport().get_visible_rect().size.y

	# 动画期间把鼠标挡住：这一小会儿不该还能点到决定、卡片、按钮。
	_blocker.mouse_filter = Control.MOUSE_FILTER_STOP

	# 一条新的时间线要开始，先把上一条掐掉（位置由 _lay_ink 全权决定，。
	if _tween != null and _tween.is_valid():
		_tween.kill()
		# 上一次要是被打断了，卡片可能正亮着——先收掉，从头来。
		_card.modulate.a = 0.0
		_stop_played()
		_clear_reactions()
	if _tail_tween != null and _tail_tween.is_valid():
		_tail_tween.kill()
	_reset_state_beat()

	# 起点和终点都在屏幕外，所以首尾都是干净的：开始前什么都没有，。
	var top_edge : float = -_roller_h
	var end_edge : float = _height - _roller_h

	AudioManager.play(AudioManager.Sound.ROLLER_DOWN)

	_tween = create_tween()
	# ① 压下来：慢起快落，像机器压下来那一下。
	_tween.tween_method(_lay_ink, top_edge, end_edge, ROLL_DOWN)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	# 压在纸上的那一下：画面跟着沉一沉。
	_tween.tween_callback(_thump)
	# ② 一条一条过今天的版面（长度 = 条数 × CARD_STEP）。
	_append_cards(_tween)
	# ③ 全黑、玩家看不见的时候过天。
	_tween.tween_callback(_pass_day)
	# ④ 抬滚筒之前，看这一晚有没有群体换档：有就多演一段"变天"。
	#    放在第二条时间线里，因为要不要等 1.35 秒，只有过完天才知道。
	_tween.tween_callback(func(): _start_tail(end_edge, top_edge))

# 压到底那一下：整块画面往下一沉再回弹，像机器真的砸在纸面上。
func _thump() -> void:
	position = Vector2.ZERO
	var kick : Tween = create_tween()
	kick.tween_property(self, "position", Vector2(0.0, THUMP_DROP), 0.05)
	kick.tween_property(self, "position", Vector2(0.0, -THUMP_DROP * 0.4), 0.07)
	kick.tween_property(self, "position", Vector2.ZERO, 0.10)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

# 中段：把今天登出去的每一条，依次摆到那张预览卡上。
func _append_cards(tween : Tween) -> void:
	# 存的是**在报纸里的下标**，不是"第几个非空条目"
	var indices : Array[int] = []
	if _paper != null:
		for i in _paper.events.size():
			if _paper.events[i] != null:
				indices.append(i)

	# 空报纸是合法的（那天就是一份空报）：一条都没有就整段跳过，。
	for k in indices.size():
		var index : int = indices[k]
		var res : NewsResource = _paper.events[index]
		# 用 bind 而不是 lambda 抓循环变量：bind 是**当场把值绑死**，。
		tween.tween_callback(_show_card.bind(res, index))
		tween.tween_property(_card, "modulate:a", 1.0, CARD_FADE)
		tween.tween_interval(CARD_HOLD)
		tween.tween_property(_card, "modulate:a", 0.0, CARD_FADE)

func _show_card(res : NewsResource, index : int) -> void:
	# 摆出来这一下配一声：卡片正要淡进来，声音和画面同一刻起。
	AudioManager.play(AudioManager.Sound.CARD_APPEAR, CARD_TICK_DB,
		1.0 + minf(float(index) * CARD_SOUND_STEP, CARD_SOUND_MAX))

	# 谁被这条新闻写到，谁就动一下、喷一炮、开口（软新闻谁都不理）。
	var fake : bool = SHOW_FAKE_IN_CARD and _paper != null and _paper.is_fake(index)
	_play_reaction(res, fake)
	EventBus.news_card_shown.emit(res, index)

	# is_fake 必须在 setup() **之前**设：RawMaterial._apply() 读它来上色。
	_card.is_fake = fake
	_card.setup(res)

	# 假新闻：卡片抖、墨迹晕开、一层低频杂音。
	if fake:
		_fake_distort()

# 这条新闻摆出来了：谁被写到，谁就动一下、喷一炮、开口。
func _play_reaction(res : NewsResource, fake : bool = false) -> void:
	var reactions : Array[Dictionary] = NewsReaction.of(res)
	if reactions.is_empty():
		# 软新闻：没人反应，画面也别变脸。
		return

	# 先告诉玩家"这条冲着谁"：该家闪白放大，其余压暗。
	_highlight(reactions)
	# 再让整幅城景跟着这条新闻的情绪变一下色。
	_tint_background(reactions)

	# 四家一起开口太吵：三家以上有反应时，每家只说一句。
	var solo : bool = reactions.size() > 2
	for one in reactions:
		var reader : int = one["reader"]
		var slot : int = int(_slot_of_reader.get(reader, -1))
		if slot < 0:
			continue
		var mood : String = one["mood"]
		var strength : float = one["strength"]

		# 错峰：四个人不该同一帧起手，否则像四个复制人。
		var delay : float = ReactionData.REACT_STAGGER[slot % ReactionData.REACT_STAGGER.size()]
		if delay <= 0.0:
			_do_reaction(slot, mood, strength, fake, solo)
			continue
		var wait : Tween = create_tween()
		wait.tween_interval(delay)
		wait.tween_callback(_do_reaction.bind(slot, mood, strength, fake, solo))
		_stagger_tweens.append(wait)

# 真正让某一家动起来（已经在自己的时点上）。
func _do_reaction(slot : int, mood : String, strength : float,
		fake : bool, solo : bool) -> void:
	# 个体幅度：同一条新闻，士兵动得比商人轻。
	var amount : float = clampf(
		strength * ReactionData.REACT_SCALE[slot % ReactionData.REACT_SCALE.size()], 0.0, 1.0)
	_react(slot, mood, amount)
	if _emoji != null:
		_emoji.fire_one(slot, mood, amount, fake)
	_group_speak(slot, mood, amount, solo)

# 反应归属：被写到的闪白 + 放大 3%，没被写到的压暗到 75% 再恢复。
func _highlight(reactions : Array[Dictionary]) -> void:
	var lit : Dictionary = {}
	for one in reactions:
		var slot : int = int(_slot_of_reader.get(int(one["reader"]), -1))
		if slot >= 0:
			lit[slot] = true

	for i in _breathers.size():
		if _fx_tweens[i] != null and _fx_tweens[i].is_valid():
			_fx_tweens[i].kill()
		var sprite : Sprite2D = _breathers[i]
		# 上一张卡可能没演完：先归位，再从头演。
		sprite.modulate.a = 1.0
		sprite.scale = _base_scale[i]

		var tw : Tween = create_tween()
		_fx_tweens[i] = tw
		if lit.has(i):
			tw.tween_method(_set_flash.bind(i), 0.0, ReactionData.HIGHLIGHT_FLASH,
				ReactionData.HIGHLIGHT_IN)
			tw.parallel().tween_property(sprite, "scale",
				_base_scale[i] * ReactionData.HIGHLIGHT_SCALE, ReactionData.HIGHLIGHT_IN + 0.02)
			tw.tween_method(_set_flash.bind(i), ReactionData.HIGHLIGHT_FLASH, 0.0,
				ReactionData.HIGHLIGHT_OUT)
			tw.parallel().tween_property(sprite, "scale", _base_scale[i],
				ReactionData.HIGHLIGHT_OUT)\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		else:
			tw.tween_property(sprite, "modulate:a", ReactionData.DIM_ALPHA, 0.10)
			tw.tween_interval(0.12)
			tw.tween_property(sprite, "modulate:a", 1.0, 0.25)

func _set_flash(value : float, slot : int) -> void:
	if slot < 0 or slot >= _flash_mats.size():
		return
	_flash_mats[slot].set_shader_parameter("flash", value)

# 整幅城景轻染一下情绪色：怒→偏红、怕→偏蓝、喜→偏暖黄、丧→偏灰。
func _tint_background(reactions : Array[Dictionary]) -> void:
	if _layers.is_empty():
		return
	# 取最强的那条反应定颜色（四家同款时就是它自己）。
	var mood : String = ""
	var best : float = -1.0
	for one in reactions:
		var strength : float = float(one["strength"])
		if strength > best:
			best = strength
			mood = String(one["mood"])

	var target : Color = Color.WHITE.lerp(
		ReactionData.MOOD_COLOR.get(mood, Color.WHITE), ReactionData.TINT_STRENGTH)
	# 先把上一张卡残留的颜色抹掉，再重新染。
	_apply_tint(0.0, target)
	if _tint_tween != null and _tint_tween.is_valid():
		_tint_tween.kill()
	_tint_tween = create_tween()
	_tint_tween.tween_method(_apply_tint.bind(target), 0.0, 1.0, ReactionData.TINT_IN)
	_tint_tween.tween_method(_apply_tint.bind(target), 1.0, 0.0, ReactionData.TINT_OUT)

func _apply_tint(k : float, target : Color) -> void:
	var c : Color = Color.WHITE.lerp(target, k)
	for layer in _layers:
		layer.modulate = c

# 假新闻的失真：垫一层低频杂音。
# 卡片的位置 / 缩放 / 轴心**一点不碰**——它是场景摆好的 2 倍缩放，任何变换都会让它偏位。
# "这是假的"由粒子去饱和 + 低频杂音 + 红卡标记三件事一起说。
func _fake_distort() -> void:
	AudioManager.play_stream(FAKE_NOISE, FAKE_NOISE_DB, FAKE_NOISE_PITCH)

# 剪影动一下：只改偏移量，位置仍由 _breathe_silhouettes 每帧统一写。
# duration > 0 时用它替代按情绪定好的默认时长（换档那一段要慢一些）。
func _react(slot : int, mood : String, strength : float, duration : float = 0.0) -> void:
	if slot < 0 or slot >= _breathers.size():
		return
	_react_mood[slot] = mood
	_react_amount[slot] = clampf(strength, 0.0, 1.0)
	_react_progress[slot] = 0.0

	if _react_tweens[slot] != null and _react_tweens[slot].is_valid():
		_react_tweens[slot].kill()

	var time : float = duration if duration > 0.0 else (
		ReactionData.SHAKE_TIME if mood == "angry" else ReactionData.REACT_TIME)
	var tw : Tween = create_tween()
	tw.tween_method(_set_react_progress.bind(slot), 0.0, 1.0, time)
	_react_tweens[slot] = tw

func _set_react_progress(value : float, slot : int) -> void:
	if slot < 0 or slot >= _react_progress.size():
		return
	_react_progress[slot] = value

# 这一帧，这个剪影该往哪偏。
func _react_offset(slot : int) -> Vector2:
	var t : float = _react_progress[slot]
	if t <= 0.0 or t >= 1.0:
		return Vector2.ZERO
	var amp : Vector2 = ReactionData.MOOD_OFFSET.get(_react_mood[slot], Vector2.ZERO) * _react_amount[slot]
	match _react_mood[slot]:
		"angry":
			# 左右抖，越抖越小
			return Vector2(sin(t * TAU * 3.0) * (1.0 - t) * amp.x, 0.0)
		"fear":
			# 往后缩一下再回来
			return Vector2(-amp.x * sin(PI * t), amp.y * sin(PI * t))
		"happy":
			# 轻跳
			return Vector2(0.0, -amp.y * sin(PI * t))
		"power":
			# 先沉后起
			return Vector2(0.0, amp.y * (1.0 - cos(TAU * t)) * 0.5)
		_:
			# 丧气：往下塌
			return Vector2(0.0, amp.y * sin(PI * t))

# 这一家开口：按情绪取池子，按强度决定说几条。
func _group_speak(slot : int, mood : String, strength : float, solo : bool = false) -> void:
	var table : Array = VOICE_BY_MOOD.get(mood, VOICE_BY_MOOD["sad"])
	if table.is_empty():
		return
	# 洗一遍再取前 N 条：不重复，而且每次组合都不一样。
	var pool : Array = table.duplicate()
	pool.shuffle()

	var count : int = 1 if solo else 1 + int(strength > 0.6) + int(strength > 0.9)
	count = mini(count, mini(ReactionData.VOICE_MAX, pool.size()))
	for i in count:
		var delay : float = VOICE_DELAY[i % VOICE_DELAY.size()]
		# 每一条自己排一条小时间线：错开才有"一群人同时开口"的感觉。
		var line : Tween = create_tween()
		line.tween_interval(delay)
		line.tween_callback(_speak.bind(pool[i], VOICE_PITCH[slot % VOICE_PITCH.size()]))

func _speak(stream : AudioStream, pitch : float = 1.0) -> void:
	_played.append(stream)
	AudioManager.play_stream(stream, CROWD_DB, pitch)

# 把四家的反应全部归零（重播 / 被打断）。
func _clear_reactions() -> void:
	# 还没到点的那几家先取消，免得归零之后又被回调点着。
	for tw in _stagger_tweens:
		if tw != null and tw.is_valid():
			tw.kill()
	_stagger_tweens.clear()

	for i in _react_progress.size():
		_react_progress[i] = 0.0
		_react_mood[i] = ""
		_react_amount[i] = 0.0
		if _react_tweens[i] != null and _react_tweens[i].is_valid():
			_react_tweens[i].kill()

	# 归属提示 / 染色也要一起收干净。
	for i in _breathers.size():
		if _fx_tweens[i] != null and _fx_tweens[i].is_valid():
			_fx_tweens[i].kill()
		_breathers[i].modulate.a = 1.0
		_breathers[i].scale = _base_scale[i]
		if i < _flash_mats.size():
			_flash_mats[i].set_shader_parameter("flash", 0.0)

	if _tint_tween != null and _tint_tween.is_valid():
		_tint_tween.kill()
	for layer in _layers:
		layer.modulate = Color.WHITE

	if _emoji != null:
		_emoji.clear()

# 重播 / 被打断时：把上一场还在响的人声收掉（正常流程里不打断任何一句）。
func _stop_played() -> void:
	for stream in _played:
		AudioManager.stop_stream(stream)
	_played.clear()

# 只改一个数：滚筒上沿在哪。
func _lay_ink(edge : float) -> void:
	var ink_h : float = maxf(edge, 0.0)
	back_grond.offset_bottom = ink_h
	_roller.offset_top = edge
	_roller.offset_bottom = edge + _roller_h

	var shadow_top : float = edge + _roller_h
	_shadow.offset_top = shadow_top
	_shadow.offset_bottom = shadow_top + _shadow_h
	# 阴影是"滚子压在纸上"的那一层，所以下沿**没进画面**（还在上沿外）时不能露。
	_shadow.visible = shadow_top > 0.0 and shadow_top < _height

# 过天：墨已经盖满了，这一刻发生的事玩家都看不见。
func _pass_day() -> void:
	# 翻页声：这一天到这儿为止。
	AudioManager.play(AudioManager.Sound.DAY_PASS)
	EventBus.day_passed.emit(_paper)


# —— 变天：某个群体换档 ——

func _on_group_state_changed(reader : int, prev, next) -> void:
	_state_changes.append({"reader" : reader, "prev" : prev, "next" : next})

func _on_government_state_changed(prev, next) -> void:
	# 领地没有剪影，只出横幅；用 -1 标一下。
	_state_changes.append({"reader" : -1, "prev" : prev, "next" : next})

# 抬滚筒 + 发 day_pass_finished。中间要不要插"变天"，看 _state_changes。
func _start_tail(end_edge : float, top_edge : float) -> void:
	if _tail_tween != null and _tail_tween.is_valid():
		_tail_tween.kill()
	_tail_tween = create_tween()

	if not _state_changes.is_empty():
		_tail_tween.tween_callback(_play_state_beat)
		_tail_tween.tween_interval(ReactionData.STATE_BEAT_TIME)

	_tail_tween.tween_callback(func(): AudioManager.play(AudioManager.Sound.ROLLER_UP))
	_tail_tween.tween_method(_lay_ink, end_edge, top_edge, ROLL_UP)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tail_tween.tween_callback(func():
		_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)
	# 滚筒抬完了：该压上来的东西（终刊号）这时候才可以动。
	_tail_tween.tween_callback(func(): EventBus.day_pass_finished.emit())

# 满墨的黑底上：谁换了档，谁动一下，头上浮一行「谁　从什么 → 到什么」。
func _play_state_beat() -> void:
	if _state_changes.is_empty():
		return

	var worse : bool = false
	var line : int = 0
	for change in _state_changes:
		if line >= _banner.size():
			break
		var prev : Variant = change["prev"]
		var next : Variant = change["next"]
		var reader : int = int(change["reader"])
		var before : Dictionary = StateText.of(prev)
		var after : Dictionary = StateText.of(next)
		var mood : String = StateText.mood_of(next)
		if mood != "happy":
			worse = true

		_show_banner_line(line, "%s　%s → %s" % [
			_group_name(reader), String(before["text"]), String(after["text"])],
			after["color"])
		line += 1

		# 换档比读一条报更狠：满强度、动作拉长，粒子用状态自己的颜色（不套情绪色）。
		if reader >= 0:
			var slot : int = int(_slot_of_reader.get(reader, -1))
			if slot >= 0:
				_react(slot, mood, 1.0, ReactionData.STATE_MOTION_TIME)
				# 演到一半再补一炮：2.2 秒里只喷一次会显得早早就结束了。
				_beat_burst(slot, after["color"])

	AudioManager.play(AudioManager.Sound.SETTLE_BAD if worse else AudioManager.Sound.SETTLE_GOOD)

# 换档时的两炮粒子：第一炮立刻，第二炮在 STATE_SECOND_BURST 之后。
func _beat_burst(slot : int, color : Color) -> void:
	if _emoji == null:
		return
	_emoji.fire_one_tinted(slot, color, 1.0)
	var tw : Tween = create_tween()
	_beat_tweens.append(tw)
	tw.tween_interval(ReactionData.STATE_SECOND_BURST)
	tw.tween_callback(func(): _emoji.fire_one_tinted(slot, color, 0.85))

func _show_banner_line(index : int, text : String, color : Color) -> void:
	if index < 0 or index >= _banner.size():
		return
	var label : Label = _banner[index]
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.modulate.a = 0.0

	var tw : Tween = create_tween()
	_beat_tweens.append(tw)
	tw.tween_interval(ReactionData.STATE_LINE_STAGGER * float(index))
	tw.tween_property(label, "modulate:a", 1.0, ReactionData.STATE_FADE_IN)
	tw.tween_interval(ReactionData.STATE_HOLD)
	tw.tween_property(label, "modulate:a", 0.0, ReactionData.STATE_FADE_OUT)

# 横幅是运行时建的：不进场景文件，也就不动任何已有的布局。
func _build_banner() -> void:
	for i in BANNER_LINES:
		var label : Label = Label.new()
		label.theme = BANNER_THEME
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.anchor_left = 0.0
		label.anchor_right = 1.0
		label.anchor_top = 0.0
		label.anchor_bottom = 0.0
		label.offset_top = ReactionData.STATE_BANNER_TOP + float(i) * ReactionData.STATE_LINE_HEIGHT
		label.offset_bottom = label.offset_top + ReactionData.STATE_LINE_HEIGHT
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.modulate.a = 0.0
		label.add_theme_font_size_override("font_size", ReactionData.STATE_FONT_SIZE)
		label.add_theme_constant_override("outline_size", 8)
		label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
		add_child(label)
		_banner.append(label)

func _reset_state_beat() -> void:
	_state_changes.clear()
	for tw in _beat_tweens:
		if tw != null and tw.is_valid():
			tw.kill()
	_beat_tweens.clear()
	for label in _banner:
		label.modulate.a = 0.0
		label.text = ""

# 领地名 / 四家的名字：文字的唯一来源在 Texts。
func _group_name(reader : int) -> String:
	match reader:
		GroupData.READERS.FARMER:
			return Texts.GROUP_FARMER
		GroupData.READERS.WORKER:
			return Texts.GROUP_WORKER
		GroupData.READERS.MERCHANT:
			return Texts.GROUP_MERCHANT
		GroupData.READERS.SOLDIER:
			return Texts.GROUP_SOLDIER
		_:
			return Texts.GROUP_GOVERNMENT


# —— 调试 ——

# F9 依次预览五种反应（只在调试构建里生效，不进正式包）。
const DEBUG_MOODS : Array[String] = ["angry", "fear", "happy", "power", "sad"]
var _debug_cursor : int = 0

func _unhandled_input(event : InputEvent) -> void:
	if not OS.is_debug_build():
		return
	var key : InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo or key.keycode != KEY_F9:
		return
	if _breathers.is_empty():
		return
	var mood : String = DEBUG_MOODS[_debug_cursor % DEBUG_MOODS.size()]
	_debug_cursor += 1
	for slot in _breathers.size():
		_react(slot, mood, 1.0)
		if _emoji != null:
			_emoji.fire_one(slot, mood, 1.0)
	get_viewport().set_input_as_handled()
