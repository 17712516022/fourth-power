class_name EmojiParticles extends Control

# 四个剪影头顶各挂一个**一次性**粒子发射器（EmojiPartcle ~ 4）。

@onready var emoji_partcle: GPUParticles2D = %EmojiPartcle
@onready var emoji_partcle_2: GPUParticles2D = %EmojiPartcle2
@onready var emoji_partcle_3: GPUParticles2D = %EmojiPartcle3
@onready var emoji_partcle_4: GPUParticles2D = %EmojiPartcle4

const EMOJI_02 = preload("uid://dbvfrw76wrm1r")
const EMOJI_03 = preload("uid://bg0etdwjxxin2")
const EMOJI_04 = preload("uid://bdre6kgyrfixa")
const EMOJI_05 = preload("uid://ccigwl1nn1y23")
const EMOJI_06 = preload("uid://ctwhoop0tvef5")
const EMOJI_07 = preload("uid://cxvjo8poarh76")
const EMOJI_08 = preload("uid://1gaqpaoui6yk")
const EMOJI_09 = preload("uid://dwtxmsgilead2")
const EMOJI_10 = preload("uid://b42hwc6qxh0n6")
const EMOJI_11 = preload("uid://dquvj8y203bee")
const EMOJI_12 = preload("uid://dgwc5g23r3sy")
const EMOJI_13 = preload("uid://dnxxgxl2uco4")
const EMOJI_14 = preload("uid://cfu0whwyql38c")
const EMOJI_15 = preload("uid://d2camdclby8e7")
const EMOJI_16 = preload("uid://d24fmuirsxuen")
const EMOJI_17 = preload("uid://duwbm4b8tst0g")
const EMOJI_18 = preload("uid://ncglhcvydki8")
const EMOJI_19 = preload("uid://b0b1qvykqiruj")
const EMOJI_20 = preload("uid://ci1lo0pe4ker7")
const EMOJI = preload("uid://165hbvrmw55t")

# 随机是从这张表里抽的：**加减候选只改这里**（上面那些 const 是它引用的原料）。
const ALL_EMOJIS : Array[Texture2D] = [
	EMOJI, EMOJI_02, EMOJI_03, EMOJI_04, EMOJI_05, EMOJI_06, EMOJI_07,
	EMOJI_08, EMOJI_09, EMOJI_10, EMOJI_11, EMOJI_12, EMOJI_13, EMOJI_14,
	EMOJI_15, EMOJI_16, EMOJI_17, EMOJI_18, EMOJI_19, EMOJI_20,
]

# 开一炮：四家各随机一张图，从头喷（调试用；正式过场走 fire_one）。
func fire() -> void:
	for emitter in emitters():
		emitter.texture = random_texture()
		emitter.restart()
		emitter.emitting = true

# 只让某一家开一炮，并按情绪染色。
# slot 与 Scene/DayPassAnimation.tscn 里四个剪影的**摆放顺序**一致：
# 0 农民 · 1 工人 · 2 士兵 · 3 商人（不是 GroupData.READERS 的枚举顺序）。
# fake = 这条是假新闻：情绪色往灰里拉，读作"他们信了，但这是假的"。
func fire_one(slot : int, mood : String, strength : float, fake : bool = false) -> void:
	var list : Array[GPUParticles2D] = emitters()
	if slot < 0 or slot >= list.size():
		return
	var emitter : GPUParticles2D = list[slot]
	# 贴图是纯白 icon：染色靠 modulate，不换素材。
	var color : Color = ReactionData.MOOD_COLOR.get(mood, Color.WHITE)
	if fake:
		color = color.lerp(Color(0.72, 0.72, 0.72), ReactionData.FAKE_DESATURATE)
	fire_one_tinted(slot, color, strength)

# 指定颜色的那一炮：状态换档用状态自己的颜色（UiColors），不套情绪色。
func fire_one_tinted(slot : int, color : Color, strength : float) -> void:
	var list : Array[GPUParticles2D] = emitters()
	if slot < 0 or slot >= list.size():
		return
	var emitter : GPUParticles2D = list[slot]
	emitter.modulate = color
	emitter.amount = int(round(lerpf(
		float(ReactionData.EMOJI_BASE), float(ReactionData.EMOJI_MAX), clampf(strength, 0.0, 1.0))))
	emitter.texture = random_texture()
	emitter.restart()
	emitter.emitting = true

# 把四家都收干净（重播 / 退出过场时用）。
func clear() -> void:
	for emitter in emitters():
		emitter.emitting = false
		emitter.modulate = Color.WHITE

# 只换贴图、不发射。
func randomize_textures() -> void:
	for emitter in emitters():
		emitter.texture = random_texture()

# 四个发射器。
func emitters() -> Array[GPUParticles2D]:
	return [emoji_partcle, emoji_partcle_2, emoji_partcle_3, emoji_partcle_4]

func random_texture() -> Texture2D:
	if ALL_EMOJIS.is_empty():
		return null
	return ALL_EMOJIS[randi() % ALL_EMOJIS.size()]
