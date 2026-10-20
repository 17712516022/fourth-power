class_name World extends Node2D

@onready var groups: Node = %Groups
@onready var government : Government = $Government

func _ready() -> void:
	# 把政府交给每个群体。
	for i in groups.get_children():
		var group : Group = i
		group.government = government
	
	# 先按开局那一眼把系数摆好：政府现在每天**第一个**动，。
	_sync_modifers()

	EventBus.day_passed.connect(_on_day_passed)

func _on_day_passed(newspaper : NewsPaper) -> void:
	_on_tick(newspaper)
	EventBus.action_end.emit()

func _on_tick(newspaper : NewsPaper) -> void:
	# 手上这张报纸的推量，是上一轮政府动作生成的：先抬成"正在读的一期"，
	# 再让政府动今天的手（它生成的是下一期报纸的推量）。
	PolicyPush.promote()

	# 今天有没有大事：每天五成。
	RawMaterialGenerater.roll_big_event()

	# 政府先动手**：它看的是**昨天结束时**各家的处境（第一天就是开局那一眼），。
	government.step(groups)

	# 然后每个群体过今天：日子 -> 世界与政府的影响 -> 报纸 -> 决定去哪个状态。
	for i in groups.get_children():
		var group : Group = i
		group.step(newspaper)

	# 群体今天的处境 -> 全局系数（**明天**的政府过日子时读它）。
	_sync_modifers()


# 存档：读档后把系数按恢复的群体状态重算一遍。
func sync_modifers() -> void:
	_sync_modifers()

# 群体今天的处境 -> 全局系数（Modifer）。
func _sync_modifers() -> void:
	for i in groups.get_children():
		if i is Farmers:
			var farmers : Farmers = i
			Modifer.yield_modifer = farmers.state_machine.current_state.yield_multiple()
		elif i is Workers:
			var workers : Workers = i
			Modifer.industry_modifer = workers.state_machine.current_state.industry_multiple()
		elif i is Merchants:
			var merchants : Merchants = i
			Modifer.tax_modifer = merchants.state_machine.current_state.tax_multiple()
