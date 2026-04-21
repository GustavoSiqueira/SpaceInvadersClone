extends Area2D

signal ufo_destroyed(pts: int)
signal ufo_exited

const SPEED = 300.0
const POINT_VALUES: Array[int] = [50, 100, 150, 300]
const EXPLOSION_SCENE = preload("res://scenes/explosion.tscn")

## Set to 1 (right) or -1 (left) before adding to scene tree.
var direction: int = 1
var is_hit: bool = false

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	add_to_group("ufo")


func _physics_process(delta: float) -> void:
	if is_hit:
		return
	position.x += direction * SPEED * delta
	if (direction > 0 and position.x > 1680.0) or (direction < 0 and position.x < -80.0):
		ufo_exited.emit()
		queue_free()


func hit() -> void:
	if is_hit:
		return
	is_hit = true
	var pts: int = POINT_VALUES[randi() % POINT_VALUES.size()]
	ufo_destroyed.emit(pts)
	Explosion.spawn(EXPLOSION_SCENE, self)
	queue_free()
