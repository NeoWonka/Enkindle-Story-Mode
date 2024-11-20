extends CharacterBody2D

@export var SPEED := 700
#NeoWonka 22:08 10/14/2024: Changed health for testing purposes
@export var BASE_HP := 100
var hp := BASE_HP:
	set(value):
		hp = value
		if hp <= 0.0:
			hp = BASE_HP
			
			Global.CurrentLevel._on_dungeon_exit_body_entered(null)
			Global.UI.delete_spells()
			
			#var listing := Global.spells_name.keys()
			#listing.shuffle()
			for spell: String in ["fireball","shield"]:
				var spell_cost: Resource = Global.spells_name[spell][0]
				Global.UI.load_spell(spell_cost)
@export var CAMERA_INPUT_UPDATE := 0.1
@export var DASH_DURATION_SECONDS := 0.2
@export var DASH_LENGTH := 350
@export var CAMERA_TRACKING_OFFSET := 200
@export var INTERACT_DISTANCE := 220
@export var ELEMENT_INPUT_TIMEOUT := 0.5:
	set (value):
		if is_inside_tree() and $element_input_timeout:
			$element_input_timeout.wait_time = value
@export var PUSH_STRENGTH := 70
@export var SLASH_DAMAGE := 0.5

@onready var camera_target: Vector2:
	get:
		return $cameratarget.global_position
var move_camera_target := true

@export var spells: Array[String] = []
#NeoWonka 20:53cst 10/14/2024: Adding spell inventory for "if" statements restricting casting.
@export var spell_inventory: Array[String] = ["fireball", "shield"]
var spell_input := ""
var currently_casting_spell_name := ""

signal interact

enum STATES {
	Normal,
	Crafting,
	Dash,
	Dash_Enter,
	Dash_Exit,
}

var state := STATES.Normal

var dashing_target := Vector2.ZERO
var current_target := Vector2.ZERO
var dash_previous_position := Vector2.ZERO
var dash_time_elapsed := 0.0

var slash_damage := Effect.new()
var damage_multiplier := 1.0


func _ready() -> void:
	hp = BASE_HP
	slash_damage.damage = SLASH_DAMAGE
	#$element_input_timeout.wait_time = ELEMENT_INPUT_TIMEOUT
	
	#var listing := ["fireball", "earthshock", "lightning", "dancing_wisps", "shield", "waterwave"]
	#listing.shuffle()
	for spell: String in spell_inventory:
		var spell_cost: Resource = Global.spells_name[spell][0]
		Global.UI.load_spell(spell_cost)

func get_input() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * SPEED

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("element_1"):
		spell_input += "1"
	if Input.is_action_just_pressed("element_2"):
		spell_input += "2"
	if Input.is_action_just_pressed("element_3"):
		spell_input += "3"
	if Input.is_action_just_pressed("element_4"):
		spell_input += "4"
	
	if state != STATES.Crafting:
		if currently_casting_spell_name == "" and spell_input != "":
			Global.UI.light_element_input(spell_input)
		
		# on Successful Spell input read
		#NeoWonka 22:40 10/14/2024: Changed spells list to the inventory array
		for spell: String in spell_inventory:
			var spell_res: Spell_Cost = Global.spells_name[spell][0]
			if spell_res.cost == spell_input:
				if spell in spell_inventory:
					if Spell_Cost.to_conditional(spell_res.cost):
						Global.UI.cursor_state = spell_res.cursor_state
						currently_casting_spell_name = spell_res.readable_name
						spell_input = ""
				else:
					if not $error.playing:
						$error.play()
				pass
				
		var special_activate := special_activated()
		if special_activate[0] == true:
			var to_launch: Node2D = null
			
			if currently_casting_spell_name != "":
				spell_input = ""
				Global.UI.reset_cast_indicator()
				to_launch = Global.spells_name[currently_casting_spell_name.to_lower().replace(" ", "_")][1].instantiate()
				to_launch.global_position = global_position
				
			if currently_casting_spell_name == "Fireball":
				if special_activate[1] != Vector2.ZERO:
					to_launch.rotate(special_activate[1].angle())
				else:
					to_launch.look_at(get_global_mouse_position())
					
				Global.Projectiles.add_child(to_launch)
			elif currently_casting_spell_name == "Earthshock":
				Global.Projectiles.add_child(to_launch)
			elif currently_casting_spell_name == "Dancing Wisps":
				if special_activate[1] != Vector2.ZERO:
					to_launch.rotate(special_activate[1].angle())
				else:
					to_launch.look_at(get_global_mouse_position())
					
				Global.Projectiles.add_child(to_launch)
				to_launch.global_position = global_position
			elif currently_casting_spell_name == "Lightning":
				Global.Projectiles.add_child(to_launch)
			elif currently_casting_spell_name == "Waterwave":
				if special_activate[1] != Vector2.ZERO:
					to_launch.rotate(special_activate[1].angle())
				else:
					to_launch.look_at(get_global_mouse_position())
					
				Global.Projectiles.add_child(to_launch)
			elif currently_casting_spell_name == "Shield":
				add_child(to_launch)
				pass
				
			if currently_casting_spell_name != "":
				currently_casting_spell_name = ""
				
	if spell_input.length() != 0 and $element_input_timeout.is_stopped():
		$element_input_timeout.start()
			
	match state:
		STATES.Normal:
			get_input()
			
			if Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized() != Vector2.ZERO:
				$object_interact.target_position = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized() * INTERACT_DISTANCE
				#if %AnimationTree.get("parameters/playback").get_current_node() != "slash":
					#%AnimationTree.get("parameters/playback").travel("move")
					#$slash_hitbox_down.monitoring = false
					#$slash_hitbox_left.monitoring = false
					#$slash_hitbox_right.monitoring = false
					#$slash_hitbox_up.monitoring = false
				%AnimationTree.set("parameters/move/BlendSpace2D/blend_position", Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized())
				%AnimationTree.set("parameters/idle/BlendSpace2D/blend_position", Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized())
				%AnimationTree.set("parameters/slash/BlendSpace2D/blend_position", Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized())
			else:
				%AnimationTree.get("parameters/playback").travel("idle")
		
			if Input.is_action_just_pressed("dash"):
				state = STATES.Dash_Enter
			
			if Input.is_action_just_pressed("interact") and $object_interact.is_colliding():
				if $object_interact.get_collider().name == "crafting":
					emit_signal("interact", $object_interact.get_collider())
					state = STATES.Crafting
				
			if Input.is_action_just_pressed("slash"):
				%AnimationTree.get("parameters/playback").travel("slash", false)
			
			var collision := move_and_collide(velocity * delta)
			if collision:
				handle_collision(collision)
		STATES.Crafting:
			Global.UI.light_cost_spell_input(spell_input)
			Global.UI.light_cost_fire_input(spell_input)
			if spell_input == Global.UI.spell_cost.cost:
				if Spell_Cost.to_major_cost(spell_input):
					Global.UI.load_spell(Global.UI.spell_cost)
					Global.UI.spell_cost = Global.UI.randomize_spell()
					spell_input = ""
			if spell_input == Global.UI.fire_cost:
				if Spell_Cost.to_major_cost(spell_input):
					Global.UI.load_fire_benefit()
					spell_input = ""
			if Input.is_action_just_pressed("dash"):
				Global.UI.load_rest_benefit()
			if Input.is_action_just_pressed("interact") and $object_interact.is_colliding():
				emit_signal("interact", $object_interact.get_collider())
				state = STATES.Normal
			pass
		STATES.Dash_Enter:
			var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
			dashing_target = position + direction * DASH_LENGTH
			dash_previous_position = position
			dash_time_elapsed = 0.0
			
			var tween := create_tween()
			current_target = position
			tween.tween_property(self, "current_target", dashing_target, DASH_DURATION_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.finished.connect(_on_dash_timeout)
			state = STATES.Dash
			pass
		STATES.Dash:
			dash_time_elapsed += delta
			if dash_time_elapsed > DASH_DURATION_SECONDS:
				dash_time_elapsed = DASH_DURATION_SECONDS  # Clamp to max duration
			
			# Calculate velocity based on the change in position
			var new_position := dash_previous_position.lerp(current_target, dash_time_elapsed / DASH_DURATION_SECONDS)
			velocity = (new_position - position) / delta
			
			move_and_collide(velocity * delta)
			dash_previous_position = new_position
			pass
		STATES.Dash_Exit:
			dashing_target = Vector2.ZERO
			state = STATES.Normal
			pass

func special_activated() -> Array:
	var mouse_special := Input.is_action_just_pressed("special")
	var joystick_special := Input.get_vector("special_left", "special_right", "special_up", "special_down")
	return [mouse_special || joystick_special != Vector2.ZERO, joystick_special]

func handle_collision(collision: KinematicCollision2D) -> void:
	var collider := collision.get_collider()
	if collider and not collider is TileMap:
		if collider.has_method("push"):
			collider.push(-collision.get_normal().normalized() * PUSH_STRENGTH)

func apply_effect(effect: Effect) -> void:
	hp -= (effect.damage * damage_multiplier)

func _on_dash_timeout() -> void:
	state = STATES.Dash_Exit

func _on_cameratarget_update_timeout() -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Check if the input vector is not zero
	if input_vector != Vector2.ZERO:
		# Restrict movement to cardinal directions
		var cardinal_vector := Vector2.ZERO
		if abs(input_vector.x) > abs(input_vector.y):
			# Horizontal movement (left or right)
			cardinal_vector.x = sign(input_vector.x)
		else:
			# Vertical movement (up or down)
			cardinal_vector.y = sign(input_vector.y)

		# Update the camera target position
		$cameratarget.position = cardinal_vector.normalized() * CAMERA_TRACKING_OFFSET
	pass # Replace with function body.

func _on_element_input_timeout_timeout() -> void:
	spell_input = ""
	if currently_casting_spell_name == "":
		Global.UI.reset_cast_indicator()
	Global.UI.reset_camp_indicators()


func _on_slash_hitbox_up_area_entered(area: Area2D) -> void:
	area.get_parent().apply_effect(slash_damage)
	pass # Replace with function body.


func _on_slash_hitbox_left_area_entered(area: Area2D) -> void:
	area.get_parent().apply_effect(slash_damage)
	pass # Replace with function body.


func _on_slash_hitbox_right_area_entered(area: Area2D) -> void:
	area.get_parent().apply_effect(slash_damage)
	pass # Replace with function body.


func _on_slash_hitbox_down_area_entered(area: Area2D) -> void:
	area.get_parent().apply_effect(slash_damage)
	pass # Replace with function body.
