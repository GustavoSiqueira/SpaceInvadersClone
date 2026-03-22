extends GutTest

const HudScene = preload("res://scenes/hud.tscn")


func _make_hud():
	var hud = HudScene.instantiate()
	add_child_autoqfree(hud)
	return hud


func test_scene_instantiates_without_error() -> void:
	var hud = _make_hud()
	assert_not_null(hud)


func test_pause_panel_hidden_on_ready() -> void:
	var hud = _make_hud()
	var panel = hud.get_node("PausePanel")
	assert_false(panel.visible)


func test_game_over_panel_hidden_on_ready() -> void:
	var hud = _make_hud()
	var panel = hud.get_node("GameOverPanel")
	assert_false(panel.visible)


func test_show_pause_makes_panel_visible() -> void:
	var hud = _make_hud()
	hud.show_pause()
	var panel = hud.get_node("PausePanel")
	assert_true(panel.visible)


func test_hide_pause_makes_panel_invisible() -> void:
	var hud = _make_hud()
	hud.show_pause()
	hud.hide_pause()
	var panel = hud.get_node("PausePanel")
	assert_false(panel.visible)


func test_resume_button_emits_pause_toggled() -> void:
	var hud = _make_hud()
	watch_signals(hud)
	hud.show_pause()
	var btn = hud.get_node("PausePanel/VBoxContainer/ResumeButton")
	btn.emit_signal("pressed")
	assert_signal_emitted(hud, "pause_toggled")


func test_options_button_emits_options_requested() -> void:
	var hud = _make_hud()
	watch_signals(hud)
	hud.show_pause()
	var btn = hud.get_node("PausePanel/VBoxContainer/OptionsButton")
	btn.emit_signal("pressed")
	assert_signal_emitted(hud, "options_requested")


func test_exit_button_emits_exit_requested() -> void:
	var hud = _make_hud()
	watch_signals(hud)
	hud.show_pause()
	var btn = hud.get_node("PausePanel/VBoxContainer/ExitButton")
	btn.emit_signal("pressed")
	assert_signal_emitted(hud, "exit_requested")


func test_pause_panel_has_resume_button() -> void:
	var hud = _make_hud()
	var btn = hud.get_node("PausePanel/VBoxContainer/ResumeButton")
	assert_not_null(btn)
	assert_eq(btn.text, "Resume")


func test_pause_panel_has_options_button() -> void:
	var hud = _make_hud()
	var btn = hud.get_node("PausePanel/VBoxContainer/OptionsButton")
	assert_not_null(btn)
	assert_eq(btn.text, "Options")


func test_pause_panel_has_exit_button() -> void:
	var hud = _make_hud()
	var btn = hud.get_node("PausePanel/VBoxContainer/ExitButton")
	assert_not_null(btn)
	assert_eq(btn.text, "Exit to Desktop")
