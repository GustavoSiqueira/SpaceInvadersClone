extends GutTest

const TitleScene = preload("res://scenes/title_screen.tscn")


func _make_title_screen():
	var ts = TitleScene.instantiate()
	add_child_autoqfree(ts)
	return ts


func test_scene_instantiates_without_error() -> void:
	var ts = _make_title_screen()
	assert_not_null(ts)


func test_root_is_control() -> void:
	var ts = _make_title_screen()
	assert_true(ts is Control)


func test_new_game_button_exists() -> void:
	var ts = _make_title_screen()
	var btn = ts.get_node("MenuArea/MenuContainer/NewGameButton")
	assert_not_null(btn)


func test_options_button_exists() -> void:
	var ts = _make_title_screen()
	var btn = ts.get_node("MenuArea/MenuContainer/OptionsButton")
	assert_not_null(btn)


func test_exit_button_exists() -> void:
	var ts = _make_title_screen()
	var btn = ts.get_node("MenuArea/MenuContainer/ExitButton")
	assert_not_null(btn)


func test_title_label_exists_with_correct_text() -> void:
	var ts = _make_title_screen()
	var lbl = ts.get_node("LogoArea/TitleLabel")
	assert_not_null(lbl)
	assert_eq(lbl.text, "SPACE INVADERS")


func test_new_game_button_is_not_disabled() -> void:
	var ts = _make_title_screen()
	var btn = ts.get_node("MenuArea/MenuContainer/NewGameButton")
	assert_false(btn.disabled)


func test_options_button_is_enabled() -> void:
	var ts = _make_title_screen()
	var btn = ts.get_node("MenuArea/MenuContainer/OptionsButton")
	assert_false(btn.disabled)


func test_script_has_on_new_game_pressed_method() -> void:
	var ts = _make_title_screen()
	assert_true(ts.has_method("_on_new_game_pressed"))


func test_script_has_on_exit_pressed_method() -> void:
	var ts = _make_title_screen()
	assert_true(ts.has_method("_on_exit_pressed"))


func test_new_game_button_has_focus_after_ready() -> void:
	var ts = _make_title_screen()
	var btn = ts.get_node("MenuArea/MenuContainer/NewGameButton")
	assert_true(btn.has_focus())
