class_name Explosion
extends Sprite2D

## Generic sprite-sheet explosion. Advances through hframes on a timer,
## queue_frees after the last frame. Used by both alien.kill() (3 frames)
## and player.hit() (2 frames) — frame count is inferred from the Sprite2D.

@export var frame_duration: float = 0.08

var _timer: Timer


## Instantiate `scene` at `entity`'s global position, parented to the entity's
## parent so the effect outlives `entity.queue_free()`. No-op if `entity` is
## already detached.
static func spawn(scene: PackedScene, entity: Node2D) -> void:
	var parent := entity.get_parent()
	if parent == null:
		return
	var ex := scene.instantiate()
	parent.add_child(ex)
	ex.global_position = entity.global_position


func _ready() -> void:
	frame = 0
	_timer = Timer.new()
	_timer.one_shot = false
	_timer.wait_time = frame_duration
	_timer.timeout.connect(_on_timeout)
	add_child(_timer)
	_timer.start()


func _on_timeout() -> void:
	if frame + 1 >= hframes:
		queue_free()
	else:
		frame += 1
