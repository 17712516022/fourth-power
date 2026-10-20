class_name NewsPaper extends RefCounted

# 排到版面上的东西。
var events : Array[NewsResource] = []

# 和 events 一一对应：这一格排的是不是假新闻。
var fakes : Array[bool] = []

func _init(today : Array[NewsResource] = [], fake_flags : Array[bool] = []) -> void:
	events = today.duplicate()
	fakes = fake_flags.duplicate()

func is_fake(index : int) -> bool:
	return index >= 0 and index < fakes.size() and fakes[index]
