class_name NewsResource extends Resource

# 这条消息对应状态机上的哪一条**转移边**（值是 NewsData.NewsType 的序号）。
@export var type : int = -1

# 版面上真正显示出来的东西
@export var headline : String = ""
@export_multiline var body : String = ""
@export var image : Texture2D

@export var influnce : InfluenceGroup

# 版面不够时用来凑数的通用内容（天气、漫画、小说、八卦、灾害）。
@export var is_filler : bool = false

# 是不是**大事件**。
@export var is_big_event : bool = false

# 主线编号：大事件才有，通用素材留空。来信靠它找回"这是哪一件事"。
@export var event_id : String = ""

# 大事件的效果：四家 × 四维，16 个数（见 BigEventEffect）。
@export var big_effect : BigEventEffect
