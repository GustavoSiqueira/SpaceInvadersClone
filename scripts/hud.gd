extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var hi_score_label: Label = $HiScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var game_over_panel: Control = $GameOverPanel


func _ready() -> void:
	game_over_panel.hide()
	update_score(0, 0)
	update_lives(3)


func update_score(score: int, hi_score: int) -> void:
	score_label.text = "SCORE: %d" % score
	hi_score_label.text = "HI: %d" % hi_score


func update_lives(lives: int) -> void:
	lives_label.text = "LIVES: %d" % lives


func show_game_over() -> void:
	game_over_panel.show()
