class_name World extends Node2D

@onready var groups: Node = %Groups
@onready var government : Government = $Government

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	# 把政府交给每个群体。
	# 必须在第一天之前做完——群体的 _live() 从第一天起就要读粮仓。
	for i in groups.get_children():
		var group : Group = i
		group.government = government
	
	EventBus.day_passed.connect(_on_day_passed)

func _on_day_passed(newspaper : NewsPaper) -> void:
	_on_tick(newspaper)
	EventBus.action_end.emit()

func _on_tick(newspaper : NewsPaper) -> void:
	# 先让每个群体过完今天
	for i in groups.get_children():
		var group : Group = i
		group.step(newspaper)

	# 政府最后看一遍世界，决定明天压还是抚。
	# 放在最后是有意的：它看到的永远是已经发生的事，不是预测。
	government.step(groups)
