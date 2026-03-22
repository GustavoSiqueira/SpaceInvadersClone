extends Control

@onready var new_game_button: Button = $MenuArea/MenuContainer/NewGameButton
@onready var options_button: Button = $MenuArea/MenuContainer/OptionsButton
@onready var exit_button: Button = $MenuArea/MenuContainer/ExitButton


func _ready() -> void:
	Settings.load()
	Settings.apply_language()
	new_game_button.pressed.connect(_on_new_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	new_game_button.grab_focus()


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_screen.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
