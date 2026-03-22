extends Area2D

signal killed(pts: int)

const TYPE_POINTS: Array[int] = [30, 20, 10]
const TYPE_COLORS: Array[Color] = [Color.CYAN, Color.CHARTREUSE, Color.WHITE]

var alien_type: int = 0
var points: int = 30
var is_dead: bool = false
var anim_frame: int = 0

@onready var frame0: Polygon2D = $Frame0
@onready var frame1: Polygon2D = $Frame1


## Call this before add_child — stores type only, colors applied in _ready().
func set_type(t: int) -> void:
	alien_type = clampi(t, 0, 2)
	points = TYPE_POINTS[alien_type]


func _ready() -> void:
	var col := TYPE_COLORS[alien_type]
	frame0.color = col
	frame1.color = col


func toggle_frame() -> void:
	anim_frame = 1 - anim_frame
	frame0.visible = (anim_frame == 0)
	frame1.visible = (anim_frame == 1)


func kill() -> void:
	if is_dead:
		return
	is_dead = true
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	killed.emit(points)
	frame0.visible = true
	frame1.visible = true
	frame0.color = Color.YELLOW
	frame1.color = Color.YELLOW
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 0.0, 0.0), 0.25)
	tween.tween_callback(queue_free)
