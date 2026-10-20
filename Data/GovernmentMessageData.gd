extends Node

# 政府来信只跟大事件走：一件大事两封来信（请求 / 威胁），按当局好感挑一封；
# 一件大事两封回信（履约 / 违约）。好感就是请求口吻的概率，余数是威胁。
# 走路径不走 uid：手写的新文件还没被编辑器扫过，当次认不出 uid。

# ===== 主线来信：24 件大事件，一件两封 =====

const LETTER_B01_ASK = preload("res://Resource/GovernmentMessage/LetterB01WestRallyAsk.tres")
const LETTER_B01_THREAT = preload("res://Resource/GovernmentMessage/LetterB01WestRallyThreat.tres")
const LETTER_B02_ASK = preload("res://Resource/GovernmentMessage/LetterB02ReliefCrisisAsk.tres")
const LETTER_B02_THREAT = preload("res://Resource/GovernmentMessage/LetterB02ReliefCrisisThreat.tres")
const LETTER_B03_ASK = preload("res://Resource/GovernmentMessage/LetterB03LeagueFoundedAsk.tres")
const LETTER_B03_THREAT = preload("res://Resource/GovernmentMessage/LetterB03LeagueFoundedThreat.tres")
const LETTER_B04_ASK = preload("res://Resource/GovernmentMessage/LetterB04NoticeBoardAsk.tres")
const LETTER_B04_THREAT = preload("res://Resource/GovernmentMessage/LetterB04NoticeBoardThreat.tres")
const LETTER_B05_ASK = preload("res://Resource/GovernmentMessage/LetterB05EvictionsAsk.tres")
const LETTER_B05_THREAT = preload("res://Resource/GovernmentMessage/LetterB05EvictionsThreat.tres")
const LETTER_B06_ASK = preload("res://Resource/GovernmentMessage/LetterB06LaborersRejectedAsk.tres")
const LETTER_B06_THREAT = preload("res://Resource/GovernmentMessage/LetterB06LaborersRejectedThreat.tres")
const LETTER_B07_ASK = preload("res://Resource/GovernmentMessage/LetterB07IsolationAsk.tres")
const LETTER_B07_THREAT = preload("res://Resource/GovernmentMessage/LetterB07IsolationThreat.tres")
const LETTER_B08_ASK = preload("res://Resource/GovernmentMessage/LetterB08HarvestEscortAsk.tres")
const LETTER_B08_THREAT = preload("res://Resource/GovernmentMessage/LetterB08HarvestEscortThreat.tres")
const LETTER_B09_ASK = preload("res://Resource/GovernmentMessage/LetterB09ShopsClosedAsk.tres")
const LETTER_B09_THREAT = preload("res://Resource/GovernmentMessage/LetterB09ShopsClosedThreat.tres")
const LETTER_B10_ASK = preload("res://Resource/GovernmentMessage/LetterB10CoercionActAsk.tres")
const LETTER_B10_THREAT = preload("res://Resource/GovernmentMessage/LetterB10CoercionActThreat.tres")
const LETTER_B11_ASK = preload("res://Resource/GovernmentMessage/LetterB11EditorArrestedAsk.tres")
const LETTER_B11_THREAT = preload("res://Resource/GovernmentMessage/LetterB11EditorArrestedThreat.tres")
const LETTER_B12_ASK = preload("res://Resource/GovernmentMessage/LetterB12LeaderArrestedAsk.tres")
const LETTER_B12_THREAT = preload("res://Resource/GovernmentMessage/LetterB12LeaderArrestedThreat.tres")
const LETTER_B13_ASK = preload("res://Resource/GovernmentMessage/LetterB13LadiesRecordsAsk.tres")
const LETTER_B13_THREAT = preload("res://Resource/GovernmentMessage/LetterB13LadiesRecordsThreat.tres")
const LETTER_B14_ASK = preload("res://Resource/GovernmentMessage/LetterB14LadiesBannedAsk.tres")
const LETTER_B14_THREAT = preload("res://Resource/GovernmentMessage/LetterB14LadiesBannedThreat.tres")
const LETTER_B15_ASK = preload("res://Resource/GovernmentMessage/LetterB15NoRentAsk.tres")
const LETTER_B15_THREAT = preload("res://Resource/GovernmentMessage/LetterB15NoRentThreat.tres")
const LETTER_B16_ASK = preload("res://Resource/GovernmentMessage/LetterB16LandActAsk.tres")
const LETTER_B16_THREAT = preload("res://Resource/GovernmentMessage/LetterB16LandActThreat.tres")
const LETTER_B17_ASK = preload("res://Resource/GovernmentMessage/LetterB17RumorTalksAsk.tres")
const LETTER_B17_THREAT = preload("res://Resource/GovernmentMessage/LetterB17RumorTalksThreat.tres")
const LETTER_B18_ASK = preload("res://Resource/GovernmentMessage/LetterB18ParkAssassinationAsk.tres")
const LETTER_B18_THREAT = preload("res://Resource/GovernmentMessage/LetterB18ParkAssassinationThreat.tres")
const LETTER_B19_ASK = preload("res://Resource/GovernmentMessage/LetterB19WestportRallyAsk.tres")
const LETTER_B19_THREAT = preload("res://Resource/GovernmentMessage/LetterB19WestportRallyThreat.tres")
const LETTER_B20_ASK = preload("res://Resource/GovernmentMessage/LetterB20NewDepartureAsk.tres")
const LETTER_B20_THREAT = preload("res://Resource/GovernmentMessage/LetterB20NewDepartureThreat.tres")
const LETTER_B21_ASK = preload("res://Resource/GovernmentMessage/LetterB21AmericanFundAsk.tres")
const LETTER_B21_THREAT = preload("res://Resource/GovernmentMessage/LetterB21AmericanFundThreat.tres")
const LETTER_B22_ASK = preload("res://Resource/GovernmentMessage/LetterB22ElectionAsk.tres")
const LETTER_B22_THREAT = preload("res://Resource/GovernmentMessage/LetterB22ElectionThreat.tres")
const LETTER_B23_ASK = preload("res://Resource/GovernmentMessage/LetterB23LadiesLeagueFoundedAsk.tres")
const LETTER_B23_THREAT = preload("res://Resource/GovernmentMessage/LetterB23LadiesLeagueFoundedThreat.tres")
const LETTER_B24_ASK = preload("res://Resource/GovernmentMessage/LetterB24LadiesLeagueDissolvedAsk.tres")
const LETTER_B24_THREAT = preload("res://Resource/GovernmentMessage/LetterB24LadiesLeagueDissolvedThreat.tres")

# event_id -> [请求信, 威胁信]。
const EVENT_LETTERS : Dictionary = {
	"b01_west_rally" : [LETTER_B01_ASK, LETTER_B01_THREAT],
	"b02_relief_crisis" : [LETTER_B02_ASK, LETTER_B02_THREAT],
	"b03_league_founded" : [LETTER_B03_ASK, LETTER_B03_THREAT],
	"b04_notice_board" : [LETTER_B04_ASK, LETTER_B04_THREAT],
	"b05_evictions" : [LETTER_B05_ASK, LETTER_B05_THREAT],
	"b06_laborers_rejected" : [LETTER_B06_ASK, LETTER_B06_THREAT],
	"b07_isolation" : [LETTER_B07_ASK, LETTER_B07_THREAT],
	"b08_harvest_escort" : [LETTER_B08_ASK, LETTER_B08_THREAT],
	"b09_shops_closed" : [LETTER_B09_ASK, LETTER_B09_THREAT],
	"b10_coercion_act" : [LETTER_B10_ASK, LETTER_B10_THREAT],
	"b11_editor_arrested" : [LETTER_B11_ASK, LETTER_B11_THREAT],
	"b12_leader_arrested" : [LETTER_B12_ASK, LETTER_B12_THREAT],
	"b13_ladies_records" : [LETTER_B13_ASK, LETTER_B13_THREAT],
	"b14_ladies_banned" : [LETTER_B14_ASK, LETTER_B14_THREAT],
	"b15_no_rent" : [LETTER_B15_ASK, LETTER_B15_THREAT],
	"b16_land_act" : [LETTER_B16_ASK, LETTER_B16_THREAT],
	"b17_rumor_talks" : [LETTER_B17_ASK, LETTER_B17_THREAT],
	"b18_park_assassination" : [LETTER_B18_ASK, LETTER_B18_THREAT],
	"b19_westport_rally" : [LETTER_B19_ASK, LETTER_B19_THREAT],
	"b20_new_departure" : [LETTER_B20_ASK, LETTER_B20_THREAT],
	"b21_american_fund" : [LETTER_B21_ASK, LETTER_B21_THREAT],
	"b22_election" : [LETTER_B22_ASK, LETTER_B22_THREAT],
	"b23_ladies_league_founded" : [LETTER_B23_ASK, LETTER_B23_THREAT],
	"b24_ladies_league_dissolved" : [LETTER_B24_ASK, LETTER_B24_THREAT],
}

# ===== 主线回信：一件两封，口气仍只有请求 / 威胁两种 =====

const REPLY_B01_KEPT = preload("res://Resource/GovernmentMessage/ReplyB01Kept.tres")
const REPLY_B01_BREACH = preload("res://Resource/GovernmentMessage/ReplyB01Breach.tres")
const REPLY_B02_KEPT = preload("res://Resource/GovernmentMessage/ReplyB02Kept.tres")
const REPLY_B02_BREACH = preload("res://Resource/GovernmentMessage/ReplyB02Breach.tres")
const REPLY_B03_KEPT = preload("res://Resource/GovernmentMessage/ReplyB03Kept.tres")
const REPLY_B03_BREACH = preload("res://Resource/GovernmentMessage/ReplyB03Breach.tres")
const REPLY_B04_KEPT = preload("res://Resource/GovernmentMessage/ReplyB04Kept.tres")
const REPLY_B04_BREACH = preload("res://Resource/GovernmentMessage/ReplyB04Breach.tres")
const REPLY_B05_KEPT = preload("res://Resource/GovernmentMessage/ReplyB05Kept.tres")
const REPLY_B05_BREACH = preload("res://Resource/GovernmentMessage/ReplyB05Breach.tres")
const REPLY_B06_KEPT = preload("res://Resource/GovernmentMessage/ReplyB06Kept.tres")
const REPLY_B06_BREACH = preload("res://Resource/GovernmentMessage/ReplyB06Breach.tres")
const REPLY_B07_KEPT = preload("res://Resource/GovernmentMessage/ReplyB07Kept.tres")
const REPLY_B07_BREACH = preload("res://Resource/GovernmentMessage/ReplyB07Breach.tres")
const REPLY_B08_KEPT = preload("res://Resource/GovernmentMessage/ReplyB08Kept.tres")
const REPLY_B08_BREACH = preload("res://Resource/GovernmentMessage/ReplyB08Breach.tres")
const REPLY_B09_KEPT = preload("res://Resource/GovernmentMessage/ReplyB09Kept.tres")
const REPLY_B09_BREACH = preload("res://Resource/GovernmentMessage/ReplyB09Breach.tres")
const REPLY_B10_KEPT = preload("res://Resource/GovernmentMessage/ReplyB10Kept.tres")
const REPLY_B10_BREACH = preload("res://Resource/GovernmentMessage/ReplyB10Breach.tres")
const REPLY_B11_KEPT = preload("res://Resource/GovernmentMessage/ReplyB11Kept.tres")
const REPLY_B11_BREACH = preload("res://Resource/GovernmentMessage/ReplyB11Breach.tres")
const REPLY_B12_KEPT = preload("res://Resource/GovernmentMessage/ReplyB12Kept.tres")
const REPLY_B12_BREACH = preload("res://Resource/GovernmentMessage/ReplyB12Breach.tres")
const REPLY_B13_KEPT = preload("res://Resource/GovernmentMessage/ReplyB13Kept.tres")
const REPLY_B13_BREACH = preload("res://Resource/GovernmentMessage/ReplyB13Breach.tres")
const REPLY_B14_KEPT = preload("res://Resource/GovernmentMessage/ReplyB14Kept.tres")
const REPLY_B14_BREACH = preload("res://Resource/GovernmentMessage/ReplyB14Breach.tres")
const REPLY_B15_KEPT = preload("res://Resource/GovernmentMessage/ReplyB15Kept.tres")
const REPLY_B15_BREACH = preload("res://Resource/GovernmentMessage/ReplyB15Breach.tres")
const REPLY_B16_KEPT = preload("res://Resource/GovernmentMessage/ReplyB16Kept.tres")
const REPLY_B16_BREACH = preload("res://Resource/GovernmentMessage/ReplyB16Breach.tres")
const REPLY_B17_KEPT = preload("res://Resource/GovernmentMessage/ReplyB17Kept.tres")
const REPLY_B17_BREACH = preload("res://Resource/GovernmentMessage/ReplyB17Breach.tres")
const REPLY_B18_KEPT = preload("res://Resource/GovernmentMessage/ReplyB18Kept.tres")
const REPLY_B18_BREACH = preload("res://Resource/GovernmentMessage/ReplyB18Breach.tres")
const REPLY_B19_KEPT = preload("res://Resource/GovernmentMessage/ReplyB19Kept.tres")
const REPLY_B19_BREACH = preload("res://Resource/GovernmentMessage/ReplyB19Breach.tres")
const REPLY_B20_KEPT = preload("res://Resource/GovernmentMessage/ReplyB20Kept.tres")
const REPLY_B20_BREACH = preload("res://Resource/GovernmentMessage/ReplyB20Breach.tres")
const REPLY_B21_KEPT = preload("res://Resource/GovernmentMessage/ReplyB21Kept.tres")
const REPLY_B21_BREACH = preload("res://Resource/GovernmentMessage/ReplyB21Breach.tres")
const REPLY_B22_KEPT = preload("res://Resource/GovernmentMessage/ReplyB22Kept.tres")
const REPLY_B22_BREACH = preload("res://Resource/GovernmentMessage/ReplyB22Breach.tres")
const REPLY_B23_KEPT = preload("res://Resource/GovernmentMessage/ReplyB23Kept.tres")
const REPLY_B23_BREACH = preload("res://Resource/GovernmentMessage/ReplyB23Breach.tres")
const REPLY_B24_KEPT = preload("res://Resource/GovernmentMessage/ReplyB24Kept.tres")
const REPLY_B24_BREACH = preload("res://Resource/GovernmentMessage/ReplyB24Breach.tres")

# event_id -> [履约回信, 违约回信]
const EVENT_REPLIES : Dictionary = {
	"b01_west_rally" : [REPLY_B01_KEPT, REPLY_B01_BREACH],
	"b02_relief_crisis" : [REPLY_B02_KEPT, REPLY_B02_BREACH],
	"b03_league_founded" : [REPLY_B03_KEPT, REPLY_B03_BREACH],
	"b04_notice_board" : [REPLY_B04_KEPT, REPLY_B04_BREACH],
	"b05_evictions" : [REPLY_B05_KEPT, REPLY_B05_BREACH],
	"b06_laborers_rejected" : [REPLY_B06_KEPT, REPLY_B06_BREACH],
	"b07_isolation" : [REPLY_B07_KEPT, REPLY_B07_BREACH],
	"b08_harvest_escort" : [REPLY_B08_KEPT, REPLY_B08_BREACH],
	"b09_shops_closed" : [REPLY_B09_KEPT, REPLY_B09_BREACH],
	"b10_coercion_act" : [REPLY_B10_KEPT, REPLY_B10_BREACH],
	"b11_editor_arrested" : [REPLY_B11_KEPT, REPLY_B11_BREACH],
	"b12_leader_arrested" : [REPLY_B12_KEPT, REPLY_B12_BREACH],
	"b13_ladies_records" : [REPLY_B13_KEPT, REPLY_B13_BREACH],
	"b14_ladies_banned" : [REPLY_B14_KEPT, REPLY_B14_BREACH],
	"b15_no_rent" : [REPLY_B15_KEPT, REPLY_B15_BREACH],
	"b16_land_act" : [REPLY_B16_KEPT, REPLY_B16_BREACH],
	"b17_rumor_talks" : [REPLY_B17_KEPT, REPLY_B17_BREACH],
	"b18_park_assassination" : [REPLY_B18_KEPT, REPLY_B18_BREACH],
	"b19_westport_rally" : [REPLY_B19_KEPT, REPLY_B19_BREACH],
	"b20_new_departure" : [REPLY_B20_KEPT, REPLY_B20_BREACH],
	"b21_american_fund" : [REPLY_B21_KEPT, REPLY_B21_BREACH],
	"b22_election" : [REPLY_B22_KEPT, REPLY_B22_BREACH],
	"b23_ladies_league_founded" : [REPLY_B23_KEPT, REPLY_B23_BREACH],
	"b24_ladies_league_dissolved" : [REPLY_B24_KEPT, REPLY_B24_BREACH],
}
