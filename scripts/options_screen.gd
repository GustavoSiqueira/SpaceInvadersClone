extends Control

signal closed

var overlay_mode: bool = false

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

const LANGUAGE_LOCALES: Array[String] = ["", "en", "pt_BR", "es", "fr", "de", "it"]
const LANGUAGE_LABELS: Array[String] = [
	"System Default", "English", "Português (Brasil)", "Español", "Français", "Deutsch", "Italiano"
]

var _rebind_buttons: Dictionary = {}   # action -> Button
var _waiting_for_key: String = ""
var _in_use_timer: Timer
var _in_use_action: String = ""
var _ui_bg: ColorRect
var _ui_vbox: VBoxContainer


func _ready() -> void:
	Settings.load()
	_setup_in_use_timer()
	if not overlay_mode:
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
	_rebind_buttons.clear()

	# Dark background
	_ui_bg = ColorRect.new()
	_ui_bg.color = Color(0.05, 0.05, 0.05, 1.0)
	_ui_bg.anchor_right = 1.0
	_ui_bg.anchor_bottom = 1.0
	add_child(_ui_bg)

	# Centered VBoxContainer
	_ui_vbox = VBoxContainer.new()
	_ui_vbox.anchor_left   = 0.5
	_ui_vbox.anchor_right  = 0.5
	_ui_vbox.anchor_top    = 0.08
	_ui_vbox.anchor_bottom = 0.95
	_ui_vbox.offset_left   = -260.0
	_ui_vbox.offset_right  = 260.0
	_ui_vbox.add_theme_constant_override("separation", 8)
	add_child(_ui_vbox)
	var vbox := _ui_vbox

	# Title
	var title := Label.new()
	title.text = tr("OPTIONS")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)

	_add_separator_label(vbox, tr("-- KEY BINDINGS --"))

	for action in REBINDABLE_ACTIONS:
		_add_rebind_row(vbox, action)

	_add_separator_label(vbox, tr("-- DISPLAY --"))

	_add_crt_row(vbox)

	_add_separator_label(vbox, tr("-- AUDIO --"))

	_add_volume_row(vbox, tr("Music Volume"), Settings.get_music_volume(), _on_music_volume_changed)
	_add_volume_row(vbox, tr("SFX Volume"),  Settings.get_sfx_volume(),   _on_sfx_volume_changed)

	_add_separator_label(vbox, tr("-- LANGUAGE --"))

	_add_language_row(vbox)

	vbox.add_child(HSeparator.new())

	var back_btn := Button.new()
	back_btn.text = tr("Back")
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
	lbl.text = tr(ACTION_LABELS[action])
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
	lbl.text = tr("CRT Effect")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var chk := CheckBox.new()
	chk.button_pressed = Settings.get_crt_enabled()
	chk.toggled.connect(_on_crt_toggled)

	row.add_child(lbl)
	row.add_child(chk)
	parent.add_child(row)


func _add_volume_row(parent: VBoxContainer, label_text: String, initial_value: float, callback: Callable) -> void:
	var row := HBoxContainer.new()

	var lbl := Label.new()
	lbl.text = label_text
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = initial_value
	slider.custom_minimum_size = Vector2(160.0, 0.0)
	slider.value_changed.connect(callback)

	row.add_child(lbl)
	row.add_child(slider)
	parent.add_child(row)


func _add_language_row(parent: VBoxContainer) -> void:
	var row := HBoxContainer.new()

	var lbl := Label.new()
	lbl.text = tr("Language")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var opt := OptionButton.new()
	opt.custom_minimum_size = Vector2(200.0, 32.0)
	var current_lang := Settings.get_language()
	for i in LANGUAGE_LOCALES.size():
		# Language names are always shown in their native script
		var label := LANGUAGE_LABELS[i] if i > 0 else tr("System Default")
		opt.add_item(label, i)
		if LANGUAGE_LOCALES[i] == current_lang:
			opt.select(i)
	opt.item_selected.connect(_on_language_selected)

	row.add_child(lbl)
	row.add_child(opt)
	parent.add_child(row)


func _on_language_selected(index: int) -> void:
	Settings.set_language(LANGUAGE_LOCALES[index])
	Settings.save()
	Settings.apply_language()
	call_deferred("_rebuild_ui")


func _rebuild_ui() -> void:
	_waiting_for_key = ""
	_in_use_action = ""
	if _ui_bg:
		_ui_bg.free()
	if _ui_vbox:
		_ui_vbox.free()
	_build_ui()


func _on_music_volume_changed(value: float) -> void:
	Settings.set_music_volume(value)
	Settings.save()
	_apply_bus_volume("Music", value)


func _on_sfx_volume_changed(value: float) -> void:
	Settings.set_sfx_volume(value)
	Settings.save()
	_apply_bus_volume("SFX", value)


func _apply_bus_volume(bus_name: String, value: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return  # bus not yet created — no-op until audio assets are added
	var db := linear_to_db(value) if value > 0.001 else -80.0
	AudioServer.set_bus_volume_db(idx, db)
	AudioServer.set_bus_mute(idx, value <= 0.0)


func _on_rebind_pressed(action: String) -> void:
	if _waiting_for_key != "":
		return  # already waiting for another key
	_waiting_for_key = action
	_rebind_buttons[action].text = "Press a key..."
	_rebind_buttons[action].release_focus()


func _input(event: InputEvent) -> void:
	if overlay_mode and _waiting_for_key == "" and event.is_action_pressed("pause"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()
		return
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
	if overlay_mode:
		closed.emit()
	else:
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
