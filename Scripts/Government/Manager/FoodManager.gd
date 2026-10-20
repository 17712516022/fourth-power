class_name FoodManager extends RefCounted

var food_value : float = 0.60
# 两个基础速率。
const YIELD : float = 0.080
const EATEN : float = 0.078

const TIGHT : float = 0.40
const GOOD : float = 0.7

var state : FoodState = FoodState.Normal

enum FoodState{
	High,Normal,Low
}

# 开局就按初值算一次：外面（FoodInfluence）第一次读它时要是对的，。
func _init() -> void:
	update_food_state()

# 收成、吃粮。
func update() -> void:
	var final_yield : float = YIELD * Modifer.yield_modifer
	var final_eaten : float = EATEN * Modifer.eaten_modifer
	var delta : float =  final_yield - final_eaten
	food_value = clampf(food_value + delta , 0.0 ,1.0)
	
	update_food_state()

func update_food_state() -> void:
	if food_value < TIGHT:
		state = FoodState.Low
	elif food_value > GOOD:
		state = FoodState.High
	else :
		state = FoodState.Normal


# 进一笔 / 退一笔，正负都行。
func add(amount : float) -> void:
	food_value = clampf(food_value + amount, 0.0, 1.0)
	update_food_state()
