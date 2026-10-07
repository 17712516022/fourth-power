class_name NewsResource extends Resource

# 这条消息对应状态机上的哪一条**转移边**（值是 NewsData.NewsType 的序号）。
#
# 为什么读报的人需要它：光有"内容"不够，Group 还要判断更进一步的事——
# "这条是不是我的终局"、"这条是不是政府在镇压"。那些判断问的是边，不是文本。
#
# **不要手写这个值。** 它由 NewsData._ready() 按说法池归位：
# 池子是唯一的真源，一张 .tres 属于哪条边，由它挂在哪个池子里决定。
# 用 int 而不是 NewsData.NewsType，是为了避开 autoload 名出现在类型位置的问题。
@export var type : int = -1

# 版面上真正显示出来的东西
@export var headline : String = ""
@export_multiline var body : String = ""
@export var image : Texture2D

@export var influnce : InfluenceGroup

# 版面不够时用来凑数的通用内容（天气、漫画、小说、八卦、灾害）。
# 真正的新闻是"世界发生了什么"，它们只是"没人关心但天天都有"。
@export var is_filler : bool = false
