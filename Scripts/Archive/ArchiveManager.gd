extends Node

# 图鉴 —— 自动加载，名叫 ArchiveManager。

const NEWS_FILE : String = "user://archive.cfg"
const ENDING_FILE : String = "user://endings.cfg"
const SECTION : String = "archive"

# 书架（按 NewsType 的序号分段，见 NewsData.NewsType）
enum Shelf {
	Farmer,
	Worker,
	Merchant,
	Officer,
	Government,
	Event,
	Misc,
}

# catalog() 照这个顺序铺格子（Enum.values() 在这里不保证可用，写死更稳）。
const SHELVES : Array = [
	Shelf.Farmer, Shelf.Worker, Shelf.Merchant,
	Shelf.Officer, Shelf.Government, Shelf.Event, Shelf.Misc,
]

# NewsType 的分段末位
const FARMER_LAST : int = 7
const WORKER_LAST : int = 17
const MERCHANT_LAST : int = 27
const OFFICER_LAST : int = 35
const GOVERNMENT_LAST : int = 68
const EVENT_ONLY : int = 69

# resource_path -> {"day" : 首次登在第几天, "count" : 一共登了几次}
var _news : Dictionary = {}
# EndingData.Id -> true
var _endings : Dictionary = {}


func _ready() -> void:
	_load_endings()
	_load_news()
	EventBus.paper_ready.connect(_on_paper_ready)
	EventBus.ending_reached.connect(_on_ending_reached)


# 埋点：这一份报纸印出去了，版面里每一条都记一笔。
func _on_paper_ready(paper : NewsPaper) -> void:
	if paper == null:
		return
	for index in paper.events.size():
		var res : NewsResource = paper.events[index]
		if res == null:
			continue
		var key : String = res.resource_path
		if key == "":
			continue
		var entry : Dictionary = _news.get(key, {"day" : EndingManager.day, "count" : 0})
		entry["count"] = int(entry["count"]) + 1
		_news[key] = entry
	# 每印一期就落盘：菜单里的图鉴永远是最新的，和有没有存档无关。
	_save_news()


func _on_ending_reached(id : int) -> void:
	if id == EndingData.Id.None or _endings.has(id):
		return
	_endings[id] = true
	_save_endings()


# 读

func seen(key : String) -> bool:
	return _news.has(key)


func entry_of(key : String) -> Dictionary:
	return _news.get(key, {})


func news_count() -> int:
	return _news.size()


func ending_seen(id : int) -> bool:
	return _endings.has(id)


func ending_count() -> int:
	return _endings.size()


# 全量清单：书架 -> Array[NewsResource]（图鉴面板照着它铺格子）
func catalog() -> Dictionary:
	var out : Dictionary = {}
	for shelf in SHELVES:
		out[shelf] = []
	for type in NewsData.res_dic.keys():
		var shelf : int = shelf_of(int(type))
		for res in NewsData.res_dic[type]:
			if res is NewsResource:
				(out[shelf] as Array).append(res)
	return out


func shelf_of(type : int) -> int:
	if type <= FARMER_LAST:
		return Shelf.Farmer
	if type <= WORKER_LAST:
		return Shelf.Worker
	if type <= MERCHANT_LAST:
		return Shelf.Merchant
	if type <= OFFICER_LAST:
		return Shelf.Officer
	if type <= GOVERNMENT_LAST:
		return Shelf.Government
	if type == EVENT_ONLY:
		return Shelf.Event
	return Shelf.Misc


# 新闻那份文件

func _load_news() -> void:
	_news.clear()
	var cfg : ConfigFile = ConfigFile.new()
	if cfg.load(NEWS_FILE) != OK:
		return
	var raw : Variant = cfg.get_value(SECTION, "news", {})
	if not (raw is Dictionary):
		return
	for key in (raw as Dictionary).keys():
		if raw[key] is Dictionary:
			_news[String(key)] = (raw[key] as Dictionary).duplicate(true)


func _save_news() -> void:
	var cfg : ConfigFile = ConfigFile.new()
	cfg.set_value(SECTION, "news", _news)
	cfg.save(NEWS_FILE)


# 开新一局：这一局的报纸从零开始。
func reset() -> void:
	_news.clear()
	_save_news()


# 结局那份文件

func _load_endings() -> void:
	_endings.clear()
	var cfg : ConfigFile = ConfigFile.new()
	if cfg.load(ENDING_FILE) != OK:
		return
	for id in cfg.get_value(SECTION, "seen", []):
		_endings[int(id)] = true


func _save_endings() -> void:
	var ids : Array = []
	for id in _endings.keys():
		ids.append(int(id))
	ids.sort()
	var cfg : ConfigFile = ConfigFile.new()
	cfg.set_value(SECTION, "seen", ids)
	cfg.save(ENDING_FILE)
