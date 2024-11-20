extends Spell

@export var DAMAGE := 1.5

signal enemies_found
var the_enemies: Array[Area2D]

func _ready() -> void:
	find_enemies()
	await enemies_found
	var enemies: Array = the_enemies
	for index: int in enemies.size():
		if index == 5:
			break
		var enemy: Node2D = enemies[index].get_parent()
		var at: Vector2 = enemy.get_feet()
		var curr_lightning: Node2D = get_node("l" + str(index))
		curr_lightning.get_node("hitbox").monitoring = true
		curr_lightning.global_position = at 
		curr_lightning.visible = true
	for i: int in range(5):
		if not get_node("l" + str(i)).visible:
			get_node("l" + str(i)).position.y += 100000
	$AnimationPlayer.play("damage")
	pass

func find_enemies() -> void:
	while the_enemies.size() == 0:
		the_enemies = $enemy_detect.get_overlapping_areas()
		await get_tree().process_frame
	emit_signal("enemies_found")


func _on_hitbox_area_entered(area: Area2D) -> void:
	var effect := Effect.new()
	effect.damage = DAMAGE
	area.get_parent().apply_effect(effect)
	pass
