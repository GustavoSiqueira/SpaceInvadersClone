extends Area2D

const SPEED = 400.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position.y -= SPEED * delta


func _on_body_entered(_body: Node) -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("boundary"):
		queue_free()
		return
	if area.is_in_group("alien"):
		area.kill()
		queue_free()
		return
	if area.is_in_group("shield_segment"):
		area.queue_free()
		queue_free()
		return
	if area.is_in_group("ufo"):
		area.hit()
		queue_free()
		return
	queue_free()
