class_name NewsPaperGenerator extends Control

# 它自己就是版面：**子节点全是版位，一格一个坑。

func _ready() -> void:
	EventBus.paper_need_create.connect(_on_paper_need_create)

func _on_paper_need_create() -> void:
	# 玩家排完版，按了决定 —— 把这一版抄成一份报纸。
	var paper : NewsPaper = build()
	# 交给世界之前，先让信誉随今天的内容动一动。
	NewsPaperManager.settle_influence(paper)
	# 而"交给世界"不在这里：报纸先送到过天黑场，等屏幕黑透了它才发 day_passed。
	EventBus.paper_ready.emit(paper)

# 把版面上排好的东西收成一份报纸。
func build() -> NewsPaper:
	var today : Array[NewsResource] = []
	var fake_flags : Array[bool] = []
	for i in get_children():
		# 版面下挂的是版位（RawMaterialSlot），不是素材卡片（RawMaterial）。
		if not (i is RawMaterialSlot):
			continue
		var slot : RawMaterialSlot = i
		if slot.res == null:
			continue
		today.append(slot.res)
		# 假新闻的"假"要一路活到结算那一步，所以在抄内容的时候一起抄下来。
		fake_flags.append(slot.is_fake)
	return NewsPaper.new(today, fake_flags)
