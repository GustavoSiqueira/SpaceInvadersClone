extends Node2D

const COLS = 8
const ROWS = 4
const SEG = 8  # pixels per segment


func _ready() -> void:
	_build()


func _build() -> void:
	for row in range(ROWS):
		for col in range(COLS):
			if _is_notch(row, col):
				continue
			add_child(_make_segment(col, row))


func _is_notch(row: int, col: int) -> bool:
	# Arch cutout at bottom-center (classic bunker shape)
	return row >= 2 and col >= 3 and col <= 4


func _make_segment(col: int, row: int) -> Area2D:
	var a := Area2D.new()
	a.collision_layer = 16
	a.collision_mask = 0
	a.monitorable = true
	a.monitoring = false
	a.position = Vector2(col * SEG, row * SEG)
	a.add_to_group("shield_segment")

	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(SEG, SEG)
	cs.shape = rs
	a.add_child(cs)

	var p := Polygon2D.new()
	var h := SEG * 0.5
	p.polygon = PackedVector2Array([
		Vector2(-h, -h), Vector2(h, -h),
		Vector2(h, h), Vector2(-h, h)
	])
	p.color = Color(0.0, 0.8, 0.2, 1.0)
	a.add_child(p)

	return a
