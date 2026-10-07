class_name Merchants extends Group

# 纯逻辑对象，不进场景树——它不需要树的任何东西。
var state_machine : MerchantStateMachine = MerchantStateMachine.new()


# --- 它是谁 ---

func initial_attribute() -> Dictionary:
	return {"happy" : 0.3, "angry" : 0.30, "fear" : 0.0, "power" : 0.0}

func my_kind() -> GroupData.READERS:
	return GroupData.READERS.MERCHANT

func finale_type() -> int:
	return NewsData.NewsType.MerchantFlight


# 每天被 World 调用一次
func read_newspaper(newspaper : NewsPaper) -> void:
	_live()                            # 过日子：真相在变
	_read_paper(newspaper)                # 报纸：只改门槛，碰不到 attribute
	state_machine.change_state(attribute, push)   # 决定：真相 + 报纸推的门槛
	_act()                                # 行动：行动反过来改真相


# --- 内向：不改世界，只改自己 ---
func _live() -> void:
	# 先摇今天的骰子：四个属性各飘一点。
	_drift()
	
	# 上面几行是"我自己过日子"，下面几行是"外面的东西落在我头上"。
	# 两者都在改 attribute，但来源不同：上面是内生的，下面是世界给的。
	if government == null:
		return
	
	_read_world()                                                          # 世道乱，谁都怕
	
	# 粮荒是商人的行情。系数在 FoodInfluence.merchant()——
	# 那里和工人的版本并排摆着：**同一个粮仓，相反的符号。**
	#
	# 注意这里没有"商人趁机去囤积"的代码。他不去，他只是高兴；
	# 高兴之后会不会走到 Hoard，是状态机的事。
	_absorb(attribute, FoodInfluence.merchant(government.asset.food))
	
	# 路上不太平。兵一散，最先收摊的是商户——不是怕死，是怕货丢了。
	_absorb(attribute, SoldierPowerInfluence.merchant(government.asset.army))


# --- 外向：以后这里要发出事件让世界看见。现在只做对自己那部分 ---
#
# 这里只剩下"哪个状态有代价"。代价是多少在 Modifer 里。
func _act() -> void:
	match state_machine.current_state:
		MerchantStateMachine.MerchantState.Hoard:
			_absorb(attribute, Modifer.merchant_hoard())
	
		MerchantStateMachine.MerchantState.CloseShop:
			_absorb(attribute, Modifer.merchant_closeshop())
		_:
			pass
