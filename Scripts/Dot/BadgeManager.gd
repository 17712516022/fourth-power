extends Node

# 红点（Badge）总账 —— 自动加载，名叫 BadgeManager。

const SEP : String = "/"

var _newest : Dictionary = {}
var _seen : Dictionary = {}
var _dots : Dictionary = {}

# 任何一个 key 的水位变了都会发。
signal changed

# 写

# 发生了一件值得提醒的事。
func push(key : String, count : int = 1) -> void:
	if key == "":
		return
	_newest[key] = int(_newest.get(key, 0)) + maxi(count, 1)
	_refresh(key)

# 玩家看到了这个入口：水位推到最新，红点自然灭。
func mark_seen(key : String) -> void:
	if key == "":
		return
	_seen[key] = int(_newest.get(key, 0))
	# 子级也一并算看过——点开"政府"就等于里面几项都看过了。
	for k in _newest.keys():
		if String(k).begins_with(key + SEP):
			_seen[k] = int(_newest[k])
	_refresh(key)

# 开新一局：账目清零（读档不走这里，走 restore）。
func reset() -> void:
	var touched : Array = _dots.keys()
	_newest.clear()
	_seen.clear()
	for k in touched:
		_push_to(String(k))
	changed.emit()

# 读

# 这个入口有多少件没看：自己 + 所有子级。
func unread(key : String) -> int:
	var total : int = maxi(0, int(_newest.get(key, 0)) - int(_seen.get(key, 0)))
	for k in _newest.keys():
		var ks : String = String(k)
		if ks.begins_with(key + SEP):
			total += maxi(0, int(_newest[k]) - int(_seen.get(k, 0)))
	return total

# 红点组件

# 红点组件在 _ready 里注册自己：此后这个 key 一动，它就跟着变。
func bind(key : String, dot : Node) -> void:
	if key == "" or dot == null:
		return
	if not _dots.has(key):
		_dots[key] = []
	if not (_dots[key] as Array).has(dot):
		(_dots[key] as Array).append(dot)
	_push_to(key)

# 存档

func snapshot() -> Dictionary:
	return {"newest" : _newest.duplicate(), "seen" : _seen.duplicate()}

func restore(data : Dictionary) -> void:
	_newest.clear()
	_seen.clear()
	for k in data.get("newest", {}).keys():
		_newest[String(k)] = int(data["newest"][k])
	for k in data.get("seen", {}).keys():
		_seen[String(k)] = int(data["seen"][k])
	for k in _dots.keys():
		_push_to(String(k))
	changed.emit()

# 内部

# 一个 key 变了：它自己和它所有的**父级**都要重推（父级是汇总出来的）。
func _refresh(key : String) -> void:
	_push_to(key)
	var parent : String = key
	while parent.contains(SEP):
		parent = parent.substr(0, parent.rfind(SEP))
		_push_to(parent)
	changed.emit()

func _push_to(key : String) -> void:
	if not _dots.has(key):
		return
	var n : int = unread(key)
	for dot in _dots[key]:
		if is_instance_valid(dot):
			dot.set_state(n > 0, n)
