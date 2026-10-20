class_name ArchivePanel extends Control

# 图鉴面板：新闻按书架铺格子（登过才亮），结局按达成情况列出来。
# 唯一的入口是开始菜单（见 StartMenu.gd）：装在那里，局内没有入口。

const FONT = preload("res://theme/font.tres")

# 主题四态都在 theme/ 下的 .tres 里写死，这里只负责挑一套挂上去。
const SKINS : Dictionary = {
	&"warm": {
		"normal": preload("res://theme/ButtonWarmNormal.tres"),
		"hover": preload("res://theme/ButtonWarmHover.tres"),
		"pressed": preload("res://theme/ButtonWarmPressed.tres"),
		"unable": preload("res://theme/ButtonWarmUnable.tres"),
	},
	&"sage": {
		"normal": preload("res://theme/ButtonSageNormal.tres"),
		"hover": preload("res://theme/ButtonSageHover.tres"),
		"pressed": preload("res://theme/ButtonSagePressed.tres"),
		"unable": preload("res://theme/ButtonSageUnable.tres"),
	},
	&"rust": {
		"normal": preload("res://theme/ButtonRustNormal.tres"),
		"hover": preload("res://theme/ButtonRustHover.tres"),
		"pressed": preload("res://theme/ButtonRustPressed.tres"),
		"unable": preload("res://theme/ButtonRustUnable.tres"),
	},
	&"violet": {
		"normal": preload("res://theme/ButtonVioletNormal.tres"),
		"hover": preload("res://theme/ButtonVioletHover.tres"),
		"pressed": preload("res://theme/ButtonVioletPressed.tres"),
		"unable": preload("res://theme/ButtonVioletUnable.tres"),
	},
	&"ivory": {
		"normal": preload("res://theme/ButtonIvoryNormal.tres"),
		"hover": preload("res://theme/ButtonIvoryHover.tres"),
		"pressed": preload("res://theme/ButtonIvoryPressed.tres"),
		"unable": preload("res://theme/ButtonIvoryUnable.tres"),
	},
	&"steel": {
		"normal": preload("res://theme/ButtonSteelNormal.tres"),
		"hover": preload("res://theme/ButtonSteelHover.tres"),
		"pressed": preload("res://theme/ButtonSteelPressed.tres"),
		"unable": preload("res://theme/ButtonSteelUnable.tres"),
	},
	&"ink": {
		"normal": preload("res://theme/ButtonNormal.tres"),
		"hover": preload("res://theme/ButtonHover.tres"),
		"pressed": preload("res://theme/ButtonPressed.tres"),
		"unable": preload("res://theme/ButtonUnable.tres"),
	},
}

# 书架序号 -> 主题名，顺序同 ArchiveManager.Shelf / Texts.ARCHIVE_SHELF_NAMES。
const SHELF_SKINS : Array = [&"warm", &"steel", &"rust", &"sage", &"ink", &"violet", &"ivory"]

const CARD_SIZE : Vector2 = Vector2(150, 74)
const SHELF_SIZE : Vector2 = Vector2(118, 0)

const INK : Color = Color(0.13, 0.11, 0.09, 1)
const INK_FAINT : Color = Color(0.45, 0.42, 0.38, 1)

enum Page { News, Ending }
enum Look { Normal, Active, Locked }

@onready var title_label : Label = %Title
@onready var close_button : Button = %Close
@onready var news_tab : Button = %NewsTab
@onready var ending_tab : Button = %EndingTab
@onready var progress : Label = %Progress
@onready var news_page : Control = %NewsPage
@onready var ending_page : Control = %EndingPage
@onready var shelf_box : VBoxContainer = %ShelfBox
@onready var news_grid : GridContainer = %NewsGrid
@onready var ending_box : VBoxContainer = %EndingBox
@onready var detail : PanelContainer = %Detail
@onready var detail_title : Label = %DetailTitle
@onready var detail_image : TextureRect = %DetailImage
@onready var detail_body : RichTextLabel = %DetailBody
@onready var detail_close : Button = %DetailClose

var _catalog : Dictionary = {}
var _shelf : int = 0
var _page : int = Page.News
var _shelf_buttons : Array = []
var _cards : Array = []


func _ready() -> void:
	hide()
	detail.hide()
	title_label.text = Texts.ARCHIVE_TITLE
	news_tab.text = Texts.ARCHIVE_TAB_NEWS
	ending_tab.text = Texts.ARCHIVE_TAB_ENDING
	close_button.text = Texts.ARCHIVE_CLOSE
	detail_close.text = Texts.ARCHIVE_CLOSE
	close_button.pressed.connect(close)
	detail_close.pressed.connect(_on_detail_close)
	news_tab.pressed.connect(_on_tab.bind(Page.News))
	ending_tab.pressed.connect(_on_tab.bind(Page.Ending))
	_paint(close_button, &"sage")
	_paint(detail_close, &"sage")
	_catalog = ArchiveManager.catalog()
	_build_shelves()
	_paint_tabs()


func open() -> void:
	detail.hide()
	_show_page(_page)
	show()


func close() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	detail.hide()
	hide()


func _on_tab(p : int) -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	_show_page(p)


func _show_page(p : int) -> void:
	_page = p
	news_page.visible = p == Page.News
	ending_page.visible = p == Page.Ending
	_paint_tabs()
	if p == Page.News:
		_fill_shelves()
		_fill_grid()
		progress.text = Texts.ARCHIVE_NEWS_PROGRESS % [ArchiveManager.news_count(), _total_news()]
	else:
		_fill_endings()
		progress.text = Texts.ARCHIVE_ENDING_PROGRESS % [
			ArchiveManager.ending_count(), EndingData.HEADLINE.size()]


# 新闻页暖黄、结局页暗紫，当前页压亮并锁住，免得两个并排的 tab 分不出。
func _paint_tabs() -> void:
	var on_news : bool = _page == Page.News
	news_tab.disabled = on_news
	ending_tab.disabled = not on_news
	_paint(news_tab, &"warm", Look.Active if on_news else Look.Normal)
	_paint(ending_tab, &"violet", Look.Active if not on_news else Look.Normal)


func _total_news() -> int:
	var total : int = 0
	for shelf in _catalog.keys():
		total += (_catalog[shelf] as Array).size()
	return total


# 左栏

func _build_shelves() -> void:
	var shelves : Array = _catalog.keys()
	shelves.sort()
	for shelf in shelves:
		var button : Button = Button.new()
		button.custom_minimum_size = SHELF_SIZE
		button.theme = FONT
		button.add_theme_font_size_override("font_size", 17)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_paint(button, _shelf_skin(shelf))
		button.pressed.connect(_on_shelf.bind(shelf))
		shelf_box.add_child(button)
		_shelf_buttons.append(button)


func _on_shelf(slot : int) -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	_shelf = slot
	_fill_shelves()
	_fill_grid()


func _fill_shelves() -> void:
	var shelves : Array = _catalog.keys()
	shelves.sort()
	for i in shelves.size():
		var shelf : int = shelves[i]
		var items : Array = _catalog[shelf]
		var seen : int = 0
		for res in items:
			if ArchiveManager.seen((res as NewsResource).resource_path):
				seen += 1
		var button : Button = _shelf_buttons[i]
		button.text = Texts.ARCHIVE_SHELF_PROGRESS % [
			Texts.ARCHIVE_SHELF_NAMES[shelf], seen, items.size()]
		var active : bool = shelf == _shelf
		button.disabled = active
		_paint(button, _shelf_skin(shelf), Look.Active if active else Look.Normal)


# 格子

func _fill_grid() -> void:
	for card in _cards:
		if is_instance_valid(card):
			news_grid.remove_child(card)
			card.queue_free()
	_cards.clear()

	for res in _catalog.get(_shelf, []):
		var news : NewsResource = res
		var seen : bool = ArchiveManager.seen(news.resource_path)
		var button : Button = Button.new()
		button.custom_minimum_size = CARD_SIZE
		button.theme = FONT
		button.add_theme_font_size_override("font_size", 15)
		button.clip_text = true
		_paint(button, &"ivory", Look.Locked if not seen else Look.Normal)
		button.text = news.headline if seen else Texts.ARCHIVE_LOCKED
		button.tooltip_text = news.headline if seen else ""
		button.disabled = not seen
		if seen:
			button.pressed.connect(_open_detail.bind(news))
		news_grid.add_child(button)
		_cards.append(button)


func _shelf_skin(shelf : int) -> StringName:
	if shelf >= 0 and shelf < SHELF_SKINS.size():
		return StringName(SHELF_SKINS[shelf])
	return &"ink"


# Active 借用同一套的 hover：当前项亮起来、光晕更大，跟"选中"的语义对得上。
func _paint(button : Button, skin_name : StringName, look : int = Look.Normal) -> void:
	var skin : Dictionary = SKINS.get(skin_name, SKINS[&"ink"]) as Dictionary
	button.add_theme_stylebox_override("normal", skin["normal"] as StyleBox)
	button.add_theme_stylebox_override("hover", skin["hover"] as StyleBox)
	button.add_theme_stylebox_override("pressed", skin["pressed"] as StyleBox)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_pressed_color", Color(0.93, 0.93, 0.93, 1))
	if look == Look.Active:
		button.add_theme_stylebox_override("disabled", skin["hover"] as StyleBox)
		button.add_theme_color_override("font_disabled_color", INK)
	else:
		button.add_theme_stylebox_override("disabled", skin["unable"] as StyleBox)
		button.add_theme_color_override("font_disabled_color",
			INK_FAINT if look == Look.Locked else INK)


func _open_detail(news : NewsResource) -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	detail_title.text = news.headline
	detail_body.text = news.body
	detail_image.texture = news.image
	detail_image.visible = news.image != null
	detail.show()


func _on_detail_close() -> void:
	AudioManager.play(AudioManager.Sound.CLICK)
	detail.hide()


# 结局栏

func _fill_endings() -> void:
	for child in ending_box.get_children():
		ending_box.remove_child(child)
		child.queue_free()

	var ids : Array = EndingData.HEADLINE.keys()
	ids.sort()
	for id in ids:
		ending_box.add_child(_ending_block(int(id)))


func _ending_block(id : int) -> Control:
	var seen : bool = ArchiveManager.ending_seen(id)

	var holder : VBoxContainer = VBoxContainer.new()
	holder.add_theme_constant_override("separation", 6)

	var head : Label = Label.new()
	head.theme = FONT
	head.add_theme_font_size_override("font_size", 26)
	head.add_theme_color_override("font_color", INK if seen else INK_FAINT)
	head.text = EndingData.headline_of(id) if seen else Texts.ARCHIVE_LOCKED
	holder.add_child(head)

	if seen:
		var text : RichTextLabel = RichTextLabel.new()
		text.theme = FONT
		text.bbcode_enabled = true
		text.fit_content = true
		text.scroll_active = false
		text.add_theme_font_size_override("normal_font_size", 16)
		text.add_theme_color_override("default_color", INK)
		text.text = EndingData.body_of(id, EndingManager.TOTAL_DAYS)
		holder.add_child(text)

	holder.add_child(HSeparator.new())
	return holder
