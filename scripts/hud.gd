extends CanvasLayer

signal pause_toggled
signal options_requested
signal exit_requested

@onready var score_label: Label = $ScoreLabel
@onready var hi_score_label: Label = $HiScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var game_over_panel: Control = $GameOverPanel
@onready var pause_panel: Control = $PausePanel
@onready var resume_button: Button = $PausePanel/VBoxContainer/ResumeButton
@onready var options_button: Button = $PausePanel/VBoxContainer/OptionsButton
@onready var exit_button: Button = $PausePanel/VBoxContainer/ExitButton


func _ready() -> void:
	game_over_panel.hide()
	pause_panel.hide()
	update_lives(3)
	resume_button.pressed.connect(func(): pause_toggled.emit())
	options_button.pressed.connect(func(): options_requested.emit())
	exit_button.pressed.connect(func(): exit_requested.emit())


func update_score(score: int, hi_score: int) -> void:
	score_label.text = "SCORE: %d" % score
	hi_score_label.text = "HI: %d" % hi_score


func update_lives(lives: int) -> void:
	lives_label.text = "LIVES: %d" % lives


func show_game_over() -> void:
	game_over_panel.show()


func hide_game_over() -> void:
	game_over_panel.hide()


func show_pause() -> void:
	pause_panel.show()
	resume_button.grab_focus()


func hide_pause() -> void:
	pause_panel.hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_toggled.emit()
		get_viewport().set_input_as_handled()
