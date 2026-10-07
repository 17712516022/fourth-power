class_name Government extends Node

# ============================================================
# 政府
#
# 拆开之后这里只做两件事：
#   **看世界**（把世界读成几个数）
#   **下命令**（作用于所有人）
# 家底怎么变，全在 GovernmentAsset 里。
#
# step() 的四行就是它的全部：
#   看 -> 过日子 -> 定策 -> 做
# ============================================================

# 家底。六个数和它们每天的更新规则都在这个对象里。
var asset : GovernmentAsset = GovernmentAsset.new()

var policy_machine : GovernmentStateMachine = GovernmentStateMachine.new()


# --- 今天从世界上读到的东西 ---
#
# 它们不是资产，是**政府眼里的世界**。每一条都在 _perceive() 里被写，
# 然后一次性交给 asset.update()。
#
# 这四行同时就是"政府过日子必须知道的全部事情"。
var _threat : float = 0.0            # 外面多乱
var _farming : int = 0               # 农民闹到第几级（0 正常 / 1 抗租 / 2 流亡）
var _worker_happy : float = 0.0      # 工人心气
var _soldier_power : float = 0.0     # 士兵的组织度


# --- 行动的价码 ---
#
# 这些不是家底，是政府**动手时要付多少**。
# 家底在 GovernmentAsset 里，这里只放"动作的价钱"——
# 两者的区别是：家底会被花掉，价码不会，它只是个数。
const CONCILIATE_ANGRY : float = -0.015   # 安抚：所有人的怒降多少
const CONCILIATE_COST  : float = 0.020    # 安抚：每天花掉多少国库
const SUPPRESS_FEAR    : float = 0.020    # 镇压：所有人的怕涨多少
const SUPPRESS_ARMY    : float = 0.020    # 镇压：每天磨掉多少兵


# 每个群体的状态机都把"闹到第几级"表达成同一个 enum 的序号：
# 0 = 正常，1 = 暗流，2 = 明面，3 = 终局。
# 所以不用管它是农民还是商人，序号本身就是威胁度。
const THREAT_BY_LEVEL : Array[float] = [0.0, 0.40, 0.75, 1.00]


# 每天被 World 调用一次，在四个群体都过完自己的日子之后。
# 顺序是有意的：政府看到的永远是**今天已经发生的**世界，不是预测。
func step(groups : Node) -> void:
	_perceive(groups)                                                       # 看：外面多乱
	asset.update(_threat, _farming, _worker_happy, _soldier_power)          # 过日子：家底
	policy_machine.change_policy(asset, _threat)                            # 定：压还是抚
	_execute(groups)                                                        # 做：作用在所有人身上


# --- 看：把世界读成四个数 ---
func _perceive(groups : Node) -> void:
	var worst : float = 0.0
	
	for node in groups.get_children():
		worst = maxf(worst, _threat_of(node))
		
		if node is Farmers:
			# 农民今天在不在种地。粮仓那一行要用它。
			_farming = _level_of(node)
		
		if node is Workers:
			# 工人今天心气如何。工业力那一行要用它。
			# 工业力是**实际产出**，所以读 attribute（日子给的真相），
			# 不读 push（那只是报纸把门槛推了推，改变不了机器转多快）。
			_worker_happy = node.attribute["happy"]
		
		if node is Soldier:
			# 政府在册能调的兵，就是士兵自己的组织度。
			_soldier_power = node.attribute["power"]
	
	_threat = worst


func _threat_of(node : Node) -> float:
	return THREAT_BY_LEVEL[clampi(_level_of(node), 0, THREAT_BY_LEVEL.size() - 1)]


# 一个群体"闹到第几级"。所有状态机都按同一套阶梯编号，
# 所以这里不用管它是农民还是商人——序号本身就是严重程度。
func _level_of(node : Node) -> int:
	if not ("state_machine" in node):
		return 0
	var machine : Variant = node.get("state_machine")
	if machine == null or not ("current_state" in machine):
		return 0
	return machine.get("current_state")


# --- 做 ---
func _execute(groups : Node) -> void:
	match policy_machine.current_policy:
		GovernmentStateMachine.Policy.Conciliate:
			# 花钱买平安：所有人的怒被压下去，国库跟着瘪。
			for node in groups.get_children():
				_press(node, "angry", CONCILIATE_ANGRY)
			asset.money.spend(CONCILIATE_COST)
		
		GovernmentStateMachine.Policy.Suppress:
			# 派兵弹压：所有人的怕被抬起来。
			#
			# 注意这一手对不同群体是**不一样的**——怕涨上去，
			# 农民会跑（FLEE_IN 低）、商人会跑、工人会忍、士兵会散。
			# 政府只发一道命令，结果是有人被压住、有人永远消失。
			# **那不是这里选的，是四个群体各自的阈值决定的。**
			for node in groups.get_children():
				_press(node, "fear", SUPPRESS_FEAR)
				if node is Soldier:
					# 出兵损耗的是政府自己的兵。长期镇压会把组织度磨光，
					# 那时政策自动转回安抚——这就是"兵打光了只能谈"。
					_press(node, "power", -SUPPRESS_ARMY)
		
		_:
			pass


# 政府唯一直接伸进别人身体里的地方。
# 字典是引用——这里改的就是群体自己的 attribute，不是副本。
func _press(node : Node, key : String, delta : float) -> void:
	if not ("attribute" in node):
		return
	var attr : Dictionary = node.get("attribute")
	attr[key] = clampf(attr[key] + delta, 0.0, 1.0)
