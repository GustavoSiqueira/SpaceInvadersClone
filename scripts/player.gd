extends CharacterBody2D

signal player_hit

const SPEED = 300.0
const BULLET_SCENE = preload("res://scenes/player_bullet.tscn")

## Injected by main.gd after scene is ready.
var bullets_container: Node2D = null

var is_alive: bool = true

@onready var sprite: Polygon2D = $Sprite


func _ready() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	var dir := int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	# Direct position update — no gravity or wall collisions needed.
	position.x += dir * SPEED * delta
	position.x = clampf(position.x, 24.0, 776.0)

	if Input.is_action_just_pressed("ui_accept"):
		_shoot()


func _shoot() -> void:
	if bullets_container == null or bullets_container.get_child_count() > 0:
		return
	var b := BULLET_SCENE.instantiate()
	b.global_position = global_position + Vector2(0.0, -20.0)
	bullets_container.add_child(b)


func hit() -> void:
	if not is_alive:
		return
	is_alive = false
	sprite.color = Color.RED
	player_hit.emit()


func respawn() -> void:
	is_alive = true
	position.x = 400.0
	sprite.color = Color.WHITE
