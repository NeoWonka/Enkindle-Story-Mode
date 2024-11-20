extends Spell

@export var DAMAGE := 1

var effect := Effect.new()

func _ready() -> void:
	effect.damage = DAMAGE
	$AnimationPlayer.play("rumble")

func damage_all() -> void:
	for enemy: Node2D in $hitbox.get_overlapping_areas():
		enemy.get_parent().apply_effect(effect)
