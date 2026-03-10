extends GutTest

const PlayerBulletScene = preload("res://scenes/player_bullet.tscn")
const EnemyBulletScene = preload("res://scenes/enemy_bullet.tscn")
const AlienScene = preload("res://scenes/alien.tscn")
const PlayerScene = preload("res://scenes/player.tscn")
const UfoScene = preload("res://scenes/ufo.tscn")


# --- PlayerBullet ---

func test_player_bullet_kills_alien_on_area_entered() -> void:
	var bullet: Area2D = PlayerBulletScene.instantiate()
	add_child_autoqfree(bullet)

	var alien: Area2D = AlienScene.instantiate()
	alien.set_type(0)
	add_child_autoqfree(alien)
	alien.add_to_group("alien")  # normally added by alien_formation

	watch_signals(alien)
	bullet._on_area_entered(alien)

	assert_true(alien.is_dead)
	assert_signal_emitted(alien, "killed")


func test_player_bullet_frees_itself_after_hitting_alien() -> void:
	var bullet: Area2D = PlayerBulletScene.instantiate()
	add_child_autoqfree(bullet)

	var alien: Area2D = AlienScene.instantiate()
	alien.set_type(0)
	add_child_autoqfree(alien)
	alien.add_to_group("alien")  # normally added by alien_formation

	bullet._on_area_entered(alien)
	await get_tree().process_frame

	assert_false(is_instance_valid(bullet))


func test_player_bullet_frees_on_boundary() -> void:
	var bullet: Area2D = PlayerBulletScene.instantiate()
	add_child_autoqfree(bullet)

	var boundary := Area2D.new()
	boundary.add_to_group("boundary")
	add_child_autoqfree(boundary)

	bullet._on_area_entered(boundary)
	await get_tree().process_frame

	assert_false(is_instance_valid(bullet))


func test_player_bullet_frees_on_ufo_hit() -> void:
	var bullet: Area2D = PlayerBulletScene.instantiate()
	add_child_autoqfree(bullet)

	var ufo: Area2D = UfoScene.instantiate()
	add_child_autoqfree(ufo)

	bullet._on_area_entered(ufo)
	await get_tree().process_frame

	assert_false(is_instance_valid(bullet))


# --- EnemyBullet ---

func test_enemy_bullet_calls_hit_on_player() -> void:
	var bullet: Area2D = EnemyBulletScene.instantiate()
	add_child_autoqfree(bullet)

	var player: CharacterBody2D = PlayerScene.instantiate()
	add_child_autoqfree(player)

	# player is in "player" group after _ready(); trigger body_entered handler directly.
	bullet._on_body_entered(player)

	assert_false(player.is_alive)


func test_enemy_bullet_removes_shield_segment() -> void:
	var bullet: Area2D = EnemyBulletScene.instantiate()
	add_child_autoqfree(bullet)

	var segment := Area2D.new()
	segment.add_to_group("shield_segment")
	add_child_autoqfree(segment)

	bullet._on_area_entered(segment)
	await get_tree().process_frame

	assert_false(is_instance_valid(segment))


func test_enemy_bullet_frees_itself_on_boundary() -> void:
	var bullet: Area2D = EnemyBulletScene.instantiate()
	add_child_autoqfree(bullet)

	var boundary := Area2D.new()
	boundary.add_to_group("boundary")
	add_child_autoqfree(boundary)

	bullet._on_area_entered(boundary)
	await get_tree().process_frame

	assert_false(is_instance_valid(bullet))
