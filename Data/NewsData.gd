extends Node

# ============================================================
# 素材库

# -------------------- 农民 Farmers --------------------
const FARMER_RESIST : Array = [
	preload("res://Resource/news/farmer/FarmerResist.tres"),
	preload("res://Resource/news/farmer/FarmerResist2.tres"),
	preload("res://Resource/news/farmer/FarmerResist3.tres"),
]
const FARMER_RESIST_END : Array = [
	preload("res://Resource/news/farmer/FarmerResistEnd.tres"),
	preload("res://Resource/news/farmer/FarmerResistEnd2.tres"),
	preload("res://Resource/news/farmer/FarmerResistEnd3.tres"),
]
const FARMER_FLEE : Array = [
	preload("res://Resource/news/farmer/FarmerFlee.tres"),
	preload("res://Resource/news/farmer/FarmerFlee2.tres"),
	preload("res://Resource/news/farmer/FarmerFlee3.tres"),
]
const FARMER_RETURN : Array = [
	preload("res://Resource/news/farmer/FarmerReturn.tres"),
]

# -------------------- 工人 Workers --------------------
const WORKER_SLOWDOWN : Array = [
	preload("res://Resource/news/worker/WorkerSlowdown.tres"),
	preload("res://Resource/news/worker/WorkerSlowdown2.tres"),
	preload("res://Resource/news/worker/WorkerSlowdown3.tres"),
]
const WORKER_SLOWDOWN_END : Array = [
	preload("res://Resource/news/worker/WorkerSlowdownEnd.tres"),
	preload("res://Resource/news/worker/WorkerSlowdownEnd2.tres"),
	preload("res://Resource/news/worker/WorkerSlowdownEnd3.tres"),
]
const WORKER_STRIKE : Array = [
	preload("res://Resource/news/worker/WorkerStrike.tres"),
	preload("res://Resource/news/worker/WorkerStrike2.tres"),
	preload("res://Resource/news/worker/WorkerStrike3.tres"),
]
const WORKER_STRIKE_END : Array = [
	preload("res://Resource/news/worker/WorkerStrikeEnd.tres"),
	preload("res://Resource/news/worker/WorkerStrikeEnd2.tres"),
	preload("res://Resource/news/worker/WorkerStrikeEnd3.tres"),
]

# -------------------- 商人 Merchants --------------------
const MERCHANT_HOARD : Array = [
	preload("res://Resource/news/merchant/MerchantHoard.tres"),
	preload("res://Resource/news/merchant/MerchantHoard2.tres"),
	preload("res://Resource/news/merchant/MerchantHoard3.tres"),
]
const MERCHANT_HOARD_END : Array = [
	preload("res://Resource/news/merchant/MerchantHoardEnd.tres"),
	preload("res://Resource/news/merchant/MerchantHoardEnd2.tres"),
	preload("res://Resource/news/merchant/MerchantHoardEnd3.tres"),
]
const MERCHANT_CLOSE_SHOP : Array = [
	preload("res://Resource/news/merchant/MerchantCloseShop.tres"),
	preload("res://Resource/news/merchant/MerchantCloseShop2.tres"),
	preload("res://Resource/news/merchant/MerchantCloseShop3.tres"),
]
const MERCHANT_CLOSE_SHOP_END : Array = [
	preload("res://Resource/news/merchant/MerchantCloseShopEnd.tres"),
	preload("res://Resource/news/merchant/MerchantCloseShopEnd2.tres"),
	preload("res://Resource/news/merchant/MerchantCloseShopEnd3.tres"),
]
const MERCHANT_FLIGHT : Array = [
	preload("res://Resource/news/merchant/MerchantFlight.tres"),
	preload("res://Resource/news/merchant/MerchantFlight2.tres"),
	preload("res://Resource/news/merchant/MerchantFlight3.tres"),
]
const MERCHANT_RETURN : Array = [
	preload("res://Resource/news/merchant/MerchantReturn.tres"),
]

# -------------------- 士兵 Soldier --------------------
const SOLDIER_SLACK : Array = [
	preload("res://Resource/news/soldier/SoldierSlack.tres"),
	preload("res://Resource/news/soldier/SoldierSlack2.tres"),
	preload("res://Resource/news/soldier/SoldierSlack3.tres"),
]
const SOLDIER_SLACK_END : Array = [
	preload("res://Resource/news/soldier/SoldierSlackEnd.tres"),
	preload("res://Resource/news/soldier/SoldierSlackEnd2.tres"),
	preload("res://Resource/news/soldier/SoldierSlackEnd3.tres"),
]
const SOLDIER_MUTINY : Array = [
	preload("res://Resource/news/soldier/SoldierMutiny.tres"),
	preload("res://Resource/news/soldier/SoldierMutiny2.tres"),
	preload("res://Resource/news/soldier/SoldierMutiny3.tres"),
]
const SOLDIER_MUTINY_END : Array = [
	preload("res://Resource/news/soldier/SoldierMutinyEnd.tres"),
	preload("res://Resource/news/soldier/SoldierMutinyEnd2.tres"),
	preload("res://Resource/news/soldier/SoldierMutinyEnd3.tres"),
]
const SOLDIER_DISBAND : Array = [
	preload("res://Resource/news/soldier/SoldierDisband.tres"),
	preload("res://Resource/news/soldier/SoldierDisband2.tres"),
	preload("res://Resource/news/soldier/SoldierDisband3.tres"),
]
const SOLDIER_DESERT : Array = [
	preload("res://Resource/news/soldier/SoldierDesert.tres"),
	preload("res://Resource/news/soldier/SoldierDesert2.tres"),
	preload("res://Resource/news/soldier/SoldierDesert3.tres"),
]
const SOLDIER_RALLY : Array = [
	preload("res://Resource/news/soldier/SoldierRally.tres"),
]

# -------------------- 政府 Government --------------------
const GOVERNMENT_CONCILIATE : Array = [
	preload("res://Resource/news/government/GovernmentConciliate.tres"),
	preload("res://Resource/news/government/GovernmentConciliate2.tres"),
	preload("res://Resource/news/government/GovernmentConciliate3.tres"),
]
const GOVERNMENT_SUPPRESS : Array = [
	preload("res://Resource/news/government/GovernmentSuppress.tres"),
	preload("res://Resource/news/government/GovernmentSuppress2.tres"),
	preload("res://Resource/news/government/GovernmentSuppress3.tres"),
]
const GOVERNMENT_IDLE : Array = [
	preload("res://Resource/news/government/GovernmentIdle.tres"),
	preload("res://Resource/news/government/GovernmentIdle2.tres"),
	preload("res://Resource/news/government/GovernmentIdle3.tres"),
]

# -------------------- 软新闻：凑版面用的日常栏目 --------------------
# 单条也做成单元素数组，是为了结构统一——以后想给"天气"多写几版，
# 往池子里加就行，不用改任何别的代码。
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
	# --- 农民 Farmers ---
	FarmerResistStart ,       # 暗流：Normal   -> Resist   抗租拖税
	FarmerResistEnd,         #      Resist   -> Normal   不抗了
	FarmerFlee,              # 极端：Normal/Resist -> Flee  流亡，地荒了，税基没了
	FarmerReturn,            # 回流：Flee -> Normal   风声过了，人陆续回来
	
	# --- 工人 Workers ---
	WorkerSlowdownStart,     # 暗流：Normal   -> Slowdown 怠工
	WorkerSlowdownEnd,       #      Slowdown -> Normal   复工
	WorkerStrikeStart,       # 明面：Slowdown -> Strike   罢工
	WorkerStrikeEnd,         #      Strike   -> Normal   复工
	
	# --- 商人 Merchants ---
	MerchantHoardStart,      # 暗流：Normal    -> Hoard     囤积惜售
	MerchantHoardEnd,        #      Hoard     -> Normal    放货
	MerchantCloseShopStart,  # 明面：Hoard     -> CloseShop 罢市
	MerchantCloseShopEnd,    #      CloseShop -> Normal    复市
	MerchantFlight,          # 极端：*         -> Flight    资本外逃
	MerchantReturn,          # 回流：Flight -> Normal    太平了，资本回埠
	
	# --- 士兵 Soldier ---
	SoldierSlackStart,       # 暗流：Normal -> Slack   消极执勤
	SoldierSlackEnd,         #      Slack  -> Normal  恢复执勤
	SoldierMutinyStart,      # 明面：Slack  -> Mutiny  哗变
	SoldierMutinyEnd,        #      Mutiny -> Slack   收枪，人还在磨
	SoldierDisband,          #      Mutiny -> Normal  编制散了，组织不起来了
	SoldierDesert,           # 极端：*      -> Desert  溃散逃亡
	SoldierRally,            # 归队：Desert -> Normal    残部重新收拢
	
	# --- 政府 Government ---
	GovernmentConciliate,    # -> Conciliate  下诏安抚
	GovernmentSuppress,      # -> Suppress    派兵弹压
	GovernmentIdle,          # -> Idle        收手
	
	# --- 软新闻：报纸凑版面用的通用内容 ---
	Weather,
	Cartoon,
	Novel,
	CelebrityGossip,
	Disaster,
	MarketPrice,             # 米粮行情
	Opera,                   # 戏园开演
	Advertisement,           # 洋行广告
	SchoolAdmission,         # 学堂招生
	Recruitment,             # 招工启事
	Lottery,                 # 彩票开奖
	Railway,                 # 铁路加开
	Charity,                 # 慈善赈济
	Epidemic,                # 防疫布告
	TempleFair,              # 庙会
	Antique,                 # 古董字画
	Fire,                    # 火警
}

# 每条边 -> 它的说法池。
var res_dic : Dictionary = {
	# --- 农民 Farmers ---
	NewsType.FarmerResistStart : FARMER_RESIST,
	NewsType.FarmerResistEnd : FARMER_RESIST_END,
	NewsType.FarmerFlee : FARMER_FLEE,
	NewsType.FarmerReturn : FARMER_RETURN,
	
	# --- 工人 Workers ---
	NewsType.WorkerSlowdownStart : WORKER_SLOWDOWN,
	NewsType.WorkerSlowdownEnd : WORKER_SLOWDOWN_END,
	NewsType.WorkerStrikeStart : WORKER_STRIKE,
	NewsType.WorkerStrikeEnd : WORKER_STRIKE_END,
	
	# --- 商人 Merchants ---
	NewsType.MerchantHoardStart : MERCHANT_HOARD,
	NewsType.MerchantHoardEnd : MERCHANT_HOARD_END,
	NewsType.MerchantCloseShopStart : MERCHANT_CLOSE_SHOP,
	NewsType.MerchantCloseShopEnd : MERCHANT_CLOSE_SHOP_END,
	NewsType.MerchantFlight : MERCHANT_FLIGHT,
	NewsType.MerchantReturn : MERCHANT_RETURN,
	
	# --- 士兵 Soldier ---
	NewsType.SoldierSlackStart : SOLDIER_SLACK,
	NewsType.SoldierSlackEnd : SOLDIER_SLACK_END,
	NewsType.SoldierMutinyStart : SOLDIER_MUTINY,
	NewsType.SoldierMutinyEnd : SOLDIER_MUTINY_END,
	NewsType.SoldierDisband : SOLDIER_DISBAND,
	NewsType.SoldierDesert : SOLDIER_DESERT,
	NewsType.SoldierRally : SOLDIER_RALLY,
	
	# --- 政府 Government ---
	NewsType.GovernmentConciliate : GOVERNMENT_CONCILIATE,
	NewsType.GovernmentSuppress : GOVERNMENT_SUPPRESS,
	NewsType.GovernmentIdle : GOVERNMENT_IDLE,
	
	# --- 软新闻 ---
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
#
# **这一步是必要的**，不是顺手：Group 要拿 res.type 判断"这是不是我的终局"、
# "这是不是政府在镇压"，而 .tres 文件里不该、也没法手写这个值。
# 池子（res_dic）是唯一的真源，所以由它来盖章。
# 顺带的好处是：以后给某条边加新说法，不用记得去补 type。
func _ready() -> void:
	for type in res_dic:
		for res in res_dic[type]:
			if res != null:
				res.type = type

# ============================================================
# 软新闻：凑版面用的日常栏目
#
# 天气、漫画、连载、广告、庙会……它们和"世界发生了什么"无关，
# 只是报纸天天都有的东西。真新闻不够铺满版面时，从这里补。
#
# 单独列一张表而不是遍历 res_dic 去问 is_filler：
# 那样每加一条软新闻都要靠约定去维持，而这张表里少写一个，
# 后果只是"少一种可选的填充"，不会出错。
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


# 从这条边的一堆说法里随机挑一个。
func pick(event : NewsType) -> NewsResource:
	var pool : Array = res_dic.get(event)
	if pool == null or pool.is_empty():
		return null
	return pool.pick_random()
