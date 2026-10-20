class_name EndingData

# 七个结局的静态表。
# 判定只看五样东西：政府状态、稳定度、影响力、好感度、四家状态。
# 判定顺序与阈值在 EndingManager.judge()；这里只放"要调手感就动这几行"的数和字。

enum Id {
	None,
	NoMaster,      # 无主
	NewOrder,      # 新秩序
	Unread,        # 无人读
	Ban,           # 查禁
	Coopt,         # 招安
	FourthEstate,  # 第四权力
	Coexist,       # 共存
}

# 判定阈值
# 顺序与用法见 EndingManager.judge()：世界 → 读者 → 政府怎么处置你。

# 世界终结线：**与政府崩溃线是同一个数**（StateChangeData.governmentCollapseStabilityNeed）。
# 跌破它，政府已经散了就是"无主之城"；政府还在、农民又上了街、报纸也已经没人读，
# 才是"乡野新序"。
const STABILITY_LINE : float = 6.0

# 信誉的四道线（<= 与 > 的边界以 judge() 为准）：
#   <  80   无人读报：读者已经走光
#   < 150   乡野新序里那句"报纸没有分量"
#   > 200   第四权力：够硬，政府恨你也动不了你
#   > 220   本报奉命：够大，政府愿意收编你
const INFLUENCE_LOW : float = 80.0
const INFLUENCE_MID : float = 150.0
const INFLUENCE_HIGH : float = 200.0
const INFLUENCE_TOP : float = 220.0

# 好感的两头：
#   < 20   政府恨你——要么查封停刊，要么（世界太平且报纸够硬）第四权力
#   > 80   政府够亲近——本报奉命
const FAVOR_LOW : float = 20.0
const FAVOR_HIGH : float = 80.0

# 领地段：**只有两档**。
# 第三档"乱"已被"稳定度 < 6"整片吃掉——那已经是无主之城 / 乡野新序自己的正文了。
# 名字不叫 World：项目里已经有一个 class_name World（Scripts/World.gd）。
enum WorldState {
	Calm,    # 安
	Strain,  # 困
}

# 安 / 困 的分界（与 StabilityManager.TIGHT 同值：8 以下就是"困"）。
const WORLD_CALM_LINE : float = 8.0


# 头条（结局名）。一律四个字，字间留一个空格：
# 终刊号和档案栏都用同一个字号显示，字数齐了版面才不忽宽忽窄。
const HEADLINE : Dictionary = {
	Id.NoMaster : "无 主 之 城",
	Id.NewOrder : "乡 野 新 序",
	Id.Unread : "无 人 读 报",
	Id.Ban : "查 封 停 刊",
	Id.Coopt : "本 报 奉 命",
	Id.FourthEstate : "第 四 权 力",
	Id.Coexist : "照 常 出 刊",
}

# 主段：报社的收场。
const BODY : Dictionary = {
	Id.NoMaster :
		"总督府的灯灭了三天。第四天，有人把门板卸下来卖了。\n\n"
		+ "城门没人守，粮价没人定，案子没人断。四乡的人陆续进城，在官署口站了一会儿，又各自回去。\n\n"
		+ "本报照常出刊。印厂的纸还剩十一令，铅字缺了两个——「权」那一枚，昨天被人拿走了。",

	Id.NewOrder :
		"第 {next} 天的早上，总督府没有发告示。发告示的是四乡。\n\n"
		+ "他们不用铅字，用木刻。印出来的东西糙，字也错了两处，可城门上贴满了。\n\n"
		+ "本报照常出刊。编辑还是原来那几个，读者换了一批。\n\n"
		+ "街上现在说的那些话，本报一个字也没说过。",

	Id.Unread :
		"印了三百份，卖出去四十一份，退回来一百二十份。\n\n"
		+ "退报的人没说什么，把报纸叠好放在柜台上就走了。柜台上已经摞了六天的。\n\n"
		+ "第十天起，不再有人来投书。第二十天起，也不再有人来问价钱。\n\n"
		+ "造假的事，城里人都知道。他们只是不再提。",

	Id.Ban :
		"查封的人来的时候是早上六点。他们不砸机器，只把铅字一箱一箱抬走，按笔画顺序，装得很整齐。\n\n"
		+ "主笔被请到总督府去「坐一坐」，坐了十四天。出来的时候，总督府给他备了车。\n\n"
		+ "本报停刊。停刊那天，城里三家铺子关了门，什么都没说。\n\n"
		+ "两个月后，有人在南边见过一台旧印机，还在用。",

	Id.Coopt :
		"从这一期起，本报抬头加了四个字：奉命刊行。\n\n"
		+ "总督府的政令照登，四乡的收成照登，兵营的操演照登。数字都是总督府给的，很好看。\n\n"
		+ "报社的院子大了三倍，主笔换了新桌子。\n\n"
		+ "有时夜里会想起那些没登的事。想起来的时候，就把明天的版面再核一遍。",

	Id.FourthEstate :
		"总督府来函，问本报下期登什么。\n\n"
		+ "主笔回了八个字：还没定，定了送总督府一份。\n\n"
		+ "{days} 天里，本报登过总督府不想让人看的事，也顶过总督府的令。总督府动过手，没动成。\n\n"
		+ "城里现在有四家说得上话：地、兵、钱，和这张报纸。",

	Id.Coexist :
		"{days} 天，一天没停。\n\n"
		+ "总督府没办本报，本报也没扳倒总督府。该登的登了，该压的压了，各自留了一寸。\n\n"
		+ "下一期照常出刊。头版是一条河工的新闻，写得平，没人记得住。\n\n"
		+ "这样也好。",
}

# 领地段：这座城最后是什么样子。
const WORLD_BODY : Dictionary = {
	WorldState.Calm :
		"四乡的租麦进了仓，坊里的机器照常开，铺面一间接一间地开门。城门口的车马，比入秋时多了三成。",

	WorldState.Strain :
		"四乡的地租事到年底才平，逃出去的人回来了一半。坊里的机器开了又停，铺面还剩七成。\n\n"
		+ "这座城没有倒，只是矮了一截。",
}

# 一家算不算"极端"：只看它站在哪个状态，不看任何数值。
# 挑的是"城已经在街上"的那几档——
#   农民 动乱 / 工人 示威·动乱 / 商人 蛀空 / 士兵 哗变。
# 要加要减，只改这一处。
static func is_extreme(state : Variant) -> bool:
	if state == null:
		return false
	return (state is FarmerStateUpRising
		or state is WorkerStateMarch
		or state is WorkerStateUpRising
		or state is MerchantStateHollow
		or state is SoldierStateMutiny)


# 无主之城 / 乡野新序 本身就是领地的结局：不再接领地段。
static func uses_world_end(id : int) -> bool:
	return id != Id.NoMaster and id != Id.NewOrder


static func headline_of(id : int) -> String:
	return String(HEADLINE.get(id, ""))


# 正文里有天数的占位：一局多长，字就跟着说多长。
static func body_of(id : int, days : int) -> String:
	return String(BODY.get(id, "")).format({"days" : days, "next" : days + 1})


static func world_body_of(state : int) -> String:
	return String(WORLD_BODY.get(state, ""))
