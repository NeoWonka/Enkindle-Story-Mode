@tool
class_name Enemy
extends CharacterBody2D

@export_group("Behavior Testing")
@export var dash_button := false:
	set(value):
		if Engine.is_editor_hint():
			return
		dash_attack()
		action_state = ACTION_STATES.Dash_Attack
		debug_dashing = true
		await dash_cooldown_finished
		debug_dashing = false

@export_group("Parameters")
@export var ACTIVE := false:
	set(value):
		if HP <= 0:
			ACTIVE = false
		else:
			ACTIVE = value
		return
@export var action_state := ACTION_STATES.Idle
@export var BASE_SPEED := 20
@export var HP: float = 3.0:
	set(value):
		HP = value
		if HP > 0:
			if current_hp_sprite:
				for child: Node2D in current_hp_sprite.get_children():
					child.visible = false
				for child: Node2D in current_hp_sprite.get_children().slice(0, int(HP * 2)):
					child.visible = true
				pass
				
		if value == 0:
			pass
		elif value < 0:
			if (find_children("drop_*").size() == 2):
				find_children("drop_*")[1].queue_free()
		if value <= 0:
			for child: Node in get_children():
				if not child is Wisp:
					continue
				child.activate()
				child.call_deferred("reparent", Global.Projectiles)
			ACTIVE = false
			current_hp_sprite.visible = false
			$AnimationPlayer.stop()
			$AnimationPlayer.play("death")
			pass
@export var GOLEM_TYPE := Wisp.Elements.Earth
@export var DASH_LENGTH := 200
@export var DASH_DURATION_SECONDS := 0.5
@export var DASH_COOLDOWN_SECONDS := 0.3
@export var KEEP_DISTANCE_FROM_PLAYER := 110
@export var ATTACK_1_DAMAGE := 1
@export var ATTACK_2_DAMAGE := 1

@onready var wisp_scene := preload("res://wisp.tscn")


signal dash_finished
signal dash_cooldown_finished

var debug_dashing := false
var dashing_target := Vector2.ZERO
var current_target := Vector2.ZERO
var dash_time_elapsed: float = 0.0
var previous_position: Vector2
var dash_tween: Tween

var current_hp_sprite: Node2D = null

var query_offscreen := false

enum ACTION_STATES {
	Idle,
	Chase,
	Dash_Catchup,
	Dash_Attack_Windup,
	Dash_Attack,
	Dash_Attack_Followthrough,
}

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	HP = HP
	current_hp_sprite = $hp_sprites.get_node("health" + str(HP))
	current_hp_sprite.visible = true
	GOLEM_TYPE = (Wisp.Elements.values().pick_random())
	
	match GOLEM_TYPE:
		Wisp.Elements.Earth:
			$sprites/bubble_earth.visible = true
			for child: Node2D in find_children("drop_*"):
				if not child.name.contains("earth"):
					child.queue_free()
		Wisp.Elements.Air:
			$sprites/bubble_air.visible = true
			for child: Node2D in find_children("drop_*"):
				if not child.name.contains("air"):
					child.queue_free()
		Wisp.Elements.Fire:
			$sprites/bubble_fire.visible = true
			for child: Node2D in find_children("drop_*"):
				if not child.name.contains("fire"):
					child.queue_free()
		Wisp.Elements.Water:
			$sprites/bubble_water.visible = true
			for child: Node2D in find_children("drop_*"):
				if not child.name.contains("water"):
					child.queue_free()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	#if HP < 0.5 and query_offscreen:
		#if not $AnimationPlayer.is_playing():
			#$sprites.visible = false
	
	if debug_dashing:
		update_dash(delta)
	
	if not ACTIVE:
		return
	
	match action_state:
		ACTION_STATES.Idle:
			move_and_collide(velocity * delta)
			velocity = Vector2.ZERO
		ACTION_STATES.Chase:
			velocity = global_position.direction_to(Global.Player.global_position)
			move_and_collide(velocity * BASE_SPEED * delta)
			velocity = Vector2.ZERO
			
			if global_position.distance_to(Global.Player.global_position) < KEEP_DISTANCE_FROM_PLAYER:
				action_state = ACTION_STATES.Dash_Attack_Windup
		ACTION_STATES.Dash_Attack_Windup:
			dash_attack()
		ACTION_STATES.Dash_Attack:
			update_dash(delta)
		ACTION_STATES.Dash_Attack_Followthrough:
			pass

func dash_attack() -> void:
	$AnimationPlayer.play("windup")
	await $AnimationPlayer.animation_finished
	action_state = ACTION_STATES.Dash_Attack
	start_dash()
	#$environmental_collision_box.disabled = true
	set_collision_mask_value(2, false)
	set_collision_layer_value(3, false)
	$hitbox.monitoring = true
	await dash_finished
	#$environmental_collision_box.disabled = false
	set_collision_mask_value(2, true)
	set_collision_layer_value(3, false)
	$hitbox.monitoring = false
	dash_cooldown()
	await dash_cooldown_finished
	action_state = ACTION_STATES.Chase
	pass


func dash_cooldown() -> void:
	var timer := get_tree().create_timer(DASH_COOLDOWN_SECONDS)
	await timer.timeout
	emit_signal("dash_cooldown_finished")
	pass

func start_dash() -> void:
	dashing_target = global_position + global_position.direction_to(Global.Player.global_position) * DASH_LENGTH
	current_target = global_position
	dash_time_elapsed = 0.0
	previous_position = global_position
	
	dash_tween = create_tween()
	dash_tween.tween_property(self, "current_target", dashing_target, DASH_DURATION_SECONDS).\
		set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await dash_tween.finished
	
	dashing_target = Vector2.ZERO
	emit_signal("dash_finished")

func update_dash(delta: float) -> void:
	dash_time_elapsed += delta
	if dash_time_elapsed > DASH_DURATION_SECONDS:
		dash_time_elapsed = DASH_DURATION_SECONDS  # Clamp to max duration
	
	# Calculate velocity based on the change in position
	var new_position := previous_position.lerp(current_target, dash_time_elapsed / DASH_DURATION_SECONDS)
	velocity = (new_position - global_position) / delta
	
	move_and_collide(velocity * delta)
	previous_position = new_position

func push(push_vector: Vector2) -> void:
	velocity += push_vector

func send_damage(_body: Node2D) -> void:
	var effect := Effect.new()
	effect.damage = ATTACK_1_DAMAGE
	Global.Player.apply_effect(effect)

func apply_effect(effect: Effect) -> void:
	HP -= effect.damage
	push(effect.knockback)
	

func get_feet() -> Vector2:
	return $feet.global_position

func set_hitstun() -> void:
	$AnimationPlayer.stop()
	$AnimationPlayer.queue("RESET")
	action_state = ACTION_STATES.Idle
	if dash_tween:
		dash_tween.kill()
	pass

func finish_hitstun() -> void:
	action_state = ACTION_STATES.Chase
	print("hitstun end")

func _on_death_disappear_screen_exited() -> void:
	if HP > 0 or ACTIVE:
		return
	query_offscreen = true

func revitalize() -> void:
	$AnimationPlayer.play("RESET")
	HP = 3
	current_hp_sprite.visible = true
	for child: Node2D in current_hp_sprite.get_children():
		child.visible = false
	for child: Node2D in current_hp_sprite.get_children().slice(0, int(HP * 2)):
		child.visible = true
	var wisp: Node2D = wisp_scene.instantiate()
	wisp.name = "drop_"
	match GOLEM_TYPE:
		Wisp.Elements.Earth:
			wisp.name += "earth"
			wisp.TYPE = Wisp.Elements.Earth
		Wisp.Elements.Air:
			wisp.name += "air"
			wisp.TYPE = Wisp.Elements.Air
		Wisp.Elements.Fire:
			wisp.name += "fire"
			wisp.TYPE = Wisp.Elements.Fire
		Wisp.Elements.Water:
			wisp.name += "water"
			wisp.TYPE = Wisp.Elements.Water
	add_child(wisp)
	var wisp2: Node2D = wisp_scene.instantiate()
	wisp2.name = "drop_"
	match GOLEM_TYPE:
		Wisp.Elements.Earth:
			wisp2.name += "earth"
			wisp2.TYPE = Wisp.Elements.Earth
		Wisp.Elements.Air:
			wisp2.name += "air"
			wisp2.TYPE = Wisp.Elements.Air
		Wisp.Elements.Fire:
			wisp2.name += "fire"
			wisp2.TYPE = Wisp.Elements.Fire
		Wisp.Elements.Water:
			wisp2.name += "water"
			wisp2.TYPE = Wisp.Elements.Water
	add_child(wisp2)
