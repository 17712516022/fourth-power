class_name GovernmentStateMachine extends Node

enum Policy {
	Idle,
	Conciliate,
	Suppress,
}

const WATCH_IN   : float = 0.35   # 骚乱过这个 -> 开始管
const THREAT_LOW : float = 0.20   # 骚乱跌破这个 -> 收手（迟滞）
const HARD_LINE  : float = 0.50   # 好战度过这个 -> 选硬的

var current_policy : Policy = Policy.Idle

# 读进来的是政府的家底和外面的乱劲，状态机不持有它们。
func change_policy(asset : GovernmentAsset, threat : float) -> void:
	var next : Policy = _next_policy(asset, threat)
	if next == current_policy:
		return

	current_policy = next
	_report(current_policy)

func _next_policy(asset : GovernmentAsset, threat : float) -> Policy:
	# 决策只用到三项：脾气（选软还是硬）、钱（抚得起吗）、兵（压得动吗）。
	# 剩下三项（粮、工业力、稳定度）暂时不参与——它们是下一环的燃料。
	var belligerence : float = asset.belligerence.value
	var money : float = asset.money.value
	var soldier_power : float = asset.army.value
	
	match current_policy:
		Policy.Idle:
			if threat > WATCH_IN:
				# 政府性格在这里分叉。别的群体到了这一步没有选择。
				if belligerence > HARD_LINE:
					return Policy.Suppress
				return Policy.Conciliate
	
		Policy.Conciliate:
			if threat < THREAT_LOW:
				return Policy.Idle
			if money <= 0.0:
				return Policy.Suppress        # 没钱了，只能硬来
			if belligerence > HARD_LINE:
				return Policy.Suppress        # 安抚没用，翻脸
	
		Policy.Suppress:
			if threat < THREAT_LOW:
				return Policy.Idle
			if soldier_power <= 0.0:
				return Policy.Conciliate      # 兵打光了，只能谈
	
	return current_policy

# 状态变了，报出去。
#
# 这一处和四个群体的写法**故意不一样**，不是漏了：
#   群体的新闻在枚举里是按"转移边"定义的（FarmerResistStart 就是 Normal -> Resist），
#   所以它们必须报 (prev, next) 两头，否则升级和结束分不清。
#   而政府的新闻是按**结果政策**定义的——GovernmentConciliate 就是"开始安抚"，
#   至于上一刻是在 Idle（下诏安抚）还是在 Suppress（兵打光了改谈），
#   对报纸来说是同一条消息。
#
# 想区分"下诏"和"罢兵"，得先往 NewsData 里加一条 GovernmentSuppressEnd 之类，
# 那是改枚举，不是改这里。
func _report(next_policy : Policy) -> void:
	match next_policy:
		Policy.Idle:
			RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentIdle)
		Policy.Conciliate:
			RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentConciliate)
		Policy.Suppress:
			RawMaterialGenerater.get_material(NewsData.NewsType.GovernmentSuppress)
