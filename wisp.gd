class_name Wisp

extends CharacterBody2D

enum Elements {
	Earth,
	Air,
	Fire,
	Water,
}

@export var SPEED := 400
@export var TYPE := Elements.Earth
@export var ACTIVE := false

func _ready() -> void:
	match TYPE:
		Elements.Earth:
			$EarthOrb.visible = true
		Elements.Air:
			$AirOrb.visible = true
		Elements.Fire:
			$FireOrb.visible = true
		Elements.Water:
			$WaterOrb.visible = true
	set_process(false)
	$range.monitoring = ACTIVE
	$collect.monitoring = ACTIVE

func activate() -> void:
	ACTIVE = true
	set_process(ACTIVE)
	$range.monitoring = ACTIVE
	$collect.monitoring = ACTIVE

func _process(delta: float) -> void:
	velocity = global_position.direction_to(Global.Player.global_position)
	move_and_collide(velocity * SPEED * delta)
#NeoWonka 22:07cst 10/14/2024: changed wisp value for testing purposes
func _on_collect_body_entered(body: Node2D) -> void:
	if body.name != "character":
		return
	if not ACTIVE:
		return
	match TYPE:
		Elements.Earth:
			Global.UI.get_node("magic").get_node("earth").elements_left += 3
			Global.UI.get_node("magic").get_node("earth").current_value = 6
		Elements.Air:
			Global.UI.get_node("magic").get_node("air").elements_left += 3
			Global.UI.get_node("magic").get_node("air").current_value = 6
		Elements.Fire:
			Global.UI.get_node("magic").get_node("fire").elements_left += 3
			Global.UI.get_node("magic").get_node("fire").current_value = 6
		Elements.Water:
			Global.UI.get_node("magic").get_node("water").elements_left += 3
			Global.UI.get_node("magic").get_node("water").current_value = 6
	queue_free()
	pass # Replace with function body.


func _on_range_body_entered(body: Node2D) -> void:
	if body.name == "character":
		set_process(true)
	pass # Replace with function body.


func _on_range_body_exited(body: Node2D) -> void:
	if body.name == "character":
		set_process(false)
	pass # Replace with function body.
