extends Spell

@export var DAMAGE := 3
@export var SPEED := 2000

func _ready() -> void:
	$sfx.play()
	pass

func _process(delta: float) -> void:
	velocity = transform.x * SPEED
	var collision := move_and_collide(velocity * delta)
	if collision:
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	pass # Replace with function body.


func _on_hitbox_area_entered(area: Area2D) -> void:
	var effect := Effect.new()
	effect.damage = DAMAGE
	area.get_parent().apply_effect(effect)
	pass # Replace with function body.
