class_name ReactionData extends RefCounted

# 过场里"群体对一条新闻的反应"的全部可调参数。
# 判定"谁、什么情绪、多强"在 Scripts/DayPass/NewsReaction.gd；
# 这里只管"怎么演"。


# —— 判定 ——

# 推量低于这个数就当这条新闻对这个群体没影响。
# 现成的推量是 0.036 / 0.054 / 0.072 / 0.09 四档（见 Resource/news/InflunceGroup）。
const THRESHOLD : float = 0.02

# 推量到这个值 = 满强度。
const PUSH_REFERENCE : float = 0.09

# 大事件直接改属性，量级更大（常见 0.1），单独归一。
const BIG_REFERENCE : float = 0.12

# 再怎么弱，也要看得出动了（强度下限）。
const MIN_STRENGTH : float = 0.35


# —— 演出 ——

# 一条新闻摆出来时，群体反应的时长；必须 < DayPassAnimation.CARD_HOLD（0.8）。
const REACT_TIME : float = 0.45

# 愤怒是左右抖，时间短了看不出"抖"，单独给长一点。
const SHAKE_TIME : float = 0.50

# 情绪 → 粒子染色。贴图是纯白 icon（asserts/图标包/.../white/11-symbols），
# 直接 modulate 就能上色，不需要美术再出一套彩色图。
const MOOD_COLOR : Dictionary = {
	"happy" : Color(1.0, 0.80, 0.32),   # 金：称心
	"angry" : Color(1.0, 0.34, 0.26),   # 红：上火
	"fear"  : Color(0.46, 0.72, 1.0),   # 蓝：发怵
	"power" : Color(0.78, 0.84, 0.95),  # 钢：来劲
	"sad"   : Color(0.52, 0.58, 0.72),  # 灰蓝：丧气
}

# 情绪 → 剪影一个动作的最大位移（像素）。
# 剪影是 0.3 缩放，所以 5~7px 在这里等于 17~23px 的观感。
const MOOD_OFFSET : Dictionary = {
	"happy" : Vector2(0.0, 7.0),   # 往上跳
	"angry" : Vector2(5.0, 0.0),   # 左右抖
	"fear"  : Vector2(6.0, 4.0),   # 往后缩
	"power" : Vector2(0.0, 5.0),   # 沉一下再起
	"sad"   : Vector2(0.0, 4.0),   # 往下塌
}

# 粒子数量：强度 0 → BASE，强度 1 → MAX。
const EMOJI_BASE : int = 10
const EMOJI_MAX : int = 26

# 每个群体最多几条人声。四家同时反应时 = 4 条，和原来"随机 4 条"一样多。
const VOICE_MAX : int = 2


# —— 个体差异：四家不是四个复制人 ——

# 同一帧四个人一起抖，会像机器。按场景顺序（农民·工人·士兵·商人）错开一点。
# 最晚 0.15s 起手，加上动作 0.45s，仍然在 CARD_HOLD（0.8s）之内。
const REACT_STAGGER : Array[float] = [0.00, 0.05, 0.10, 0.15]

# 同一件事，四家的反应幅度也不该一样：农民最闹、工人次之、士兵最稳（军人不轻易动）、
# 商人偏克制。全部 ≤1，强度拉满时也还留着差别（超过 1 会被 clamp 掉）。
const REACT_SCALE : Array[float] = [1.00, 0.96, 0.86, 0.94]


# —— 反应归属：谁被写到，谁亮 ——

# 没被写到的那几家压暗到多少（alpha）。
const DIM_ALPHA : float = 0.75

# 被写到的那家放大多少（倍）。
const HIGHLIGHT_SCALE : float = 1.03

# 闪白强度：0 = 原色，1 = 全白。
const HIGHLIGHT_FLASH : float = 0.85

# 闪白：进得快、退得慢（0.08 + 0.30 ≈ 0.4s，卡在 CARD_HOLD 之内）。
const HIGHLIGHT_IN : float = 0.08
const HIGHLIGHT_OUT : float = 0.30


# —— 背景情绪染色 ——

# 整幅城景往情绪色偏多少：0.10 已经能看出来，再高就抢戏了。
const TINT_STRENGTH : float = 0.10

# 染色总时长 ≈ 0.38s。
const TINT_IN : float = 0.10
const TINT_OUT : float = 0.28


# —— 假新闻的失真 ——

# 假新闻的粒子往灰里拉多少（0 = 保持情绪色，1 = 全灰）。
const FAKE_DESATURATE : float = 0.65


# —— 状态换档的"变天" ——
# 这一段插在 _pass_day 之后、抬滚筒之前：满墨的黑底，四家站在下面，谁换档谁动。

# 整段时长（只在有人换档的日子才会花掉这段时间）。
const STATE_BEAT_TIME : float = 2.20

# 换档的动作要比读报久：字停在那儿的时候，人不能已经站定。
const STATE_MOTION_TIME : float = 0.90

# 第二炮粒子的时点：一段 2.2 秒的戏，只喷一次会显得前半段就演完了。
const STATE_SECOND_BURST : float = 0.55

# 每一行横幅：淡入 / 停 / 淡出。多行按 STAGGER 依次出现。
const STATE_FADE_IN : float = 0.22
const STATE_HOLD : float = 1.15
const STATE_FADE_OUT : float = 0.30
const STATE_LINE_STAGGER : float = 0.08

# 横幅的位置与字号（全宽居中，一行一行往下排）。
# 四行最多占到 30 + 4×46 = 214，正好压在剪影（约 235 起）上面，不会挡人。
const STATE_BANNER_TOP : float = 30.0
const STATE_LINE_HEIGHT : float = 46.0
const STATE_FONT_SIZE : int = 32
