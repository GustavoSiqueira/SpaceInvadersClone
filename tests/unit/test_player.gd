extends GutTest

const PlayerScene = preload("res://scenes/player.tscn")


func _make_player() -> CharacterBody2D:
	var p := PlayerScene.instantiate()
	add_child_autoqfree(p)
	return p


# --- hit ---

func test_hit_sets_is_alive_false() -> void:
	var player := _make_player()
	player.hit()
	assert_false(player.is_alive)


func test_hit_emits_player_hit_signal() -> void:
	var player := _make_player()
	watch_signals(player)
	player.hit()
	assert_signal_emitted(player, "player_hit")


func test_hit_is_idempotent() -> void:
	var player := _make_player()
	watch_signals(player)
	player.hit()
	player.hit()
	assert_signal_emit_count(player, "player_hit", 1)


func test_hit_starts_tween() -> void:
	var player := _make_player()
	player.hit()
	assert_not_null(player._hit_tween)


# --- respawn ---

func test_respawn_sets_is_alive_true() -> void:
	var player := _make_player()
	player.hit()
	player.respawn()
	assert_true(player.is_alive)


func test_respawn_resets_position_x() -> void:
	var player := _make_player()
	player.position.x = 100.0
	player.respawn()
	assert_almost_eq(player.position.x, 800.0, 0.001)


func test_respawn_clears_tween_and_resets_modulate() -> void:
	var player := _make_player()
	player.hit()
	player.respawn()
	assert_null(player._hit_tween)
	assert_eq(player.get_node("Sprite").modulate, Color.WHITE)


# --- _shoot ---

func test_shoot_with_empty_container_spawns_bullet() -> void:
	var player := _make_player()
	var container := Node2D.new()
	add_child_autoqfree(container)
	player.bullets_container = container
	player._shoot()
	assert_eq(container.get_child_count(), 1)


func test_shoot_with_existing_bullet_does_not_spawn_another() -> void:
	var player := _make_player()
	var container := Node2D.new()
	add_child_autoqfree(container)
	player.bullets_container = container
	player._shoot()
	player._shoot()
	assert_eq(container.get_child_count(), 1)
