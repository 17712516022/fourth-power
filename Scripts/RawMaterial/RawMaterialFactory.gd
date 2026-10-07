class_name RawMaterialFactory extends Node

# 素材池至少要有这么多条。
#
# 它应该**等于版面上的坑位数**——池子比坑位少，玩家就排不满，
# 每天必然被扣"漏新闻"的分。以后改版式（加栏、减栏）时，
# 这个数要跟着一起改，否则会悄悄变成"永远差一条"。
const MIN_POOL : int = 6

var container : HBoxContainer
# 用路径而不是 uid。
#
# 这里本来写的是 uid://ccbuk5e5840cv——那是 raw_material.tscn 改名成
# RawMaterial.tscn 之前的号，改名后它换了新 uid，而这个号被
# raw_material_detail.tscn 继承了。于是素材工厂会实例化出详情面板。
# 路径不会这样悄悄易主。
const RAW_MATERIAL = preload("res://Scene/RawMaterial.tscn")

func SetUp(p_container : HBoxContainer) -> void:
	container = p_container

func _ready() -> void:
	EventBus.game_start.connect(fill_pool)
	EventBus.action_end.connect(_on_action_end)

func _on_action_end() -> void:
	fill_pool()

# 把素材池铺满。
func fill_pool() -> void:
	if container == null:
		return                 # 容器还没注入：等 Ui 装配完再铺
	
	for i in container.get_children():
		i.queue_free()
	
	# 顺便数一遍今天有几条**真新闻**（不是软新闻的那些）。
	# 必须在下面 clear() 之前数完——那是报纸结算要用、而清空之后就再也拿不到的数。
	RawMaterialGenerater.real_news_count = 0
	
	# 铺了几条。queue_free() 是延迟的，所以不能事后去数子节点，
	# 只能在这里自己记。
	var printed : int = 0
	
	for i in RawMaterialGenerater.material_list:
		var material : NewsData.NewsType = i
		
		# 这条边今天用哪种说法，是在这里定的：同一件事每次说法不同，
		# 否则世界一轮一轮循环，报纸天天说一样的话。
		var res : NewsResource = NewsData.pick(material)
		if res == null:
			continue                 # 这条边还没配素材：跳过，别塞个空格子
		
		# 统计放在 pick 之后：只有真的铺进池子的才算“今天发生了”。
		# 顺带一提，软新闻与真新闻是**按边**区分的，同一条边的三个版本
		# 在这件事上完全一致，所以从任意一个版本上读都行。
		if not res.is_filler:
			RawMaterialGenerater.real_news_count += 1
			# 广播出去：大新闻档案（FakeNewsList）、以后的假新闻系统……谁关心谁去听。
			# 重复出现在这里不拦——去重是听的人的事。
			EventBus.big_news_appeared.emit(res, material)
		
		var new_raw_material_scene : RawMaterial = RAW_MATERIAL.instantiate()
		new_raw_material_scene.setup(res)
		container.add_child(new_raw_material_scene)
		printed += 1
	
	# 真新闻铺完了。不够短，就用软新闻补足。
	var short_by : int = MIN_POOL - printed
	if short_by > 0:
		for filler in NewsData.random_fillers(short_by):
			var filler_scene : RawMaterial = RAW_MATERIAL.instantiate()
			filler_scene.setup(filler)
			container.add_child(filler_scene)
	
	RawMaterialGenerater.material_list.clear()
