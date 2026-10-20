class_name GovernmentActions extends RefCounted

# 政府能动的手 —— 一个动作一个方法，全是 static。

# 软手

# 安抚：花钱买平安——所有人的怒被压下去，国库跟着瘪。
static func conciliate(groups : Node, asset : GovernmentAsset) -> void:
	press_all(groups, "angry", GovernmentActionData.CONCILIATE_ANGRY)
	asset.money.spend(GovernmentActionData.CONCILIATE_COST)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentConciliate)

# 赈济：开仓放粮，先把最饿的两家（农民、工人）安顿住。
static func relief(groups : Node, asset : GovernmentAsset) -> void:
	for node in groups.get_children():
		if node is Farmers:
			press(node, "angry", GovernmentActionData.RELIEF_FARMER_ANGRY)
			press(node, "happy", GovernmentActionData.RELIEF_HAPPY)
		elif node is Workers:
			press(node, "angry", GovernmentActionData.RELIEF_WORKER_ANGRY)
			press(node, "happy", GovernmentActionData.RELIEF_HAPPY)
	asset.money.spend(GovernmentActionData.RELIEF_COST)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentRelief)

# 办实业：拿钱砸工业力，铺面有活干，人心松一点。
static func invest(groups : Node, asset : GovernmentAsset) -> void:
	press_all(groups, "happy", GovernmentActionData.INVEST_HAPPY)
	asset.money.spend(GovernmentActionData.INVEST_COST)
	asset.industry.add(GovernmentActionData.INVEST_GAIN)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentInvest)

# 扩军：拿钱招兵——兵多了，街面上也多一层怕。
static func recruit(groups : Node, asset : GovernmentAsset) -> void:
	press_all(groups, "fear", GovernmentActionData.RECRUIT_FEAR)
	for node in groups.get_children():
		if node is Soldier:
			press(node, "power", GovernmentActionData.RECRUIT_POWER)
	asset.money.spend(GovernmentActionData.RECRUIT_COST)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentRecruit)

# 硬手

# 弹压：派兵弹压——所有人的怕被抬起来，自己的兵一天天磨掉。
static func suppress(groups : Node, asset : GovernmentAsset) -> void:
	press_all(groups, "fear", GovernmentActionData.SUPPRESS_ALL_FEAR)
	for node in groups.get_children():
		if node is Soldier:
			press(node, "power", -GovernmentActionData.SUPPRESS_ALL_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

# 戒严：全城尽是枪——怕涨得更凶，但机器跟着停摆。
static func martial_law(groups : Node, asset : GovernmentAsset) -> void:
	press_all(groups, "fear", GovernmentActionData.MARTIAL_FEAR)
	press_all(groups, "happy", GovernmentActionData.MARTIAL_HAPPY)
	asset.industry.add(GovernmentActionData.MARTIAL_INDUSTRY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMartial)

# 刮钱 / 刮粮

# 征税：国库进一笔，商人与农民记恨——多收的那笔钱本来是他们兜里的。
static func tax(groups : Node, asset : GovernmentAsset) -> void:
	for node in groups.get_children():
		if node is Merchants:
			press(node, "angry", GovernmentActionData.TAX_MERCHANT_ANGRY)
		elif node is Farmers:
			press(node, "angry", GovernmentActionData.TAX_FARMER_ANGRY)
	asset.money.add(GovernmentActionData.TAX_GAIN)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentTax)

# 征粮：粮仓进一笔，怨气记在农民头上。
static func requisition(groups : Node, asset : GovernmentAsset) -> void:
	for node in groups.get_children():
		if node is Farmers:
			press(node, "angry", GovernmentActionData.REQUISITION_FARMER_ANGRY)
	asset.food.add(GovernmentActionData.REQUISITION_GAIN)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentRequisition)

# 政府的"对症下药"：每一家的每一个状态，各有一只对应的手。

# 每个姿势一张表**：同一个档的农民，常态政府和强硬政府的手不一样。

static func normal_against(group : Node) -> Callable:
	if group is Farmers:
		return normal_against_farmer(group)
	if group is Workers:
		return normal_against_worker(group)
	if group is Merchants:
		return normal_against_merchant(group)
	if group is Soldier:
		return normal_against_soldier(group)
	return Callable()

# 常态政府对农民：五档，五只对应的手。
static func normal_against_farmer(farmer : Farmers) -> Callable:
	var state : FarmerState = farmer.state_machine.current_state
	if state is FarmerStateNormal:
		return GovernmentActions.collect_grain
	if state is FarmerStateResist:
		return GovernmentActions.reduce_grain
	if state is FarmerStateSlowdown:
		return GovernmentActions.encourage_farming
	if state is FarmerStateFlee:
		return GovernmentActions.relieve_farmers
	if state is FarmerStateUpRising:
		return GovernmentActions.attempt_suppress
	return Callable()

# 常态 · 对农民的五只手（**这一节就是"基底"**）

# 正常 → 加收粮食：地里有人、也没闹事，趁这时候多收一笔。
static func collect_grain(groups : Node, asset : GovernmentAsset) -> void:
	press_farmers(groups, "fear", GovernmentActionData.COLLECT_GRAIN_FEAR)
	press_farmers(groups, "angry", GovernmentActionData.COLLECT_GRAIN_ANGRY)
	press_farmers(groups, "happy", GovernmentActionData.COLLECT_GRAIN_HAPPY)
	asset.food.add(GovernmentActionData.COLLECT_GRAIN_GAIN)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentRequisition)

# 抗租 → 减收粮食：让一步。
static func reduce_grain(groups : Node, asset : GovernmentAsset) -> void:
	press_farmers(groups, "angry", GovernmentActionData.REDUCE_GRAIN_ANGRY)
	asset.food.add(GovernmentActionData.REDUCE_GRAIN_LOSS)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentConciliate)

# 怠工 → 劝课农桑：不逼，改劝——派员下乡劝农、讲水利蚕桑。
static func encourage_farming(groups : Node, _asset : GovernmentAsset) -> void:
	press_farmers(groups, "happy", GovernmentActionData.ENCOURAGE_HAPPY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentFarming)

# 逃亡 → 开展赈济：人都跑了，先把怕按住，他们才肯回来。
static func relieve_farmers(groups : Node, _asset : GovernmentAsset) -> void:
	press_farmers(groups, "fear", GovernmentActionData.RELIEVE_FEAR)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentRelief)

# 动乱 → 尝试镇压：把人劝散——怒平了、怕消了，心里那口气也松了。
static func attempt_suppress(groups : Node, _asset : GovernmentAsset) -> void:
	press_farmers(groups, "happy", GovernmentActionData.SUPPRESS_HAPPY)
	press_farmers(groups, "fear", GovernmentActionData.SUPPRESS_FEAR)
	press_farmers(groups, "angry", GovernmentActionData.SUPPRESS_ANGRY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

# 强硬 · 对农民的五只手

static func hardline_against(group : Node) -> Callable:
	if group is Farmers:
		return hardline_against_farmer(group)
	if group is Workers:
		return hardline_against_worker(group)
	if group is Merchants:
		return hardline_against_merchant(group)
	if group is Soldier:
		return hardline_against_soldier(group)
	return Callable()

static func hardline_against_farmer(farmer : Farmers) -> Callable:
	var state : FarmerState = farmer.state_machine.current_state
	if state is FarmerStateNormal:
		return GovernmentActions.collect_grain
	if state is FarmerStateResist:
		return GovernmentActions.hardline_resist
	if state is FarmerStateSlowdown:
		return GovernmentActions.hardline_slowdown
	if state is FarmerStateFlee:
		return GovernmentActions.hardline_flee
	if state is FarmerStateUpRising:
		return GovernmentActions.hardline_uprising
	return Callable()

# 抗租 → 基底（减收粮食）+ 磨兵。
static func hardline_resist(groups : Node, asset : GovernmentAsset) -> void:
	press_farmers(groups, "angry", GovernmentActionData.REDUCE_GRAIN_ANGRY)
	asset.food.add(GovernmentActionData.REDUCE_GRAIN_LOSS)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

# 怠工 → 基底（劝课农桑）+ 磨兵。
static func hardline_slowdown(groups : Node, _asset : GovernmentAsset) -> void:
	press_farmers(groups, "happy", GovernmentActionData.ENCOURAGE_HAPPY)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReprimand)

# 逃亡 → 基底（开展赈济）+ 磨兵。
static func hardline_flee(groups : Node, _asset : GovernmentAsset) -> void:
	press_farmers(groups, "fear", GovernmentActionData.RELIEVE_FEAR)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentInternment)

# 动乱 → 基底（尝试镇压）+ 磨兵 + 打掉组织度。
static func hardline_uprising(groups : Node, _asset : GovernmentAsset) -> void:
	press_farmers(groups, "happy", GovernmentActionData.SUPPRESS_HAPPY)
	press_farmers(groups, "fear", GovernmentActionData.SUPPRESS_FEAR)
	press_farmers(groups, "angry", GovernmentActionData.SUPPRESS_ANGRY)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	press_farmers(groups, "power", -GovernmentActionData.HARDLINE_CRUSH_POWER)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

# 强硬那几只常用到的两个小工具：只摸农民 / 只摸兵。
static func press_farmers(groups : Node, key : String, delta : float) -> void:
	for node in groups.get_children():
		if node is Farmers:
			press(node, key, delta)

static func press_army(groups : Node, delta : float) -> void:
	for node in groups.get_children():
		if node is Soldier:
			press(node, "power", delta)

# 恐怖 · 对农民的五只手

static func terror_against(group : Node) -> Callable:
	if group is Farmers:
		return terror_against_farmer(group)
	if group is Workers:
		return terror_against_worker(group)
	if group is Merchants:
		return terror_against_merchant(group)
	if group is Soldier:
		return terror_against_soldier(group)
	return Callable()

static func terror_against_farmer(farmer : Farmers) -> Callable:
	var state : FarmerState = farmer.state_machine.current_state
	if state is FarmerStateNormal:
		return GovernmentActions.collect_grain
	if state is FarmerStateResist:
		return GovernmentActions.terror_resist
	if state is FarmerStateSlowdown:
		return GovernmentActions.terror_slowdown
	if state is FarmerStateFlee:
		return GovernmentActions.terror_flee
	if state is FarmerStateUpRising:
		return GovernmentActions.terror_uprising
	return Callable()

# 抗租 → 基底（减收粮食）+ 坏方向（怒往上）+ 磨兵（更狠）。
static func terror_resist(groups : Node, asset : GovernmentAsset) -> void:
	press_farmers(groups, "angry", GovernmentActionData.REDUCE_GRAIN_ANGRY)
	asset.food.add(GovernmentActionData.REDUCE_GRAIN_LOSS)
	press_farmers(groups, "angry", GovernmentActionData.TERROR_RESIST_ANGRY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentRequisition)

# 怠工 → 基底（劝课农桑）+ 坏方向（怕往上）+ 磨兵（更狠）。
static func terror_slowdown(groups : Node, _asset : GovernmentAsset) -> void:
	press_farmers(groups, "happy", GovernmentActionData.ENCOURAGE_HAPPY)
	press_farmers(groups, "fear", GovernmentActionData.TERROR_SLOWDOWN_FEAR)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReform)

# 逃亡 → 基底（开展赈济）+ 坏方向（怒往上）+ 磨兵（更狠）。
static func terror_flee(groups : Node, _asset : GovernmentAsset) -> void:
	press_farmers(groups, "fear", GovernmentActionData.RELIEVE_FEAR)
	press_farmers(groups, "angry", GovernmentActionData.TERROR_FLEE_ANGRY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentExpulsion)

# 动乱 → 基底（尝试镇压）+ 坏方向（乐压回去）+ 磨兵 + 打掉组织度。
static func terror_uprising(groups : Node, _asset : GovernmentAsset) -> void:
	press_farmers(groups, "happy", GovernmentActionData.SUPPRESS_HAPPY)
	press_farmers(groups, "fear", GovernmentActionData.SUPPRESS_FEAR)
	press_farmers(groups, "angry", GovernmentActionData.SUPPRESS_ANGRY)
	press_farmers(groups, "happy", GovernmentActionData.TERROR_UPRISING_HAPPY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	press_farmers(groups, "power", -GovernmentActionData.TERROR_CRUSH_POWER)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMassacre)

# 保守 · 对农民的五只手

static func conservative_against(group : Node) -> Callable:
	if group is Farmers:
		return conservative_against_farmer(group)
	if group is Workers:
		return conservative_against_worker(group)
	if group is Merchants:
		return conservative_against_merchant(group)
	if group is Soldier:
		return conservative_against_soldier(group)
	return Callable()

static func conservative_against_farmer(farmer : Farmers) -> Callable:
	var state : FarmerState = farmer.state_machine.current_state
	if state is FarmerStateNormal:
		return GovernmentActions.collect_grain
	if state is FarmerStateResist:
		return GovernmentActions.conservative_resist
	if state is FarmerStateSlowdown:
		return GovernmentActions.conservative_slowdown
	if state is FarmerStateFlee:
		return GovernmentActions.conservative_flee
	if state is FarmerStateUpRising:
		return GovernmentActions.conservative_uprising
	return Callable()

# 抗租 → 基底（减收粮食）+ 养兵。
static func conservative_resist(groups : Node, asset : GovernmentAsset) -> void:
	press_farmers(groups, "angry", GovernmentActionData.REDUCE_GRAIN_ANGRY)
	asset.food.add(GovernmentActionData.REDUCE_GRAIN_LOSS)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentConciliate)

# 怠工 → 基底（劝课农桑）+ 养兵。
static func conservative_slowdown(groups : Node, _asset : GovernmentAsset) -> void:
	press_farmers(groups, "happy", GovernmentActionData.ENCOURAGE_HAPPY)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentFavor)

# 逃亡 → 基底（开展赈济）+ 养兵。
static func conservative_flee(groups : Node, _asset : GovernmentAsset) -> void:
	press_farmers(groups, "fear", GovernmentActionData.RELIEVE_FEAR)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentRelief)

# 动乱 → 基底（尝试镇压）+ 养兵 + 力气涨回来。
static func conservative_uprising(groups : Node, _asset : GovernmentAsset) -> void:
	press_farmers(groups, "happy", GovernmentActionData.SUPPRESS_HAPPY)
	press_farmers(groups, "fear", GovernmentActionData.SUPPRESS_FEAR)
	press_farmers(groups, "angry", GovernmentActionData.SUPPRESS_ANGRY)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	press_farmers(groups, "power", GovernmentActionData.CONSERVATIVE_SURRENDER)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

# 无能 · 对农民的五只手

static func incompetent_against(group : Node) -> Callable:
	if group is Farmers:
		return incompetent_against_farmer(group)
	if group is Workers:
		return incompetent_against_worker(group)
	if group is Merchants:
		return incompetent_against_merchant(group)
	if group is Soldier:
		return incompetent_against_soldier(group)
	return Callable()

static func incompetent_against_farmer(farmer : Farmers) -> Callable:
	var state : FarmerState = farmer.state_machine.current_state
	if state is FarmerStateNormal:
		return GovernmentActions.collect_grain
	if state is FarmerStateResist:
		return GovernmentActions.incompetent_resist
	if state is FarmerStateSlowdown:
		return GovernmentActions.incompetent_slowdown
	if state is FarmerStateFlee:
		return GovernmentActions.incompetent_flee
	if state is FarmerStateUpRising:
		return GovernmentActions.incompetent_uprising
	return Callable()

# 抗租 → 基底（减收粮食）+ 白丢一笔 + 养兵（更厚）。
static func incompetent_resist(groups : Node, asset : GovernmentAsset) -> void:
	press_farmers(groups, "angry", GovernmentActionData.REDUCE_GRAIN_ANGRY)
	asset.food.add(GovernmentActionData.REDUCE_GRAIN_LOSS)
	asset.food.add(GovernmentActionData.INCOMPETENT_FOOD)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentConciliate)

# 怠工 → 基底（劝课农桑）+ 白丢一笔 + 养兵（更厚）。
static func incompetent_slowdown(groups : Node, asset : GovernmentAsset) -> void:
	press_farmers(groups, "happy", GovernmentActionData.ENCOURAGE_HAPPY)
	asset.food.add(GovernmentActionData.INCOMPETENT_FOOD)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentHelpless)

# 逃亡 → 基底（开展赈济）+ 白丢一笔 + 养兵（更厚）。
static func incompetent_flee(groups : Node, asset : GovernmentAsset) -> void:
	press_farmers(groups, "fear", GovernmentActionData.RELIEVE_FEAR)
	asset.food.add(GovernmentActionData.INCOMPETENT_FOOD)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentIdle)

# 动乱 → 基底（尝试镇压）+ 养兵（更厚）+ 力气涨回来 + 白丢一笔。
static func incompetent_uprising(groups : Node, asset : GovernmentAsset) -> void:
	press_farmers(groups, "happy", GovernmentActionData.SUPPRESS_HAPPY)
	press_farmers(groups, "fear", GovernmentActionData.SUPPRESS_FEAR)
	press_farmers(groups, "angry", GovernmentActionData.SUPPRESS_ANGRY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	press_farmers(groups, "power", GovernmentActionData.CONSERVATIVE_SURRENDER)
	asset.food.add(GovernmentActionData.INCOMPETENT_FOOD)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDrift)

# 工人 Workers

# 各档叠的那一层里，四家共用的两笔"亏账"（无能政府的白丢）。

# 工人 · 基底（常态的五只）

# 正常 → 摊派工役：厂里人齐、也不闹，趁这时候多榨一笔。
static func draft_labor(groups : Node, asset : GovernmentAsset) -> void:
	press_workers(groups, "fear", GovernmentActionData.DRAFT_FEAR)
	press_workers(groups, "angry", GovernmentActionData.DRAFT_ANGRY)
	press_workers(groups, "happy", GovernmentActionData.DRAFT_HAPPY)
	asset.industry.add(GovernmentActionData.DRAFT_INDUSTRY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDraft)

# 怠工 → 劝谕上工：不逼，只劝。
static func exhort_workers(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "happy", GovernmentActionData.EXHORT_HAPPY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentExhort)

# 低效 → 以工代赈：人不敢进厂、厂里也没活，政府开工赈着。
static func work_relief(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "fear", GovernmentActionData.WORK_RELIEF_FEAR)
	press_workers(groups, "happy", GovernmentActionData.WORK_RELIEF_HAPPY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentWorkRelief)

# 停工 → 调处工潮：把厂主与工人叫到一处，各让一步。
static func arbitration(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "angry", GovernmentActionData.ARBITRATE_ANGRY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentArbitration)

# 示威 → 劝散聚集：沿街劝导，有话递禀，不必聚众。
static func disperse(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "angry", GovernmentActionData.DISPERSE_ANGRY)
	press_workers(groups, "fear", GovernmentActionData.DISPERSE_FEAR)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDisperse)

# 动乱 → 尝试镇压：与农民那一只同法（借"调兵弹压"）。
static func attempt_suppress_workers(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "happy", GovernmentActionData.SUPPRESS_HAPPY)
	press_workers(groups, "fear", GovernmentActionData.SUPPRESS_FEAR)
	press_workers(groups, "angry", GovernmentActionData.SUPPRESS_ANGRY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

# 常态政府对工人：五只对应的手。
static func normal_against_worker(worker : Workers) -> Callable:
	var state : WorkerState = worker.state_machine.current_state
	if state is WorkerStateNormal:
		return GovernmentActions.draft_labor
	if state is WorkerStateSlowdown:
		return GovernmentActions.exhort_workers
	if state is WorkerStateDepression:
		return GovernmentActions.work_relief
	if state is WorkerStateStrike:
		return GovernmentActions.arbitration
	if state is WorkerStateMarch:
		return GovernmentActions.disperse
	if state is WorkerStateUpRising:
		return GovernmentActions.attempt_suppress_workers
	return Callable()

# 强硬 · 对工人的五只手（基底 + 磨兵）

static func hardline_worker_slowdown(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "happy", GovernmentActionData.EXHORT_HAPPY)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

static func hardline_worker_depression(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "fear", GovernmentActionData.WORK_RELIEF_FEAR)
	press_workers(groups, "happy", GovernmentActionData.WORK_RELIEF_HAPPY)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentInternment)

static func hardline_worker_strike(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "angry", GovernmentActionData.ARBITRATE_ANGRY)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

static func hardline_worker_march(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "angry", GovernmentActionData.DISPERSE_ANGRY)
	press_workers(groups, "fear", GovernmentActionData.DISPERSE_FEAR)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMartial)

static func hardline_worker_uprising(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "happy", GovernmentActionData.SUPPRESS_HAPPY)
	press_workers(groups, "fear", GovernmentActionData.SUPPRESS_FEAR)
	press_workers(groups, "angry", GovernmentActionData.SUPPRESS_ANGRY)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	press_workers(groups, "power", -GovernmentActionData.HARDLINE_CRUSH_POWER)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

static func hardline_against_worker(worker : Workers) -> Callable:
	var state : WorkerState = worker.state_machine.current_state
	if state is WorkerStateNormal:
		return GovernmentActions.draft_labor
	if state is WorkerStateSlowdown:
		return GovernmentActions.hardline_worker_slowdown
	if state is WorkerStateDepression:
		return GovernmentActions.hardline_worker_depression
	if state is WorkerStateStrike:
		return GovernmentActions.hardline_worker_strike
	if state is WorkerStateMarch:
		return GovernmentActions.hardline_worker_march
	if state is WorkerStateUpRising:
		return GovernmentActions.hardline_worker_uprising
	return Callable()

# 恐怖 · 对工人的五只手（基底 + 更狠磨兵 + 坏方向）

static func terror_worker_slowdown(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "happy", GovernmentActionData.EXHORT_HAPPY)
	press_workers(groups, "happy", GovernmentActionData.TERROR_WORKER_SLOWDOWN_HAPPY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReform)

static func terror_worker_depression(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "fear", GovernmentActionData.WORK_RELIEF_FEAR)
	press_workers(groups, "happy", GovernmentActionData.WORK_RELIEF_HAPPY)
	press_workers(groups, "angry", GovernmentActionData.TERROR_WORKER_DEPRESSION_ANGRY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentExpulsion)

static func terror_worker_strike(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "angry", GovernmentActionData.ARBITRATE_ANGRY)
	press_workers(groups, "angry", GovernmentActionData.TERROR_WORKER_STRIKE_ANGRY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMassacre)

static func terror_worker_march(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "angry", GovernmentActionData.DISPERSE_ANGRY)
	press_workers(groups, "fear", GovernmentActionData.DISPERSE_FEAR)
	press_workers(groups, "angry", GovernmentActionData.TERROR_WORKER_MARCH_ANGRY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMassacre)

static func terror_worker_uprising(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "happy", GovernmentActionData.SUPPRESS_HAPPY)
	press_workers(groups, "fear", GovernmentActionData.SUPPRESS_FEAR)
	press_workers(groups, "angry", GovernmentActionData.SUPPRESS_ANGRY)
	press_workers(groups, "happy", GovernmentActionData.TERROR_UPRISING_HAPPY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	press_workers(groups, "power", -GovernmentActionData.TERROR_CRUSH_POWER)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMassacre)

static func terror_against_worker(worker : Workers) -> Callable:
	var state : WorkerState = worker.state_machine.current_state
	if state is WorkerStateNormal:
		return GovernmentActions.draft_labor
	if state is WorkerStateSlowdown:
		return GovernmentActions.terror_worker_slowdown
	if state is WorkerStateDepression:
		return GovernmentActions.terror_worker_depression
	if state is WorkerStateStrike:
		return GovernmentActions.terror_worker_strike
	if state is WorkerStateMarch:
		return GovernmentActions.terror_worker_march
	if state is WorkerStateUpRising:
		return GovernmentActions.terror_worker_uprising
	return Callable()

# 保守 · 对工人的五只手（基底 + 养兵。

static func conservative_worker_slowdown(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "happy", GovernmentActionData.EXHORT_HAPPY)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

static func conservative_worker_depression(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "fear", GovernmentActionData.WORK_RELIEF_FEAR)
	press_workers(groups, "happy", GovernmentActionData.WORK_RELIEF_HAPPY)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentRelief)

static func conservative_worker_strike(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "angry", GovernmentActionData.ARBITRATE_ANGRY)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

static func conservative_worker_march(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "angry", GovernmentActionData.DISPERSE_ANGRY)
	press_workers(groups, "fear", GovernmentActionData.DISPERSE_FEAR)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

static func conservative_worker_uprising(groups : Node, _asset : GovernmentAsset) -> void:
	press_workers(groups, "happy", GovernmentActionData.SUPPRESS_HAPPY)
	press_workers(groups, "fear", GovernmentActionData.SUPPRESS_FEAR)
	press_workers(groups, "angry", GovernmentActionData.SUPPRESS_ANGRY)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	press_workers(groups, "power", GovernmentActionData.CONSERVATIVE_SURRENDER)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

static func conservative_against_worker(worker : Workers) -> Callable:
	var state : WorkerState = worker.state_machine.current_state
	if state is WorkerStateNormal:
		return GovernmentActions.draft_labor
	if state is WorkerStateSlowdown:
		return GovernmentActions.conservative_worker_slowdown
	if state is WorkerStateDepression:
		return GovernmentActions.conservative_worker_depression
	if state is WorkerStateStrike:
		return GovernmentActions.conservative_worker_strike
	if state is WorkerStateMarch:
		return GovernmentActions.conservative_worker_march
	if state is WorkerStateUpRising:
		return GovernmentActions.conservative_worker_uprising
	return Callable()

# 无能 · 对工人的五只手（保守那一层 + 每只白丢一笔工业力）

static func incompetent_worker_slowdown(groups : Node, asset : GovernmentAsset) -> void:
	press_workers(groups, "happy", GovernmentActionData.EXHORT_HAPPY)
	asset.industry.add(GovernmentActionData.INCOMPETENT_INDUSTRY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentHelpless)

static func incompetent_worker_depression(groups : Node, asset : GovernmentAsset) -> void:
	press_workers(groups, "fear", GovernmentActionData.WORK_RELIEF_FEAR)
	press_workers(groups, "happy", GovernmentActionData.WORK_RELIEF_HAPPY)
	asset.industry.add(GovernmentActionData.INCOMPETENT_INDUSTRY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentIdle)

static func incompetent_worker_strike(groups : Node, asset : GovernmentAsset) -> void:
	press_workers(groups, "angry", GovernmentActionData.ARBITRATE_ANGRY)
	asset.industry.add(GovernmentActionData.INCOMPETENT_INDUSTRY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDrift)

static func incompetent_worker_march(groups : Node, asset : GovernmentAsset) -> void:
	press_workers(groups, "angry", GovernmentActionData.DISPERSE_ANGRY)
	press_workers(groups, "fear", GovernmentActionData.DISPERSE_FEAR)
	asset.industry.add(GovernmentActionData.INCOMPETENT_INDUSTRY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDrift)

static func incompetent_worker_uprising(groups : Node, asset : GovernmentAsset) -> void:
	press_workers(groups, "happy", GovernmentActionData.SUPPRESS_HAPPY)
	press_workers(groups, "fear", GovernmentActionData.SUPPRESS_FEAR)
	press_workers(groups, "angry", GovernmentActionData.SUPPRESS_ANGRY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	press_workers(groups, "power", GovernmentActionData.CONSERVATIVE_SURRENDER)
	asset.industry.add(GovernmentActionData.INCOMPETENT_INDUSTRY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDrift)

static func incompetent_against_worker(worker : Workers) -> Callable:
	var state : WorkerState = worker.state_machine.current_state
	if state is WorkerStateNormal:
		return GovernmentActions.draft_labor
	if state is WorkerStateSlowdown:
		return GovernmentActions.incompetent_worker_slowdown
	if state is WorkerStateDepression:
		return GovernmentActions.incompetent_worker_depression
	if state is WorkerStateStrike:
		return GovernmentActions.incompetent_worker_strike
	if state is WorkerStateMarch:
		return GovernmentActions.incompetent_worker_march
	if state is WorkerStateUpRising:
		return GovernmentActions.incompetent_worker_uprising
	return Callable()

# 商人 Merchants

# 商人 · 基底（常态的五只，正常那一只与四层共用）

# 正常 → 加征商捐：货物进出按成抽收。
static func collect_excise(groups : Node, asset : GovernmentAsset) -> void:
	press_merchants(groups, "fear", GovernmentActionData.EXCISE_FEAR)
	press_merchants(groups, "angry", GovernmentActionData.EXCISE_ANGRY)
	press_merchants(groups, "happy", GovernmentActionData.EXCISE_HAPPY)
	asset.money.add(GovernmentActionData.EXCISE_MONEY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentExcise)

# 繁荣 → 劝募公债：生意最好的时候伸手借一笔。
static func call_bond(groups : Node, asset : GovernmentAsset) -> void:
	press_merchants(groups, "happy", GovernmentActionData.BOND_HAPPY)
	asset.money.add(GovernmentActionData.BOND_GAIN)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentBond)

# 投资 → 保商护业：免杂捐、加巡查，只求钱留在本埠。
static func protect_trade(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "fear", GovernmentActionData.PROTECT_FEAR)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentProtect)

# 外逃 → 挽留殷商：派员分头挽留，人在，税基就在。
static func retain_merchants(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "angry", GovernmentActionData.RETAIN_ANGRY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentRetain)

# 投机 → 查禁囤积：查栈、责成平价出粜。
static func inspect_hoarding(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "happy", GovernmentActionData.INSPECT_HAPPY)
	press_merchants(groups, "angry", GovernmentActionData.INSPECT_ANGRY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentInspect)

# 蛀空 → 整顿市面：限期复业、不许久闭。
static func rectify_market(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "fear", GovernmentActionData.RECTIFY_FEAR)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentRectify)

# 常态政府对商人：五只对应的手。
static func normal_against_merchant(merchant : Merchants) -> Callable:
	var state : MerchantState = merchant.state_machine.current_state
	if state is MerchantStateNormal:
		return GovernmentActions.collect_excise
	if state is MerchantStateProsperity:
		return GovernmentActions.call_bond
	if state is MerchantStateInvest:
		return GovernmentActions.protect_trade
	if state is MerchantStateAbroad:
		return GovernmentActions.retain_merchants
	if state is MerchantStateSpeculate:
		return GovernmentActions.inspect_hoarding
	if state is MerchantStateHollow:
		return GovernmentActions.rectify_market
	return Callable()

# 强硬 · 对商人的五只手（基底 + 磨兵）

static func hardline_merchant_prosperity(groups : Node, asset : GovernmentAsset) -> void:
	press_merchants(groups, "happy", GovernmentActionData.BOND_HAPPY)
	asset.money.add(GovernmentActionData.BOND_GAIN)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

static func hardline_merchant_invest(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "fear", GovernmentActionData.PROTECT_FEAR)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

static func hardline_merchant_abroad(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "angry", GovernmentActionData.RETAIN_ANGRY)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

static func hardline_merchant_speculate(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "happy", GovernmentActionData.INSPECT_HAPPY)
	press_merchants(groups, "angry", GovernmentActionData.INSPECT_ANGRY)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMartial)

static func hardline_merchant_hollow(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "fear", GovernmentActionData.RECTIFY_FEAR)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	press_merchants(groups, "power", -GovernmentActionData.HARDLINE_CRUSH_POWER)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

static func hardline_against_merchant(merchant : Merchants) -> Callable:
	var state : MerchantState = merchant.state_machine.current_state
	if state is MerchantStateNormal:
		return GovernmentActions.collect_excise
	if state is MerchantStateProsperity:
		return GovernmentActions.hardline_merchant_prosperity
	if state is MerchantStateInvest:
		return GovernmentActions.hardline_merchant_invest
	if state is MerchantStateAbroad:
		return GovernmentActions.hardline_merchant_abroad
	if state is MerchantStateSpeculate:
		return GovernmentActions.hardline_merchant_speculate
	if state is MerchantStateHollow:
		return GovernmentActions.hardline_merchant_hollow
	return Callable()

# 恐怖 · 对商人的五只手（基底 + 更狠磨兵 + 坏方向）

static func terror_merchant_prosperity(groups : Node, asset : GovernmentAsset) -> void:
	press_merchants(groups, "happy", GovernmentActionData.BOND_HAPPY)
	asset.money.add(GovernmentActionData.BOND_GAIN)
	press_merchants(groups, "happy", GovernmentActionData.TERROR_MERCHANT_PROSPERITY_HAPPY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMartial)

static func terror_merchant_invest(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "fear", GovernmentActionData.PROTECT_FEAR)
	press_merchants(groups, "fear", GovernmentActionData.TERROR_MERCHANT_INVEST_FEAR)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMartial)

static func terror_merchant_abroad(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "angry", GovernmentActionData.RETAIN_ANGRY)
	press_merchants(groups, "happy", GovernmentActionData.TERROR_MERCHANT_ABROAD_HAPPY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentExpulsion)

static func terror_merchant_speculate(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "happy", GovernmentActionData.INSPECT_HAPPY)
	press_merchants(groups, "angry", GovernmentActionData.INSPECT_ANGRY)
	press_merchants(groups, "fear", GovernmentActionData.TERROR_MERCHANT_SPECULATE_FEAR)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMartial)

static func terror_merchant_hollow(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "fear", GovernmentActionData.RECTIFY_FEAR)
	press_merchants(groups, "happy", GovernmentActionData.TERROR_MERCHANT_HOLLOW_HAPPY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	press_merchants(groups, "power", -GovernmentActionData.TERROR_CRUSH_POWER)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMartial)

static func terror_against_merchant(merchant : Merchants) -> Callable:
	var state : MerchantState = merchant.state_machine.current_state
	if state is MerchantStateNormal:
		return GovernmentActions.collect_excise
	if state is MerchantStateProsperity:
		return GovernmentActions.terror_merchant_prosperity
	if state is MerchantStateInvest:
		return GovernmentActions.terror_merchant_invest
	if state is MerchantStateAbroad:
		return GovernmentActions.terror_merchant_abroad
	if state is MerchantStateSpeculate:
		return GovernmentActions.terror_merchant_speculate
	if state is MerchantStateHollow:
		return GovernmentActions.terror_merchant_hollow
	return Callable()

# 保守 · 对商人的五只手（基底 + 养兵。

static func conservative_merchant_prosperity(groups : Node, asset : GovernmentAsset) -> void:
	press_merchants(groups, "happy", GovernmentActionData.BOND_HAPPY)
	asset.money.add(GovernmentActionData.BOND_GAIN)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

static func conservative_merchant_invest(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "fear", GovernmentActionData.PROTECT_FEAR)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentInvest)

static func conservative_merchant_abroad(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "angry", GovernmentActionData.RETAIN_ANGRY)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

static func conservative_merchant_speculate(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "happy", GovernmentActionData.INSPECT_HAPPY)
	press_merchants(groups, "angry", GovernmentActionData.INSPECT_ANGRY)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

static func conservative_merchant_hollow(groups : Node, _asset : GovernmentAsset) -> void:
	press_merchants(groups, "fear", GovernmentActionData.RECTIFY_FEAR)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	press_merchants(groups, "power", GovernmentActionData.CONSERVATIVE_SURRENDER)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

static func conservative_against_merchant(merchant : Merchants) -> Callable:
	var state : MerchantState = merchant.state_machine.current_state
	if state is MerchantStateNormal:
		return GovernmentActions.collect_excise
	if state is MerchantStateProsperity:
		return GovernmentActions.conservative_merchant_prosperity
	if state is MerchantStateInvest:
		return GovernmentActions.conservative_merchant_invest
	if state is MerchantStateAbroad:
		return GovernmentActions.conservative_merchant_abroad
	if state is MerchantStateSpeculate:
		return GovernmentActions.conservative_merchant_speculate
	if state is MerchantStateHollow:
		return GovernmentActions.conservative_merchant_hollow
	return Callable()

# 无能 · 对商人的五只手（保守那一层 + 每只白丢一笔钱）

static func incompetent_merchant_prosperity(groups : Node, asset : GovernmentAsset) -> void:
	press_merchants(groups, "happy", GovernmentActionData.BOND_HAPPY)
	asset.money.add(GovernmentActionData.BOND_GAIN)
	asset.money.add(GovernmentActionData.INCOMPETENT_MONEY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentIdle)

static func incompetent_merchant_invest(groups : Node, asset : GovernmentAsset) -> void:
	press_merchants(groups, "fear", GovernmentActionData.PROTECT_FEAR)
	asset.money.add(GovernmentActionData.INCOMPETENT_MONEY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentHelpless)

static func incompetent_merchant_abroad(groups : Node, asset : GovernmentAsset) -> void:
	press_merchants(groups, "angry", GovernmentActionData.RETAIN_ANGRY)
	asset.money.add(GovernmentActionData.INCOMPETENT_MONEY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDrift)

static func incompetent_merchant_speculate(groups : Node, asset : GovernmentAsset) -> void:
	press_merchants(groups, "happy", GovernmentActionData.INSPECT_HAPPY)
	press_merchants(groups, "angry", GovernmentActionData.INSPECT_ANGRY)
	asset.money.add(GovernmentActionData.INCOMPETENT_MONEY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDrift)

static func incompetent_merchant_hollow(groups : Node, asset : GovernmentAsset) -> void:
	press_merchants(groups, "fear", GovernmentActionData.RECTIFY_FEAR)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	press_merchants(groups, "power", GovernmentActionData.CONSERVATIVE_SURRENDER)
	asset.money.add(GovernmentActionData.INCOMPETENT_MONEY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDrift)

static func incompetent_against_merchant(merchant : Merchants) -> Callable:
	var state : MerchantState = merchant.state_machine.current_state
	if state is MerchantStateNormal:
		return GovernmentActions.collect_excise
	if state is MerchantStateProsperity:
		return GovernmentActions.incompetent_merchant_prosperity
	if state is MerchantStateInvest:
		return GovernmentActions.incompetent_merchant_invest
	if state is MerchantStateAbroad:
		return GovernmentActions.incompetent_merchant_abroad
	if state is MerchantStateSpeculate:
		return GovernmentActions.incompetent_merchant_speculate
	if state is MerchantStateHollow:
		return GovernmentActions.incompetent_merchant_hollow
	return Callable()

# 士兵 Soldier

# 士兵 · 基底（常态的五只，正常那一只与四层共用）

# 正常 → 点验充伍：承平之日，点名、验枪、补额——营里也跟着紧一紧。
static func muster(groups : Node, asset : GovernmentAsset) -> void:
	press_soldiers(groups, "fear", GovernmentActionData.MUSTER_FEAR)
	press_soldiers(groups, "power", GovernmentActionData.MUSTER_POWER)
	asset.money.spend(GovernmentActionData.MUSTER_COST)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentRecruit)

# 腐败 → 饬令操演：点名不到者惩、枪械不清者罚。
static func drill_troops(groups : Node, _asset : GovernmentAsset) -> void:
	press_soldiers(groups, "angry", GovernmentActionData.DRILL_ANGRY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDrill)

# 溃散 → 补发欠饷：欠了几个月的饷先补一月。
static func pay_arrears(groups : Node, asset : GovernmentAsset) -> void:
	press_soldiers(groups, "happy", GovernmentActionData.PAY_HAPPY)
	asset.money.spend(GovernmentActionData.PAY_COST)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentPay)

# 扰民 → 申明军法：扰民者以军法从事。
static func army_law(groups : Node, _asset : GovernmentAsset) -> void:
	press_soldiers(groups, "fear", GovernmentActionData.ARMY_LAW_FEAR)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentArmyLaw)

# 哗变 → 招抚收心：宣谕犒赏，先把人心拢回来。
static func pacify_mutiny(groups : Node, _asset : GovernmentAsset) -> void:
	press_soldiers(groups, "happy", GovernmentActionData.PACIFY_HAPPY)
	press_soldiers(groups, "fear", GovernmentActionData.PACIFY_FEAR)
	press_soldiers(groups, "angry", GovernmentActionData.PACIFY_ANGRY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

# 常态政府对士兵：五只对应的手。
static func normal_against_soldier(soldier : Soldier) -> Callable:
	var state : SoldierState = soldier.state_machine.current_state
	if state is SoldierStateNormal:
		return GovernmentActions.muster
	if state is SoldierStateCorrupt:
		return GovernmentActions.drill_troops
	if state is SoldierStateDesert:
		return GovernmentActions.pay_arrears
	if state is SoldierStateRampage:
		return GovernmentActions.army_law
	if state is SoldierStateMutiny:
		return GovernmentActions.pacify_mutiny
	return Callable()

# 强硬 · 对士兵的五只手（基底 + 磨兵）

static func hardline_soldier_corrupt(groups : Node, _asset : GovernmentAsset) -> void:
	press_soldiers(groups, "angry", GovernmentActionData.DRILL_ANGRY)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReform)

static func hardline_soldier_desert(groups : Node, asset : GovernmentAsset) -> void:
	press_soldiers(groups, "happy", GovernmentActionData.PAY_HAPPY)
	asset.money.spend(GovernmentActionData.PAY_COST)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentInternment)

static func hardline_soldier_rampage(groups : Node, _asset : GovernmentAsset) -> void:
	press_soldiers(groups, "fear", GovernmentActionData.ARMY_LAW_FEAR)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

static func hardline_soldier_mutiny(groups : Node, _asset : GovernmentAsset) -> void:
	press_soldiers(groups, "happy", GovernmentActionData.PACIFY_HAPPY)
	press_soldiers(groups, "fear", GovernmentActionData.PACIFY_FEAR)
	press_soldiers(groups, "angry", GovernmentActionData.PACIFY_ANGRY)
	press_army(groups, -GovernmentActionData.HARDLINE_ARMY)
	press_soldiers(groups, "power", -GovernmentActionData.HARDLINE_CRUSH_POWER)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)

static func hardline_against_soldier(soldier : Soldier) -> Callable:
	var state : SoldierState = soldier.state_machine.current_state
	if state is SoldierStateNormal:
		return GovernmentActions.muster
	if state is SoldierStateCorrupt:
		return GovernmentActions.hardline_soldier_corrupt
	if state is SoldierStateDesert:
		return GovernmentActions.hardline_soldier_desert
	if state is SoldierStateRampage:
		return GovernmentActions.hardline_soldier_rampage
	if state is SoldierStateMutiny:
		return GovernmentActions.hardline_soldier_mutiny
	return Callable()

# 恐怖 · 对士兵的五只手（基底 + 更狠磨兵 + 坏方向）

static func terror_soldier_corrupt(groups : Node, _asset : GovernmentAsset) -> void:
	press_soldiers(groups, "angry", GovernmentActionData.DRILL_ANGRY)
	press_soldiers(groups, "angry", GovernmentActionData.TERROR_SOLDIER_CORRUPT_ANGRY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReform)

static func terror_soldier_desert(groups : Node, asset : GovernmentAsset) -> void:
	press_soldiers(groups, "happy", GovernmentActionData.PAY_HAPPY)
	asset.money.spend(GovernmentActionData.PAY_COST)
	press_soldiers(groups, "happy", GovernmentActionData.TERROR_SOLDIER_DESERT_HAPPY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentExpulsion)

static func terror_soldier_rampage(groups : Node, _asset : GovernmentAsset) -> void:
	press_soldiers(groups, "fear", GovernmentActionData.ARMY_LAW_FEAR)
	press_soldiers(groups, "fear", GovernmentActionData.TERROR_SOLDIER_RAMPAGE_FEAR)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMassacre)

static func terror_soldier_mutiny(groups : Node, _asset : GovernmentAsset) -> void:
	press_soldiers(groups, "happy", GovernmentActionData.PACIFY_HAPPY)
	press_soldiers(groups, "fear", GovernmentActionData.PACIFY_FEAR)
	press_soldiers(groups, "angry", GovernmentActionData.PACIFY_ANGRY)
	press_soldiers(groups, "happy", GovernmentActionData.TERROR_UPRISING_HAPPY)
	press_army(groups, -GovernmentActionData.TERROR_ARMY)
	press_soldiers(groups, "power", -GovernmentActionData.TERROR_CRUSH_POWER)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentMassacre)

static func terror_against_soldier(soldier : Soldier) -> Callable:
	var state : SoldierState = soldier.state_machine.current_state
	if state is SoldierStateNormal:
		return GovernmentActions.muster
	if state is SoldierStateCorrupt:
		return GovernmentActions.terror_soldier_corrupt
	if state is SoldierStateDesert:
		return GovernmentActions.terror_soldier_desert
	if state is SoldierStateRampage:
		return GovernmentActions.terror_soldier_rampage
	if state is SoldierStateMutiny:
		return GovernmentActions.terror_soldier_mutiny
	return Callable()

# 保守 · 对士兵的五只手（基底 + 养兵。

static func conservative_soldier_corrupt(groups : Node, _asset : GovernmentAsset) -> void:
	press_soldiers(groups, "angry", GovernmentActionData.DRILL_ANGRY)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

static func conservative_soldier_desert(groups : Node, asset : GovernmentAsset) -> void:
	press_soldiers(groups, "happy", GovernmentActionData.PAY_HAPPY)
	asset.money.spend(GovernmentActionData.PAY_COST)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentRelief)

static func conservative_soldier_rampage(groups : Node, _asset : GovernmentAsset) -> void:
	press_soldiers(groups, "fear", GovernmentActionData.ARMY_LAW_FEAR)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

static func conservative_soldier_mutiny(groups : Node, _asset : GovernmentAsset) -> void:
	press_soldiers(groups, "happy", GovernmentActionData.PACIFY_HAPPY)
	press_soldiers(groups, "fear", GovernmentActionData.PACIFY_FEAR)
	press_soldiers(groups, "angry", GovernmentActionData.PACIFY_ANGRY)
	press_army(groups, GovernmentActionData.CONSERVATIVE_ARMY)
	press_soldiers(groups, "power", GovernmentActionData.CONSERVATIVE_SURRENDER)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentReconcile)

static func conservative_against_soldier(soldier : Soldier) -> Callable:
	var state : SoldierState = soldier.state_machine.current_state
	if state is SoldierStateNormal:
		return GovernmentActions.muster
	if state is SoldierStateCorrupt:
		return GovernmentActions.conservative_soldier_corrupt
	if state is SoldierStateDesert:
		return GovernmentActions.conservative_soldier_desert
	if state is SoldierStateRampage:
		return GovernmentActions.conservative_soldier_rampage
	if state is SoldierStateMutiny:
		return GovernmentActions.conservative_soldier_mutiny
	return Callable()

# 无能 · 对士兵的五只手（保守那一层 + 每只白丢一笔钱）

static func incompetent_soldier_corrupt(groups : Node, asset : GovernmentAsset) -> void:
	press_soldiers(groups, "angry", GovernmentActionData.DRILL_ANGRY)
	asset.money.add(GovernmentActionData.INCOMPETENT_MONEY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentHelpless)

static func incompetent_soldier_desert(groups : Node, asset : GovernmentAsset) -> void:
	press_soldiers(groups, "happy", GovernmentActionData.PAY_HAPPY)
	asset.money.spend(GovernmentActionData.PAY_COST)
	asset.money.add(GovernmentActionData.INCOMPETENT_MONEY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDrift)

static func incompetent_soldier_rampage(groups : Node, asset : GovernmentAsset) -> void:
	press_soldiers(groups, "fear", GovernmentActionData.ARMY_LAW_FEAR)
	asset.money.add(GovernmentActionData.INCOMPETENT_MONEY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDrift)

static func incompetent_soldier_mutiny(groups : Node, asset : GovernmentAsset) -> void:
	press_soldiers(groups, "happy", GovernmentActionData.PACIFY_HAPPY)
	press_soldiers(groups, "fear", GovernmentActionData.PACIFY_FEAR)
	press_soldiers(groups, "angry", GovernmentActionData.PACIFY_ANGRY)
	press_army(groups, GovernmentActionData.INCOMPETENT_ARMY)
	press_soldiers(groups, "power", GovernmentActionData.CONSERVATIVE_SURRENDER)
	asset.money.add(GovernmentActionData.INCOMPETENT_MONEY)
	RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentDrift)

static func incompetent_against_soldier(soldier : Soldier) -> Callable:
	var state : SoldierState = soldier.state_machine.current_state
	if state is SoldierStateNormal:
		return GovernmentActions.muster
	if state is SoldierStateCorrupt:
		return GovernmentActions.incompetent_soldier_corrupt
	if state is SoldierStateDesert:
		return GovernmentActions.incompetent_soldier_desert
	if state is SoldierStateRampage:
		return GovernmentActions.incompetent_soldier_rampage
	if state is SoldierStateMutiny:
		return GovernmentActions.incompetent_soldier_mutiny
	return Callable()

# 另外三家的下力方式（与 press_farmers 一个写法）

static func press_workers(groups : Node, key : String, delta : float) -> void:
	for node in groups.get_children():
		if node is Workers:
			press(node, key, delta)

static func press_merchants(groups : Node, key : String, delta : float) -> void:
	for node in groups.get_children():
		if node is Merchants:
			press(node, key, delta)

static func press_soldiers(groups : Node, key : String, delta : float) -> void:
	for node in groups.get_children():
		if node is Soldier:
			press(node, key, delta)

# 所有动作共用的下力方式

static func press_all(groups : Node, key : String, delta : float) -> void:
	for node in groups.get_children():
		press(node, key, delta)

static func press(node : Node, key : String, delta : float) -> void:
	if not ("attribute" in node):
		return
	var attr : Dictionary = node.get("attribute")
	attr[key] = clampf(attr[key] + delta, 0.0, 1.0)
	# 政策这一笔同时记下来，新闻层要按它反推阈值。
	if node.has_method("my_kind"):
		PolicyPush.note(node.my_kind(), key, delta)
