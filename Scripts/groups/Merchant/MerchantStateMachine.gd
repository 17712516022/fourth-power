class_name MerchantStateMachine extends Node

enum MerchantState {
	Normal,
	Hoard,
	CloseShop,
	Flight,
}

const HOARD_IN  : float = 0.45   # 怒超过这个 -> 开始惜售
const HOARD_OUT : float = 0.35   # 怒跌破这个 -> 重新开门
const CLOSE_IN  : float = 0.50   # 怒再高一点 -> 直接罢市
const CLOSE_OUT : float = 0.30   # 怒跌破这个 -> 复市
const FLIGHT_IN  : float = 0.30  # 怕超过这个 -> 走人
const FLIGHT_OUT : float = 0.18  # 怕跌回这个以下 -> 资本回埠（迟滞）
const POWER_MIN : float = 0.10   # 本钱不到这个数，闹不起来

var current_state : MerchantState = MerchantState.Normal

# 属性是读进来的，状态机不持有它；push 是报纸把门槛推到哪。
# **两者不混**：报纸改不了他们有多怒，只能改他们要多怒才敢动手。
func change_state(attribute : Dictionary, push : Dictionary) -> void:
	var next : MerchantState = _next_state(attribute, push)
	if next == current_state:
		return
	
	var prev : MerchantState = current_state
	current_state = next
	_report(prev, next)

# 当前状态决定能去哪。互斥由 match 保证，不靠函数调用顺序。
# push 正 = 退（抬怒线、压怕线），负 = 进。
func _next_state(attribute : Dictionary, push : Dictionary) -> MerchantState:
	var angry : float = attribute["angry"]
	var fear  : float = attribute["fear"]
	var power : float = attribute["power"]
	
	match current_state:
		MerchantState.Normal:
			if fear > FLIGHT_IN - push["fear"]:
				return MerchantState.Flight
			if angry > HOARD_IN + push["angry"] and power > POWER_MIN:
				return MerchantState.Hoard

		MerchantState.Hoard:
			if fear > FLIGHT_IN - push["fear"]:
				return MerchantState.Flight
			if angry > CLOSE_IN + push["angry"]:
				return MerchantState.CloseShop
			if angry < HOARD_OUT - push["angry"] * 0.5:
				return MerchantState.Normal

		MerchantState.CloseShop:
			if fear > FLIGHT_IN - push["fear"]:
				return MerchantState.Flight
			if angry < CLOSE_OUT - push["angry"] * 0.5:
				return MerchantState.Normal

		MerchantState.Flight:
			# **这里不是终局。** 太平了，钱会回来——商人的嗅觉比谁都灵，
			# 但也比谁都胆小，所以回来的门槛（0.18）压得比走的时候（0.30）低得多。
			if fear < FLIGHT_OUT - push["fear"]:
				return MerchantState.Normal
	
	return current_state

# 状态变了，把这条**转移**报出去。
#
# 报的是"从哪来到哪去"，不是"进入了什么状态"或"离开了什么状态"。
# 一条边 = 一个 (prev, next) 组合，单看一头会丢信息：
#   Hoard -> CloseShop 时商人并没有"结束囤积"，他是升级了。
#   只看"离开了 Hoard"就会白发一条 MerchantHoardEnd。
func _report(prev_state : MerchantState, next_state : MerchantState) -> void:
	# 终局只有一条：不管从哪个状态走，报的都是"人和钱一起走了"。
	# 它压在 match 前面，因为三条边通向这里，分开写会抄三遍同样的东西。
	if next_state == MerchantState.Flight:
		RawMaterialGenerater.get_material(NewsData.NewsType.MerchantFlight)
		return

	# 反过来：Flight 唯一的出边就是回埠。和"复市"不是一回事——
	# 那边是铺子重新开门，这边是人和钱重新回到这个埠。
	if prev_state == MerchantState.Flight:
		RawMaterialGenerater.get_material(NewsData.NewsType.MerchantReturn)
		return

	match prev_state:
		MerchantState.Normal:
			if next_state == MerchantState.Hoard:
				RawMaterialGenerater.get_material(NewsData.NewsType.MerchantHoardStart)

		MerchantState.Hoard:
			if next_state == MerchantState.Normal:
				RawMaterialGenerater.get_material(NewsData.NewsType.MerchantHoardEnd)
			elif next_state == MerchantState.CloseShop:
				RawMaterialGenerater.get_material(NewsData.NewsType.MerchantCloseShopStart)

		MerchantState.CloseShop:
			if next_state == MerchantState.Normal:
				RawMaterialGenerater.get_material(NewsData.NewsType.MerchantCloseShopEnd)
