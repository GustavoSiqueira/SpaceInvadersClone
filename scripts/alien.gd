extends Area2D

signal killed(pts: int)

const TYPE_POINTS: Array[int] = [30, 20, 10]
const ALIEN_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/alien_a.png"),
	preload("res://assets/sprites/alien_b.png"),
	preload("res://assets/sprites/alien_c.png"),
]
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")

var alien_type: int = 0
var points: int = 30
var is_dead: bool = false
var anim_frame: int = 0

@onready var sprite: Sprite2D = $Sprite


## Call this before add_child — stores type only, texture applied in _ready().
func set_type(t: int) -> void:
	alien_type = clampi(t, 0, 2)
	points = TYPE_POINTS[alien_type]


func _ready() -> void:
	sprite.texture = ALIEN_TEXTURES[alien_type]
	sprite.frame = 0


func toggle_frame() -> void:
	anim_frame = 1 - anim_frame
	sprite.frame = anim_frame


func kill() -> void:
	if is_dead:
		return
	is_dead = true
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	killed.emit(points)
	Explosion.spawn(EXPLOSION_SCENE, self)
	sprite.modulate = Color.YELLOW
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 0.0, 0.0), 0.25)
	tween.tween_callback(queue_free)
