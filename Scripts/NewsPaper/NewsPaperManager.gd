extends Node

const INFLUENCE_REAL          : float = 2.0   # 登一条真新闻
const INFLUENCE_FILLER        : float = 1.0   # 登一条软新闻
const INFLUENCE_MISS_PENALTY  : float = 2.0   # 漏一条真新闻
const INFLUENCE_FAKE_NEWS     : float = 5.0   # 造一条假新闻
const INFLUENCE_MIN : float = 10.0   # 再低也还剩一点——总归有人信
const INFLUENCE_MAX : float = 300.0

# 报纸的信誉：它说的话，有几分被当真。
var influence : float = 100.0

func get_influence() -> float:
	return influence

func spend_influnce(value : float) -> void:
	influence -= value

# 造得起假新闻吗？扣完 5 点不能跌破结算下限——
# 牌子可以省，但不能在这一步砸穿。
func can_afford_fake_news() -> bool:
	return influence - INFLUENCE_FAKE_NEWS >= INFLUENCE_MIN

# 造一条假新闻的开销。调用前先问一句 can_afford_fake_news()。
func spend_fake_news() -> void:
	spend_influnce(INFLUENCE_FAKE_NEWS)
	EventBus.influence_changed.emit()

# 今天这份报纸，让信誉动了多少。
func settle_influence(paper : NewsPaper) -> void:
	var gain : float = 0.0
	var real_printed : int = 0
	
	for item in paper.events:
		if item == null:
			continue               # 空格位：没排东西，不加也不扣
		
		if item.is_filler:
			gain += INFLUENCE_FILLER
		else:
			gain += INFLUENCE_REAL
			real_printed += 1
	# 漏掉的真新闻。
	var missed : int = maxi(RawMaterialGenerater.real_news_count - real_printed, 0)
	gain -= missed * INFLUENCE_MISS_PENALTY
	
	influence = clampf(influence + gain, INFLUENCE_MIN, INFLUENCE_MAX)
	EventBus.influence_changed.emit()
