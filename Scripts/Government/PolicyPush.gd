class_name PolicyPush extends RefCounted

# 政策层改属性，新闻层推阈值。
#
# 政府动作走完时，这里记下"这次动作给谁改了多少"；发新闻时折成阈值推量（取反）：
#   政策让商人怒 +0.024  ->  新闻把商人的"怒"阈值推 -0.024。
# 读报时政府新闻不再读 .tres 里手写的 influnce，改用这里生成的推量；
# 事件新闻（农夫/工匠/商人/士兵自己的状态稿）仍走原来的静态卡。

# 政策改 1 点，新闻就推 1 点。嫌猛就改这里。
const SCALE : float = 1.0
const DIMS : Array = ["happy", "fear", "angry"]

# 本次政府动作：{who: {dim: delta}}
static var _recording : Dictionary = {}
# 已经生成、等着上报纸的推量：{str(type): {who: {dim: push}}}
static var _next : Dictionary = {}
# 正在读的那一期报纸用的推量
static var _active : Dictionary = {}
# 生成过的 InfluenceGroup，按新闻类型缓存
static var _cache : Dictionary = {}
# 没有推量时给一个空表：UI 会把它读成"没什么动静"，而不是"说不上来"。
static var _empty : InfluenceGroup = null


static func reset() -> void:
	_recording.clear()
	_next.clear()
	_active.clear()
	_cache.clear()


# 每天政府只动一次手，动手前把上一笔清掉。
static func begin() -> void:
	_recording.clear()


# 政策改了某一家的某一维，记一笔。
static func note(kind : int, dim : String, delta : float) -> void:
	if not DIMS.has(dim):
		return
	var who : String = _who(kind)
	if who == "":
		return
	var per : Dictionary = _recording.get(who, {})
	per[dim] = float(per.get(dim, 0.0)) + delta
	_recording[who] = per


# 政府动作发出新闻时调：把这一笔按新闻类型存起来，等读报时用。
static func commit(type : int) -> void:
	if not NewsData.is_government(type):
		return
	if _recording.is_empty():
		return
	var key : String = str(type)
	var entry : Dictionary = _next.get(key, {})
	for who in _recording:
		var per : Dictionary = entry.get(who, {})
		var rec : Dictionary = _recording[who]
		for dim in rec:
			per[dim] = float(per.get(dim, 0.0)) - float(rec[dim]) * SCALE
		entry[who] = per
	_next[key] = entry
	_recording.clear()


# 过天时，把上一轮生成的推量抬成"正在读的这一期"。
static func promote() -> void:
	_active = _next
	_next = {}
	_cache.clear()


# 读报：读的是已经登出去的那一期，用 _active。
# 政府新闻没有对应记录时返回 null（宁可没有，也不退回手写卡）。
static func influence_of(res : NewsResource) -> InfluenceGroup:
	if res == null:
		return null
	if not NewsData.is_government(res.type):
		return res.influnce
	var key : String = str(res.type)
	if not _active.has(key):
		return _no_push()
	return _build(_active[key], "a:" + key)


# 悬停预览：手里这张还没登，优先看 _next；没有再看正在读的那期（比如说明信）。
static func influence_preview(res : NewsResource) -> InfluenceGroup:
	if res == null:
		return null
	if not NewsData.is_government(res.type):
		return res.influnce
	var key : String = str(res.type)
	if _next.has(key):
		return _build(_next[key], "n:" + key)
	if _active.has(key):
		return _build(_active[key], "a:" + key)
	return _no_push()


static func _no_push() -> InfluenceGroup:
	if _empty == null:
		_empty = InfluenceGroup.new()
	return _empty


static func _build(entry : Dictionary, cache_key : String) -> InfluenceGroup:
	if _cache.has(cache_key):
		return _cache[cache_key] as InfluenceGroup
	var inf : InfluenceGroup = InfluenceGroup.new()
	for who in entry:
		var per : Dictionary = entry[who]
		for dim in per:
			inf.set("%s_%s" % [who, dim], float(per[dim]))
	_cache[cache_key] = inf
	return inf


# 存档：只存"还没上报纸"的那一份；正在读的那份过完今天就没了。
static func snapshot() -> Dictionary:
	return _next.duplicate(true)


static func restore(data : Variant) -> void:
	_next = data.duplicate(true) if data is Dictionary else {}
	_active = {}
	_cache.clear()
	_recording.clear()


static func _who(kind : int) -> String:
	match kind:
		GroupData.READERS.WORKER:
			return "worker"
		GroupData.READERS.MERCHANT:
			return "merchant"
		GroupData.READERS.SOLDIER:
			return "soldier"
		GroupData.READERS.FARMER:
			return "farmer"
		_:
			return ""
