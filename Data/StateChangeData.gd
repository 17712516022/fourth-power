extends Node

# 状态的静态数据（自动加载）。


# 农民 Farmers

# 常态出发
const farmerNormalResistTransportNeed : float = 0.72
const farmerNormalFleeTransportNeed : float = 0.34
const farmerNormalSlowdownTransportNeed : float = 0.66

# 怠工出发
const farmerSlowdownFleeTransportNeed : float = 0.40
const farmerSlowdownNormalTransportNeed : float = 0.72

# 抗租出发
const farmerResistUpRisingTransportNeed : float = 0.90
const farmerResistNormalTransportNeed : float = 0.62

# 逃亡出发
const farmerFleeUpRisingTransportNeed : float = 0.90
const farmerFleeNormalTransportNeed : float = 0.26

# 动乱出发（回常态要三条一起成立）
const farmerUpRisingNormalHappyNeed : float = 0.75
const farmerUpRisingNormalFearNeed : float = 0.50
const farmerUpRisingNormalAngryNeed : float = 0.50

# 产出倍数：地里还剩多少人——正常全产，抗租只少一点（地还在种），。
const farmerNormalYieldMultiple : float = 1.0
const farmerSlowdownYieldMultiple : float = 0.8
const farmerFleeYieldMultiple : float = 0.6
const farmerResistYieldMultiple : float = 0.9
const farmerUpRisingYieldMultiple : float = 0.3


# 工人 Workers

# 常态出发
const workerNormalSlowdownTransportNeed : float = 0.70
const workerNormalDepressionTransportNeed : float = 0.62
const workerNormalStrikeTransportNeed : float = 0.47

# 怠工出发
const workerSlowdownNormalTransportNeed : float = 0.80
const workerSlowdownDepressionTransportNeed : float = 0.60

# 低效出发
const workerDepressionNormalTransportNeed : float = 0.52
const workerDepressionUpRisingTransportNeed : float = 0.62

# 停工出发
const workerStrikeNormalTransportNeed : float = 0.39
const workerStrikeMarchTransportNeed : float = 0.62

# 示威出发
const workerMarchUpRisingTransportNeed : float = 0.85
const workerMarchNormalHappyNeed : float = 0.75
const workerMarchNormalFearNeed : float = 0.60
const workerMarchNormalAngryNeed : float = 0.55

# 动乱出发（回常态要三条一起成立）
const workerUpRisingNormalHappyNeed : float = 0.80
const workerUpRisingNormalFearNeed : float = 0.60
const workerUpRisingNormalAngryNeed : float = 0.55

# 产出倍数：厂里还剩多少人在动手——正常全速，怠工磨洋工，。
const workerNormalYieldMultiple : float = 1.0
const workerSlowdownYieldMultiple : float = 0.8
const workerDepressionYieldMultiple : float = 0.4
const workerStrikeYieldMultiple : float = 0.6
const workerMarchYieldMultiple : float = 0.5
const workerUpRisingYieldMultiple : float = 0.2


# 商人 Merchants

# 常态出发
const merchantNormalProsperityTransportNeed : float = 0.50
const merchantNormalInvestTransportNeed : float = 0.84
const merchantNormalAbroadTransportNeed : float = 0.61

# 繁荣出发
const merchantProsperitySpeculateTransportNeed : float = 0.75
const merchantProsperityNormalTransportNeed : float = 0.40

# 投资出发
const merchantInvestSpeculateTransportNeed : float = 0.55
const merchantInvestNormalTransportNeed : float = 0.94

# 投机出发
const merchantSpeculateHollowTransportNeed : float = 0.45

# 蛀空出发（回常态要两条一起成立）
const merchantHollowNormalHappyNeed : float = 0.25
const merchantHollowNormalFearNeed : float = 0.45

# 外逃出发
const merchantAbroadNormalTransportNeed : float = 0.51

# 产出倍数：这个埠上还收得上多少税——繁荣、投资两头最旺，。
const merchantNormalYieldMultiple : float = 1.0
const merchantProsperityYieldMultiple : float = 1.2
const merchantInvestYieldMultiple : float = 1.3
const merchantSpeculateYieldMultiple : float = 0.8
const merchantHollowYieldMultiple : float = 0.3
const merchantAbroadYieldMultiple : float = 0.6


# 士兵 Soldier

# 常态出发（三条线都要够得着：怒 0.50 / 怕 0.75 / 乐 0.55）
const soldierNormalDesertTransportNeed : float = 0.60
const soldierNormalRampageTransportNeed : float = 0.75
const soldierNormalCorruptTransportNeed : float = 0.55

# 溃散出发
const soldierDesertMutinyTransportNeed : float = 0.42
const soldierDesertNormalTransportNeed : float = 0.70

# 扰民出发
const soldierRampageMutinyTransportNeed : float = 0.45
const soldierRampageNormalTransportNeed : float = 0.90

# 腐败出发
const soldierCorruptRampageTransportNeed : float = 0.70
const soldierCorruptNormalTransportNeed : float = 0.55

# 兵变出发（回常态要三条一起成立）
const soldierMutinyNormalHappyNeed : float = 0.60
const soldierMutinyNormalFearNeed : float = 0.50
const soldierMutinyNormalAngryNeed : float = 0.50

# 产出倍数（枪杆子的成色）
const soldierNormalYieldMultiple : float = 1.0
const soldierDesertYieldMultiple : float = 0.5
const soldierRampageYieldMultiple : float = 0.75
const soldierCorruptYieldMultiple : float = 0.85
const soldierMutinyYieldMultiple : float = 0.2


# 稳定度系数（四个群体）

const farmerNormalStabilityCoef : float = 0.0
const farmerSlowdownStabilityCoef : float = 1.0
const farmerResistStabilityCoef : float = 1.0
const farmerFleeStabilityCoef : float = 1.0
const farmerUpRisingStabilityCoef : float = 2.0

const workerNormalStabilityCoef : float = 0.0
const workerSlowdownStabilityCoef : float = 1.0
const workerDepressionStabilityCoef : float = 1.0
const workerStrikeStabilityCoef : float = 1.0
const workerMarchStabilityCoef : float = 2.0
const workerUpRisingStabilityCoef : float = 3.0

const merchantNormalStabilityCoef : float = 0.0
const merchantProsperityStabilityCoef : float = -1.0
const merchantInvestStabilityCoef : float = -1.0
const merchantAbroadStabilityCoef : float = 1.0
const merchantSpeculateStabilityCoef : float = 2.0
const merchantHollowStabilityCoef : float = 3.0

const soldierNormalStabilityCoef : float = 0.0
const soldierCorruptStabilityCoef : float = 1.0
const soldierDesertStabilityCoef : float = 1.0
const soldierRampageStabilityCoef : float = 1.0
const soldierMutinyStabilityCoef : float = 2.0


# 政府 Government

# 好战的那五道线（成对出现：进线在外、回线在内，中间 0.10 是迟滞带）
const governmentNormalHardlineBelligerenceNeed : float = 0.58
const governmentHardlineNormalBelligerenceNeed : float = 0.50
const governmentHardlineTerrorBelligerenceNeed : float = 0.72
const governmentTerrorHardlineBelligerenceNeed : float = 0.64
const governmentNormalConservativeBelligerenceNeed : float = 0.42
const governmentConservativeNormalBelligerenceNeed : float = 0.50
const governmentConservativeIncompetentBelligerenceNeed : float = 0.32
const governmentIncompetentConservativeBelligerenceNeed : float = 0.40

# 崩溃那条线（只从恐怖 / 无能各自单向出去）
const governmentCollapseStabilityNeed : float = 6.0
