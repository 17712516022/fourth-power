extends Node

# 今天世界上发生了哪些事。
var material_list : Array[NewsData.NewsType] = []

# 今天一共发生了几条**真新闻**（不是软新闻的那些）。
#
# 为什么单独存一份：material_list 在铺完素材池的瞬间就被清空了，
# 而报纸结算（NewsPaper.settle_influence）要等玩家按了 Decide 才跑——
# 那时候池子早就空了。"漏掉几条真新闻"这个数**必须在清空之前留下来**，
# 所以由铺池子的那一方（RawMaterialFactory）顺便数好放这儿。
var real_news_count : int = 0

func get_material(event : NewsData.NewsType) -> void:
	material_list.append(event)
