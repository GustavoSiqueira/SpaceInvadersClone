class_name Settings

const _PATH := "user://settings.cfg"
const _SEC_KEYS  := "keybindings"
const _SEC_PREFS := "preferences"

const DEFAULT_KEYS: Dictionary = {
	"move_left":  KEY_LEFT,
	"move_right": KEY_RIGHT,
	"shoot":      KEY_SPACE,
	"restart":    KEY_F5,
	"pause":      KEY_ESCAPE,
}

static var _data: Dictionary = {}
static var _loaded: bool = false


static func load() -> void:
	if _loaded:
		return
	_loaded = true
	_data = {
		"move_left":   DEFAULT_KEYS["move_left"],
		"move_right":  DEFAULT_KEYS["move_right"],
		"shoot":       DEFAULT_KEYS["shoot"],
		"restart":     DEFAULT_KEYS["restart"],
		"pause":       DEFAULT_KEYS["pause"],
		"crt_enabled": true,
	}
	var cfg := ConfigFile.new()
	if cfg.load(_PATH) != OK:
		return
	for action in DEFAULT_KEYS.keys():
		_data[action] = cfg.get_value(_SEC_KEYS, action, _data[action])
	_data["crt_enabled"] = cfg.get_value(_SEC_PREFS, "crt_enabled", true)


static func save() -> void:
	var cfg := ConfigFile.new()
	for action in DEFAULT_KEYS.keys():
		cfg.set_value(_SEC_KEYS, action, _data[action])
	cfg.set_value(_SEC_PREFS, "crt_enabled", _data["crt_enabled"])
	cfg.save(_PATH)


static func get_keycode(action: String) -> Key:
	return _data.get(action, DEFAULT_KEYS.get(action, KEY_NONE)) as Key


static func set_keycode(action: String, keycode: Key) -> void:
	_data[action] = keycode


static func get_crt_enabled() -> bool:
	return _data.get("crt_enabled", true)


static func set_crt_enabled(value: bool) -> void:
	_data["crt_enabled"] = value


## Resets all static state. For use in unit tests only.
static func _reset_for_test() -> void:
	_data = {}
	_loaded = false
