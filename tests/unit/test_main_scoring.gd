extends GutTest

const MainScene = preload("res://scenes/main.tscn")

var main: Node2D


func before_each() -> void:
	main = MainScene.instantiate()
	add_child_autoqfree(main)
	# Reset to clean state for each test.
	main.score = 0
	main.hi_score = 0
	main.lives = 3
	main.wave = 1
	main.game_active = true


# --- _add_score ---

func test_add_score_increases_score() -> void:
	main._add_score(100)
	assert_eq(main.score, 100)


func test_add_score_accumulates() -> void:
	main._add_score(30)
	main._add_score(20)
	assert_eq(main.score, 50)


func test_add_score_updates_hi_score_when_exceeded() -> void:
	main.hi_score = 50
	main._add_score(100)
	assert_eq(main.hi_score, 100)


func test_add_score_does_not_decrease_hi_score() -> void:
	main.hi_score = 500
	main._add_score(10)
	assert_eq(main.hi_score, 500)


# --- _kill_player ---

func test_kill_player_decrements_lives() -> void:
	main._kill_player()
	assert_eq(main.lives, 2)


func test_kill_player_triggers_game_over_at_zero_lives() -> void:
	main.lives = 1
	main._kill_player()
	assert_false(main.game_active)


func test_kill_player_no_game_over_when_lives_remain() -> void:
	main.lives = 3
	main._kill_player()
	assert_true(main.game_active)


# --- _restart_game ---

func test_restart_game_resets_score() -> void:
	main.score = 999
	main._restart_game()
	assert_eq(main.score, 0)


func test_restart_game_resets_lives() -> void:
	main.lives = 1
	main._restart_game()
	assert_eq(main.lives, 3)


func test_restart_game_resets_wave() -> void:
	main.wave = 5
	main._restart_game()
	assert_eq(main.wave, 1)


func test_restart_game_sets_game_active() -> void:
	main.game_active = false
	main._restart_game()
	assert_true(main.game_active)
