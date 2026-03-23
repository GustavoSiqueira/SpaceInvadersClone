class_name Settings

const _PATH      := "user://settings.cfg"
const _SEC_KEYS   := "keybindings"
const _SEC_PREFS  := "preferences"
const _SEC_GAMEPAD := "gamepad_bindings"

const SUPPORTED_LOCALES: Array[String] = ["en", "pt_BR", "es", "fr", "de", "it"]

const DEFAULT_GAMEPAD_BINDINGS: Dictionary = {
	"move_left":  {"type": "button", "button": JOY_BUTTON_DPAD_LEFT},
	"move_right": {"type": "button", "button": JOY_BUTTON_DPAD_RIGHT},
	"shoot":      {"type": "button", "button": JOY_BUTTON_A},
	"pause":      {"type": "button", "button": JOY_BUTTON_START},
}

const DEFAULT_KEYS: Dictionary = {
	"move_left":  KEY_LEFT,
	"move_right": KEY_RIGHT,
	"shoot":      KEY_SPACE,
	"pause":      KEY_ESCAPE,
}

static var _data: Dictionary = {}
static var _loaded: bool = false


static func load() -> void:
	if _loaded:
		return
	_loaded = true
	_data = {
		"move_left":    DEFAULT_KEYS["move_left"],
		"move_right":   DEFAULT_KEYS["move_right"],
		"shoot":        DEFAULT_KEYS["shoot"],
		"pause":        DEFAULT_KEYS["pause"],
		"crt_enabled":  true,
		"music_volume": 1.0,
		"sfx_volume":   1.0,
		"language":     "",
	}
	for action in DEFAULT_GAMEPAD_BINDINGS.keys():
		_data["gamepad_" + action] = DEFAULT_GAMEPAD_BINDINGS[action].duplicate()
	var cfg := ConfigFile.new()
	if cfg.load(_PATH) != OK:
		return
	for action in DEFAULT_KEYS.keys():
		_data[action] = cfg.get_value(_SEC_KEYS, action, _data[action])
	for action in DEFAULT_GAMEPAD_BINDINGS.keys():
		_data["gamepad_" + action] = cfg.get_value(_SEC_GAMEPAD, action, _data["gamepad_" + action])
	_data["crt_enabled"]  = cfg.get_value(_SEC_PREFS, "crt_enabled",  true)
	_data["music_volume"] = cfg.get_value(_SEC_PREFS, "music_volume", 1.0)
	_data["sfx_volume"]   = cfg.get_value(_SEC_PREFS, "sfx_volume",   1.0)
	_data["language"]     = cfg.get_value(_SEC_PREFS, "language",     "")


static func save() -> void:
	var cfg := ConfigFile.new()
	for action in DEFAULT_KEYS.keys():
		cfg.set_value(_SEC_KEYS, action, _data[action])
	for action in DEFAULT_GAMEPAD_BINDINGS.keys():
		cfg.set_value(_SEC_GAMEPAD, action, _data.get("gamepad_" + action, DEFAULT_GAMEPAD_BINDINGS[action]))
	cfg.set_value(_SEC_PREFS, "crt_enabled",  _data["crt_enabled"])
	cfg.set_value(_SEC_PREFS, "music_volume", _data["music_volume"])
	cfg.set_value(_SEC_PREFS, "sfx_volume",   _data["sfx_volume"])
	cfg.set_value(_SEC_PREFS, "language",     _data["language"])
	cfg.save(_PATH)


static func get_keycode(action: String) -> Key:
	return _data.get(action, DEFAULT_KEYS.get(action, KEY_NONE)) as Key


static func set_keycode(action: String, keycode: Key) -> void:
	_data[action] = keycode


static func get_gamepad_binding(action: String) -> Dictionary:
	return _data.get("gamepad_" + action, DEFAULT_GAMEPAD_BINDINGS.get(action, {})).duplicate()


static func set_gamepad_binding(action: String, binding: Dictionary) -> void:
	_data["gamepad_" + action] = binding


static func get_crt_enabled() -> bool:
	return _data.get("crt_enabled", true)


static func set_crt_enabled(value: bool) -> void:
	_data["crt_enabled"] = value


static func get_music_volume() -> float:
	return _data.get("music_volume", 1.0)


static func set_music_volume(value: float) -> void:
	_data["music_volume"] = clampf(value, 0.0, 1.0)


static func get_sfx_volume() -> float:
	return _data.get("sfx_volume", 1.0)


static func set_sfx_volume(value: float) -> void:
	_data["sfx_volume"] = clampf(value, 0.0, 1.0)


static func get_language() -> String:
	return _data.get("language", "")


static func set_language(value: String) -> void:
	_data["language"] = value


## Resolves the active locale and applies it to TranslationServer.
## Uses the stored preference; if empty, falls back to system locale;
## if system locale is unsupported, falls back to "en".
static func apply_language() -> void:
	var lang: String = _data.get("language", "")
	if lang == "":
		lang = _resolve_system_locale()
	TranslationServer.set_locale(lang)


static func _resolve_system_locale() -> String:
	var sys := OS.get_locale()  # e.g. "pt_BR", "en_US", "fr_FR"
	# Exact match first (important for pt_BR vs pt_PT)
	for supported in SUPPORTED_LOCALES:
		if sys == supported:
			return supported
	# Language-prefix match: "en_US" → "en", "es_MX" → "es"
	var prefix := sys.split("_")[0]
	for supported in SUPPORTED_LOCALES:
		if supported == prefix or supported.split("_")[0] == prefix:
			return supported
	return "en"


## Resets all static state. For use in unit tests only.
static func _reset_for_test() -> void:
	_data = {}
	_loaded = false

## Deletes the persisted settings file. For use in unit tests only.
static func _delete_file_for_test() -> void:
	var dir := DirAccess.open("user://")
	if dir:
		dir.remove("settings.cfg")
