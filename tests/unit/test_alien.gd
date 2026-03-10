extends GutTest

const AlienScene = preload("res://scenes/alien.tscn")


func _make_alien(t: int = 0) -> Area2D:
	var a := AlienScene.instantiate()
	a.set_type(t)
	add_child_autoqfree(a)
	return a


# --- set_type ---

func test_set_type_0_sets_alien_type_and_points() -> void:
	var alien := _make_alien(0)
	assert_eq(alien.alien_type, 0)
	assert_eq(alien.points, 30)


func test_set_type_1_sets_alien_type_and_points() -> void:
	var alien := _make_alien(1)
	assert_eq(alien.alien_type, 1)
	assert_eq(alien.points, 20)


func test_set_type_2_sets_alien_type_and_points() -> void:
	var alien := _make_alien(2)
	assert_eq(alien.alien_type, 2)
	assert_eq(alien.points, 10)


func test_set_type_clamps_negative_to_0() -> void:
	var alien := _make_alien(-5)
	assert_eq(alien.alien_type, 0)
	assert_eq(alien.points, 30)


func test_set_type_clamps_high_to_2() -> void:
	var alien := _make_alien(99)
	assert_eq(alien.alien_type, 2)
	assert_eq(alien.points, 10)


# --- kill ---

func test_kill_sets_is_dead() -> void:
	var alien := _make_alien(0)
	alien.kill()
	assert_true(alien.is_dead)


func test_kill_emits_killed_signal() -> void:
	var alien := _make_alien(0)
	watch_signals(alien)
	alien.kill()
	assert_signal_emitted(alien, "killed")


func test_kill_emits_killed_with_correct_points() -> void:
	var alien := _make_alien(1)
	watch_signals(alien)
	alien.kill()
	assert_signal_emitted_with_parameters(alien, "killed", [20])


func test_kill_is_idempotent() -> void:
	var alien := _make_alien(0)
	watch_signals(alien)
	alien.kill()
	alien.kill()
	assert_signal_emit_count(alien, "killed", 1)


# --- toggle_frame ---

func test_toggle_frame_swaps_anim_frame_0_to_1() -> void:
	var alien := _make_alien(0)
	assert_eq(alien.anim_frame, 0)
	alien.toggle_frame()
	assert_eq(alien.anim_frame, 1)


func test_toggle_frame_swaps_anim_frame_back_to_0() -> void:
	var alien := _make_alien(0)
	alien.toggle_frame()
	alien.toggle_frame()
	assert_eq(alien.anim_frame, 0)
