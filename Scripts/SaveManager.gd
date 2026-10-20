extends Node

# 存档（自动加载，名字就叫 SaveManager）。

# 只有一个档。
const SAVE_PATH : String = "user://save.sav"
const SAVE_VERSION : int = 1
const GAME_SCENE : String = "res://Scene/ui.tscn"

# 开局那笔信誉。
const START_INFLUENCE : float = 100.0

var save_data : Dictionary = {}

# 场景绑进来的对象（Ui 装配完调 Bind）
var _ui : Ui = null
var _world : World = null
var _attribute_ui : AttributeUi = null
var _factory : RawMaterialFactory = null
var _fake_list : FakeNewsList = null
var _messenger : GovernmentMessager = null

# “继续游戏”已经把盘读进 save_data 了，等场景装好再往世界里灌。
var _pending_load : bool = false

# 文件

func get_file_name() -> String:
	return SAVE_PATH

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# 开一局新的：先把跨场景活着的自动加载拨回起点，再落一个"第一天"的存档。
func new_game() -> void:
	NewsPaperManager.influence = START_INFLUENCE
	GovernmentFavor.reset()
	BadgeManager.reset()
	RawMaterialGenerater.material_list.clear()
	RawMaterialGenerater.real_news_count = 0
	Modifer.reset()
	EndingManager.reset()
	ArchiveManager.reset()
	PolicyPush.reset()
	_pending_load = false
	save_data = {
		"version" : SAVE_VERSION,
		"day" : 1,
		"influence" : START_INFLUENCE,
	}
	_write()

# 把此刻的世界收成一份存档，写进存档文件。写没写进去要告诉调用方，
# 存档键得据此给玩家一个说法。
func save_game() -> bool:
	if _world == null:
		return false
	save_data = _collect()
	return _write()

# 把存档读进 save_data。
func load_game() -> bool:
	return _read()

# “继续游戏”走这条：读盘，标记待应用，然后换到游戏场景。
func request_load() -> void:
	if not load_game():
		return
	_pending_load = true
	get_tree().change_scene_to_file(GAME_SCENE)

func has_pending_load() -> bool:
	return _pending_load

func _write() -> bool:
	var file : FileAccess = FileAccess.open(get_file_name(), FileAccess.WRITE)
	if file == null:
		push_warning("存档写不进去：%s（%s）"
			% [get_file_name(), error_string(FileAccess.get_open_error())])
		return false
		# 一行 JSON。
	file.store_line(JSON.stringify(save_data))
	file.close()
	return true

func _read() -> bool:
	if not FileAccess.file_exists(get_file_name()):
		return false
	var file : FileAccess = FileAccess.open(get_file_name(), FileAccess.READ)
	if file == null:
		push_warning("存档打不开：%s" % get_file_name())
		return false
	var parsed : Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("存档解析失败（不是字典）：%s" % get_file_name())
		return false
	save_data = parsed
	return true

# 接线：Ui 装配完把这几样交给存档。

func Bind(p_ui : Ui, p_world : World, p_attribute_ui : AttributeUi,
		p_factory : RawMaterialFactory, p_fake_list : FakeNewsList,
		p_messenger : GovernmentMessager) -> void:
	_ui = p_ui
	_world = p_world
	_attribute_ui = p_attribute_ui
	_factory = p_factory
	_fake_list = p_fake_list
	_messenger = p_messenger

# 装好的场景如果是"读档进来的"，把存档灌进去。
func apply_pending_load() -> bool:
	if not _pending_load:
		return false
	_pending_load = false
	_apply(save_data)
	return true

# 收集

func _collect() -> Dictionary:
	var data : Dictionary = {
		"version" : SAVE_VERSION,
		"day" : _attribute_ui.day if _attribute_ui != null else 1,
		# 结局：结算过没有、是哪一条（没结算就是 EndingData.Id.None）。
		"ended" : EndingManager.ended,
		"ending" : EndingManager.ending,

		"influence" : NewsPaperManager.get_influence(),
		"real_news_count" : RawMaterialGenerater.real_news_count,
		# 红点水位（哪几个入口、看到第几条）。
		"badges" : BadgeManager.snapshot(),
		"groups" : {},
		"government" : {},
		"pool" : _collect_cards(_factory.container if _factory != null else null),
		# 还压在详情队列里、没落进池子的大新闻，外加该补几条软新闻。
		"pending" : _factory.snapshot_pending() if _factory != null else {},
		"slots" : _collect_slots(),
		# 大新闻档案：造假只能从这里面挑。
		"fake_archive" : _fake_list.snapshot() if _fake_list != null else {},
		# 政府信箱：发信节拍、没读的那封、正盯着的要求、答应了没答应的白送。
		"messenger" : _messenger.snapshot() if _messenger != null else {},
		# 政府新闻的阈值推量（政策改属性后折出来的那一份）。
		"policy_push" : PolicyPush.snapshot(),
	}

	# 四家
	for node in _world.groups.get_children():
		var key : String = _group_key(node)
		if key == "":
			continue
		var group : Group = node
		data["groups"][key] = {
			"attribute" : group.attribute.duplicate(),
			"machine" : _machine_snapshot(group.get("state_machine")),
		}

	# 政府
	var government : Government = _world.government
	data["government"] = {
		"policy" : _machine_snapshot(government.policy_machine),
		"asset" : _asset_snapshot(government.asset),
		# 政府好感度。
		"favor" : GovernmentFavor.favor,
	}
	return data

func _asset_snapshot(asset : GovernmentAsset) -> Dictionary:
	return {
		"food" : asset.food.food_value,
		"money" : asset.money.value,
		"industry" : asset.industry.value,
		"stability" : asset.stability.value,
		"belligerence" : asset.belligerence.value,
		"army" : asset.army.value,
	}

# 池子里每张卡：只存 .tres 路径与真假，不存资源本身——。
func _collect_cards(container : Node) -> Array:
	var out : Array = []
	if container == null:
		return out
	for child in container.get_children():
		if child is RawMaterial:
			var card : RawMaterial = child
			out.append(_card_entry(card.res, card.is_fake))
	return out

func _collect_slots() -> Array:
	var out : Array = []
	if _ui == null:
		return out
	for child in _ui.pressure.slot_container.get_children():
		if child is RawMaterialSlot:
			var slot : RawMaterialSlot = child
			out.append(_card_entry(slot.res, slot.is_fake))
	return out

func _card_entry(res : NewsResource, fake : bool) -> Dictionary:
	return {
		"res" : res.resource_path if res != null else "",
		"fake" : fake,
	}

# 一个状态机：当前在哪个档（成员名）+ 每个档的阈值。
func _machine_snapshot(machine : Variant) -> Dictionary:
	if machine == null:
		return {}
	var out : Dictionary = {
		"state" : _current_state_name(machine),
		"lines" : {},
	}
	for member in _state_members(machine):
		out["lines"][member] = _float_props(machine.get(member))
	return out

# 机器里指向各状态对象的成员：名字都以 "State" 结尾（current_state 不算——。
func _state_members(machine : Object) -> Array[String]:
	var out : Array[String] = []
	for info in machine.get_property_list():
		if info.type == TYPE_OBJECT and info.name.ends_with("State"):
			out.append(info.name)
	return out

func _current_state_name(machine : Object) -> String:
	var current : Variant = machine.get("current_state")
	for member in _state_members(machine):
		if machine.get(member) == current:
			return member
	return ""

# 一个状态对象上**它自己声明**的 float 成员（就是那些阈值）。
func _float_props(state : Object) -> Dictionary:
	var out : Dictionary = {}
	for info in state.get_property_list():
		if info.type != TYPE_FLOAT:
			continue
		if (info.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
			continue
		out[info.name] = state.get(info.name)
	return out

# 应用

func _apply(data : Dictionary) -> void:
	if data.is_empty() or _world == null:
		return

	# 只覆盖存档里**确实带着**的东西。
	if data.has("influence"):
		NewsPaperManager.influence = float(data["influence"])

	# 红点水位：老存档没有这个键，就保持新局那份空的（new_game() 已经清过），。
	if data.has("badges"):
		BadgeManager.restore(data["badges"])
		
	# 四家
	var groups : Dictionary = data.get("groups", {})
	for node in _world.groups.get_children():
		var key : String = _group_key(node)
		if key == "" or not groups.has(key):
			continue
		var group : Group = node
		var group_data : Dictionary = groups[key]
		var attribute : Dictionary = group_data.get("attribute", {})
		for k in attribute:
			group.attribute[k] = float(attribute[k])
		_apply_machine(group.get("state_machine"), group_data.get("machine", {}))

	# 政府
	var gov_data : Dictionary = data.get("government", {})
	_apply_machine(_world.government.policy_machine, gov_data.get("policy", {}))
	_apply_asset(_world.government.asset, gov_data.get("asset", {}))
	# 好感度：老存档（那会儿还没有这个机制）没有这个键，就当中立重来，。
	GovernmentFavor.restore(float(gov_data.get("favor", GovernmentFavor.START)))

	# 系数按恢复后的群体状态重算一遍——政府明天过日子要读它。
	_world.sync_modifers()

	# 素材池 / 版面
	if data.has("real_news_count"):
		RawMaterialGenerater.real_news_count = int(data["real_news_count"])
	if data.has("pool") and _factory != null:
		_factory.restore_pool(data["pool"])
	if data.has("slots"):
		_restore_slots(data["slots"])
		# 待看的大新闻排在池子之后：它要把队首那张的详情重新摆到玩家面前，。
	if data.has("pending") and _factory != null:
		_factory.restore_pending(data["pending"])
		# 造假档案。
	if data.has("fake_archive") and _fake_list != null:
		_fake_list.restore(data["fake_archive"])
		# 政府信箱。
	if data.has("messenger") and _messenger != null:
		_messenger.restore(data["messenger"])
	# 老存档没有这一项：清空，政府新闻这一期就按"没有推量"处理。
	PolicyPush.restore(data.get("policy_push", {}))

	# 面板
	if _attribute_ui != null and data.has("day"):
		_attribute_ui.set_day(int(data["day"]))

	# 结局：天数与"结算过没有"都接回来。
	# 老存档没有 ended / ending：当作没结算，接着打。
	if data.has("day"):
		EndingManager.set_day(int(data["day"]))
	EndingManager.restore_ending(
		bool(data.get("ended", false)),
		int(data.get("ending", EndingData.Id.None)))
	# 存档那一刻政府已经崩了的话，不能等到下一次过天才结账。
	EndingManager.check_after_load()

func _apply_asset(asset : GovernmentAsset, data : Dictionary) -> void:
	if data.is_empty():
		return
	asset.food.food_value = float(data.get("food", asset.food.food_value))
	asset.food.update_food_state()
	asset.money.value = float(data.get("money", asset.money.value))
	asset.money.update_state()
	asset.industry.value = float(data.get("industry", asset.industry.value))
	asset.industry.update_state()
	asset.stability.value = float(data.get("stability", asset.stability.value))
	asset.stability.update_state()
	asset.belligerence.value = float(data.get("belligerence", asset.belligerence.value))
	asset.army.value = float(data.get("army", asset.army.value))
	asset.army.update_state()

func _apply_machine(machine : Variant, data : Dictionary) -> void:
	if machine == null or data.is_empty():
		return
	var lines : Dictionary = data.get("lines", {})
	for member in lines:
		var state : Variant = machine.get(member)
		if state == null:
			continue
		var props : Dictionary = lines[member]
		for p in props:
			state.set(p, float(props[p]))
			# 档位放最后：阈值先就位，再落到存档那一刻所在的那一档。
	var target : String = data.get("state", "")
	if target != "" and machine.get(target) != null:
		machine.set("current_state", machine.get(target))

func _restore_slots(entries : Array) -> void:
	if _ui == null:
		return
	var slots : Array = []
	for child in _ui.pressure.slot_container.get_children():
		if child is RawMaterialSlot:
			slots.append(child)
	for i in slots.size():
		var slot : RawMaterialSlot = slots[i]
		if i >= entries.size():
			slot.setup(null, false)
			continue
		var entry : Dictionary = entries[i]
		slot.setup(_load_res(entry.get("res", "")), bool(entry.get("fake", false)))

func _load_res(path : String) -> NewsResource:
	if path == "" or not ResourceLoader.exists(path):
		return null
	return load(path) as NewsResource

# 认群体：按类型认，不按节点名——改名字不连累这里（同 AttributeUi.SetUp）。

func _group_key(node : Node) -> String:
	if node is Farmers:
		return "farmer"
	if node is Workers:
		return "worker"
	if node is Merchants:
		return "merchant"
	if node is Soldier:
		return "soldier"
	return ""
