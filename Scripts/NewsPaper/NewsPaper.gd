class_name NewsPaper extends RefCounted

# 排到版面上的东西。一格一条，**数组的顺序就是版面上的位置顺序**。
var events : Array[NewsResource] = []

func _init(today : Array[NewsResource] = []) -> void:
	events = today.duplicate()

# 空版面是合法的——**报纸不必填满**。哪天没人排，那天就是一份空报。
func is_empty() -> bool:
	return events.is_empty()
