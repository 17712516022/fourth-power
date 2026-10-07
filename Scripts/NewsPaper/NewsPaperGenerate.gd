class_name NewsPaperGenerator extends Control

# 它自己就是版面：**子节点全是版位，一格一个坑。**
# 所以要加一栏，是在场景里加一个节点，不是来这里改代码。

func _ready() -> void:
	EventBus.paper_need_create.connect(_on_paper_need_create)

func _on_paper_need_create() -> void:
	# 玩家排完版，按了决定 —— 世界就按这份报纸往前走一天。
	var paper : NewsPaper = build()
	# 交给世界之前，先让信誉随今天的内容动一动
	NewsPaperManager.settle_influence(paper)
	EventBus.day_passed.emit(paper)

# 把版面上排好的东西收成一份报纸。
# 关键是**在这一刻把内容抄下来**：收 slot.res，不收 slot 本身。
# 版位之后被换内容、被释放，都与这份报纸无关了。
func build() -> NewsPaper:
	var today : Array[NewsResource] = []
	for i in get_children():
		# 版面下挂的是版位（RawMaterialSlot），不是素材卡片（RawMaterial）。
		if not (i is RawMaterialSlot):
			continue
		var slot : RawMaterialSlot = i
		if slot.res == null:
			continue                # 空版位：没排东西，不进报纸
		today.append(slot.res)
	return NewsPaper.new(today)
