extends GutTest


func before_each() -> void:
	Settings._reset_for_test()


# --- Default values ---

func test_default_move_left() -> void:
	Settings.load()
	assert_eq(Settings.get_keycode("move_left"), KEY_LEFT)


func test_default_move_right() -> void:
	Settings.load()
	assert_eq(Settings.get_keycode("move_right"), KEY_RIGHT)


func test_default_shoot() -> void:
	Settings.load()
	assert_eq(Settings.get_keycode("shoot"), KEY_SPACE)


func test_default_pause() -> void:
	Settings.load()
	assert_eq(Settings.get_keycode("pause"), KEY_ESCAPE)


func test_default_restart() -> void:
	Settings.load()
	assert_eq(Settings.get_keycode("restart"), KEY_F5)


func test_default_crt_enabled_is_true() -> void:
	Settings.load()
	assert_true(Settings.get_crt_enabled())


# --- Keycode mutation ---

func test_set_keycode_updates_value() -> void:
	Settings.load()
	Settings.set_keycode("shoot", KEY_Z)
	assert_eq(Settings.get_keycode("shoot"), KEY_Z)


func test_set_keycode_does_not_affect_other_actions() -> void:
	Settings.load()
	Settings.set_keycode("shoot", KEY_Z)
	assert_eq(Settings.get_keycode("move_left"), KEY_LEFT)
	assert_eq(Settings.get_keycode("move_right"), KEY_RIGHT)
	assert_eq(Settings.get_keycode("pause"), KEY_ESCAPE)
	assert_eq(Settings.get_keycode("restart"), KEY_F5)


# --- CRT mutation ---

func test_set_crt_enabled_false() -> void:
	Settings.load()
	Settings.set_crt_enabled(false)
	assert_false(Settings.get_crt_enabled())


func test_set_crt_enabled_true_after_false() -> void:
	Settings.load()
	Settings.set_crt_enabled(false)
	Settings.set_crt_enabled(true)
	assert_true(Settings.get_crt_enabled())


# --- Idempotency ---

func test_load_is_idempotent_preserves_mutation() -> void:
	Settings.load()
	Settings.set_keycode("shoot", KEY_A)
	Settings.load()  # second call must be a no-op
	assert_eq(Settings.get_keycode("shoot"), KEY_A)


# --- Save / reload round-trips ---

func test_save_and_reload_keycode() -> void:
	Settings.load()
	Settings.set_keycode("move_left", KEY_A)
	Settings.save()
	Settings._reset_for_test()
	Settings.load()
	assert_eq(Settings.get_keycode("move_left"), KEY_A)
	# Restore default so subsequent runs are unaffected
	Settings.set_keycode("move_left", KEY_LEFT)
	Settings.save()


func test_save_and_reload_crt_disabled() -> void:
	Settings.load()
	Settings.set_crt_enabled(false)
	Settings.save()
	Settings._reset_for_test()
	Settings.load()
	assert_false(Settings.get_crt_enabled())
	# Restore default
	Settings.set_crt_enabled(true)
	Settings.save()
