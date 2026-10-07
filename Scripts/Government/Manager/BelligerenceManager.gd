class_name BelligerenceManager extends RefCounted

# ============================================================
# 好战度 —— 政府的脾气
#
# 长期高压把它推硬，长期太平把它泡软。
#
# 平衡点在 threat = 0.20——**只要骚乱没彻底断根，政府就一天比一天硬。**
# 这条线就是政策分叉的燃料：安抚着安抚着，它自己会翻脸。
# 没有谁逼它，是它自己的脾气涨过了 HARD_LINE。
#
# 这是政府唯一"自己长出来"的东西——其余五项全部来自世界上的别人。
# ============================================================

var value : float = 0.40

const GAIN  : float = 0.020   # 骚乱把脾气推硬的速度
const DECAY : float = 0.004   # 太平把脾气泡软的速度


func update(threat : float) -> void:
	value = clampf(value + threat * GAIN - DECAY, 0.0, 1.0)
