class_name Texts

# 全项目用户看得见的字，只在这儿写。


# 开始菜单
const MENU_TITLE : String = "第四权力"
const MENU_SUBTITLE : String = "一份报纸，一座城"
const MENU_START : String = "开 始 游 戏"
const MENU_CONTINUE : String = "继 续 游 戏"
const MENU_QUIT : String = "退 出 游 戏"
const MENU_NO_SAVE : String = "（无 存 档）"
const MENU_EDITORIAL : String = "EDITORIAL"
const MENU_ISSUE : String = "VOL. I · NO. 1"
const MENU_VERSION : String = "v0.1  原型"

# 打字机上循环写的那几行。
const MENU_TYPE_LINES : Array[String] = [
	# 一天的开始
	"入秋才几天，本城的麦价就涨了三回。",
	"粮铺十家有九家关了门，一袋麦卖到八枚银币。",
	"粮仓昨晚被抢，麦袋撒了半条街。",
	
	# 四乡先动
	"农夫约好不交地租，总督的卫兵已经下乡。",
	"逃跑的人结队出南门，一天上百。",
	"城西搭起三处施食站，一天发掉两千多碗汤。",
	
	# 城里跟着动
	"织坊的机器全停了，工匠一批批离开。",
	"坊主请兵来护坊，工匠退到城外一座空教堂。",
	"商会关门开会，决定各店先停业。",
	"本城三艘商船出海，没说什么时候回来。",
	
	# 最坏的时候
	"驻军一个营昨晚哗变，喊声整夜没停。",
	"散兵沿路抢粮，日子没法过。",
	"总督急调马队，分守四门。",

	# 收手
	"总督贴出告示，说乱事已经平了。",
	"城里设了善后专员，愿意回来种地的，给种子和口粮。",
	"哗变的士兵交枪回营，可编制已经散了。",

	# 报社自语，然后又是新的一天
	"本报明天照常出刊，刮风下雨也不停。",
	"报社昼夜有人，看到什么都可以来投书。",
	"这件事怎么写，全看你这一支笔。",
]


# 四家的名字
const GROUP_FARMER : String = "农夫"
const GROUP_WORKER : String = "工匠"
const GROUP_MERCHANT : String = "商人"
const GROUP_SOLDIER : String = "士兵"
const GROUP_GOVERNMENT : String = "总督"


# 属性面板
const PANEL_HELP_TOOLTIP : String = "帮助"
const PANEL_SETTING_TOOLTIP : String = "设置"
const PANEL_SAVE_TOOLTIP : String = "存档"
const PANEL_SAVE_DONE : String = "已 存 档"
const PANEL_SAVE_FAILED : String = "存 档 失 败"
const PANEL_FAKE_BUTTON : String = "制造假的新闻"

# 四行模板。
# 一局 30 天，这里报的是"第几天"——原来写成 WEEK，会显示成 WEEK 30。
const PANEL_INFLUENCE : String = "[b][u]影响力 [color=red]%d[/color][/u][/b]"
const PANEL_ROW : String = "%s：[color=#%s]%s[/color]"
const PANEL_FAVOR : String = "[img=25]%s[/img] 好感度 [color=#%s]%d/100[/color]"

# 五行的行头（图标 + 名字）。
const PANEL_HEAD_FARMER : String = "[img=25]res://asserts/图标包/no-padding/64px/white/5-food/bread.png[/img] " + GROUP_FARMER
const PANEL_HEAD_WORKER : String = "[img=25]res://asserts/图标包/no-padding/64px/white/6-buildings/anvil.png[/img] " + GROUP_WORKER
const PANEL_HEAD_MERCHANT : String = "[img=25]res://asserts/图标包/no-padding/64px/white/1-game/mana.png[/img] " + GROUP_MERCHANT
const PANEL_HEAD_SOLDIER : String = "[img=25]res://asserts/图标包/no-padding/64px/white/3-gear/pistol.png[/img] " + GROUP_SOLDIER
const PANEL_HEAD_GOVERNMENT : String = "[img=25]res://asserts/图标包/no-padding/64px/white/6-buildings/bank.png[/img] " + GROUP_GOVERNMENT

# 稳定度那一行只剩一条进度条（Scene/StabilityBar.tscn），没有字，也没有行头。
const PANEL_STABILITY_TOOLTIP : String = "稳定度"


# 状态名
const STATE_NORMAL : String = "正常"
const STATE_SLOWDOWN : String = "怠工"
const STATE_UPRISING : String = "动乱"

const STATE_FARMER_RESIST : String = "抗租"
const STATE_FARMER_FLEE : String = "逃亡"

const STATE_WORKER_DEPRESSION : String = "低效"
const STATE_WORKER_STRIKE : String = "停工"
const STATE_WORKER_MARCH : String = "示威"

const STATE_MERCHANT_PROSPERITY : String = "繁荣"
const STATE_MERCHANT_INVEST : String = "投资"
const STATE_MERCHANT_SPECULATE : String = "投机"
const STATE_MERCHANT_HOLLOW : String = "蛀空"
const STATE_MERCHANT_ABROAD : String = "外逃"

const STATE_SOLDIER_DESERT : String = "溃散"
const STATE_SOLDIER_RAMPAGE : String = "扰民"
const STATE_SOLDIER_CORRUPT : String = "腐败"
const STATE_SOLDIER_MUTINY : String = "哗变"

const STATE_GOV_NORMAL : String = "常态"
const STATE_GOV_CONSERVATIVE : String = "软弱"
const STATE_GOV_INCOMPETENT : String = "无能"
const STATE_GOV_HARDLINE : String = "强硬"
const STATE_GOV_TERROR : String = "恐怖"
const STATE_GOV_COLLAPSE : String = "崩溃"


# 解释层（Scripts/Explain/Explain.gd）：因果与归因的每一句话都写在这儿。

# 四维 + 两本账的短名。
const DIM_HAPPY : String = "满意"
const DIM_ANGRY : String = "愤怒"
const DIM_FEAR : String = "恐惧"
const DIM_POWER : String = "行动力"
const DIM_BELLIGERENCE : String = "好战度"
const DIM_STABILITY : String = "稳定度"

# 解释层的字都进说明卡（Scene/MessagePanel.tscn，米色纸面），所以这里带 BBCode。
#
# 色板（在 #f1ebdb 的纸面上过对比度）：
#   INK 硬信息 / LINE 门槛 / DIM 注释 / BAD 会更糟 / GOOD 会更稳 / COLD 另一头也危险
#   规则：一条信息只上一种颜色——数字默认墨色，只有"方向"才上红绿，注释一律压灰。
const COLOR_INK : String = "#3b2f22"
const COLOR_LINE : String = "#59462e"
const COLOR_DIM : String = "#7a6a52"
const COLOR_BAD : String = "#a33a2c"
const COLOR_GOOD : String = "#2f6b4f"
const COLOR_COLD : String = "#2f5f7a"

# 成因：一条出口成没成立、离成立还差多少、这条线被报纸推了多少。
# 这几种字型是等宽的（一个汉字=两个数字宽），所以行短就是对齐的：
#   一行控制在 22 个字以内，正好放满 340 px，不折行。
const EXPLAIN_AND : String = "[color=#7a6a52]同时[/color]"
const EXPLAIN_HOLDS_BAD : String = "[b][color=#a33a2c]→「%s」[/color][/b]"
const EXPLAIN_HOLDS_GOOD : String = "[b][color=#2f6b4f]→「%s」[/color][/b]"
const EXPLAIN_GAP : String = "[color=#7a6a52]差 %.2f[/color]"
const EXPLAIN_PAPER_CANNOT : String = "[color=#6b5a45]报纸只挪线，挪了不回来。[/color]"
const EXPLAIN_TO_NORMAL : String = "[color=#7a6a52]把 %s 这条线%s，回来更快。[/color]"
const EXPLAIN_PUSH_UP : String = "[b][color=#59462e]推高[/color][/b]"
const EXPLAIN_PUSH_DOWN : String = "[b][color=#59462e]推低[/color][/b]"
const EXPLAIN_GOV_CANNOT : String = "[color=#6b5a45]报纸改不了好战度。[/color]"
const EXPLAIN_BELLIGERENCE : String = "好战度 %s（兵 %.2f / 钱 %.2f）\n目标 %.2f，每天只走三成"
const EXPLAIN_STABILITY_FORMULA : String = "[color=#6b5a45]%.0f − Σ(系数 × 行动力) = %.2f[/color]"
const EXPLAIN_STABILITY_LINE : String = "[b]%s[/b] 是乱世线，还差 %s；跌破 %.1f 就崩。"

# 行动后果：这一条登出去会把门槛挪到哪儿。
const EXPLAIN_CARD_TITLE : String = "这一版登出去"
# 标题栏下面那条线由场景画（Divider），文案里不要再画一条。
# 一行一条：家 / 维 / 更难|更易 / 去向。不报数值。
const EXPLAIN_CARD_LINE_SHORT : String = "%s  %s  %s%s"
const EXPLAIN_EASIER : String = "更易"
const EXPLAIN_HARDER : String = "更难"
const EXPLAIN_BIG_EVENT : String = "[b]大事件[/b]（当场改情绪）"
const EXPLAIN_BIG_FOOTER : String = "[color=#7a6a52]最前一条 ×2；改的是情绪，不推门槛[/color]"
const EXPLAIN_MORE_LINES : String = "[color=#7a6a52]（另有 %d 条线）[/color]"
const EXPLAIN_FIRST_SLOT : String = "[color=#7a6a52]最前一条 ×2；门槛永久[/color]"
const EXPLAIN_GROUP_OF : Dictionary = {
	"farmer" : GROUP_FARMER,
	"worker" : GROUP_WORKER,
	"merchant" : GROUP_MERCHANT,
	"soldier" : GROUP_SOLDIER,
}


# 弹窗（造假确认 / 政府来信）
const POP_CONFIRM : String = "你确定吗[br]这将会花费5点影响力"
const POP_WARN : String = "影响力不够"

# 按键上的字。
const POP_REFUSE : String = "算了"
const POP_DETERMINE : String = "就登"
const POP_OBEY : String = "照办"
const POP_DEFY : String = "无视"
const POP_TAKE : String = "收下"
const POP_DROP : String = POP_REFUSE
const POP_ACK : String = "知道了"

# 来信的正文排版：抬头 + 空行 + 正文。
const POP_BODY : String = "%s\n\n%s"
# 信里没有 title 字段时的抬头。
const POP_TITLE_FALLBACK : String = "来信"

# 信末那行大白话：把公文口气翻成"他要你做什么、代价多少"。数字由结算常量填。
const GOV_HINT_DEMAND : String = "\n\n（%s%s。照办：总督好感 +%d；不照办：总督好感 -%d）"
const GOV_HINT_ASK_VERB : String = "他要你"
const GOV_HINT_THREAT_VERB : String = "他逼你"
const GOV_HINT_PICK : String = "把这条新闻登出来"
const GOV_HINT_NOT_PICK : String = "别登这条新闻"
const GOV_HINT_KEPT : String = "\n\n（总督好感 +%d，影响力 +%d）"
const GOV_HINT_BREACH : String = "\n\n（总督府压制了你，总督好感 -%d、影响力 -%d）"


# 悬停消息面板（记者口气）
const MSG_FILLER : String = "填版面用的……别的嘛，就没什么了。"
const MSG_UNKNOWN : String = "这条……我也说不上来。你看着办吧。"
const MSG_QUIET : String = "我觉得……这条大概没什么动静。"
const MSG_PRESS : String = "要不……先押一押？"
const MSG_CALM : String = "登出去……几家反倒能安一安。\n你说呢？"


# 设置面板
const SET_TITLE : String = "游戏设置"
const SET_MASTER : String = "主音量"
const SET_SFX : String = "音效"
const SET_MUSIC : String = "音乐"
const SET_BACK_MENU : String = "返回主菜单"
const SET_QUIT : String = "退出游戏"
const SET_BACK_GAME : String = "返回游戏"


# 素材详情
const RAW_IKNOW : String = "我知道了"


# 最后一期号
const ENDING_MASTHEAD : String = "第 %d 天 · 最后一期"
const ENDING_RESTART : String = "重 新 开 始"
const ENDING_ISSUES : String = "共出刊 %d 期"
const ENDING_LEDGER : String = "最终影响力 %d　　总督好感 %d"
const ENDING_STABILITY : String = "稳定度 %.1f / 12"


# 档案
const ARCHIVE_TITLE : String = "报 社 档 案"
const ARCHIVE_TAB_NEWS : String = "新 闻"
const ARCHIVE_TAB_ENDING : String = "结 局"
const ARCHIVE_NEWS_PROGRESS : String = "已登 %d / %d"
const ARCHIVE_ENDING_PROGRESS : String = "已达成 %d / %d"
const ARCHIVE_SHELF_PROGRESS : String = "%s %d/%d"
const ARCHIVE_LOCKED : String = "？"
const ARCHIVE_CLOSE : String = "关 闭"
const ARCHIVE_ENTRY : String = "档 案"
# 下标与 ArchiveManager.Shelf 同序。
const ARCHIVE_SHELF_NAMES : Array = [GROUP_FARMER, GROUP_WORKER, GROUP_MERCHANT, GROUP_SOLDIER, GROUP_GOVERNMENT, "大事件", "杂项"]
