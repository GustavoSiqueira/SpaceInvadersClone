extends GutTest


func test_translation_server_has_english_locale() -> void:
	assert_true(TranslationServer.get_loaded_locales().has("en"))


func test_translation_server_has_portuguese_locale() -> void:
	assert_true(TranslationServer.get_loaded_locales().has("pt_BR"))


func test_translation_server_has_spanish_locale() -> void:
	assert_true(TranslationServer.get_loaded_locales().has("es"))


func test_translation_server_has_french_locale() -> void:
	assert_true(TranslationServer.get_loaded_locales().has("fr"))


func test_translation_server_has_german_locale() -> void:
	assert_true(TranslationServer.get_loaded_locales().has("de"))


func test_translation_server_has_italian_locale() -> void:
	assert_true(TranslationServer.get_loaded_locales().has("it"))


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


func test_portuguese_game_over_translation() -> void:
	var saved := TranslationServer.get_locale()
	TranslationServer.set_locale("pt_BR")
	assert_eq(tr("GAME OVER"), "FIM DE JOGO")
	TranslationServer.set_locale(saved)


func test_spanish_game_over_translation() -> void:
	var saved := TranslationServer.get_locale()
	TranslationServer.set_locale("es")
	assert_eq(tr("GAME OVER"), "FIN DEL JUEGO")
	TranslationServer.set_locale(saved)


func test_french_game_over_translation() -> void:
	var saved := TranslationServer.get_locale()
	TranslationServer.set_locale("fr")
	assert_eq(tr("GAME OVER"), "PARTIE TERMINÉE")
	TranslationServer.set_locale(saved)


func test_german_game_over_translation() -> void:
	var saved := TranslationServer.get_locale()
	TranslationServer.set_locale("de")
	assert_eq(tr("GAME OVER"), "SPIEL VORBEI")
	TranslationServer.set_locale(saved)


func test_italian_game_over_translation() -> void:
	var saved := TranslationServer.get_locale()
	TranslationServer.set_locale("it")
	assert_eq(tr("GAME OVER"), "FINE DEL GIOCO")
	TranslationServer.set_locale(saved)


func test_portuguese_new_game_translation() -> void:
	var saved := TranslationServer.get_locale()
	TranslationServer.set_locale("pt_BR")
	assert_eq(tr("New Game"), "Novo Jogo")
	TranslationServer.set_locale(saved)


func test_portuguese_back_translation() -> void:
	var saved := TranslationServer.get_locale()
	TranslationServer.set_locale("pt_BR")
	assert_eq(tr("Back"), "Voltar")
	TranslationServer.set_locale(saved)
