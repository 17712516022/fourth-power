class_name StateText extends RefCounted

# 状态 → 面板那一行要的两样东西：**叫什么名字** + **上什么色**。

static func of(state : Variant) -> Dictionary:
	if state == null:
		return _normal()

	# 农民
	if state is FarmerStateSlowdown:
		return {"text" : Texts.STATE_SLOWDOWN, "color" : UiColors.HIDDEN}
	if state is FarmerStateResist:
		return {"text" : Texts.STATE_FARMER_RESIST, "color" : UiColors.HIDDEN}
	if state is FarmerStateFlee:
		return {"text" : Texts.STATE_FARMER_FLEE, "color" : UiColors.EXTREME}
	if state is FarmerStateUpRising:
		return {"text" : Texts.STATE_UPRISING, "color" : UiColors.OPEN}

	# 工人
	if state is WorkerStateSlowdown:
		return {"text" : Texts.STATE_SLOWDOWN, "color" : UiColors.HIDDEN}
	if state is WorkerStateDepression:
		return {"text" : Texts.STATE_WORKER_DEPRESSION, "color" : UiColors.HIDDEN}
	if state is WorkerStateStrike:
		return {"text" : Texts.STATE_WORKER_STRIKE, "color" : UiColors.HIDDEN}
	if state is WorkerStateMarch:
		return {"text" : Texts.STATE_WORKER_MARCH, "color" : UiColors.OPEN}
	if state is WorkerStateUpRising:
		return {"text" : Texts.STATE_UPRISING, "color" : UiColors.EXTREME}

	# 商人
	if state is MerchantStateProsperity:
		return {"text" : Texts.STATE_MERCHANT_PROSPERITY, "color" : UiColors.SAFE}
	if state is MerchantStateInvest:
		return {"text" : Texts.STATE_MERCHANT_INVEST, "color" : UiColors.HIDDEN}
	if state is MerchantStateSpeculate:
		return {"text" : Texts.STATE_MERCHANT_SPECULATE, "color" : UiColors.HIDDEN}
	if state is MerchantStateHollow:
		return {"text" : Texts.STATE_MERCHANT_HOLLOW, "color" : UiColors.OPEN}
	if state is MerchantStateAbroad:
		return {"text" : Texts.STATE_MERCHANT_ABROAD, "color" : UiColors.EXTREME}

	# 士兵
	if state is SoldierStateDesert:
		return {"text" : Texts.STATE_SOLDIER_DESERT, "color" : UiColors.HIDDEN}
	if state is SoldierStateRampage:
		return {"text" : Texts.STATE_SOLDIER_RAMPAGE, "color" : UiColors.HIDDEN}
	if state is SoldierStateCorrupt:
		return {"text" : Texts.STATE_SOLDIER_CORRUPT, "color" : UiColors.HIDDEN}
	if state is SoldierStateMutiny:
		return {"text" : Texts.STATE_SOLDIER_MUTINY, "color" : UiColors.EXTREME}

	# 政府（六档：常态白、保守黄、无能/强硬橙、恐怖/崩溃红）
	if state is GovernmentStateConservative:
		return {"text" : Texts.STATE_GOV_CONSERVATIVE, "color" : UiColors.HIDDEN}
	if state is GovernmentStateIncompetent:
		return {"text" : Texts.STATE_GOV_INCOMPETENT, "color" : UiColors.OPEN}
	if state is GovernmentStateHardline:
		return {"text" : Texts.STATE_GOV_HARDLINE, "color" : UiColors.OPEN}
	if state is GovernmentStateTerror:
		return {"text" : Texts.STATE_GOV_TERROR, "color" : UiColors.EXTREME}
	if state is GovernmentStateCollapse:
		return {"text" : Texts.STATE_GOV_COLLAPSE, "color" : UiColors.EXTREME}

	return _normal()


# 兜底：四家的"正常"档、以及认不出来的状态，都报这一条。
static func _normal() -> Dictionary:
	return {"text" : Texts.STATE_NORMAL, "color" : UiColors.NORMAL}


# 换档那一刻，过场里该给这张脸配什么情绪（见 Scripts/DayPass/DayPassAnimation）。
# 正常档 = 好转，一笑而过；越靠前越"坏"。
static func mood_of(state : Variant) -> String:
	if state == null:
		return "happy"

	# 对抗、升级：怒。
	if state is FarmerStateResist or state is FarmerStateUpRising \
			or state is WorkerStateStrike or state is WorkerStateMarch \
			or state is WorkerStateUpRising or state is SoldierStateMutiny \
			or state is SoldierStateRampage or state is SoldierStateCorrupt:
		return "angry"

	# 跑、散、出海：怕。
	if state is FarmerStateFlee or state is SoldierStateDesert \
			or state is MerchantStateAbroad:
		return "fear"

	# 停下来、缩下去：丧。
	if state is FarmerStateSlowdown or state is WorkerStateSlowdown \
			or state is WorkerStateDepression or state is MerchantStateHollow:
		return "sad"

	# 赚钱、开店：喜。
	if state is MerchantStateProsperity or state is MerchantStateInvest:
		return "happy"

	# 投机：来劲。
	if state is MerchantStateSpeculate:
		return "power"

	# 领地：强硬 / 恐怖 = 怒；崩溃 = 怕；保守 / 无能 = 丧。
	if state is GovernmentStateHardline or state is GovernmentStateTerror:
		return "angry"
	if state is GovernmentStateCollapse:
		return "fear"
	if state is GovernmentStateConservative or state is GovernmentStateIncompetent:
		return "sad"

	# 回到常态（四条 Normal 都落在这里）。
	return "happy"
