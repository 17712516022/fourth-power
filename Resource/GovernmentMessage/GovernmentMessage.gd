class_name GovernmentMessageResource extends Resource

# 口气（Ask / Threat）× 要你做什么（Pick 请你登 / NotPick 别登），外加回信。
enum Type { AskPick, AskNotPick, ThreatPick, ThreatNotPick, Reply }

@export var type : Type = Type.AskPick

# 抬头，如"总督府来函"。
@export var displaying_name : String = ""

# 正文；%s 换成盯的那条新闻的真标题。
@export_multiline var text : String = ""

# 盯的那条新闻（NewsData.NewsType 序号）；回信是 -1。
@export var news : int = -1

# Pick 那两档递过去的那条，落进素材池时算不算假新闻。
@export var fake : bool = true

# 主线编号：这封信盯的是哪一件大事件（通用来信留空）。
@export var event_id : String = ""

# 随信附上的那张稿子：Pick 那两档一打开信箱就落进素材池（不附就留空）。
@export var offer : NewsResource

static func is_threat(type : int) -> bool:
	return type == Type.ThreatPick or type == Type.ThreatNotPick

static func is_pick(type : int) -> bool:
	return type == Type.AskPick or type == Type.ThreatPick

static func is_reply(type : int) -> bool:
	return type == Type.Reply
