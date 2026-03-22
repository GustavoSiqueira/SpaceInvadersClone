extends GutTest


func test_translation_server_has_english_locale() -> void:
	assert_true(TranslationServer.get_loaded_locales().has("en"))


func test_tr_game_over_returns_english() -> void:
	assert_eq(tr("GAME OVER"), "GAME OVER")


func test_tr_score_format_returns_correct_string() -> void:
	assert_eq(tr("SCORE: %d") % 100, "SCORE: 100")


func test_tr_hi_format_returns_correct_string() -> void:
	assert_eq(tr("HI: %d") % 500, "HI: 500")


func test_tr_lives_format_returns_correct_string() -> void:
	assert_eq(tr("LIVES: %d") % 3, "LIVES: 3")


func test_tr_options_label() -> void:
	assert_eq(tr("OPTIONS"), "OPTIONS")


func test_tr_resume_label() -> void:
	assert_eq(tr("Resume"), "Resume")
