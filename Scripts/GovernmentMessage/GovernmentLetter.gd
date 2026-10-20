class_name GovernmentLetter extends RefCounted

# 信 = {title, body, news, fake, type, event_id}。

static func to_dict(res : GovernmentMessageResource) -> Dictionary:
	return {
		"title" : res.displaying_name,
		"body" : res.text,
		"news" : res.news,
		"fake" : res.fake,
		"type" : res.type,
		"event_id" : res.event_id,
		# 存路径不存资源：这封信要进存档，存档只认字。
		"offer" : res.offer.resource_path if res.offer != null else "",
	}

# 这封信盯的是哪一条（回信是 -1）。
static func slot_of(msg : Dictionary) -> int:
	return int(msg.get("news", -1))

static func fill(msg : Dictionary, slot : int = -1) -> Dictionary:
	if slot < 0:
		slot = slot_of(msg)
	var out : Dictionary = msg.duplicate()
	# 用 replace 不用 `%`：正文里没有 %s 时 `%` 会报错。
	var body : String = String(msg.get("body", "")).replace("%s", headline_of(slot, String(msg.get("event_id", ""))))
	# 正文后面补一行大白话：这封信要你干什么，照办 / 不照办各是什么代价。
	var type : int = int(msg.get("type", -1))
	if type >= 0 and not GovernmentMessageResource.is_reply(type):
		body += demand_hint(type)
	out["body"] = body
	return out


# 来信末尾那行：把公文的口气翻成"他要你做什么、代价多少"。
static func demand_hint(type : int) -> String:
	var threat : bool = GovernmentMessageResource.is_threat(type)
	var pick : bool = GovernmentMessageResource.is_pick(type)
	var gain : int = int(GovernmentFavor.GAIN_OBEY_THREAT if threat else GovernmentFavor.GAIN_OBEY)
	var loss : int = int(GovernmentFavor.LOSS_DEFY_THREAT if threat else GovernmentFavor.LOSS_DEFY)
	var what : String = Texts.GOV_HINT_PICK if pick else Texts.GOV_HINT_NOT_PICK
	var verb : String = Texts.GOV_HINT_THREAT_VERB if threat else Texts.GOV_HINT_ASK_VERB
	return Texts.GOV_HINT_DEMAND % [verb, what, gain, loss]


# 回信末尾那行：刚才那一下，账是怎么算的。
static func reply_hint(type : int, obeyed : bool) -> String:
	var threat : bool = GovernmentMessageResource.is_threat(type)
	if obeyed:
		var gain : int = int(GovernmentFavor.GAIN_OBEY_THREAT if threat else GovernmentFavor.GAIN_OBEY)
		return Texts.GOV_HINT_KEPT % [gain, int(GovernmentFavor.KEEP_INFLUENCE)]
	var loss : int = int(GovernmentFavor.LOSS_DEFY_THREAT if threat else GovernmentFavor.LOSS_DEFY)
	return Texts.GOV_HINT_BREACH % [loss, int(GovernmentFavor.BREACH_INFLUENCE)]

# 大事件同属一个 NewsType，只能按 event_id 认出是哪一件标题。
static func headline_of(event : int, event_id : String = "") -> String:
	if event_id != "":
		var one : NewsResource = NewsData.by_event_id.get(event_id)
		return one.headline if one != null else ""
	if event < 0:
		return ""
	var pool : Array = NewsData.res_dic.get(event, [])
	if pool.is_empty():
		return ""
	var res : NewsResource = pool[0]
	return res.headline if res != null else ""

# 该回的那封：一件大事两封，[履约, 违约]，按 event_id 取。
static func reply(_type : int, obeyed : bool, slot : int, event_id : String = "") -> Dictionary:
	if not GovernmentMessageData.EVENT_REPLIES.has(event_id):
		return {}
	var by_event : Array = GovernmentMessageData.EVENT_REPLIES[event_id]
	var template : GovernmentMessageResource = by_event[0] if obeyed else by_event[1]
	if template == null:
		return {}
	var out : Dictionary = to_dict(template)
	out["news"] = -1
	# 回信里还要引原标题：把 event_id 带过去，新闻那格归零。
	out["event_id"] = event_id
	out = fill(out, slot)
	out["body"] = String(out["body"]) + reply_hint(_type, obeyed)
	return out

# 存档回来的信：数字成了 float；更早的档里是 demand / offer 两个槽 + threat / pick 两个 bool。
static func as_msg(data : Variant) -> Dictionary:
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	var msg : Dictionary = data
	if not msg.has("news"):
		var demand : int = int(msg.get("demand", -1))
		msg["news"] = demand if demand >= 0 else int(msg.get("offer", -1))
	if not msg.has("type"):
		var threat : bool = bool(msg.get("threat", false))
		var pick : bool = bool(msg.get("pick", false))
		if threat:
			msg["type"] = GovernmentMessageResource.Type.ThreatPick if pick else GovernmentMessageResource.Type.ThreatNotPick
		else:
			msg["type"] = GovernmentMessageResource.Type.AskPick if pick else GovernmentMessageResource.Type.AskNotPick
	msg["news"] = int(msg["news"])
	msg["type"] = int(msg["type"])
	msg["fake"] = bool(msg.get("fake", true))
	msg["event_id"] = String(msg.get("event_id", ""))
	msg["offer"] = String(msg.get("offer", ""))
	return msg
