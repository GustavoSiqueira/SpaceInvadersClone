extends CanvasLayer

signal pause_toggled

@onready var score_label: Label = $ScoreLabel
@onready var hi_score_label: Label = $HiScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var game_over_panel: Control = $GameOverPanel
@onready var pause_panel: Control = $PausePanel


func _ready() -> void:
	game_over_panel.hide()
	pause_panel.hide()
	update_lives(3)


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


func hide_pause() -> void:
	pause_panel.hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_toggled.emit()
		get_viewport().set_input_as_handled()
