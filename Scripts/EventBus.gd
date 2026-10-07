extends Node

signal day_passed(newspaper : NewsPaper)

signal action_end

signal paper_need_create

signal need_show_detail(res : NewsResource)

# 一条大新闻（is_filler == false）被铺进了素材池。
# 每次出现都发，重复不重复由监听方自己判断——比如 FakeNewsList 按事件去重。
# event 是 NewsData.NewsType 的序号；用 int 而不是枚举类型，
# 理由同 NewsResource.type：autoload 名不进类型位置。
signal big_news_appeared(res : NewsResource, event : int)

# 报纸影响力变了。
# 结算（Decide 之后）、造假新闻扣费，都可能改它——而且发生在一天中间，
# 等不到 day_passed 再刷新界面。关心数字的 UI 听这个。
signal influence_changed

# 一局开始了。
#
# 和上面三个不一样：它们说的都是"一天里发生的事"，这个说的是**起点**——
# 主场景装配完毕、各个模块第一次有资格做事的那一刻。
#
# 现在只有素材池听它：开局必须先铺一次，否则玩家进来是空手对着空版面，
# 得先白按一次 Decide（而按那一次，世界已经白走了一天）。
#
# 以后要加开场演出、读存档、恢复上一局，都挂到这里来，
# 不用再让 Ui 挨个去认识每个模块。
signal game_start
