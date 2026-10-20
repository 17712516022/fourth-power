extends Node

# 政府动作的数值（自动加载）。


# 通用 · 软手（不分对象）

# 安抚：所有人的怒被压下去，国库跟着瘪。
const CONCILIATE_ANGRY : float = -0.030
const CONCILIATE_COST  : float = 0.032

# 赈济：开仓放粮，先安顿最饿的两家（农民、工人）。
const RELIEF_COST         : float = 0.020
const RELIEF_FARMER_ANGRY : float = -0.024
const RELIEF_WORKER_ANGRY : float = -0.020
const RELIEF_HAPPY        : float = 0.020

# 办实业：拿钱砸工业力（工业力高了，农民不那么怒、兵也更足）。
const INVEST_COST : float = 0.030
const INVEST_GAIN : float = 0.020
const INVEST_HAPPY : float = 0.036

# 扩军：拿钱招兵——士兵的组织度涨，街面上也多一层怕。
const RECRUIT_COST  : float = 0.030
const RECRUIT_POWER : float = 0.030
const RECRUIT_FEAR  : float = 0.054


# 通用 · 硬手（不分对象）

# 弹压：所有人的怕被抬起来，自己的兵一天天磨掉。
const SUPPRESS_ALL_FEAR : float = 0.040
const SUPPRESS_ALL_ARMY : float = 0.040

# 戒严：全城尽是枪——怕涨得更凶，但机器跟着停摆。
const MARTIAL_FEAR     : float = 0.060
const MARTIAL_HAPPY    : float = -0.020
const MARTIAL_INDUSTRY : float = -0.030


# 通用 · 刮钱 / 刮粮（不分对象）

# 征税：国库进一笔，商人与农民记恨——多收的那笔钱本来是他们兜里的。
const TAX_GAIN           : float = 0.030
const TAX_MERCHANT_ANGRY : float = 0.024
const TAX_FARMER_ANGRY   : float = 0.012

# 征粮：粮仓进一笔，怨气记在农民头上。
const REQUISITION_GAIN         : float = 0.030
const REQUISITION_FARMER_ANGRY : float = 0.024


# 农民 · 基底（常态的五只，正常那只与四层共用）

# 正常 → 加收粮食
const COLLECT_GRAIN_GAIN  : float = 0.100
const COLLECT_GRAIN_FEAR  : float = 0.030
const COLLECT_GRAIN_ANGRY : float = 0.048
const COLLECT_GRAIN_HAPPY : float = -0.048

# 抗租 → 减收粮食（少收一笔，换他们这口气松下来）
const REDUCE_GRAIN_LOSS  : float = -0.180
const REDUCE_GRAIN_ANGRY : float = -0.072

# 怠工 → 劝课农桑
const ENCOURAGE_HAPPY : float = 0.072

# 逃亡 → 开展赈济（先把怕按住，他们才肯回来）
const RELIEVE_FEAR : float = -0.090

# 动乱 → 尝试镇压（把人劝散：怒平、怕消、那口气也松了）
const SUPPRESS_HAPPY : float = 0.072
const SUPPRESS_FEAR  : float = -0.090
const SUPPRESS_ANGRY : float = -0.072


# 各档叠的那一层（四家公用）

# 强硬：除"正常"外，每一只都额外磨这么多兵。
const HARDLINE_ARMY        : float = 0.120
# 强硬：动乱 / 哗变那两只额外再打掉这么多组织度。
const HARDLINE_CRUSH_POWER : float = 0.150

# 恐怖：兵磨得更狠（比强硬的 0.120），以及动乱那两只的坏方向。
const TERROR_ARMY           : float = 0.180
const TERROR_CRUSH_POWER    : float = 0.150
const TERROR_UPRISING_HAPPY : float = -0.072

# 保守：除"正常"外，每一只都养回来这么多兵；终局那两只的力气反而涨回来。
const CONSERVATIVE_ARMY      : float = 0.060
const CONSERVATIVE_SURRENDER : float = 0.120

# 无能：兵养得更厚（比保守的 0.060），而且每一只都白丢一笔账。
const INCOMPETENT_ARMY     : float = 0.120
const INCOMPETENT_FOOD     : float = -0.150
const INCOMPETENT_INDUSTRY : float = -0.150
const INCOMPETENT_MONEY    : float = -0.150


# 农民 · 恐怖那一层的坏方向
const TERROR_RESIST_ANGRY   : float = 0.060
const TERROR_SLOWDOWN_FEAR  : float = 0.060
const TERROR_FLEE_ANGRY     : float = 0.060


# 工人 · 基底（常态的五只，正常那只与四层共用）

# 正常 → 摊派工役（和农民的"加收粮食"是一对——那边收粮，这边出货）
const DRAFT_INDUSTRY : float = 0.100
const DRAFT_FEAR     : float = 0.030
const DRAFT_ANGRY    : float = 0.048
const DRAFT_HAPPY    : float = -0.048

# 怠工 → 劝谕上工
const EXHORT_HAPPY : float = 0.072

# 低效 → 以工代赈
const WORK_RELIEF_FEAR  : float = -0.090
const WORK_RELIEF_HAPPY : float = 0.072

# 停工 → 调处工潮
const ARBITRATE_ANGRY : float = -0.072

# 示威 → 劝散聚集
const DISPERSE_ANGRY : float = -0.072
const DISPERSE_FEAR  : float = 0.030

# 动乱 → 尝试镇压（与农民那一只同法，借 SUPPRESS_* 那三只）


# 工人 · 恐怖那一层的坏方向

const TERROR_WORKER_SLOWDOWN_HAPPY   : float = -0.060
const TERROR_WORKER_DEPRESSION_ANGRY : float = 0.060
const TERROR_WORKER_STRIKE_ANGRY     : float = 0.060
const TERROR_WORKER_MARCH_ANGRY      : float = 0.060


# 商人 · 基底（常态的五只，正常那只与四层共用）

# 正常 → 加征商捐
const EXCISE_MONEY : float = 0.100
const EXCISE_FEAR  : float = 0.030
const EXCISE_ANGRY : float = 0.048
const EXCISE_HAPPY : float = -0.020

# 繁荣 → 劝募公债
const BOND_HAPPY : float = -0.072
const BOND_GAIN  : float = 0.060

# 投资 → 保商护业
const PROTECT_FEAR : float = -0.072

# 外逃 → 挽留殷商
const RETAIN_ANGRY : float = -0.072

# 投机 → 查禁囤积
const INSPECT_HAPPY : float = -0.072
const INSPECT_ANGRY : float = 0.030

# 蛀空 → 整顿市面
const RECTIFY_FEAR : float = 0.090


# 商人 · 恐怖那一层的坏方向

const TERROR_MERCHANT_PROSPERITY_HAPPY : float = -0.060
const TERROR_MERCHANT_INVEST_FEAR      : float = -0.060
# （投资那条线只读"怕"，且是**反着**的：怕 > 0.6 回正常、怕 < 0.4 去投机。
const TERROR_MERCHANT_ABROAD_HAPPY     : float = -0.060
const TERROR_MERCHANT_SPECULATE_FEAR   : float = -0.060
const TERROR_MERCHANT_HOLLOW_HAPPY     : float = -0.060


# 士兵 · 基底（常态的五只，正常那只与四层共用）

# 正常 → 点验充伍（钱变成兵，兵又推高"好战"）
const MUSTER_POWER : float = 0.060
const MUSTER_COST  : float = 0.060
const MUSTER_FEAR  : float = 0.030

# 腐败 → 饬令操演
const DRILL_ANGRY : float = 0.072

# 溃散 → 补发欠饷
const PAY_HAPPY : float = 0.072
const PAY_COST  : float = 0.060

# 扰民 → 申明军法
const ARMY_LAW_FEAR : float = 0.072

# 哗变 → 招抚收心（三样一起抬回来）
const PACIFY_HAPPY : float = 0.090
const PACIFY_FEAR  : float = 0.072
const PACIFY_ANGRY : float = 0.072


# 士兵 · 恐怖那一层的坏方向

const TERROR_SOLDIER_CORRUPT_ANGRY : float = -0.060
const TERROR_SOLDIER_DESERT_HAPPY  : float = -0.060
const TERROR_SOLDIER_RAMPAGE_FEAR  : float = -0.060
