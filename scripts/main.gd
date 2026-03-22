extends Node2D

const ALIEN_FORMATION_SCENE = preload("res://scenes/alien_formation.tscn")
const UFO_SCENE = preload("res://scenes/ufo.tscn")
const SHIELD_SCENE = preload("res://scenes/shield.tscn")
const OPTIONS_SCENE = preload("res://scenes/options_screen.tscn")

@onready var player: CharacterBody2D = $Player
@onready var player_bullets: Node2D = $PlayerBullets
@onready var enemy_bullets: Node2D = $EnemyBullets
@onready var shields: Node2D = $Shields
@onready var hud: CanvasLayer = $HUD
@onready var ufo_timer: Timer = $UFOTimer

const HI_SCORE_PATH := "user://hi_score.cfg"
const HI_SCORE_SECTION := "scores"
const HI_SCORE_KEY := "hi_score"

var score: int = 0
var hi_score: int = 0
var lives: int = 3
var wave: int = 1
var formation: Node2D = null
var ufo: Area2D = null
var game_active: bool = true
var is_paused: bool = false


func _load_hi_score() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(HI_SCORE_PATH) == OK:
		hi_score = cfg.get_value(HI_SCORE_SECTION, HI_SCORE_KEY, 0)


func _save_hi_score() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(HI_SCORE_SECTION, HI_SCORE_KEY, hi_score)
	cfg.save(HI_SCORE_PATH)


func _setup_input_actions() -> void:
	Settings.load()
	for action in ["move_left", "move_right", "shoot", "restart", "pause"]:
		_map_key_action(action, Settings.get_keycode(action))


func _map_key_action(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.keycode = keycode
	InputMap.action_add_event(action, event)


func _ready() -> void:
	_setup_input_actions()
	_load_hi_score()
	hud.update_score(score, hi_score)
	player.bullets_container = player_bullets
	player.player_hit.connect(_on_player_hit)
	ufo_timer.timeout.connect(_on_ufo_timer_timeout)
	hud.pause_toggled.connect(_toggle_pause)
	hud.options_requested.connect(_on_options_requested)
	hud.exit_requested.connect(func(): get_tree().quit())
	_create_boundaries()
	_spawn_shields()
	_spawn_formation()
	_reset_ufo_timer()


func _create_boundaries() -> void:
	_add_boundary(Vector2(400.0, -10.0), Vector2(840.0, 20.0))
	_add_boundary(Vector2(400.0, 610.0), Vector2(840.0, 20.0))


func _add_boundary(pos: Vector2, size: Vector2) -> void:
	var a := Area2D.new()
	a.collision_layer = 64
	a.collision_mask = 0
	a.monitorable = true
	a.monitoring = false
	a.position = pos
	a.add_to_group("boundary")
	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = size
	cs.shape = rs
	a.add_child(cs)
	add_child(a)


func _spawn_shields() -> void:
	var xs := [148, 278, 408, 538]
	for x in xs:
		var s := SHIELD_SCENE.instantiate()
		s.position = Vector2(x, 455)
		shields.add_child(s)


func _spawn_formation() -> void:
	if formation and is_instance_valid(formation):
		formation.queue_free()
	formation = ALIEN_FORMATION_SCENE.instantiate()
	formation.position = Vector2(50.0, 80.0)
	formation.wave = wave
	formation.enemy_bullets_container = enemy_bullets
	formation.alien_killed.connect(_on_alien_killed)
	formation.formation_cleared.connect(_on_formation_cleared)
	formation.aliens_reached_bottom.connect(_on_aliens_reached_bottom)
	add_child(formation)


func _reset_ufo_timer() -> void:
	ufo_timer.wait_time = randf_range(15.0, 30.0)
	ufo_timer.start()


func _on_ufo_timer_timeout() -> void:
	if ufo == null or not is_instance_valid(ufo):
		_spawn_ufo()
	_reset_ufo_timer()


func _spawn_ufo() -> void:
	ufo = UFO_SCENE.instantiate()
	ufo.direction = 1 if randf() > 0.5 else -1
	ufo.position = Vector2(-20.0 if ufo.direction > 0 else 820.0, 40.0)
	ufo.ufo_destroyed.connect(_on_ufo_destroyed)
	ufo.ufo_exited.connect(func(): ufo = null)
	add_child(ufo)


func _on_ufo_destroyed(pts: int) -> void:
	ufo = null
	_add_score(pts)


func _on_alien_killed(pts: int) -> void:
	_add_score(pts)


func _add_score(pts: int) -> void:
	score += pts
	if score > hi_score:
		hi_score = score
		_save_hi_score()
	hud.update_score(score, hi_score)


func _on_formation_cleared() -> void:
	if not game_active:
		return
	wave += 1
	await get_tree().create_timer(2.0).timeout
	for child in shields.get_children():
		child.queue_free()
	await get_tree().process_frame
	_spawn_shields()
	_spawn_formation()


func _on_aliens_reached_bottom() -> void:
	_kill_player()


func _on_player_hit() -> void:
	_kill_player()


func _kill_player() -> void:
	if not game_active:
		return
	lives -= 1
	hud.update_lives(lives)
	if lives <= 0:
		_game_over()
		return
	await get_tree().create_timer(2.0).timeout
	if game_active:
		player.respawn()


func _game_over() -> void:
	game_active = false
	if formation and is_instance_valid(formation):
		formation.stop()
	hud.show_game_over()


func _input(event: InputEvent) -> void:
	if not game_active and event.is_action_pressed("restart"):
		_restart_game()


func _toggle_pause() -> void:
	if not game_active:
		return
	is_paused = not is_paused
	get_tree().paused = is_paused
	if is_paused:
		hud.show_pause()
	else:
		hud.hide_pause()


func _on_options_requested() -> void:
	hud.hide_pause()
	var opts = OPTIONS_SCENE.instantiate()
	opts.overlay_mode = true
	opts.closed.connect(func():
		opts.queue_free()
		hud.show_pause()
	)
	hud.add_child(opts)


func _restart_game() -> void:
	if is_paused:
		is_paused = false
		get_tree().paused = false
	# Reset state
	score = 0
	lives = 3
	wave = 1
	game_active = true

	# Clear bullets
	for b in player_bullets.get_children():
		b.queue_free()
	for b in enemy_bullets.get_children():
		b.queue_free()

	# Clear UFO
	if ufo and is_instance_valid(ufo):
		ufo.queue_free()
	ufo = null

	# Rebuild shields
	for s in shields.get_children():
		s.queue_free()
	await get_tree().process_frame
	_spawn_shields()

	# Respawn player
	player.respawn()

	# Spawn fresh formation
	_spawn_formation()
	_reset_ufo_timer()

	# Update HUD
	hud.update_score(score, hi_score)
	hud.update_lives(lives)
	hud.hide_game_over()
	hud.hide_pause()
