class_name RawMaterialAnimation extends RefCounted

# 替身用的场景。
const FLYER_SCENE = preload("res://Scene/RawMaterial.tscn")

# 素材卡的两种"飞"：都落在池子里，但**起点不一样**。

# ① 入场
const DURATION : float = 0.45
const START_SCALE : float = 2.4
const START_ROTATION : float = -0.55
const ARC_HEIGHT : float = 150.0
const FADE_IN_TIME : float = 0.12

# ② 退回
const BACK_DURATION : float = 0.35
const BACK_ARC_HEIGHT : float = 55.0

# 给一张**刚进池子**的卡片播入场动画（从屏幕中央飞进去）。
static func play(card : RawMaterial, container : Container, delay : float = 0.0) -> void:
	if card == null or container == null:
		return
		# 起点：屏幕中央，放大了 START_SCALE 倍、歪着——具体多大由替身自己量，见 _flight。
	_flight(card, container, _screen_center(card), Vector2.ONE * START_SCALE,
		START_ROTATION, ARC_HEIGHT, DURATION, delay)

# 给一张**从版位上换下来的**卡片播退回动画（从版位那一格飞回池子）。
static func play_back(card : RawMaterial, container : Container,
		from_center : Vector2, from_scale : Vector2, delay : float = 0.0) -> void:
	if card == null or container == null:
		return
		# 不歪：它本来就在版面上摆得端端正正，飞回池子也没有翻滚的道理。
	_flight(card, container, from_center, from_scale, 0.0, BACK_ARC_HEIGHT, BACK_DURATION, delay)

# 两种"飞"共用的那一段。
static func _flight(card : RawMaterial, container : Container,
		from_center : Vector2, from_scale : Vector2,
		rotation : float, arc : float, duration : float, delay : float) -> void:
	var layer : Control = _flight_layer(container)
	if layer == null:
		return
	
	card.modulate.a = 0.0
	
	# 容器的布局是**延迟重排**的：这一帧卡片还没有尺寸、也不知道自己会被排到哪，。
	await card.get_tree().process_frame
	if not is_instance_valid(card):
		return
	
	# 替身：另做一个同样的卡片，内容和颜色都照着真卡片抄。
	var flyer : RawMaterial = FLYER_SCENE.instantiate()
	flyer.is_fake = card.is_fake
	flyer.setup(card.res)
	flyer.modulate.a = 0.0
	flyer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(flyer)
	flyer.pivot_offset = flyer.size * 0.5
	
	# 起手姿态：先摆好，免得第一帧闪到左上角。
	flyer.scale = from_scale
	flyer.rotation = rotation
	flyer.position = _to_layer(layer, from_center) - flyer.pivot_offset
	
	var half : Vector2 = flyer.pivot_offset
	var from : Vector2 = _to_layer(layer, from_center)
	
	var tween : Tween = flyer.create_tween()
	if delay > 0.0:
		tween.tween_interval(delay)
	tween.tween_property(flyer, "modulate:a", 1.0, FADE_IN_TIME)
	
	tween.set_parallel(true)
	tween.tween_property(flyer, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(flyer, "rotation", 0.0, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# 位置每帧现算：飞行途中池子可能滚动、别的卡片可能把目标挤开，。
	tween.tween_method(func(t : float):
		if not is_instance_valid(card):
			return
		var to : Vector2 = _to_layer(layer, card.get_global_rect().get_center())
		var at : Vector2 = from.lerp(to, t)
		at.y -= sin(t * PI) * arc
		flyer.position = at - half
	, 0.0, 1.0, duration)
	
	tween.chain().tween_callback(func():
		flyer.queue_free()
		if is_instance_valid(card):
			card.modulate.a = 1.0
	)

# 屏幕中央（这一帧的画布坐标）。
static func _screen_center(node : CanvasItem) -> Vector2:
	return node.get_viewport().get_visible_rect().size * 0.5

# 把画布坐标换算成某一层内部的坐标（飞行层和卡片在同一个 CanvasLayer 里，。
static func _to_layer(layer : Control, global_point : Vector2) -> Vector2:
	return layer.get_global_transform().affine_inverse() * global_point

# 沿着父链一路往上，取最外层那个 Control：它在滚动框之外，飞起来不会被裁掉。
static func _flight_layer(container : Control) -> Control:
	var node : Control = container
	while node.get_parent() is Control:
		node = node.get_parent()
	return node
