extends Control

# 开始菜单。
#
# 这个文件只干四件事：让纸动一点、让纸上写出字、让入场好看一点、把按钮接上。
# 所有"动"都刻意做得很慢——菜单是玩家还没进入世界的那个房间，
# 它应该有呼吸，但不该抢戏。**但"很慢"不等于"看不见"**：
# 上一版把幅度调得太保守，结果就是一张静止的图。

const GAME_SCENE : String = "res://Scene/ui.tscn"

# ════════════════════════════════════════════════════════════
#  一、上层纸的胀缩
# ════════════════════════════════════════════════════════════

# 一个来回 30 秒。
#
# 为什么是缩放而不是平移：平移会把图的边缘推出来，除非再做一层无缝拼贴，
# 而"放大一点点"永远留在画面内。
const DRIFT_PERIOD : float = 30.0
const DRIFT_AMOUNT : float = 0.08

# ════════════════════════════════════════════════════════════
#  二、尘埃
# ════════════════════════════════════════════════════════════

# 十几个一像素的点，各自以微小速度向上飘。
#
# 没有用粒子系统——它需要一张纹理，而项目里没有合适的"尘埃"图，
# 硬塞一个圆点图标会糊。而这些点的全部参数就是位置和速度，
# 手写反而比配一套粒子材质更短、更可控。
const DUST_COUNT : int = 18

# ════════════════════════════════════════════════════════════
#  三、打字机
# ════════════════════════════════════════════════════════════

# 菜单的背景是什么？是那个世界的一张报纸。
#
# 所以它上面不该是空的——应该有一行行字正在被写出来，
# 写的就是这座城里这一天发生的事。玩家还没进入游戏，
# 就已经从这几行字里看到了那台机器在转。
#
# 最后一句是留给他的：这一整面纸，接下来由他写。
const TYPE_LINES : Array[String] = [
	# 一天的开始
	"民国二十三年秋，本埠米价三日三涨。",
	"城中米铺十有九闭，斗米已至八百文。",
	"北门粮栈昨夜遭劫，米袋散落半条街。",

	# 四乡先动
	"四乡佃户相约不缴租，县署已派兵弹压。",
	"逃荒者结队出南门，日以百计。",
	"城西设粥棚三处，日施粥两千余碗。",

	# 城里跟着动
	"纱厂机器尽停，工人相率离厂。",
	"厂主请兵护厂，工人退至城外破庙。",
	"商会闭门议事，议决各铺暂停营业。",
	"本埠商船三艘出海，载货未言归期。",

	# 最坏的时候
	"驻军某营昨夜哗变，枪声彻夜未歇。",
	"散兵沿乡掠食，四乡苦之。",
	"县署急调马队，分驻四门。",

	# 收手
	"道台出示安民，言乱事已平。",
	"抚局已设，愿归农者给籽种口粮。",
	"哗变兵士收枪归营，然编制已散。",

	# 缓过来
	"四乡租事渐息，租米已陆续送仓。",
	"工人已陆续回厂，机器照常开动。",
	"商铺次第复市，街市渐复旧观。",

	# 报馆自语，然后又是新的一天
	"本报明日照常出刊，风雨无阻。",
	"报馆昼夜有人，凡有见闻皆可投书。",
	"此事当如何记载，全在阁下笔下。",
]


const CHAR_INTERVAL : float = 0.075   # 每打一个字要多久
const LINE_PAUSE : float = 0.5        # 打完一句，顿一下
const RESTART_PAUSE : float = 3.5     # 整篇写完，歇多久再从头写
const CURSOR_PERIOD : float = 0.8     # 光标闪一个来回的时长

var _blink : float = 0.0
var _typed : String = ""
var _line : int = 0
var _column : int = 0
var _char_timer : float = 0.0
var _restart_timer : float = 0.0
var _typing : bool = true

# ════════════════════════════════════════════════════════════

var _elapsed : float = 0.0
var _dust : Array[ColorRect] = []
var _dust_velocity : Array[Vector2] = []

@onready var drift_layer : TextureRect = %DriftLayer
@onready var dust_layer : Control = %DustLayer
@onready var type_label : Label = %TypeText
@onready var title_box : VBoxContainer = %TitleBox
@onready var menu : VBoxContainer = %Menu

@onready var start_button : Button = %StartButton
@onready var quit_button : Button = %QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	_build_dust()
	_intro()

func _process(delta : float) -> void:
	_elapsed += delta
	_drift()
	_update_dust(delta)
	_update_typewriter(delta)

# --- 纸在胀缩 ---

func _drift() -> void:
	var k : float = 1.0 + DRIFT_AMOUNT * 0.5 * (1.0 - cos(TAU * _elapsed / DRIFT_PERIOD))
	drift_layer.pivot_offset = drift_layer.size * 0.5
	drift_layer.scale = Vector2(k, k)

# --- 尘埃在飘 ---

func _build_dust() -> void:
	var area : Vector2 = get_viewport_rect().size
	for i in DUST_COUNT:
		var dot : ColorRect = ColorRect.new()
		dot.color = Color(1.0, 0.96, 0.88, randf_range(0.07, 0.24))
		dot.size = Vector2.ONE * randf_range(1.0, 2.0)
		dot.position = Vector2(randf() * area.x, randf() * area.y)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dust_layer.add_child(dot)
		_dust.append(dot)
		# 向上飘，横向带一点随机——像光柱里悬着的尘，不像雨。
		_dust_velocity.append(
			Vector2(randf_range(-4.0, 4.0), randf_range(-11.0, -3.0)))

func _update_dust(delta : float) -> void:
	var area : Vector2 = get_viewport_rect().size
	for i in _dust.size():
		var dot : ColorRect = _dust[i]
		dot.position += _dust_velocity[i] * delta

		# 飘出上边就从底下重来。换一条新的横向速度，
		# 免得看起来永远是同一批点在循环。
		if dot.position.y < -4.0:
			dot.position.y = area.y + 4.0
			dot.position.x = randf() * area.x
			_dust_velocity[i] = Vector2(
				randf_range(-4.0, 4.0), randf_range(-11.0, -3.0))
		elif dot.position.x < -4.0:
			dot.position.x = area.x + 4.0
		elif dot.position.x > area.x + 4.0:
			dot.position.x = -4.0

# --- 纸上在写字 ---

func _update_typewriter(delta : float) -> void:
	# 光标独立闪，和打字速度无关——它是在"等"下一个字。
	_blink += delta
	var cursor : String = "_" if fmod(_blink, CURSOR_PERIOD) < CURSOR_PERIOD * 0.5 else " "

	if not _typing:
		# 整篇写完了。停一会儿，再从头上写。
		_restart_timer -= delta
		if _restart_timer <= 0.0:
			_restart_typing()
		return

	_char_timer += delta
	if _char_timer >= CHAR_INTERVAL:
		_char_timer = 0.0
		_type_next()
		if not _typing:
			return                          # 刚好写完最后一个字

	type_label.text = _typed + cursor

# 往前打一个字。
# 打完一句就换行并顿一下；全打完了就把开关关掉，交给上面的等待分支。
func _type_next() -> void:
	if _line >= TYPE_LINES.size():
		_typing = false
		_restart_timer = RESTART_PAUSE
		return

	var text : String = TYPE_LINES[_line]
	if _column >= text.length():
		_typed += "\n"
		_line += 1
		_column = 0
		# 负值 = 接下来这段时间都不够打字，得先把这个窟窿补上。
		_char_timer = -LINE_PAUSE
		return

	_typed += text[_column]
	_column += 1

func _restart_typing() -> void:
	# 不清空就重打会很突兀，所以先淡掉再换。
	# 这个数要大过整段动画：等待分支靠它判定"该重来了"，
	# 不掐掉的话 tween 那半秒里它会每帧触发一次。
	_restart_timer = 999.0

	var tween : Tween = create_tween()
	tween.tween_property(type_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_reset_typing)
	tween.tween_property(type_label, "modulate:a", 1.0, 0.5)

func _reset_typing() -> void:
	_typed = ""
	_line = 0
	_column = 0
	_char_timer = 0.0
	_typing = true
	type_label.text = ""

# --- 入场 ---

# 标题先落，按钮依次跟上。
#
# 用 scale 而不是 position——标题和按钮都在容器里，容器会在每次重排时
# 覆盖子节点的 position，但不会碰 scale。所以位移要么失效、要么和布局打架，
# 缩放不会。代价是要等一帧让容器先把尺寸算出来，才能把 pivot 设在中心。
func _intro() -> void:
	await get_tree().process_frame

	var items : Array[Control] = [title_box]
	for i in menu.get_children():
		if i is Control:
			items.append(i as Control)

	for i in items.size():
		var item : Control = items[i]
		item.pivot_offset = item.size * 0.5
		item.modulate.a = 0.0
		item.scale = Vector2(1.0, 0.93)

		var tween : Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(item, "modulate:a", 1.0, 0.5).set_delay(i * 0.11)
		tween.tween_property(item, "scale", Vector2.ONE, 0.5)\
			.set_delay(i * 0.11)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)

# --- 按钮 ---

func _on_start_pressed() -> void:
	# 菜单只是入口，游戏本体在另一个场景。
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()
