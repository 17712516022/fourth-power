extends Node

# 结局 —— 自动加载，名叫 EndingManager。
# 这里是天数的真值；每过完一天判一次结局。
# 判定只看五样：政府状态、稳定度、影响力、好感度、四家状态（见 judge）。

# 一局多少期。
# 验收用：现在是 3 天。看完改回 30。
const TOTAL_DAYS : int = 30

# 现在在出第几期。
var day : int = 1

# 结算过没有：一天只结一次。
var ended : bool = false

# 结算出来的结局（EndingData.Id）。
var ending : int = EndingData.Id.None

# 世界（Ui 装配时塞进来）。
var _world : World = null


func _ready() -> void:
	EventBus.game_start.connect(_on_game_start)
	EventBus.action_end.connect(_on_action_end)


# Ui 装配完把世界交过来：判定要看政府和四家。
func SetUp(world : World) -> void:
	_world = world


# 存档回来：把天数摆到那一天。
func set_day(p_day : int) -> void:
	day = p_day


# 开新一局。
func reset() -> void:
	day = 1
	ended = false
	ending = EndingData.Id.None


# 读档：把"已经结算过"这件事也接回来。
func restore_ending(p_ended : bool, p_ending : int) -> void:
	ended = p_ended
	ending = p_ending


# 读档进来如果是"政府已经崩了"，不能等到下一次过天才结账。
func check_after_load() -> void:
	if ended or _world == null:
		return
	if _collapsed():
		_finish()


func _on_game_start() -> void:
	reset()


# 一天走完了：世界已经算过，这时候才可以判。
# 政府崩溃也走这里——它发生在今天的 tick 里，到这一声时已经落地了。
func _on_action_end() -> void:
	if ended or _world == null:
		return
	if _collapsed() or day >= TOTAL_DAYS:
		_finish()
		return
	day += 1


func _finish() -> void:
	if ended:
		return
	ended = true
	ending = judge()
	_report()
	EventBus.ending_reached.emit(ending)


# 判定顺序不能换：先看世界，再看读者，最后看政府怎么处置你。
func judge() -> int:
	if _world == null:
		return EndingData.Id.Coexist

	var stability : float = _stability()
	var influence : float = NewsPaperManager.get_influence()

	# ① 世界破了，政府也散了：城已经无主。
	if stability < EndingData.STABILITY_LINE and _collapsed():
		return EndingData.Id.NoMaster

	# ② 世界破了，政府还在：农民上了街、报纸又已经没人读，就是"乡野新序"；
	#    这一档不成立的话，接着按读者和政府去判。
	if stability < EndingData.STABILITY_LINE:
		if _farmer_up_rising() and influence < EndingData.INFLUENCE_MID:
			return EndingData.Id.NewOrder

	# ③ 没人读了：世界再好，报纸已经出局。
	if influence < EndingData.INFLUENCE_LOW:
		return EndingData.Id.Unread

	var favor : float = GovernmentFavor.favor

	# ④ 政府恨你，可世界太平、报纸又有分量——它动不了你。
	if (favor < EndingData.FAVOR_LOW
			and stability > EndingData.WORLD_CALM_LINE
			and influence > EndingData.INFLUENCE_HIGH):
		return EndingData.Id.FourthEstate

	# ⑤ 政府恨你，你又不够硬——查封。
	if favor < EndingData.FAVOR_LOW:
		return EndingData.Id.Ban

	# ⑥ 它喜欢你，也拿得住你——收编最省事。
	if favor > EndingData.FAVOR_HIGH and influence > EndingData.INFLUENCE_TOP:
		return EndingData.Id.Coopt

	# ⑦ 谁也不惹谁：各自留一寸。
	return EndingData.Id.Coexist


# 领地段：只看稳定度（"乱"那一档已经被 ① 吃掉了）。
func world_state() -> int:
	if _stability() > EndingData.WORLD_CALM_LINE:
		return EndingData.WorldState.Calm
	return EndingData.WorldState.Strain


# 读世界的几个口子

func _stability() -> float:
	if _world == null:
		return 0.0
	return _world.government.asset.stability.value


func _collapsed() -> bool:
	if _world == null:
		return false
	return _world.government.policy_machine.current_state is GovernmentStateCollapse


# 农民是不是在起义里（"乡野新序"的判据：告示是四乡发的）。
func _farmer_up_rising() -> bool:
	if _world == null:
		return false
	for node in _world.groups.get_children():
		var group : Group = node as Group
		if group != null and group.my_kind() == GroupData.READERS.FARMER:
			return _state_of(group) is FarmerStateUpRising
	return false


# 四家里有几家到了极端（只看状态，见 EndingData.is_extreme）。
func _extreme_count() -> int:
	var count : int = 0
	if _world == null:
		return count
	for node in _world.groups.get_children():
		var group : Group = node as Group
		if group != null and EndingData.is_extreme(_state_of(group)):
			count += 1
	return count


# 一家现在站在哪个状态。
func _state_of(group : Group) -> Variant:
	var machine : Variant = group.get("state_machine")
	if machine == null:
		return null
	return machine.current_state


# 终刊号底部那块结算（面板直接拿去用）。
func stats_text() -> String:
	var lines : Array[String] = []
	lines.append(Texts.ENDING_ISSUES % mini(day, TOTAL_DAYS))
	lines.append(Texts.ENDING_LEDGER % [
		int(NewsPaperManager.get_influence()), int(GovernmentFavor.favor)])
	lines.append(Texts.ENDING_STABILITY % _stability())
	lines.append(_groups_line())
	return "\n".join(lines)


# 面板还没接上时的兜底：把结算结果打到输出面板。
func _report() -> void:
	print("———— 终 刊 ————")
	print(Texts.ENDING_MASTHEAD % mini(day, TOTAL_DAYS))
	print("结局：%s" % EndingData.headline_of(ending))
	print(stats_text())
	print("——")
	print(EndingData.body_of(ending, TOTAL_DAYS))
	if EndingData.uses_world_end(ending):
		print("——")
		print(EndingData.world_body_of(world_state()))


func _groups_line() -> String:
	var parts : Array[String] = []
	if _world == null:
		return ""
	for node in _world.groups.get_children():
		var group : Group = node as Group
		if group == null:
			continue
		var text : String = String(StateText.of(_state_of(group)).get("text", ""))
		parts.append("%s %s" % [_group_name(group.my_kind()), text])
	return "　".join(parts)


func _group_name(kind : GroupData.READERS) -> String:
	match kind:
		GroupData.READERS.WORKER:
			return Texts.GROUP_WORKER
		GroupData.READERS.MERCHANT:
			return Texts.GROUP_MERCHANT
		GroupData.READERS.SOLDIER:
			return Texts.GROUP_SOLDIER
		_:
			return Texts.GROUP_FARMER
