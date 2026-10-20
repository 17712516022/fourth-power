class_name GovernmentJudge extends RefCounted

# 盯报纸 / 结账 / 出回信。NotPick 那两档盼着"没登"，Pick 那两档盼着"登"。

# 正盯着的那封信；空 = 没有考期。
var watch : Dictionary = {}

func watch_letter(msg : Dictionary) -> void:
	# 主线信没有 news 序号，只认 event_id；两样都没有就不必盯。
	var has_target : bool = GovernmentLetter.slot_of(msg) >= 0 or String(msg.get("event_id", "")) != ""
	watch = msg.duplicate() if has_target else {}

# 报纸抄好了：登了那条就当场结账，没到考期返回空。
func check_paper(newspaper : NewsPaper) -> Dictionary:
	if watch.is_empty() or newspaper == null:
		return {}
	var slot : int = GovernmentLetter.slot_of(watch)
	var want_event : String = String(watch.get("event_id", ""))
	if slot < 0 and want_event == "":
		return {}
	for res in newspaper.events:
		if matches(res, slot, want_event):
			return settle(true)
	# 这一份报纸没有兑现它：当场算违约。
	# 不在 day_passed 里结账——主线信恰好也是那时发的，会把自己刚发的信判成违约。
	return settle(false)

# 考期到头（报纸那一步已经查过）：没登就是守住了。留作兜底，平时走不到。
func settle_due() -> Dictionary:
	return settle(false) if not watch.is_empty() else {}

# 履约 好感 请求 +10 / 威胁 +5，影响力 +10；违约 好感 请求 −5 / 威胁 −10，影响力 −10。
func settle(published : bool) -> Dictionary:
	if watch.is_empty():
		return {}
	var letter : Dictionary = watch
	watch = {}
	var type : int = int(letter.get("type", -1))
	var threat : bool = GovernmentMessageResource.is_threat(type)
	var obeyed : bool = published == GovernmentMessageResource.is_pick(type)

	if obeyed:
		GovernmentFavor.add(GovernmentFavor.GAIN_OBEY_THREAT if threat else GovernmentFavor.GAIN_OBEY)
		NewsPaperManager.gain_influnce(GovernmentFavor.KEEP_INFLUENCE)
	else:
		GovernmentFavor.add(-(GovernmentFavor.LOSS_DEFY_THREAT if threat else GovernmentFavor.LOSS_DEFY))
		NewsPaperManager.spend_influnce(GovernmentFavor.BREACH_INFLUENCE)

	return GovernmentLetter.reply(type, obeyed, GovernmentLetter.slot_of(letter), String(letter.get("event_id", "")))

# 这张卡是不是被盯着的那条：主线先比 event_id，普通信先比 type，再比池子里那份资源。
static func matches(res : NewsResource, slot : int, event_id : String = "") -> bool:
	if res == null:
		return false
	if event_id != "":
		return res.event_id == event_id
	if res.type == slot and res.type >= 0:
		return true
	var pool : Array = NewsData.res_dic.get(slot, [])
	return pool.has(res)
