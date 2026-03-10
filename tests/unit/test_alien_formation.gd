extends GutTest

const FormationScene = preload("res://scenes/alien_formation.tscn")

const TOTAL = 55  # ROWS * COLS = 5 * 11


# Untyped return so callers can access script-defined properties dynamically.
func _make_formation(wave: int = 1):
	var f = FormationScene.instantiate()
	f.wave = wave
	add_child_autoqfree(f)
	return f


# --- spawn grid ---

func test_spawn_grid_creates_55_aliens() -> void:
	var f = _make_formation()
	assert_eq(f.alive_count, TOTAL)
	assert_eq(f.aliens.size(), TOTAL)


func test_row0_aliens_are_type_0() -> void:
	var f = _make_formation()
	for col in range(11):
		var alien = f.aliens[col]
		assert_eq(alien.alien_type, 0, "row 0 col %d" % col)


func test_row1_aliens_are_type_0() -> void:
	var f = _make_formation()
	for col in range(11):
		var alien = f.aliens[11 + col]
		assert_eq(alien.alien_type, 0, "row 1 col %d" % col)


func test_row2_aliens_are_type_1() -> void:
	var f = _make_formation()
	for col in range(11):
		var alien = f.aliens[22 + col]
		assert_eq(alien.alien_type, 1, "row 2 col %d" % col)


func test_row3_aliens_are_type_1() -> void:
	var f = _make_formation()
	for col in range(11):
		var alien = f.aliens[33 + col]
		assert_eq(alien.alien_type, 1, "row 3 col %d" % col)


func test_row4_aliens_are_type_2() -> void:
	var f = _make_formation()
	for col in range(11):
		var alien = f.aliens[44 + col]
		assert_eq(alien.alien_type, 2, "row 4 col %d" % col)


# --- _recalc_speed ---

func test_recalc_speed_full_wave1_step_interval_is_max() -> void:
	var f = _make_formation(1)
	# ratio = 1.0 → step_interval = clampf(lerpf(0.05, 0.8, 1.0) / 1, 0.04, 1.0) = 0.8
	assert_almost_eq(f.step_interval, 0.8, 0.001)


func test_recalc_speed_one_alien_wave1_step_interval_is_near_min() -> void:
	var f = _make_formation(1)
	f.alive_count = 1
	f._recalc_speed()
	# ratio ≈ 0.018 → step_interval ≈ 0.064, above minimum 0.04
	assert_true(f.step_interval < 0.1)
	assert_true(f.step_interval >= 0.04)


func test_recalc_speed_higher_wave_is_faster() -> void:
	var f1 = _make_formation(1)
	var interval_wave1: float = f1.step_interval

	var f2 = _make_formation(2)
	var interval_wave2: float = f2.step_interval

	assert_true(interval_wave2 < interval_wave1)


# --- _on_alien_killed ---

func test_on_alien_killed_decrements_alive_count() -> void:
	var f = _make_formation()
	f._on_alien_killed(10)
	assert_eq(f.alive_count, TOTAL - 1)


func test_on_alien_killed_emits_alien_killed_with_pts() -> void:
	var f = _make_formation()
	watch_signals(f)
	f._on_alien_killed(30)
	assert_signal_emitted_with_parameters(f, "alien_killed", [30])


func test_on_alien_killed_emits_formation_cleared_when_last() -> void:
	var f = _make_formation()
	f.alive_count = 1
	watch_signals(f)
	f._on_alien_killed(10)
	assert_signal_emitted(f, "formation_cleared")


func test_on_alien_killed_does_not_emit_cleared_when_not_last() -> void:
	var f = _make_formation()
	watch_signals(f)
	f._on_alien_killed(10)
	assert_signal_not_emitted(f, "formation_cleared")


# --- stop ---

func test_stop_sets_is_stopped() -> void:
	var f = _make_formation()
	assert_false(f.is_stopped)
	f.stop()
	assert_true(f.is_stopped)
