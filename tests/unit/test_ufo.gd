extends GutTest

const UfoScene = preload("res://scenes/ufo.tscn")

const VALID_POINT_VALUES = [50, 100, 150, 300]


func _make_ufo(dir: int = 1) -> Area2D:
	var u := UfoScene.instantiate()
	u.direction = dir
	add_child_autoqfree(u)
	return u


# --- hit ---

func test_hit_sets_is_hit() -> void:
	var ufo := _make_ufo()
	ufo.hit()
	assert_true(ufo.is_hit)


func test_hit_emits_ufo_destroyed() -> void:
	var ufo := _make_ufo()
	watch_signals(ufo)
	ufo.hit()
	assert_signal_emitted(ufo, "ufo_destroyed")


func test_hit_emits_valid_point_value() -> void:
	var ufo := _make_ufo()
	watch_signals(ufo)
	ufo.hit()
	var params: Array = get_signal_parameters(ufo, "ufo_destroyed")
	assert_true(params.size() == 1)
	assert_true(params[0] in VALID_POINT_VALUES, "unexpected pts: %d" % params[0])


func test_hit_is_idempotent() -> void:
	var ufo := _make_ufo()
	watch_signals(ufo)
	ufo.hit()
	ufo.hit()
	assert_signal_emit_count(ufo, "ufo_destroyed", 1)


# --- off-screen ---

func test_ufo_emits_exited_when_off_screen_right() -> void:
	var ufo := _make_ufo(1)
	ufo.position = Vector2(1700.0, 80.0)
	watch_signals(ufo)
	ufo._physics_process(0.016)
	assert_signal_emitted(ufo, "ufo_exited")


func test_ufo_emits_exited_when_off_screen_left() -> void:
	var ufo := _make_ufo(-1)
	ufo.position = Vector2(-100.0, 80.0)
	watch_signals(ufo)
	ufo._physics_process(0.016)
	assert_signal_emitted(ufo, "ufo_exited")
