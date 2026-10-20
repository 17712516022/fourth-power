class_name Explain extends RefCounted

# 解释层：**只读世界，不改任何数值**。

const EPS : float = 0.0005

# 每个状态：谁、哪几条出口、每条出口吃哪个属性、拿哪条线比、线叫什么。
#   attr : 参与判定的属性键（attribute["..."]），政府用 belligerence / stability
#   op   : 判据里的比较符
#   var  : 状态里那条门槛的变量名
#   to   : 成立之后去哪儿（正常 = 回程，其余 = 恶化）
#   init : 这条线在 StateChangeData 里的初值常量名（用来看"被报纸挪了多少"）
#   and  : 同号表示这几条要同时成立（AND 组合）
static var GATES : Dictionary = {
	# ---------------- 农夫 ----------------
	"FarmerStateNormal" : {"who" : "farmer", "gates" : [
		{"attr" : "angry", "op" : ">", "var" : "resist_yvzhi",
			"to" : Texts.STATE_FARMER_RESIST, "init" : "farmerNormalResistTransportNeed"},
		{"attr" : "fear", "op" : ">", "var" : "flee_yvzhi",
			"to" : Texts.STATE_FARMER_FLEE, "init" : "farmerNormalFleeTransportNeed"},
		{"attr" : "happy", "op" : "<", "var" : "slow_down_yvzhi",
			"to" : Texts.STATE_SLOWDOWN, "init" : "farmerNormalSlowdownTransportNeed"},
	]},
	"FarmerStateSlowdown" : {"who" : "farmer", "gates" : [
		{"attr" : "fear", "op" : ">", "var" : "enter_flee_lvzhi",
			"to" : Texts.STATE_FARMER_FLEE, "init" : "farmerSlowdownFleeTransportNeed"},
		{"attr" : "happy", "op" : ">", "var" : "enter_nomal_lvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "farmerSlowdownNormalTransportNeed"},
	]},
	"FarmStateResist" : {"who" : "farmer", "gates" : [
		{"attr" : "angry", "op" : ">", "var" : "enter_uprising_lvzhi",
			"to" : Texts.STATE_UPRISING, "init" : "farmerResistUpRisingTransportNeed"},
		{"attr" : "angry", "op" : "<", "var" : "enter_nomal_need",
			"to" : Texts.STATE_NORMAL, "init" : "farmerResistNormalTransportNeed"},
	]},
	"FarmerStateFlee" : {"who" : "farmer", "gates" : [
		{"attr" : "angry", "op" : ">", "var" : "uprising_yvzhi",
			"to" : Texts.STATE_UPRISING, "init" : "farmerFleeUpRisingTransportNeed"},
		{"attr" : "fear", "op" : "<", "var" : "flee_out_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "farmerFleeNormalTransportNeed"},
	]},
	"FarmerStateUpRising" : {"who" : "farmer", "gates" : [
		{"attr" : "happy", "op" : ">", "var" : "exit_happy_lvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "farmerUpRisingNormalHappyNeed", "and" : 1},
		{"attr" : "fear", "op" : "<", "var" : "exit_fear_lvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "farmerUpRisingNormalFearNeed", "and" : 1},
		{"attr" : "angry", "op" : "<", "var" : "exit_angry_lvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "farmerUpRisingNormalAngryNeed", "and" : 1},
	]},

	# ---------------- 工匠 ----------------
	"WorkerStateNormal" : {"who" : "worker", "gates" : [
		{"attr" : "angry", "op" : ">", "var" : "strike_yvzhi",
			"to" : Texts.STATE_WORKER_STRIKE, "init" : "workerNormalStrikeTransportNeed"},
		{"attr" : "fear", "op" : ">", "var" : "depression_yvzhi",
			"to" : Texts.STATE_WORKER_DEPRESSION, "init" : "workerNormalDepressionTransportNeed"},
		{"attr" : "happy", "op" : "<", "var" : "slow_down_yvzhi",
			"to" : Texts.STATE_SLOWDOWN, "init" : "workerNormalSlowdownTransportNeed"},
	]},
	"WorkerStateSlowdown" : {"who" : "worker", "gates" : [
		{"attr" : "fear", "op" : ">", "var" : "depression_yvzhi",
			"to" : Texts.STATE_WORKER_DEPRESSION, "init" : "workerSlowdownDepressionTransportNeed"},
		{"attr" : "happy", "op" : ">", "var" : "normal_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "workerSlowdownNormalTransportNeed"},
	]},
	"WorkerStateDepression" : {"who" : "worker", "gates" : [
		{"attr" : "angry", "op" : ">", "var" : "up_rising_yvzhi",
			"to" : Texts.STATE_UPRISING, "init" : "workerDepressionUpRisingTransportNeed"},
		{"attr" : "fear", "op" : "<", "var" : "normal_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "workerDepressionNormalTransportNeed"},
	]},
	"WorkerStateStrike" : {"who" : "worker", "gates" : [
		{"attr" : "angry", "op" : ">", "var" : "march_yvzhi",
			"to" : Texts.STATE_WORKER_MARCH, "init" : "workerStrikeMarchTransportNeed"},
		{"attr" : "angry", "op" : "<", "var" : "normal_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "workerStrikeNormalTransportNeed"},
	]},
	"WorkerStateMarch" : {"who" : "worker", "gates" : [
		{"attr" : "angry", "op" : ">", "var" : "up_rising_yvzhi",
			"to" : Texts.STATE_UPRISING, "init" : "workerMarchUpRisingTransportNeed"},
		{"attr" : "happy", "op" : ">", "var" : "normal_happy_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "workerMarchNormalHappyNeed", "and" : 1},
		{"attr" : "fear", "op" : "<", "var" : "normal_fear_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "workerMarchNormalFearNeed", "and" : 1},
		{"attr" : "angry", "op" : "<", "var" : "normal_angry_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "workerMarchNormalAngryNeed", "and" : 1},
	]},
	"WorkerStateUpRising" : {"who" : "worker", "gates" : [
		{"attr" : "happy", "op" : ">", "var" : "normal_happy_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "workerUpRisingNormalHappyNeed", "and" : 1},
		{"attr" : "fear", "op" : "<", "var" : "normal_fear_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "workerUpRisingNormalFearNeed", "and" : 1},
		{"attr" : "angry", "op" : "<", "var" : "normal_angry_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "workerUpRisingNormalAngryNeed", "and" : 1},
	]},

	# ---------------- 商人 ----------------
	"MerchantStateNormal" : {"who" : "merchant", "gates" : [
		{"attr" : "angry", "op" : ">", "var" : "abroad_yvzhi",
			"to" : Texts.STATE_MERCHANT_ABROAD, "init" : "merchantNormalAbroadTransportNeed"},
		{"attr" : "fear", "op" : "<", "var" : "invest_yvzhi",
			"to" : Texts.STATE_MERCHANT_INVEST, "init" : "merchantNormalInvestTransportNeed"},
		{"attr" : "happy", "op" : ">", "var" : "prosperity_yvzhi",
			"to" : Texts.STATE_MERCHANT_PROSPERITY, "init" : "merchantNormalProsperityTransportNeed"},
	]},
	"MerchantStateProsperity" : {"who" : "merchant", "gates" : [
		{"attr" : "happy", "op" : ">", "var" : "speculate_yvzhi",
			"to" : Texts.STATE_MERCHANT_SPECULATE, "init" : "merchantProsperitySpeculateTransportNeed"},
		{"attr" : "happy", "op" : "<", "var" : "normal_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "merchantProsperityNormalTransportNeed"},
	]},
	"MerchantStateInvest" : {"who" : "merchant", "gates" : [
		{"attr" : "fear", "op" : "<", "var" : "speculate_yvzhi",
			"to" : Texts.STATE_MERCHANT_SPECULATE, "init" : "merchantInvestSpeculateTransportNeed"},
		{"attr" : "fear", "op" : ">", "var" : "normal_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "merchantInvestNormalTransportNeed"},
	]},
	"MerchantStateSpeculate" : {"who" : "merchant", "gates" : [
		{"attr" : "fear", "op" : "<", "var" : "hollow_yvzhi",
			"to" : Texts.STATE_MERCHANT_HOLLOW, "init" : "merchantSpeculateHollowTransportNeed"},
	]},
	"MerchantStateHollow" : {"who" : "merchant", "gates" : [
		{"attr" : "happy", "op" : ">", "var" : "normal_happy_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "merchantHollowNormalHappyNeed", "and" : 1},
		{"attr" : "fear", "op" : ">", "var" : "normal_fear_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "merchantHollowNormalFearNeed", "and" : 1},
	]},
	"MerchantStateAbroad" : {"who" : "merchant", "gates" : [
		{"attr" : "angry", "op" : "<", "var" : "normal_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "merchantAbroadNormalTransportNeed"},
	]},

	# ---------------- 士兵 ----------------
	"SoldierStateNormal" : {"who" : "soldier", "gates" : [
		{"attr" : "angry", "op" : "<", "var" : "corrupt_yvzhi",
			"to" : Texts.STATE_SOLDIER_CORRUPT, "init" : "soldierNormalCorruptTransportNeed"},
		{"attr" : "fear", "op" : "<", "var" : "rampage_yvzhi",
			"to" : Texts.STATE_SOLDIER_RAMPAGE, "init" : "soldierNormalRampageTransportNeed"},
		{"attr" : "happy", "op" : "<", "var" : "desert_yvzhi",
			"to" : Texts.STATE_SOLDIER_DESERT, "init" : "soldierNormalDesertTransportNeed"},
	]},
	"SoldierStateDesert" : {"who" : "soldier", "gates" : [
		{"attr" : "happy", "op" : "<", "var" : "mutiny_yvzhi",
			"to" : Texts.STATE_SOLDIER_MUTINY, "init" : "soldierDesertMutinyTransportNeed"},
		{"attr" : "happy", "op" : ">", "var" : "normal_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "soldierDesertNormalTransportNeed"},
	]},
	"SoldierStateRampage" : {"who" : "soldier", "gates" : [
		{"attr" : "fear", "op" : "<", "var" : "mutiny_yvzhi",
			"to" : Texts.STATE_SOLDIER_MUTINY, "init" : "soldierRampageMutinyTransportNeed"},
		{"attr" : "fear", "op" : ">", "var" : "normal_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "soldierRampageNormalTransportNeed"},
	]},
	"SoldierStateCorrupt" : {"who" : "soldier", "gates" : [
		{"attr" : "fear", "op" : "<", "var" : "rampage_yvzhi",
			"to" : Texts.STATE_SOLDIER_RAMPAGE, "init" : "soldierCorruptRampageTransportNeed"},
		{"attr" : "angry", "op" : ">", "var" : "normal_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "soldierCorruptNormalTransportNeed"},
	]},
	"SoldierStateMutiny" : {"who" : "soldier", "gates" : [
		{"attr" : "happy", "op" : ">", "var" : "normal_happy_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "soldierMutinyNormalHappyNeed", "and" : 1},
		{"attr" : "fear", "op" : ">", "var" : "normal_fear_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "soldierMutinyNormalFearNeed", "and" : 1},
		{"attr" : "angry", "op" : ">", "var" : "normal_angry_yvzhi",
			"to" : Texts.STATE_NORMAL, "init" : "soldierMutinyNormalAngryNeed", "and" : 1},
	]},

	# ---------------- 领地 ----------------
	"GovernmentStateNormal" : {"who" : "government", "gates" : [
		{"attr" : "belligerence", "op" : ">", "var" : "hardline_belligerence",
			"to" : Texts.STATE_GOV_HARDLINE, "init" : "governmentNormalHardlineBelligerenceNeed"},
		{"attr" : "belligerence", "op" : "<", "var" : "conservative_belligerence",
			"to" : Texts.STATE_GOV_CONSERVATIVE, "init" : "governmentNormalConservativeBelligerenceNeed"},
	]},
	"GovernmentStateHardline" : {"who" : "government", "gates" : [
		{"attr" : "belligerence", "op" : ">", "var" : "terror_belligerence",
			"to" : Texts.STATE_GOV_TERROR, "init" : "governmentHardlineTerrorBelligerenceNeed"},
		{"attr" : "belligerence", "op" : "<", "var" : "normal_belligerence",
			"to" : Texts.STATE_GOV_NORMAL, "init" : "governmentHardlineNormalBelligerenceNeed"},
	]},
	"GovernmentStateConservative" : {"who" : "government", "gates" : [
		{"attr" : "belligerence", "op" : "<", "var" : "incompetent_belligerence",
			"to" : Texts.STATE_GOV_INCOMPETENT, "init" : "governmentConservativeIncompetentBelligerenceNeed"},
		{"attr" : "belligerence", "op" : ">", "var" : "normal_belligerence",
			"to" : Texts.STATE_GOV_NORMAL, "init" : "governmentConservativeNormalBelligerenceNeed"},
	]},
	"GovernmentStateTerror" : {"who" : "government", "gates" : [
		{"attr" : "stability", "op" : "<", "var" : "collapse_stability",
			"to" : Texts.STATE_GOV_COLLAPSE, "init" : "governmentCollapseStabilityNeed"},
		{"attr" : "belligerence", "op" : "<", "var" : "hardline_belligerence",
			"to" : Texts.STATE_GOV_HARDLINE, "init" : "governmentTerrorHardlineBelligerenceNeed"},
	]},
	"GovernmentStateIncompetent" : {"who" : "government", "gates" : [
		{"attr" : "stability", "op" : "<", "var" : "collapse_stability",
			"to" : Texts.STATE_GOV_COLLAPSE, "init" : "governmentCollapseStabilityNeed"},
		{"attr" : "belligerence", "op" : ">", "var" : "conservative_belligerence",
			"to" : Texts.STATE_GOV_CONSERVATIVE, "init" : "governmentIncompetentConservativeBelligerenceNeed"},
	]},
}


# ---------------------------------------------------------------- 小工具

# 状态对象 → 表里的键（脚本文件名）。
static func key_of(state : Variant) -> String:
	if state == null:
		return ""
	var script : Variant = state.get_script()
	if script == null:
		return ""
	return String(script.resource_path).get_file().get_basename()


static func group_name(node : Variant) -> String:
	if node == null:
		return ""
	match node.my_kind():
		GroupData.READERS.WORKER:
			return Texts.GROUP_WORKER
		GroupData.READERS.MERCHANT:
			return Texts.GROUP_MERCHANT
		GroupData.READERS.SOLDIER:
			return Texts.GROUP_SOLDIER
		_:
			return Texts.GROUP_FARMER


# 判定用的那个"值"：群体读 attribute，领地读 belligerence / stability。
static func value_of(node : Variant, key : String) -> float:
	if key == "belligerence" or key == "stability":
		var asset : GovernmentAsset = node.asset
		if asset == null:
			return 0.0
		if key == "stability":
			return asset.stability.value
		return asset.belligerence.value
	var attr : Variant = node.get("attribute")
	if attr == null:
		return 0.0
	return float(attr.get(key, 0.0))


static func dim_name(key : String) -> String:
	match key:
		"angry":
			return Texts.DIM_ANGRY
		"fear":
			return Texts.DIM_FEAR
		"happy":
			return Texts.DIM_HAPPY
		"power":
			return Texts.DIM_POWER
		"belligerence":
			return Texts.DIM_BELLIGERENCE
		"stability":
			return Texts.DIM_STABILITY
		_:
			return key


# 这条出口"成立"了吗（和状态机一样的比较）。
static func _holds(gate : Dictionary, value : float, line : float) -> bool:
	if String(gate["op"]) == ">":
		return value > line
	return value < line


# 离成立还差多少（带符号：负数表示已经越线）。
static func _margin(gate : Dictionary, value : float, line : float) -> float:
	if String(gate["op"]) == ">":
		return line - value
	return value - line


# 离成立还差多少（成立时是 0）。
static func _gap(gate : Dictionary, value : float, line : float) -> float:
	return maxf(_margin(gate, value, line), 0.0)


# ---------------------------------------------------------------- 成因

# 一家为什么在这个状态、回程还差多少、报纸能做什么。
static func group_report(node : Variant) -> String:
	if node == null:
		return ""
	var state : Variant = node.state_machine.current_state
	var info : Dictionary = GATES.get(key_of(state), {})
	var head : String = _head(group_name(node), StateText.of(state)["text"])
	if info.is_empty():
		return head

	var lines : Array[String] = [head]
	# AND 组合：第一条写"同时"，后面几条用"＋"，不要每行都重复"同时"。
	var and_seen : bool = false
	for gate in info["gates"]:
		var mark : String = ""
		if gate.has("and"):
			mark = "＋ " if and_seen else Texts.EXPLAIN_AND + " "
			and_seen = true
		lines.append(_gate_line(node, state, gate, mark))

	# 还在正常档就没有建议可说：出口行已经把"差多少"写清楚了。
	var advice : String = _advice(info["gates"])
	if advice != "":
		lines.append(advice)
	lines.append(Texts.EXPLAIN_PAPER_CANNOT)
	return _lines(lines)


# 标题：家名墨色加粗，档位名按"是不是正常"上色（正常=绿，其余=红）。
static func _head(who : String, state_text : String) -> String:
	var tone : String = Texts.COLOR_GOOD if state_text == Texts.STATE_NORMAL else Texts.COLOR_BAD
	return "%s [color=%s]· %s[/color]" % [
		_paint(who, Texts.COLOR_INK, true), tone, state_text]


# 一条出口：门槛变量、现在的值、还差多少。数字墨色，方向词才上色。
# compact：上面已经报过这一维的当前值（领地的好战度），这里就只留"哪条线"。
static func _gate_line(node : Variant, state : Variant, gate : Dictionary,
		mark : String = "", compact : bool = false) -> String:
	var value : float = value_of(node, gate["attr"])
	var line : float = float(state.get(gate["var"]))
	var holds : bool = _holds(gate, value, line)
	var op_text : String = "＞" if String(gate["op"]) == ">" else "＜"

	# 维名不加粗：一行里只留一个加粗（值），标题才抢眼。两位小数：面板窄，够用。
	var head : String = mark
	if not compact:
		head += _paint(dim_name(gate["attr"]), Texts.COLOR_INK) + " "
		head += _paint("%.2f" % value, Texts.COLOR_BAD if holds else Texts.COLOR_INK, true) + " "
	head += _paint(op_text, Texts.COLOR_DIM) + " "
	head += _paint("%.2f" % line, Texts.COLOR_LINE)

	if not holds:
		return head + "  " + Texts.EXPLAIN_GAP % _gap(gate, value, line)
	# 成立的是回程（绿色）还是下滑（红色）——同一个「成立」，含义正相反。
	if String(gate["to"]) == Texts.STATE_NORMAL:
		return head + "  " + Texts.EXPLAIN_HOLDS_GOOD % String(gate["to"])
	return head + "  " + Texts.EXPLAIN_HOLDS_BAD % String(gate["to"])


# 上色：拼进 RichTextLabel 的 BBCode，bold = 顺带加粗。
static func _paint(text : String, color : String, bold : bool = false) -> String:
	if bold:
		return "[b][color=%s]%s[/color][/b]" % [color, text]
	return "[color=%s]%s[/color]" % [color, text]


# 「怎么解决」：只说一句报纸能做的。回程线上面已经列过，别再重复一遍数字。
static func _advice(gates : Array) -> String:
	for gate in gates:
		if String(gate["to"]) != Texts.STATE_NORMAL:
			continue
		# 条件成立得越早，线就该越往"值所在的那一侧"让。
		var less : bool = String(gate["op"]) == "<"
		return Texts.EXPLAIN_TO_NORMAL % [dim_name(gate["attr"]),
			Texts.EXPLAIN_PUSH_UP if less else Texts.EXPLAIN_PUSH_DOWN]
	return ""


# 领地的成因：好战度 vs 两条线，外加崩溃线。
static func government_report(government : Variant) -> String:
	if government == null:
		return ""
	var asset : GovernmentAsset = government.asset
	var state : Variant = government.policy_machine.current_state
	var info : Dictionary = GATES.get(key_of(state), {})
	var head : String = _head(Texts.GROUP_GOVERNMENT, StateText.of(state)["text"])
	# 好战度两头都危险：太高走强硬/恐怖，太低走软弱/无能。
	var belligerence : float = asset.belligerence.value
	var tone : String = Texts.COLOR_INK
	if belligerence >= 0.55:
		tone = Texts.COLOR_BAD
	elif belligerence <= 0.45:
		tone = Texts.COLOR_COLD

	var lines : Array[String] = [
		head,
		Texts.EXPLAIN_BELLIGERENCE % [_paint("%.3f" % belligerence, tone, true),
			asset.army.value, asset.money.value,
			clampf(0.5 + (asset.army.value - asset.money.value) * 2.0, 0.0, 1.0)],
	]
	# 缩两格：这两行是从属于上面那行"好战度"的，别跟它平起平坐。
	for gate in info["gates"]:
		lines.append(_gate_line(government, state, gate, "  ", true))
	lines.append(Texts.EXPLAIN_GOV_CANNOT)
	return _lines(lines)


# 稳定度是怎么算出来的：12 − Σ(系数 × power)。
static func stability_report(government : Variant, groups : Variant) -> String:
	if government == null or groups == null:
		return Texts.DIM_STABILITY
	var asset : GovernmentAsset = government.asset
	var parts : Array[String] = []
	var costs : Array[String] = []
	var penalty : float = 0.0
	for node in groups.get_children():
		if not ("state_machine" in node):
			continue
		var state : Variant = node.state_machine.current_state
		var coef : float = float(state.stability_coef())
		var power : float = value_of(node, "power")
		var cost : float = clampf(coef * power, -3.0, 3.0)
		penalty += cost
		# 扣分红色、回血绿色（商人的繁荣系数是负的，会托住稳定度）。
		costs.append("%s %s" % [
			_paint(group_name(node), Texts.COLOR_INK),
			_paint("%.1f×%.2f" % [coef, power],
				Texts.COLOR_BAD if cost > 0.0 else Texts.COLOR_GOOD)])
		# 两家一行：一行四家太宽，会折行。
		if costs.size() == 2:
			parts.append(_inline(costs))
			costs.clear()
	if not costs.is_empty():
		parts.append(_inline(costs))

	var value : float = asset.stability.value
	var gap : float = value - StabilityManager.TIGHT
	var value_tone : String = Texts.COLOR_INK
	if value < StabilityManager.TIGHT:
		value_tone = Texts.COLOR_BAD
	elif value > StabilityManager.GOOD:
		value_tone = Texts.COLOR_GOOD
	var rows : Array[String] = [
		"%s %s / %.0f" % [Texts.DIM_STABILITY,
			_paint("%.2f" % value, value_tone, true), float(StabilityManager.MAX_VALUE)],
		Texts.EXPLAIN_STABILITY_FORMULA % [float(StabilityManager.MAX_VALUE), penalty],
	]
	rows.append_array(parts)
	rows.append(Texts.EXPLAIN_STABILITY_LINE % [
		_paint("%.1f" % StabilityManager.TIGHT, Texts.COLOR_LINE),
		_paint("%.2f" % gap, Texts.COLOR_BAD if gap < 1.0 else Texts.COLOR_GOOD),
		StateChangeData.governmentCollapseStabilityNeed])
	return _lines(rows)


# 几条并成一段多行文字。
static func _lines(rows : Array) -> String:
	var out : String = ""
	for i in rows.size():
		if i > 0:
			out += "\n"
		out += String(rows[i])
	return out


# 同一行里的几段，拿两个空格隔开。
static func _inline(parts : Array) -> String:
	var out : String = ""
	for i in parts.size():
		if i > 0:
			out += "  "
		out += String(parts[i])
	return out


# ---------------------------------------------------------------- 行动后果


# 这一推让那条出口更好成立还是更难成立。
# 注意「更难」不等于坏事：更难「抗租」是好事，更难「正常」才是坏事。
static func card_effect(gate : Dictionary, delta : float) -> Dictionary:
	var easier : bool
	if String(gate["op"]) == ">":
		easier = delta < 0.0
	else:
		easier = delta > 0.0
	var to_normal : bool = String(gate["to"]) == Texts.STATE_NORMAL
	var good : bool = easier == to_normal
	var tone : String = Texts.COLOR_GOOD if good else Texts.COLOR_BAD
	var word : String = Texts.EXPLAIN_EASIER if easier else Texts.EXPLAIN_HARDER
	return {"word" : _paint(word, tone, true), "tone" : tone}


# 悬停面板：这一条登出去会发生什么（只列当前档真正碰到的那几条线）。
# 只报"更难/更易"，不报数值。
static func card_report(res : NewsResource, groups : Variant) -> String:
	if res == null:
		return ""
	if res.is_filler:
		return Texts.MSG_FILLER
	var weight : float = NewsPaperManager.get_influence() / 100.0
	var pushes : Dictionary = {}
	if res.big_effect != null:
		# 大事件直接改属性。属性 +v 对某条出口的作用，等价于把门槛推 -v。
		for who in ["farmer", "worker", "merchant", "soldier"]:
			for dim in ["happy", "fear", "angry"]:
				var key : String = "%s_%s" % [who, dim]
				var v : float = float(res.big_effect.get(key))
				if absf(v) > EPS:
					pushes[key] = -v
	else:
		var influence : InfluenceGroup = PolicyPush.influence_preview(res)
		if influence != null:
			for who in ["farmer", "worker", "merchant", "soldier"]:
				for dim in ["happy", "fear", "angry"]:
					var key : String = "%s_%s" % [who, dim]
					var v : float = float(influence.get(key))
					if absf(v) > EPS:
						pushes[key] = v * weight
	# 标题由面板去画（EXPLAIN_CARD_TITLE），这里只管账单。
	var out : Array[String] = []
	var hidden : int = 0
	if groups != null and not pushes.is_empty():
		for node in groups.get_children():
			if not ("state_machine" in node):
				continue
			var state : Variant = node.state_machine.current_state
			var info : Dictionary = GATES.get(key_of(state), {})
			if info.is_empty():
				continue
			var who : String = info["who"]
			# 一家最多报三条：悬停面板比屏幕还高就没法看了，次要的那几条只计数。
			var rows : Array = []
			for gate in info["gates"]:
				var dim : String = gate["attr"]
				var delta : float = float(pushes.get("%s_%s" % [who, dim], 0.0))
				if absf(delta) > EPS:
					rows.append({"gate" : gate, "dim" : dim, "delta" : delta})
			rows.sort_custom(func(a, b): return absf(a["delta"]) > absf(b["delta"]))
			hidden += maxi(rows.size() - 3, 0)
			for row in rows.slice(0, 3):
				var gate : Dictionary = row["gate"]
				var effect : Dictionary = card_effect(gate, float(row["delta"]))
				out.append(Texts.EXPLAIN_CARD_LINE_SHORT % [
					_paint(group_name(node), Texts.COLOR_INK, true),
					_paint(dim_name(row["dim"]), Texts.COLOR_DIM),
					effect["word"],
					_paint(String(gate["to"]), effect["tone"])])
	if hidden > 0:
		out.append(Texts.EXPLAIN_MORE_LINES % hidden)
	if out.is_empty():
		return Texts.MSG_QUIET
	if res.big_effect != null:
		out.push_front(Texts.EXPLAIN_BIG_EVENT)
		out.append(Texts.EXPLAIN_BIG_FOOTER)
	else:
		out.append(Texts.EXPLAIN_FIRST_SLOT)
	return _lines(out)


# 面板上第一行当标题，其余当正文（右侧四家 / 领地 / 稳定度都这么用）。
static func split_title(text : String) -> Dictionary:
	var at : int = text.find("\n")
	if at < 0:
		return {"title" : text, "body" : ""}
	return {"title" : text.substr(0, at), "body" : text.substr(at + 1)}
