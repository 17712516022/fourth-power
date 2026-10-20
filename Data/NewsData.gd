extends Node

# 素材库

# 农民 Farmers
const FARMER_RESIST : Array = [
	preload("res://Resource/news/farmer/FarmerResist.tres"),
]
const FARMER_RESIST_END : Array = [
	preload("res://Resource/news/farmer/FarmerResistEnd.tres"),
]
const FARMER_FLEE : Array = [
	preload("res://Resource/news/farmer/FarmerFlee.tres"),
]
const FARMER_RETURN : Array = [
	preload("res://Resource/news/farmer/FarmerReturn.tres"),
]
const FARMER_UP_RISING : Array = [
	preload("res://Resource/news/farmer/FarmerUpRising.tres"),
]
const FARMER_UP_RISING_END : Array = [
	preload("res://Resource/news/farmer/FarmerUpRisingEnd.tres"),
]
const FARMER_SLOW_DOWN : Array = [
	preload("res://Resource/news/farmer/FarmerSlowDown.tres"),
]
const FARMER_SLOW_DOWN_END : Array = [
	preload("res://Resource/news/farmer/FarmerSlowDownEnd.tres"),
]

# 工人 Workers
const WORKER_STRIKE : Array = [
	preload("res://Resource/news/worker/WorkerStrike.tres"),
]
const WORKER_STRIKE_END : Array = [
	preload("res://Resource/news/worker/WorkerStrikeEnd.tres"),
]
const WORKER_MARCH : Array = [
	preload("res://Resource/news/worker/WorkerMarch.tres"),
]
const WORKER_MARCH_END : Array = [
	preload("res://Resource/news/worker/WorkerMarchEnd.tres"),
]
const WORKER_UP_RISING : Array = [
	preload("res://Resource/news/worker/WorkerUpRising.tres"),
]
const WORKER_UP_RISING_END : Array = [
	preload("res://Resource/news/worker/WorkerUpRisingEnd.tres"),
]
const WORKER_SLOWDOWN : Array = [
	preload("res://Resource/news/worker/WorkerSlowdown.tres"),
]
const WORKER_SLOWDOWN_END : Array = [
	preload("res://Resource/news/worker/WorkerSlowdownEnd.tres"),
]
const WORKER_DEPRESSION : Array = [
	preload("res://Resource/news/worker/WorkerDepression.tres"),
]
const WORKER_DEPRESSION_END : Array = [
	preload("res://Resource/news/worker/WorkerDepressionEnd.tres"),
]

# 商人 Merchants
const MERCHANT_SPECULATE : Array = [
	preload("res://Resource/news/merchant/MerchantSpeculate.tres"),
]
const MERCHANT_SPECULATE_END : Array = [
	preload("res://Resource/news/merchant/MerchantSpeculateEnd.tres"),
]
const MERCHANT_PROSPERITY : Array = [
	preload("res://Resource/news/merchant/MerchantProsperity.tres"),
]
const MERCHANT_PROSPERITY_END : Array = [
	preload("res://Resource/news/merchant/MerchantProsperityEnd.tres"),
]
const MERCHANT_INVEST : Array = [
	preload("res://Resource/news/merchant/MerchantInvest.tres"),
]
const MERCHANT_INVEST_END : Array = [
	preload("res://Resource/news/merchant/MerchantInvestEnd.tres"),
]
const MERCHANT_HOLLOW : Array = [
	preload("res://Resource/news/merchant/MerchantHollow.tres"),
]
const MERCHANT_HOLLOW_END : Array = [
	preload("res://Resource/news/merchant/MerchantHollowEnd.tres"),
]
const MERCHANT_ABROAD : Array = [
	preload("res://Resource/news/merchant/MerchantAbroad.tres"),
]
const MERCHANT_RETURN : Array = [
	preload("res://Resource/news/merchant/MerchantReturn.tres"),
]

# 士兵 Soldier
const SOLDIER_DESERT : Array = [
	preload("res://Resource/news/soldier/SoldierDesert.tres"),
]
const SOLDIER_RALLY : Array = [
	preload("res://Resource/news/soldier/SoldierRally.tres"),
]
const SOLDIER_RAMPAGE : Array = [
	preload("res://Resource/news/soldier/SoldierRampage.tres"),
]
const SOLDIER_RAMPAGE_END : Array = [
	preload("res://Resource/news/soldier/SoldierRampageEnd.tres"),
]
const SOLDIER_CORRUPT : Array = [
	preload("res://Resource/news/soldier/SoldierCorrupt.tres"),
]
const SOLDIER_CORRUPT_END : Array = [
	preload("res://Resource/news/soldier/SoldierCorruptEnd.tres"),
]
const SOLDIER_MUTINY : Array = [
	preload("res://Resource/news/soldier/SoldierMutiny.tres"),
]
const SOLDIER_DISBAND : Array = [
	preload("res://Resource/news/soldier/SoldierDisband.tres"),
]

# 政府 Government
const GOVERNMENT_CONCILIATE : Array = [
	preload("res://Resource/news/government/GovernmentConciliate.tres"),
]
const GOVERNMENT_SUPPRESS : Array = [
	preload("res://Resource/news/government/GovernmentSuppress.tres"),
]
const GOVERNMENT_IDLE : Array = [
	preload("res://Resource/news/government/GovernmentIdle.tres"),
]
const GOVERNMENT_TAX : Array = [
	preload("res://Resource/news/government/GovernmentTax.tres"),
]
const GOVERNMENT_REQUISITION : Array = [
	preload("res://Resource/news/government/GovernmentRequisition.tres"),
]
const GOVERNMENT_RELIEF : Array = [
	preload("res://Resource/news/government/GovernmentRelief.tres"),
]
const GOVERNMENT_INVEST : Array = [
	preload("res://Resource/news/government/GovernmentInvest.tres"),
]
const GOVERNMENT_RECRUIT : Array = [
	preload("res://Resource/news/government/GovernmentRecruit.tres"),
]
const GOVERNMENT_MARTIAL : Array = [
	preload("res://Resource/news/government/GovernmentMartial.tres"),
]
const GOVERNMENT_FARMING : Array = [
	preload("res://Resource/news/government/GovernmentFarming.tres"),
]
const GOVERNMENT_REPRIMAND : Array = [
	preload("res://Resource/news/government/GovernmentReprimand.tres"),
]
const GOVERNMENT_INTERNMENT : Array = [
	preload("res://Resource/news/government/GovernmentInternment.tres"),
]
const GOVERNMENT_REFORM : Array = [
	preload("res://Resource/news/government/GovernmentReform.tres"),
]
const GOVERNMENT_EXPULSION : Array = [
	preload("res://Resource/news/government/GovernmentExpulsion.tres"),
]
const GOVERNMENT_MASSACRE : Array = [
	preload("res://Resource/news/government/GovernmentMassacre.tres"),
]
const GOVERNMENT_FAVOR : Array = [
	preload("res://Resource/news/government/GovernmentFavor.tres"),
]
const GOVERNMENT_RECONCILE : Array = [
	preload("res://Resource/news/government/GovernmentReconcile.tres"),
]
const GOVERNMENT_HELPLESS : Array = [
	preload("res://Resource/news/government/GovernmentHelpless.tres"),
]
const GOVERNMENT_DRIFT : Array = [
	preload("res://Resource/news/government/GovernmentDrift.tres"),
]

# 对症的手：工人
const GOVERNMENT_DRAFT : Array = [
	preload("res://Resource/news/government/GovernmentDraft.tres"),
]
const GOVERNMENT_EXHORT : Array = [
	preload("res://Resource/news/government/GovernmentExhort.tres"),
]
const GOVERNMENT_WORK_RELIEF : Array = [
	preload("res://Resource/news/government/GovernmentWorkRelief.tres"),
]
const GOVERNMENT_ARBITRATION : Array = [
	preload("res://Resource/news/government/GovernmentArbitration.tres"),
]
const GOVERNMENT_DISPERSE : Array = [
	preload("res://Resource/news/government/GovernmentDisperse.tres"),
]

# 对症的手：商人
const GOVERNMENT_EXCISE : Array = [
	preload("res://Resource/news/government/GovernmentExcise.tres"),
]
const GOVERNMENT_BOND : Array = [
	preload("res://Resource/news/government/GovernmentBond.tres"),
]
const GOVERNMENT_PROTECT : Array = [
	preload("res://Resource/news/government/GovernmentProtect.tres"),
]
const GOVERNMENT_RETAIN : Array = [
	preload("res://Resource/news/government/GovernmentRetain.tres"),
]
const GOVERNMENT_INSPECT : Array = [
	preload("res://Resource/news/government/GovernmentInspect.tres"),
]
const GOVERNMENT_RECTIFY : Array = [
	preload("res://Resource/news/government/GovernmentRectify.tres"),
]

# 对症的手：士兵
const GOVERNMENT_DRILL : Array = [
	preload("res://Resource/news/government/GovernmentDrill.tres"),
]
const GOVERNMENT_PAY : Array = [
	preload("res://Resource/news/government/GovernmentPay.tres"),
]
const GOVERNMENT_ARMY_LAW : Array = [
	preload("res://Resource/news/government/GovernmentArmyLaw.tres"),
]

# 大事件：主线 24 件
const BIG_EVENT : Array = [
	preload("res://Resource/news/Event/B01WestRally.tres"),
	preload("res://Resource/news/Event/B02ReliefCrisis.tres"),
	preload("res://Resource/news/Event/B03LeagueFounded.tres"),
	preload("res://Resource/news/Event/B04NoticeBoard.tres"),
	preload("res://Resource/news/Event/B05Evictions.tres"),
	preload("res://Resource/news/Event/B06LaborersRejected.tres"),
	preload("res://Resource/news/Event/B07Isolation.tres"),
	preload("res://Resource/news/Event/B08HarvestEscort.tres"),
	preload("res://Resource/news/Event/B09ShopsClosed.tres"),
	preload("res://Resource/news/Event/B10CoercionAct.tres"),
	preload("res://Resource/news/Event/B11EditorArrested.tres"),
	preload("res://Resource/news/Event/B12LeaderArrested.tres"),
	preload("res://Resource/news/Event/B13LadiesRecords.tres"),
	preload("res://Resource/news/Event/B14LadiesBanned.tres"),
	preload("res://Resource/news/Event/B15NoRent.tres"),
	preload("res://Resource/news/Event/B16LandAct.tres"),
	preload("res://Resource/news/Event/B17RumorTalks.tres"),
	preload("res://Resource/news/Event/B18ParkAssassination.tres"),
	preload("res://Resource/news/Event/B19WestportRally.tres"),
	preload("res://Resource/news/Event/B20NewDeparture.tres"),
	preload("res://Resource/news/Event/B21AmericanFund.tres"),
	preload("res://Resource/news/Event/B22Election.tres"),
	preload("res://Resource/news/Event/B23LadiesLeagueFounded.tres"),
	preload("res://Resource/news/Event/B24LadiesLeagueDissolved.tres"),
]

# event_id -> 大事件。来信靠信上的 event_id 在这里找回"这是哪一件事"。
var by_event_id : Dictionary = {}


# 软新闻：凑版面用的日常栏目
const WEATHER : Array = [preload("res://Resource/news/filler/Weather.tres")]
const CARTOON : Array = [preload("res://Resource/news/filler/Cartoon.tres")]
const NOVEL : Array = [preload("res://Resource/news/filler/Novel.tres")]
const CELEBRITY_GOSSIP : Array = [preload("res://Resource/news/filler/CelebrityGossip.tres")]
const DISASTERS : Array = [preload("res://Resource/news/filler/Disasters.tres")]
const MARKET_PRICE : Array = [preload("res://Resource/news/filler/MarketPrice.tres")]
const OPERA : Array = [preload("res://Resource/news/filler/Opera.tres")]
const ADVERTISEMENT : Array = [preload("res://Resource/news/filler/Advertisement.tres")]
const SCHOOL_ADMISSION : Array = [preload("res://Resource/news/filler/SchoolAdmission.tres")]
const RECRUITMENT : Array = [preload("res://Resource/news/filler/Recruitment.tres")]
const LOTTERY : Array = [preload("res://Resource/news/filler/Lottery.tres")]
const RAILWAY : Array = [preload("res://Resource/news/filler/Railway.tres")]
const CHARITY : Array = [preload("res://Resource/news/filler/Charity.tres")]
const EPIDEMIC : Array = [preload("res://Resource/news/filler/Epidemic.tres")]
const TEMPLE_FAIR : Array = [preload("res://Resource/news/filler/TempleFair.tres")]
const ANTIQUE : Array = [preload("res://Resource/news/filler/Antique.tres")]
const FIRE : Array = [preload("res://Resource/news/filler/Fire.tres")]


enum NewsType {
	# 农民 Farmers
	FarmerResistStart,
	FarmerResistEnd,
	FarmerFlee,
	FarmerReturn,
	FarmerUpRisingStart,
	FarmerUpRisingEnd,
	FarmerSlowDown,
	FarmerSlowDownEnd,
	
	# 工人 Workers
	WorkerStrikeStart,
	WorkerStrikeEnd,
	WorkerMarchStart,
	WorkerMarchEnd,
	WorkerUpRisingStart,
	WorkerUpRisingEnd,
	WorkerSlowdownStart,
	WorkerSlowdownEnd,
	WorkerDepressionStart,
	WorkerDepressionEnd,
	
	# 商人 Merchants
	MerchantProsperityStart,
	MerchantProsperityEnd,
	MerchantInvestStart,
	MerchantInvestEnd,
	MerchantSpeculateStart,
	MerchantSpeculateEnd,
	MerchantHollowStart,
	MerchantHollowEnd,
	MerchantAbroad,
	MerchantReturn,
	
	# 士兵 Soldier
	SoldierDesert,
	SoldierRally,
	SoldierRampageStart,
	SoldierRampageEnd,
	SoldierCorruptStart,
	SoldierCorruptEnd,
	SoldierMutinyStart,
	SoldierDisband,
	
	# 政府 Government
	GovernmentConciliate,
	GovernmentSuppress,
	GovernmentIdle,
	GovernmentTax,
	GovernmentRequisition,
	GovernmentRelief,
	GovernmentInvest,
	GovernmentRecruit,
	GovernmentMartial,
	GovernmentFarming,
	GovernmentReprimand,
	GovernmentInternment,
	GovernmentReform,
	GovernmentExpulsion,
	GovernmentMassacre,
	GovernmentFavor,
	GovernmentReconcile,
	GovernmentHelpless,
	GovernmentDrift,
	GovernmentDraft,
	GovernmentExhort,
	GovernmentWorkRelief,
	GovernmentArbitration,
	GovernmentDisperse,
	GovernmentExcise,
	GovernmentBond,
	GovernmentProtect,
	GovernmentRetain,
	GovernmentInspect,
	GovernmentRectify,
	GovernmentDrill,
	GovernmentPay,
	GovernmentArmyLaw,

	# 大事件：每天 50% 概率出一条，只改四维、不推阈值。
	BigEvent,
	
	# 软新闻：报纸凑版面用的通用内容
	Weather,
	Cartoon,
	Novel,
	CelebrityGossip,
	Disaster,
	MarketPrice,
	Opera,
	Advertisement,
	SchoolAdmission,
	Recruitment,
	Lottery,
	Railway,
	Charity,
	Epidemic,
	TempleFair,
	Antique,
	Fire,
}

# 每条边 -> 它的说法池。
var res_dic : Dictionary = {
	# 农民 Farmers
	NewsType.FarmerResistStart : FARMER_RESIST,
	NewsType.FarmerResistEnd : FARMER_RESIST_END,
	NewsType.FarmerFlee : FARMER_FLEE,
	NewsType.FarmerReturn : FARMER_RETURN,
	NewsType.FarmerUpRisingStart : FARMER_UP_RISING,
	NewsType.FarmerUpRisingEnd : FARMER_UP_RISING_END,
	NewsType.FarmerSlowDown : FARMER_SLOW_DOWN,
	NewsType.FarmerSlowDownEnd : FARMER_SLOW_DOWN_END,
	
	# 工人 Workers
	NewsType.WorkerStrikeStart : WORKER_STRIKE,
	NewsType.WorkerStrikeEnd : WORKER_STRIKE_END,
	NewsType.WorkerMarchStart : WORKER_MARCH,
	NewsType.WorkerMarchEnd : WORKER_MARCH_END,
	NewsType.WorkerUpRisingStart : WORKER_UP_RISING,
	NewsType.WorkerUpRisingEnd : WORKER_UP_RISING_END,
	NewsType.WorkerSlowdownStart : WORKER_SLOWDOWN,
	NewsType.WorkerSlowdownEnd : WORKER_SLOWDOWN_END,
	NewsType.WorkerDepressionStart : WORKER_DEPRESSION,
	NewsType.WorkerDepressionEnd : WORKER_DEPRESSION_END,
	
	# 商人 Merchants
	NewsType.MerchantProsperityStart : MERCHANT_PROSPERITY,
	NewsType.MerchantProsperityEnd : MERCHANT_PROSPERITY_END,
	NewsType.MerchantInvestStart : MERCHANT_INVEST,
	NewsType.MerchantInvestEnd : MERCHANT_INVEST_END,
	NewsType.MerchantSpeculateStart : MERCHANT_SPECULATE,
	NewsType.MerchantSpeculateEnd : MERCHANT_SPECULATE_END,
	NewsType.MerchantHollowStart : MERCHANT_HOLLOW,
	NewsType.MerchantHollowEnd : MERCHANT_HOLLOW_END,
	NewsType.MerchantAbroad : MERCHANT_ABROAD,
	NewsType.MerchantReturn : MERCHANT_RETURN,
	
	# 士兵 Soldier
	NewsType.SoldierDesert : SOLDIER_DESERT,
	NewsType.SoldierRally : SOLDIER_RALLY,
	NewsType.SoldierRampageStart : SOLDIER_RAMPAGE,
	NewsType.SoldierRampageEnd : SOLDIER_RAMPAGE_END,
	NewsType.SoldierCorruptStart : SOLDIER_CORRUPT,
	NewsType.SoldierCorruptEnd : SOLDIER_CORRUPT_END,
	NewsType.SoldierMutinyStart : SOLDIER_MUTINY,
	NewsType.SoldierDisband : SOLDIER_DISBAND,
	
	# 政府 Government
	NewsType.GovernmentConciliate : GOVERNMENT_CONCILIATE,
	NewsType.GovernmentSuppress : GOVERNMENT_SUPPRESS,
	NewsType.GovernmentIdle : GOVERNMENT_IDLE,
	NewsType.GovernmentTax : GOVERNMENT_TAX,
	NewsType.GovernmentRequisition : GOVERNMENT_REQUISITION,
	NewsType.GovernmentRelief : GOVERNMENT_RELIEF,
	NewsType.GovernmentInvest : GOVERNMENT_INVEST,
	NewsType.GovernmentRecruit : GOVERNMENT_RECRUIT,
	NewsType.GovernmentMartial : GOVERNMENT_MARTIAL,
	NewsType.GovernmentFarming : GOVERNMENT_FARMING,
	NewsType.GovernmentReprimand : GOVERNMENT_REPRIMAND,
	NewsType.GovernmentInternment : GOVERNMENT_INTERNMENT,
	NewsType.GovernmentReform : GOVERNMENT_REFORM,
	NewsType.GovernmentExpulsion : GOVERNMENT_EXPULSION,
	NewsType.GovernmentMassacre : GOVERNMENT_MASSACRE,
	NewsType.GovernmentFavor : GOVERNMENT_FAVOR,
	NewsType.GovernmentReconcile : GOVERNMENT_RECONCILE,
	NewsType.GovernmentHelpless : GOVERNMENT_HELPLESS,
	NewsType.GovernmentDrift : GOVERNMENT_DRIFT,
	NewsType.GovernmentDraft : GOVERNMENT_DRAFT,
	NewsType.GovernmentExhort : GOVERNMENT_EXHORT,
	NewsType.GovernmentWorkRelief : GOVERNMENT_WORK_RELIEF,
	NewsType.GovernmentArbitration : GOVERNMENT_ARBITRATION,
	NewsType.GovernmentDisperse : GOVERNMENT_DISPERSE,
	NewsType.GovernmentExcise : GOVERNMENT_EXCISE,
	NewsType.GovernmentBond : GOVERNMENT_BOND,
	NewsType.GovernmentProtect : GOVERNMENT_PROTECT,
	NewsType.GovernmentRetain : GOVERNMENT_RETAIN,
	NewsType.GovernmentInspect : GOVERNMENT_INSPECT,
	NewsType.GovernmentRectify : GOVERNMENT_RECTIFY,
	NewsType.GovernmentDrill : GOVERNMENT_DRILL,
	NewsType.GovernmentPay : GOVERNMENT_PAY,
	NewsType.GovernmentArmyLaw : GOVERNMENT_ARMY_LAW,
	NewsType.BigEvent : BIG_EVENT,
	
	# 软新闻
	NewsType.Weather : WEATHER,
	NewsType.Cartoon : CARTOON,
	NewsType.Novel : NOVEL,
	NewsType.CelebrityGossip : CELEBRITY_GOSSIP,
	NewsType.Disaster : DISASTERS,
	NewsType.MarketPrice : MARKET_PRICE,
	NewsType.Opera : OPERA,
	NewsType.Advertisement : ADVERTISEMENT,
	NewsType.SchoolAdmission : SCHOOL_ADMISSION,
	NewsType.Recruitment : RECRUITMENT,
	NewsType.Lottery : LOTTERY,
	NewsType.Railway : RAILWAY,
	NewsType.Charity : CHARITY,
	NewsType.Epidemic : EPIDEMIC,
	NewsType.TempleFair : TEMPLE_FAIR,
	NewsType.Antique : ANTIQUE,
	NewsType.Fire : FIRE,
}

# 按池子给每个 .tres 归位。
func _ready() -> void:
	for type in res_dic:
		for res in res_dic[type]:
			if res != null:
				res.type = type

	# 大事件另建一张表：来源信只认 event_id，不认池子。
	by_event_id.clear()
	for res in BIG_EVENT:
		if res != null and res.event_id != "":
			by_event_id[res.event_id] = res

# 软新闻：凑版面用的日常栏目
const FILLER_TYPES : Array[NewsType] = [
	NewsType.Weather,
	NewsType.Cartoon,
	NewsType.Novel,
	NewsType.CelebrityGossip,
	NewsType.Disaster,
	NewsType.MarketPrice,
	NewsType.Opera,
	NewsType.Advertisement,
	NewsType.SchoolAdmission,
	NewsType.Recruitment,
	NewsType.Lottery,
	NewsType.Railway,
	NewsType.Charity,
	NewsType.Epidemic,
	NewsType.TempleFair,
	NewsType.Antique,
	NewsType.Fire,
]


# 随机取几条软新闻，用来把版面补满。
func random_fillers(count : int) -> Array[NewsResource]:
	var types : Array[NewsType] = FILLER_TYPES.duplicate()
	types.shuffle()
	
	var out : Array[NewsResource] = []
	for i in mini(count, types.size()):
		var res : NewsResource = pick(types[i])
		if res != null:
			out.append(res)
	return out


# 这条边是不是"政府自己发的话"（NewsType 里政府那一整段：换姿势 + 各种动作）。
func is_government(event : int) -> bool:
	return event >= NewsType.GovernmentConciliate and event <= NewsType.GovernmentArmyLaw

# 从这条边的一堆说法里随机挑一个。
func pick(event : NewsType) -> NewsResource:
	var pool : Array = res_dic.get(event)
	if pool == null or pool.is_empty():
		return null
	return pool.pick_random()
