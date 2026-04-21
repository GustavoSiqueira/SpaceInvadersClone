extends Node2D

signal alien_killed(pts: int)
signal formation_cleared
signal aliens_reached_bottom

const ALIEN_SCENE = preload("res://scenes/alien.tscn")
const ENEMY_BULLET_SCENE = preload("res://scenes/enemy_bullet.tscn")

const COLS = 11
const ROWS = 5
const SPACING_X = 96.0
const SPACING_Y = 80.0
const STEP_X = 22.0
const DROP_Y = 32.0
const ALIEN_WIDTH = 48.0  # matches collision shape

## Set before adding to tree.
var wave: int = 1
var enemy_bullets_container: Node2D = null

var direction: int = 1
var alive_count: int = 0
var aliens: Array = []
var step_timer: float = 0.0
var shoot_timer: float = 0.0
var step_interval: float = 0.8
var shoot_interval: float = 2.0
var is_stopped: bool = false


func _ready() -> void:
	_spawn_grid()
	_recalc_speed()


func _spawn_grid() -> void:
	for row in range(ROWS):
		for col in range(COLS):
			var a := ALIEN_SCENE.instantiate()
			var t: int
			if row <= 1:
				t = 0
			elif row <= 3:
				t = 1
			else:
				t = 2
			a.set_type(t)
			a.position = Vector2(col * SPACING_X, row * SPACING_Y)
			a.add_to_group("alien")
			a.killed.connect(_on_alien_killed)
			add_child(a)
			aliens.append(a)
	alive_count = ROWS * COLS


func _recalc_speed() -> void:
	var ratio := float(alive_count) / float(ROWS * COLS)
	step_interval = clampf(lerpf(0.05, 0.8, ratio) / float(wave), 0.04, 1.0)
	shoot_interval = clampf(lerpf(0.4, 2.5, ratio), 0.3, 3.0)


func _physics_process(delta: float) -> void:
	if is_stopped:
		return
	step_timer += delta
	shoot_timer += delta
	if step_timer >= step_interval:
		step_timer = 0.0
		_step()
	if shoot_timer >= shoot_interval:
		shoot_timer = 0.0
		_try_shoot()


func _step() -> void:
	for a in aliens:
		if is_instance_valid(a) and not a.is_dead:
			a.toggle_frame()

	position.x += STEP_X * direction

	var left := _leftmost_x() + position.x
	var right := _rightmost_x() + position.x

	if (direction > 0 and right >= 1540.0) or (direction < 0 and left <= 40.0):
		direction *= -1
		position.y += DROP_Y
		_check_bottom()


func _leftmost_x() -> float:
	var mx := INF
	for a in aliens:
		if is_instance_valid(a) and not a.is_dead:
			mx = min(mx, a.position.x)
	return mx if mx < INF else 0.0


func _rightmost_x() -> float:
	var mx := -INF
	for a in aliens:
		if is_instance_valid(a) and not a.is_dead:
			mx = max(mx, a.position.x)
	return (mx + ALIEN_WIDTH) if mx > -INF else 0.0


func _check_bottom() -> void:
	for a in aliens:
		if is_instance_valid(a) and not a.is_dead:
			if a.global_position.y >= 980.0:
				aliens_reached_bottom.emit()
				return


func _try_shoot() -> void:
	if enemy_bullets_container == null:
		return
	# Collect the bottom-most alien per column.
	var by_col: Dictionary = {}
	for a in aliens:
		if is_instance_valid(a) and not a.is_dead:
			var col := int(round(a.position.x / SPACING_X))
			if not by_col.has(col) or a.position.y > by_col[col].position.y:
				by_col[col] = a
	var shooters := by_col.values()
	if shooters.is_empty():
		return
	var shooter: Area2D = shooters[randi() % shooters.size()]
	var bullet := ENEMY_BULLET_SCENE.instantiate()
	bullet.global_position = shooter.global_position + Vector2(ALIEN_WIDTH * 0.5, ALIEN_WIDTH * 0.5)
	enemy_bullets_container.add_child(bullet)


func _on_alien_killed(pts: int) -> void:
	alive_count -= 1
	alien_killed.emit(pts)
	_recalc_speed()
	if alive_count <= 0:
		formation_cleared.emit()


func stop() -> void:
	is_stopped = true
