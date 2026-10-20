class_name NewsReaction extends RefCounted

# 一条新闻 → 四家各自心里怎么想。纯函数：不碰节点、不摇随机数，方便单独验。
#
# 现有 .tres 的符号规律（把 Resource/news/InflunceGroup 全扫过一遍才敢这么写）：
#   好消息（各种 *End / Return / Rally / 发饷 / 和解）：happy 一律是**负**的
#       —— 阈值往下压，说明"幸福线"更好满足。
#   坏消息（各种 *Start / 屠杀 / 镇压 / 征税）：
#       happy 是正的（把幸福线抬高），但 angry / fear 的符号**并不统一**
#       —— WorkerDepressionStart 写 angry = -0.09，SoldierRampageStart 写 fear = +0.054，
#       两者都是坏消息。所以坏消息这边只看**量**，不看符号。
#   结论：
#     happy 的符号 = 好/坏；
#     angry / fear / power 的绝对值 = 是哪一种情绪。
#
#   BigEventEffect 不一样：它是直接改属性的，四个数的符号就是情绪方向，照抄即可。


# 每个群体在 16 字段表里的前缀。
static func _who(reader : int) -> String:
	match reader:
		GroupData.READERS.WORKER:
			return "worker"
		GroupData.READERS.MERCHANT:
			return "merchant"
		GroupData.READERS.SOLDIER:
			return "soldier"
		_:
			return "farmer"

# 要判的四家：过场里只有这四个剪影（政府和公众没有剪影）。
static func _readers() -> Array[int]:
	return [
		GroupData.READERS.FARMER,
		GroupData.READERS.WORKER,
		GroupData.READERS.MERCHANT,
		GroupData.READERS.SOLDIER,
	]


# 一条新闻的全部反应：每条 = { reader, mood, strength }。
# 软新闻（天气 / 漫画 / 小说）没人理会，返回空数组。
static func of(res : NewsResource) -> Array[Dictionary]:
	var none : Array[Dictionary] = []
	if res == null or res.is_filler:
		return none
	if res.big_effect != null:
		return _from_big(res.big_effect)
	var influence : InfluenceGroup = PolicyPush.influence_of(res)
	if influence != null:
		return _from_push(influence)
	return none


# 普通新闻：推量 → 情绪。
static func _from_push(push : InfluenceGroup) -> Array[Dictionary]:
	var out : Array[Dictionary] = []
	for reader in _readers():
		var who : String = _who(reader)
		var happy : float = float(push.get(who + "_happy"))
		var angry : float = absf(float(push.get(who + "_angry")))
		var fear : float = absf(float(push.get(who + "_fear")))
		var power : float = absf(float(push.get(who + "_power")))
		var one : Dictionary = _judge_push(reader, happy, angry, fear, power)
		if not one.is_empty():
			out.append(one)
	return out


# 一条推量表 → 一个情绪 + 强度。
static func _judge_push(reader : int, happy : float,
		angry : float, fear : float, power : float) -> Dictionary:
	var biggest : float = maxf(maxf(absf(happy), angry), maxf(fear, power))
	if biggest < ReactionData.THRESHOLD:
		# 推量太小：这条新闻对这个群体等于没说。
		return {}

	# 好消息：笑脸。其他维度哪怕是"怒气被压下去"，也不该演成生气。
	var mood : String = "happy" if happy < 0.0 else ""
	if mood == "":
		# 坏消息：谁的量最大，就是哪种脸色。
		if power >= angry and power >= fear and power >= absf(happy) and power >= ReactionData.THRESHOLD:
			mood = "power"
		elif angry >= fear and angry >= ReactionData.THRESHOLD:
			mood = "angry"
		elif fear >= ReactionData.THRESHOLD:
			mood = "fear"
		else:
			# 只是"幸福线被抬高"：说不出名目的憋闷。
			mood = "sad"

	return {
		"reader" : reader,
		"mood" : mood,
		"strength" : clampf(biggest / ReactionData.PUSH_REFERENCE, ReactionData.MIN_STRENGTH, 1.0),
	}


# 大事件：直接改属性 → 情绪（这里符号是可信的）。
static func _from_big(eff : BigEventEffect) -> Array[Dictionary]:
	var out : Array[Dictionary] = []
	for reader in _readers():
		var who : String = _who(reader)
		var joy : float = float(eff.get(who + "_happy"))
		var angry : float = float(eff.get(who + "_angry"))
		var fear : float = float(eff.get(who + "_fear"))
		var power : float = float(eff.get(who + "_power"))
		var one : Dictionary = _judge_effect(reader, joy, angry, fear, power)
		if not one.is_empty():
			out.append(one)
	return out


# 大事件：取最大的正向那一维（负值代表这一维在下降，不是"更生气"）。
static func _judge_effect(reader : int, joy : float,
		angry : float, fear : float, power : float) -> Dictionary:
	var biggest : float = maxf(maxf(absf(joy), absf(angry)), maxf(absf(fear), absf(power)))
	if biggest < ReactionData.THRESHOLD:
		return {}

	# 平手时的优先顺序：怒 > 怕 > 底气 > 喜（越靠前的越抢眼）。
	var mood : String = ""
	var best : float = 0.0
	for row in [["angry", angry], ["fear", fear], ["power", power], ["happy", joy]]:
		if float(row[1]) > best:
			best = float(row[1])
			mood = String(row[0])

	if mood == "":
		# 四个数都不为正：不是"高兴"，只是"平静地变糟"。
		mood = "sad"

	return {
		"reader" : reader,
		"mood" : mood,
		"strength" : clampf(biggest / ReactionData.BIG_REFERENCE, ReactionData.MIN_STRENGTH, 1.0),
	}
