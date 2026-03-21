extends Control

const REBINDABLE_ACTIONS: Array[String] = [
	"move_left", "move_right", "shoot", "pause", "restart"
]

const ACTION_LABELS: Dictionary = {
	"move_left":  "Move Left",
	"move_right": "Move Right",
	"shoot":      "Shoot",
	"pause":      "Pause",
	"restart":    "Restart",
}

const CRT_SCENE := preload("res://scenes/crt_effect.tscn")

var _rebind_buttons: Dictionary = {}   # action -> Button
var _waiting_for_key: String = ""
var _in_use_timer: Timer
var _in_use_action: String = ""


func _ready() -> void:
	Settings.load()
	_setup_in_use_timer()
	# Add CRT overlay so options screen is consistent with the rest of the game
	var crt = CRT_SCENE.instantiate()
	add_child(crt)
	_build_ui()


func _setup_in_use_timer() -> void:
	_in_use_timer = Timer.new()
	_in_use_timer.one_shot = true
	_in_use_timer.timeout.connect(_on_in_use_timer_timeout)
	add_child(_in_use_timer)


func _build_ui() -> void:
	# Dark background
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.05, 1.0)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	# Centered VBoxContainer
	var vbox := VBoxContainer.new()
	vbox.anchor_left   = 0.5
	vbox.anchor_right  = 0.5
	vbox.anchor_top    = 0.08
	vbox.anchor_bottom = 0.95
	vbox.offset_left   = -260.0
	vbox.offset_right  = 260.0
	vbox.add_theme_constant_override("separation", 8)
	add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "OPTIONS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)

	_add_separator_label(vbox, "-- KEY BINDINGS --")

	for action in REBINDABLE_ACTIONS:
		_add_rebind_row(vbox, action)

	_add_separator_label(vbox, "-- DISPLAY --")

	_add_crt_row(vbox)

	_add_separator_label(vbox, "-- AUDIO (coming soon) --")

	_add_slider_row(vbox, "Music Volume")
	_add_slider_row(vbox, "SFX Volume")

	vbox.add_child(HSeparator.new())

	var back_btn := Button.new()
	back_btn.text = "Back"
	back_btn.custom_minimum_size = Vector2(200.0, 40.0)
	back_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_btn.pressed.connect(_on_back_pressed)
	vbox.add_child(back_btn)
	back_btn.grab_focus()


func _add_separator_label(parent: VBoxContainer, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 13)
	parent.add_child(lbl)


func _add_rebind_row(parent: VBoxContainer, action: String) -> void:
	var row := HBoxContainer.new()

	var lbl := Label.new()
	lbl.text = ACTION_LABELS[action]
	lbl.custom_minimum_size = Vector2(180.0, 0.0)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var btn := Button.new()
	btn.text = _key_label(Settings.get_keycode(action))
	btn.custom_minimum_size = Vector2(160.0, 32.0)
	btn.pressed.connect(_on_rebind_pressed.bind(action))
	_rebind_buttons[action] = btn

	row.add_child(lbl)
	row.add_child(btn)
	parent.add_child(row)


func _add_crt_row(parent: VBoxContainer) -> void:
	var row := HBoxContainer.new()

	var lbl := Label.new()
	lbl.text = "CRT Effect"
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var chk := CheckBox.new()
	chk.button_pressed = Settings.get_crt_enabled()
	chk.toggled.connect(_on_crt_toggled)

	row.add_child(lbl)
	row.add_child(chk)
	parent.add_child(row)


func _add_slider_row(parent: VBoxContainer, label_text: String) -> void:
	var row := HBoxContainer.new()

	var lbl := Label.new()
	lbl.text = label_text
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.value = 1.0
	slider.custom_minimum_size = Vector2(160.0, 0.0)
	slider.editable = false
	slider.focus_mode = Control.FOCUS_NONE

	row.add_child(lbl)
	row.add_child(slider)
	parent.add_child(row)


func _on_rebind_pressed(action: String) -> void:
	if _waiting_for_key != "":
		return  # already waiting for another key
	_waiting_for_key = action
	_rebind_buttons[action].text = "Press a key..."
	_rebind_buttons[action].release_focus()


func _input(event: InputEvent) -> void:
	if _waiting_for_key == "":
		return
	if not (event is InputEventKey):
		return
	if not event.pressed:
		return
	get_viewport().set_input_as_handled()

	if event.keycode == KEY_ESCAPE:
		_cancel_rebind()
		return

	# Reject keys already bound to a different action
	for other in REBINDABLE_ACTIONS:
		if other != _waiting_for_key and Settings.get_keycode(other) == event.keycode:
			_flash_in_use(_waiting_for_key)
			return

	var completed := _waiting_for_key
	_waiting_for_key = ""
	Settings.set_keycode(completed, event.keycode)
	_rebind_buttons[completed].text = _key_label(event.keycode)
	Settings.save()
	_apply_to_input_map(completed, event.keycode)


func _cancel_rebind() -> void:
	var action := _waiting_for_key
	_waiting_for_key = ""
	_rebind_buttons[action].text = _key_label(Settings.get_keycode(action))


func _flash_in_use(action: String) -> void:
	_waiting_for_key = ""
	_rebind_buttons[action].text = "In use!"
	_in_use_action = action
	_in_use_timer.start(1.0)


func _on_in_use_timer_timeout() -> void:
	if _in_use_action != "":
		_rebind_buttons[_in_use_action].text = _key_label(Settings.get_keycode(_in_use_action))
		_in_use_action = ""


func _on_crt_toggled(pressed: bool) -> void:
	Settings.set_crt_enabled(pressed)
	Settings.save()
	# Update any live CRT node in the tree (e.g. the one we added in _ready)
	var crt := get_tree().get_first_node_in_group("crt_effect")
	if crt:
		crt.visible = pressed


func _on_back_pressed() -> void:
	if _waiting_for_key != "":
		return  # block navigation while mid-rebind
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _apply_to_input_map(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_erase_events(action)
	var ev := InputEventKey.new()
	ev.keycode = keycode
	InputMap.action_add_event(action, ev)


func _key_label(keycode: Key) -> String:
	return OS.get_keycode_string(keycode)
