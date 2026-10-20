extends Node

const INFLUENCE_REAL          : float = 2.0
# 软新闻只是把版面填满，不该换来读者信任：只占格子，不涨信誉。
const INFLUENCE_FILLER        : float = 0.0
const INFLUENCE_MISS_PENALTY  : float = 2.0
const INFLUENCE_FAKE_NEWS     : float = 5.0
const INFLUENCE_MIN : float = 10.0
const INFLUENCE_MAX : float = 300.0

# 报纸的信誉：它说的话，有几分被当真。
var influence : float = 100.0

func _ready() -> void:
	EventBus.fake_news_confirmed.connect(_on_fake_news_confirmed)

func get_influence() -> float:
	return influence

func spend_influnce(value : float) -> void:
	# 扣不穿底线。
	influence = clampf(influence - value, INFLUENCE_MIN, INFLUENCE_MAX)
	# 信号在**这里**发，别让调用方补。
	EventBus.influence_changed.emit()

func gain_influnce(value : float) -> void:
	# 涨不过上限。
	influence = clampf(influence + value, INFLUENCE_MIN, INFLUENCE_MAX)
	EventBus.influence_changed.emit()

# 造得起假新闻吗？
func can_afford_fake_news() -> bool:
	return influence - INFLUENCE_FAKE_NEWS >= INFLUENCE_MIN

# 造一条假新闻的开销。
func spend_fake_news() -> void:
	spend_influnce(INFLUENCE_FAKE_NEWS)

# 造假确认了：一手交钱。
func _on_fake_news_confirmed(_res : NewsResource) -> void:
	spend_fake_news()

# 今天这份报纸，让信誉动了多少。
func settle_influence(paper : NewsPaper) -> void:
	var gain : float = 0.0
	var real_printed : int = 0
	
	for i in paper.events.size():
		var item : NewsResource = paper.events[i]
		if item == null:
			continue
		
		if paper.is_fake(i):
			# 假新闻：读者信，但账不认。
			continue
		
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
	
	# 这一份报纸是赚了还是赔了，用自己的声音说一声。
	if gain > 0.0:
		AudioManager.play(AudioManager.Sound.SETTLE_GOOD)
	elif gain < 0.0:
		AudioManager.play(AudioManager.Sound.SETTLE_BAD)
