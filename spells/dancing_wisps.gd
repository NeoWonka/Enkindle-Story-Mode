extends Spell

@export var DAMAGE := 1.0

@export var DISTANCE := 20
@export var DURATION := 1.25
@export var PROJECTILE_SPEED := 50  # Speed of the projectiles
@export var OFFSET_ANGLE := 0.2  # Angle offset for left/right projectiles
@export var INWARD_DISTANCE := 5  # Distance for inward movement
@export var INWARD_DURATION := 0.5  # Distance for inward movement

var projectiles := []

func _ready() -> void:
	var direction := transform.x.normalized()
	var left_direction := direction.rotated(-OFFSET_ANGLE)
	var right_direction := direction.rotated(OFFSET_ANGLE)

	# Create the projectiles
	#NeoWonka 21:05cst 10/22/24: removed local declaration of velocity as variable. May need to place back as different local name,
								# or change velocity var in CharcterBody2D class.
	for i in range(3):
		var projectile := get_child(i)
		velocity = Vector2.ZERO
		match i:
			0:
				velocity = direction * PROJECTILE_SPEED
			1:
				velocity = left_direction * PROJECTILE_SPEED
			2:
				velocity = right_direction * PROJECTILE_SPEED

		projectile.global_position = global_position
		#projectile.rotation = direction.angle()
		projectile.set("velocity", velocity)
		projectiles.append(projectile)

	# Start the movement logic
	move_projectiles()
	$AnimationPlayer.play("damage")

func move_projectiles() -> void:
	for projectile: CharacterBody2D in projectiles:
		var direction: Vector2 = projectile.get("velocity").normalized()
		var target_position := projectile.global_position + direction * DISTANCE
		var tween := create_tween()
		tween.tween_property(projectile, "global_position", target_position, DURATION).\
			set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		tween.finished.connect(func () -> void:
			_on_tween_completed(projectile)
		)

func _on_tween_completed(projectile: CharacterBody2D) -> void:
	if not projectile or projectile.is_queued_for_deletion():
		return
	# Make the projectile move slightly inward
	var direction: Vector2 = projectile.get("velocity").normalized()
	var inward_direction := direction.rotated(TAU/2) * INWARD_DISTANCE
	var new_target_position := projectile.global_position + inward_direction
	
	var inward_tween := create_tween()
	inward_tween.tween_property(projectile, "global_position", new_target_position, INWARD_DURATION).\
		set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	inward_tween.finished.connect(func () -> void:
		_on_inward_tween_completed(projectile)
	)

func _on_inward_tween_completed(projectile: CharacterBody2D) -> void:
	projectiles.erase(projectile)
	queue_free()


func _process(delta: float) -> void:
	for projectile: CharacterBody2D in projectiles:
		if not (projectile) or not is_instance_valid(projectile):
			continue
		if projectile.get("velocity") != Vector2.ZERO:
			var collision := projectile.move_and_collide(projectile.get("velocity") * delta)
			if collision:
				if is_instance_valid(projectile):
					projectiles.erase(projectile)
					projectile.queue_free()

func on_hit(_proj: CharacterBody2D, area: Area2D) -> void:
	var effect := Effect.new()
	effect.damage = DAMAGE
	var enemy: CharacterBody2D = area.get_parent()
	enemy.set_hitstun()
	enemy.apply_effect(effect)
	var the_sprite := $Sprite2D2
	the_sprite.tree_exited.connect(func () -> void:
		enemy.finish_hitstun()
	)
	while the_sprite != null and (not the_sprite.is_queued_for_deletion() and is_instance_valid(the_sprite)):
		enemy.push(the_sprite.velocity)
		await get_tree().process_frame
	pass

func _on_hitbox0_area_entered(area: Area2D) -> void:
	on_hit($Sprite2D, area)
	pass
	
func _on_hitbox1_area_entered(area: Area2D) -> void:
	on_hit($Sprite2D2, area)
	pass
	
func _on_hitbox2_area_entered(area: Area2D) -> void:
	on_hit($Sprite2D3, area)
	pass
