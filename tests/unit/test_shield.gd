extends GutTest

const ShieldScene = preload("res://scenes/shield.tscn")

# COLS=8, ROWS=4 → 32 total; notch: row>=2 AND col>=3 AND col<=4 → 2*2=4 cells removed → 28 segments
const EXPECTED_SEGMENTS = 28


func _make_shield() -> Node2D:
	var s := ShieldScene.instantiate()
	add_child_autoqfree(s)
	return s


# --- segment count ---

func test_shield_builds_correct_segment_count() -> void:
	var shield := _make_shield()
	assert_eq(shield.get_child_count(), EXPECTED_SEGMENTS)


# --- _is_notch ---

func test_is_notch_true_for_row2_col3() -> void:
	var shield := _make_shield()
	assert_true(shield._is_notch(2, 3))


func test_is_notch_true_for_row2_col4() -> void:
	var shield := _make_shield()
	assert_true(shield._is_notch(2, 4))


func test_is_notch_true_for_row3_col3() -> void:
	var shield := _make_shield()
	assert_true(shield._is_notch(3, 3))


func test_is_notch_true_for_row3_col4() -> void:
	var shield := _make_shield()
	assert_true(shield._is_notch(3, 4))


func test_is_notch_false_for_row0_col0() -> void:
	var shield := _make_shield()
	assert_false(shield._is_notch(0, 0))


func test_is_notch_false_for_row1_col4() -> void:
	var shield := _make_shield()
	assert_false(shield._is_notch(1, 4))


func test_is_notch_false_for_row2_col2() -> void:
	var shield := _make_shield()
	assert_false(shield._is_notch(2, 2))


# --- segment group and layer ---

func test_all_segments_in_shield_segment_group() -> void:
	var shield := _make_shield()
	for child in shield.get_children():
		assert_true(child.is_in_group("shield_segment"), "child not in group: %s" % child.name)


func test_all_segments_on_collision_layer_16() -> void:
	var shield := _make_shield()
	for child in shield.get_children():
		assert_eq(child.collision_layer, 16, "child wrong layer: %s" % child.name)
