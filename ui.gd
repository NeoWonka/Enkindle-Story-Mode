extends CanvasLayer

var cursor_state: int = Spell_Cost.CursorState.None
var fire_cost: String
var spell_cost: Spell_Cost
var loaded_spells: Array[Spell_Cost] = []
var spells_inventory: Array[String] = Character.spell_inventory

func _ready() -> void:
	Global.switch0_entered.connect(_on_switch0_entered)
	$magic.modulate.a = 0
	spell_cost = randomize_spell()
	fire_cost = randomize_fire(spell_cost.cost)
	randomize_rest()

func _on_switch0_entered() -> void:
	create_tween().tween_property($magic, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

func _process(_delta: float) -> void:
	$recticle.global_position = $recticle.get_global_mouse_position()
	$fist.global_position = $fist.get_global_mouse_position()
	match cursor_state:
		Spell_Cost.CursorState.None:
			$recticle.visible = false
			$fist.visible = false
			pass
		Spell_Cost.CursorState.Target:
			$recticle.visible = true
			pass
		Spell_Cost.CursorState.Special:
			$fist.visible = true
			pass
	$debug_current_room.text = "HP: " + str(Global.Player.hp)
	%spell_timeout.text = Global.seconds_to_string($new_spell.time_left)
	
func load_spell(spell: Spell_Cost) -> bool:
	if spell in loaded_spells:
		return false
	loaded_spells.append(spell)
	var the_slot: Node2D = null
	for node: Node2D in [$magic/Spellslots1, $magic/Spellslots2, $magic/Spellslots3]:
		if node.get_node("nametag/Label").text == "":
			the_slot = node
			break
	if the_slot:
		the_slot.get_node("nametag").visible = true
		the_slot.get_node("nametag/Label").visible = true
		the_slot.get_node("nametag/Label").text = spell.readable_name
		for i in range(spell.cost.length()):
			var ch := spell.cost[i]
			the_slot.get_node("slot" + str(i + 1)).get_node(ch).visible = true
			the_slot.get_node("slot" + str(i + 1) + "/keys/1").visible = false
			the_slot.get_node("slot" + str(i + 1) + "/keys/2").visible = false
			the_slot.get_node("slot" + str(i + 1) + "/keys/3").visible = false
			the_slot.get_node("slot" + str(i + 1) + "/keys/4").visible = false
			the_slot.get_node("slot" + str(i + 1) + "/keys/" + ch).visible = true
	return the_slot != null

func light_element_input(input: String) -> void:
	# List of nodes to check
	var nodes := [$magic/Spellslots1, $magic/Spellslots2, $magic/Spellslots3]
	
	# Iterate through each node
	for node: Node2D in nodes:
		var cumulative_match := true  # Start with cumulative match set to true

		# Iterate through each character in the input string
		for i in range(input.length()):
			var symbol_path := "slot" + str(i + 1) + "/keys/" + input[i]
			var symbol: Label = node.get_node(symbol_path)

			# If cumulative match is still true and the symbol is visible
			if cumulative_match and symbol.visible:
				symbol.material.set("shader_parameter/enable", true)
			else:
				node.get_node("slot" + str(i + 1) + "/keys/1").material.set("shader_parameter/enable", false)
				node.get_node("slot" + str(i + 1) + "/keys/2").material.set("shader_parameter/enable", false)
				node.get_node("slot" + str(i + 1) + "/keys/3").material.set("shader_parameter/enable", false)
				node.get_node("slot" + str(i + 1) + "/keys/4").material.set("shader_parameter/enable", false)
				cumulative_match = false  # Set to false if the match breaks
	return

func light_cost_fire_input(input: String) -> void:
	var cumulative_match := true
	for i in range(input.length()):
		var symbol_node := %cost_fire.get_child(i)
		var symbol: Sprite2D = symbol_node.get_child(int(input[i]) - 1)
		
		if cumulative_match and symbol.visible:
			symbol.modulate = Color.WHITE
		else:
			symbol_node.get_child(0).modulate = Color.BLACK
			symbol_node.get_child(1).modulate = Color.BLACK
			symbol_node.get_child(2).modulate = Color.BLACK
			symbol_node.get_child(3).modulate = Color.BLACK
			cumulative_match = false

func light_cost_spell_input(input: String) -> void:
	var cumulative_match := true
	for i in range(input.length()):
		var symbol_node := %cost_spell.get_child(i)
		var symbol: Sprite2D = symbol_node.get_child(int(input[i]) - 1)
		
		if cumulative_match and symbol.visible:
			symbol.modulate = Color.WHITE
		else:
			symbol_node.get_child(0).modulate = Color.BLACK
			symbol_node.get_child(1).modulate = Color.BLACK
			symbol_node.get_child(2).modulate = Color.BLACK
			symbol_node.get_child(3).modulate = Color.BLACK
			cumulative_match = false

func reset_camp_indicators() -> void:
	for rect: TextureRect in %cost_fire.get_children():
		for sprite: Sprite2D in rect.get_children():
			sprite.modulate = Color.BLACK
	for rect: TextureRect in %cost_spell.get_children():
		for sprite: Sprite2D in rect.get_children():
			sprite.modulate = Color.BLACK

func reset_cast_indicator() -> void: # turns `keys` children black
	cursor_state = Spell_Cost.CursorState.None
	var nodes := [
		get_node("magic/Spellslots1/slot1/keys"),
		get_node("magic/Spellslots1/slot2/keys"),
		get_node("magic/Spellslots1/slot3/keys"),
		get_node("magic/Spellslots1/slot4/keys"),
		get_node("magic/Spellslots2/slot1/keys"),
		get_node("magic/Spellslots2/slot2/keys"),
		get_node("magic/Spellslots2/slot3/keys"),
		get_node("magic/Spellslots2/slot4/keys"),
		get_node("magic/Spellslots3/slot1/keys"),
		get_node("magic/Spellslots3/slot2/keys"),
		get_node("magic/Spellslots3/slot3/keys"),
		get_node("magic/Spellslots3/slot4/keys"),
	]
	
	for node: Node2D in nodes:
		var children: Array = node.get_children()
		for child: Label in children:
			child.material.set_shader_parameter("enable", false)

func randomize_fire(exclude: String) -> String:
	var cost := Global.get_random_cost(Global.fire_cost_progression[Global.fire_gain_current], exclude)
	for i in range(4):
		%cost_fire.get_child(i).modulate = Color.TRANSPARENT
		for child: Sprite2D in %cost_fire.get_child(i).get_children():
			child.visible = false
	for i in range(cost.length()):
		%cost_fire.get_child(i).texture.region = Rect2(23 * ((int(cost[i]) - 1)), 0, 23, 22)
		%cost_fire.get_child(i).modulate = Color.WHITE
		%cost_fire.get_child(i).get_child(int(cost[i]) - 1).visible = true
		
	var time_gain: String = Global.time_gain_progression[Global.fire_gain_current]
	var hearts_gain: int = Global.hearts_gain_progression[Global.fire_gain_current]
	
	%fire_time_gain.text = time_gain 
	
	match hearts_gain:
		0:
			%the_and_label.modulate = Color.TRANSPARENT
			%heart0.visible = false
			%heart1.visible = false
			%heart2.visible = false
		1:
			%the_and_label.modulate = Color.WHITE
			%heart0.visible = true
			%heart1.visible = false
			%heart2.visible = false
		2:
			%the_and_label.modulate = Color.WHITE
			%heart0.visible = true
			%heart1.visible = true
			%heart2.visible = false
		3:
			%the_and_label.modulate = Color.WHITE
			%heart0.visible = true
			%heart1.visible = true
			%heart2.visible = true
	return cost
#NeoWonka 22:05 10/14/2024: Changed randomize_spell to read the spell_inventory, and reroll if that spell is already in the inventory.	
func randomize_spell() -> Spell_Cost:
	#spell_cost := Global.get_random_spell_cost()
	if spell_cost.readable_name in spells_inventory:
		while spell_cost.readable_name in spells_inventory:
			Global.get_random_spell_cost()
			return spell_cost
	#var tries := 5
	#while tries > 0 and (fire_cost.begins_with(spell_cost.cost) or spell_cost in loaded_spells):
		#spell_cost = Global.get_random_spell_cost()
		#tries -= 1
	var cost := spell_cost.cost
	
	%reward_spell.text = spell_cost.readable_name
	
	for i in range(4):
		%cost_spell.get_child(i).modulate = Color.TRANSPARENT
		for child: Sprite2D in %cost_spell.get_child(i).get_children():
			child.visible = false
	for i in cost.length():
		%cost_spell.get_child(i).texture.region = Rect2(23 * ((int(cost[i]) - 1)), 0, 23, 22)
		%cost_spell.get_child(i).modulate = Color.WHITE
		%cost_spell.get_child(i).get_child(int(spell_cost.cost[i]) - 1).visible = true
	return spell_cost
	
func randomize_rest() -> void:
	var time_spend: String = Global.time_spend_progression[Global.time_spend_current]
	%cost_rest.text = time_spend + " and reroll this menu"
	pass

func load_fire_benefit() -> void:
	Global.CurrentLevel.get_node("time_left").wait_time =\
		Global.string_to_seconds(Global.time_gain_progression[Global.fire_gain_current])\
		+ Global.time_left
	Global.CurrentLevel.get_node("time_left").start()
	Global.Player.BASE_HP += Global.hearts_gain_progression[Global.fire_gain_current]
	Global.Player.hp += Global.hearts_gain_progression[Global.fire_gain_current]
	if Global.Player.hp > Global.Player.BASE_HP:
		Global.Player.hp = Global.Player.BASE_HP
	Global.fire_gain_current += 1
	fire_cost = randomize_fire(spell_cost.cost)
	pass

func delete_spells() -> void:
	loaded_spells.clear()
	var slots: Array = [%Spellslots1, %Spellslots2, %Spellslots3]
	for slot: Node2D in slots:
		for child: CanvasItem in slot.get_children():
			if child.name == "nametag":
				child.visible = false
				child.get_node("Label").text = ""
			else:
				for inner_child: CanvasItem in child.get_children():
					if inner_child.name == "keys":
						for even_inner_child: CanvasItem in inner_child.get_children():
							even_inner_child.visible = false
					else:
						inner_child.visible = false

func load_rest_benefit() -> void:
	Global.Player.hp = Global.Player.BASE_HP
	
	var time_spend: String = Global.time_spend_progression[Global.time_spend_current]
	%cost_rest.text = time_spend + " and reroll this menu"
	
	Global.CurrentLevel.get_node("time_left").wait_time =\
		Global.time_left\
		- Global.string_to_seconds(Global.time_spend_progression[Global.time_spend_current])
	Global.CurrentLevel.get_node("time_left").start()
	
	Global.time_spend_current += 1
	
	randomize_rest()	
	spell_cost = randomize_spell()
	fire_cost = randomize_fire(spell_cost.cost)
	
	$new_spell.start()

func _on_new_spell_timeout() -> void:
	spell_cost = randomize_spell()
