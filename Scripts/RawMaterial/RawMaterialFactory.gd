class_name RawMaterialFactory extends Node

# 素材池至少要有这么多条。
const MIN_POOL : int = 6

# 一次补好几张软新闻时，让它们隔开这么多秒起飞，别全糊在屏幕中央。
const STAGGER : float = 0.06

var container : HBoxContainer
# 用路径而不是 uid。
const RAW_MATERIAL = preload("res://Scene/RawMaterial.tscn")

# 今天还没落进池子的**大新闻**：排队等玩家看完详情。
var _pending_big : Array[NewsResource] = []

# 软新闻要补几条。
var _filler_count : int = 0

func SetUp(p_container : HBoxContainer) -> void:
	container = p_container

func _ready() -> void:
	EventBus.game_start.connect(fill_pool)
	EventBus.action_end.connect(_on_action_end)
	EventBus.detail_closed.connect(_on_detail_closed)
	EventBus.government_offer_taken.connect(_on_government_offer_taken)
	EventBus.government_offer_res.connect(_on_government_offer_res)

func _on_action_end() -> void:
	# 这一局已经到头了：不再铺明天的素材（终刊号正压在这上面）。
	if EndingManager.ended:
		return
	fill_pool()

# 政府递来的那条：当场落进池子。算不算假新闻由信上那个开关定。
func _on_government_offer_taken(event : int, is_fake : bool) -> void:
	_add_card(NewsData.pick(event), 0.0, is_fake)

# 主线来信附的那张稿子：信里已经写好了，直接落进池子。
func _on_government_offer_res(res : NewsResource, is_fake : bool) -> void:
	_add_card(res, 0.0, is_fake)

# 把素材池铺满。
func fill_pool() -> void:
	if container == null:
		return
	
	for i in container.get_children():
		i.queue_free()
	
	_pending_big.clear()
	_filler_count = 0
	
	# 顺便数一遍今天有几条**真新闻**（不是软新闻的那些）。
	RawMaterialGenerater.real_news_count = 0

	# 主线大事件：摇的时候就定好了是哪一条，这里不再走 NewsData.pick()。
	for res in RawMaterialGenerater.scripted_big:
		if res == null:
			continue
		RawMaterialGenerater.real_news_count += 1
		EventBus.big_news_appeared.emit(res, res.type)
		_pending_big.append(res)
	RawMaterialGenerater.scripted_big.clear()

	for i in RawMaterialGenerater.material_list:
		var material : NewsData.NewsType = i
		
		# 这条边今天用哪种说法，是在这里定的：同一件事每次说法不同，。
		var res : NewsResource = NewsData.pick(material)
		if res == null:
			continue
		
		if not res.is_filler:
			RawMaterialGenerater.real_news_count += 1
			# 广播出去：大新闻档案（FakeNewsList）、以后的假新闻系统……谁关心谁去听。
			EventBus.big_news_appeared.emit(res, material)
			_pending_big.append(res)
			continue
		
		# 软新闻：直接铺就够了，它本来就不是"今天发生了什么"。
		_add_card(res)
	
	# 真新闻铺完了。
	_filler_count = maxi(MIN_POOL - RawMaterialGenerater.real_news_count, 0)
	
	RawMaterialGenerater.material_list.clear()
	
	_show_next_big()

# 弹下一张大新闻的详情；队列空了就补软新闻，收工。
func _show_next_big() -> void:
	if not _pending_big.is_empty():
		# 今天出事了——这一声是给玩家的：接下来弹出来的东西，必须看。
		AudioManager.play(AudioManager.Sound.DETAIL)
		EventBus.need_show_detail.emit(_pending_big[0], false, EventBus.DETAIL_QUEUE)
		return
	
	_fill_fillers()

# 玩家关掉了详情面板（点了"我知道了"）。
func _on_detail_closed(source : int) -> void:
	if source != EventBus.DETAIL_QUEUE:
		return
	if _pending_big.is_empty():
		return

	var res : NewsResource = _pending_big.pop_front()
	_add_card(res)
	_show_next_big()

# 补软新闻。
func _fill_fillers() -> void:
	if _filler_count <= 0:
		return
	var i : int = 0
	for filler in NewsData.random_fillers(_filler_count):
		_add_card(filler, i * STAGGER)
		i += 1
	_filler_count = 0

# 存档：还压在详情队列里的那一叠

# 队列里的大新闻（只存 .tres 路径）+ 该补几条软新闻。
func snapshot_pending() -> Dictionary:
	var paths : Array[String] = []
	for res in _pending_big:
		paths.append(res.resource_path if res != null else "")
	return {
		"big" : paths,
		"filler_count" : _filler_count,
	}

# 读档：把那一叠摆回来。
func restore_pending(data : Dictionary) -> void:
	_pending_big.clear()
	for path in data.get("big", []):
		var p : String = String(path)
		if p == "" or not ResourceLoader.exists(p):
			continue
		var res : NewsResource = load(p) as NewsResource
		if res != null:
			_pending_big.append(res)
	_filler_count = int(data.get("filler_count", 0))
	# 存档那一刻玩家正卡在这一叠里：把队首那张重新摆到他面前。
	_show_next_big()

# 存档：按 [[res 路径, 真假], …] 直接把池子铺回来。
func restore_pool(entries : Array) -> void:
	if container == null:
		return
	for child in container.get_children():
		child.queue_free()
	for entry in entries:
		var path : String = entry.get("res", "")
		if path == "" or not ResourceLoader.exists(path):
			continue
		var card : RawMaterial = RAW_MATERIAL.instantiate()
		card.is_fake = bool(entry.get("fake", false))
		card.setup(load(path))
		container.add_child(card)

# 落一张卡片进池子。
func _add_card(res : NewsResource, delay : float = 0.0, fake : bool = false) -> void:
	if container == null or res == null:
		return
	var card : RawMaterial = RAW_MATERIAL.instantiate()
	# is_fake 要在 setup() **之前**设：RawMaterial._apply() 读它来上色。
	card.is_fake = fake
	card.setup(res)
	container.add_child(card)
	RawMaterialAnimation.play(card, container, delay)
