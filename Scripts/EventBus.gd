extends Node

# 一天真的过去了：世界可以按这份报纸往前走。
signal day_passed(newspaper : NewsPaper)

# 过天的第一步：玩家按了决定，报纸已经抄好版面、信誉也结算过了。
signal paper_ready(newspaper : NewsPaper)

# 一天走完了：可以开始摆今天这一份报纸了。
signal action_end

# 过场里摆出了报纸上的某一条（index 是在报纸版面里的下标）。
# 表现层拿来让相关群体做反应；以后素材池 / 详情面板也可以听。
signal news_card_shown(res : NewsResource, index : int)

signal paper_need_create

# 详情面板的两种来路。
const DETAIL_QUEUE : int = 0
const DETAIL_PREVIEW : int = 1

# 点开一条素材看详情。
signal need_show_detail(res : NewsResource, is_fake : bool, source : int)

# 一条大新闻（is_filler == false）被铺进了素材池。
signal big_news_appeared(res : NewsResource, event : int)

# 素材详情面板被关掉了（玩家点了"我知道了"）。
signal detail_closed(source : int)

# 报纸影响力变了。
signal influence_changed

# 鼠标停在/离开一张新闻素材上（见 PressureUi._set_hovered）。
signal hover_on_news(res : NewsResource, entered : bool)

# 鼠标停在右侧四家 / 领地 / 稳定度上：把那一条的"为什么"交给说明卡
# （见 Ui/AttributeUi 与 MessagePanel，两者共用同一块面板）。
signal explain_show(title : String, body : String)
signal explain_hide

# 政府递来的那条新闻落进了素材池（面板一打开就发，见 GovernmentMessager._on_open_government）。
# is_fake = 这张卡算不算假新闻（红卡）。
signal government_offer_taken(event : int, is_fake : bool)

# 主线来信附的那张稿子（信里直接挂了资源，不经 NewsType 现抽）。
signal government_offer_res(res : NewsResource, is_fake : bool)

# 政府好感度变了（见 Scripts/Government/GovernmentFavor.gd）。
signal government_favor_changed

# 一局开始了。
signal game_start

# 翻开某块面板。
signal need_open_fake_list
signal need_open_help
signal need_open_settings

# 档案里挑中了一条要做假，请弹窗出来问一句。
signal need_show_popmenu(res : NewsResource)

# 造假确认了。
signal fake_news_confirmed(res : NewsResource)

# 今天发生了某件事（NewsData.NewsType 的序号）。
signal material_news_requested(event : int)

# 这一局到头了：结局号见 EndingData.Id（见 Scripts/Ending/EndingManager.gd）。
signal ending_reached(id : int)

# 过场的滚筒抬起来了：终刊号这时候才可以压上来（见 DayPassAnimation.play 的收尾）。
signal day_pass_finished

# 某个群体换档了：prev / next 是状态对象（见 StateText.of / mood_of）。
# 发生在过天那一下的黑屏里（World._on_tick → group.step → change_state），
# 过场收下之后在抬滚筒之前播"变天"。
signal group_state_changed(reader : int, prev, next)

# 领地（政府）换档了。它没有剪影，只出横幅。
signal government_state_changed(prev, next)
