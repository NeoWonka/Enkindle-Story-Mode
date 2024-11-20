extends Spell

@export var SPEED := 200
@export var DAMAGE := 1.0

var move_dir: Vector2
var enemies_encounter := []

func _ready() -> void:
	move_dir = transform.x * SPEED
	move_dir = move_dir.normalized()

func _process(delta: float) -> void:
	velocity = transform.x * SPEED
	var collision := move_and_collide(velocity * delta)
	if collision:
		for enemy: Node2D in enemies_encounter:
			enemy.finish_hitstun()
		queue_free()
	
	for enemy: Node2D in enemies_encounter:
		var effect := Effect.new()
		effect.knockback = move_dir * SPEED
		enemy.apply_effect(effect)


func _on_hitbox_area_entered(area: Area2D) -> void:
	var effect := Effect.new()
	effect.damage = DAMAGE
	area.get_parent().apply_effect(effect)
	if not area.get_parent() in enemies_encounter:
		area.get_parent().set_hitstun()
		enemies_encounter.append(area.get_parent())
	pass # Replace with function body.
