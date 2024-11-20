extends Node

var Camera: Camera2D
var Player: CharacterBody2D
var Projectiles: Node
var CurrentLevel: Node2D
var UI: CanvasLayer

var EarthWheel: Node2D
var AirWheel: Node2D
var FireWheel: Node2D
var WaterWheel: Node2D

var camp_entrance: Marker2D
var camp_camera_snap: Marker2D

@export var spells_name := {}
@export var spells_cost := {}

var time_left := 0
var times_increased_time := 0

var time_gain_progression := ["00:30", "00:45", "1:00", "1:15", "1:30", "2:00", "2:15", "2:30", "3:00", "3:15", "3:30", "4:00"]
var hearts_gain_progression := [0, 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3]
var fire_cost_progression := [1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4]
var time_spend_progression := ["01:00", "01:15", "01:30", "02:00", "03:00", "03:30", "04:00"]
var fire_gain_current := 0:
	set(value):
		if value > time_gain_progression.size() - 1:
			value = time_gain_progression.size() - 1
		
		fire_gain_current = value
var time_spend_current := 0:
	set(value):
		if value > time_spend_progression.size() - 1:
			value = time_spend_progression.size() - 1
		
		time_spend_current = value

var audios := {}

signal switch0_entered


func _ready() -> void:
	var min_size := Vector2.ZERO
	min_size.x = ProjectSettings.get_setting('display/window/size/viewport_width')
	min_size.y = ProjectSettings.get_setting('display/window/size/viewport_height')
	get_window().min_size = min_size
	
	var spell_path := "res://spells/"
	var spell_dir: DirAccess = null
	
	spell_dir = DirAccess.open(spell_path)
	spell_dir.list_dir_begin()
	var file_name := spell_dir.get_next()
	while file_name != "":
		if ".tres" in file_name:
			var path := ""
			### ON RELEASE:
			path = spell_dir.get_current_dir() + "/" + file_name.get_file().replace(".import", "").replace(".tscn", "").replace(".remap", "")
			## OTHERWISE
			# path = spell_path + file_name
			## END ON RELEASE
			var spell_cost := ResourceLoader.load(path)
			
			if not spells_cost.has(spell_cost.cost):
				spells_cost[spell_cost.cost] = []
			spells_cost[spell_cost.cost].append([spell_cost, load(path.replace("tres", "tscn"))])
			print(spells_cost[spell_cost.cost])
			spells_name[spell_cost.readable_name.to_lower().replace(" ", "_")] = ([spell_cost, load(path.replace("tres", "tscn"))])
		file_name = spell_dir.get_next()

	Camera = get_node('/root/world/camera')
	Player = get_node('/root/world/character')
	Projectiles = get_node('/root/world/projectiles')
	EarthWheel = get_node('/root/world/ui/magic/earth')
	AirWheel = get_node('/root/world/ui/magic/air')
	FireWheel = get_node('/root/world/ui/magic/fire')
	WaterWheel = get_node('/root/world/ui/magic/water')
	CurrentLevel = get_node('/root/world/level')
	UI = get_node('/root/world/ui')
	
	if Player:
		Player.interact.connect(_on_player_interact)

func _process(_delta: float) -> void:
	if not CurrentLevel:
		return
	time_left = floor(CurrentLevel.get_node("time_left").time_left)

func change_room(to: String, enable_enemies_in: String, disable_enemies_in: String) -> void:
	for enemy: Node2D in CurrentLevel.camera_polygon_restraints[Camera.polygon_restraint_target].get_children():
		enemy.ACTIVE = false
	Camera.change_room(to)
	if enable_enemies_in != "":
		for enemy: Node2D in CurrentLevel.camera_polygon_restraints[enable_enemies_in].get_children():
			enemy.ACTIVE = true
			enemy.action_state = Enemy.ACTION_STATES.Chase
			if enemy.HP <= 0:
				enemy.revitalize()
		Global.CurrentLevel.find_child("outlands").get_node("darkness").color = Color("#080808")
			
	if disable_enemies_in != "":
		for enemy: Node2D in CurrentLevel.camera_polygon_restraints[disable_enemies_in].get_children():
			enemy.ACTIVE = false
			enemy.action_state = Enemy.ACTION_STATES.Idle
		Global.CurrentLevel.find_child("outlands").get_node("darkness").color = Color("#363636")
	if has_signal(to + "_entered"):
		emit_signal(to + "_entered")

func get_random_spell() -> PackedScene:
	for spell: String in ["fireball", "earthshock", "lightning", "dancing_wisps", "shield", "waterwave"]:
		var _spell_res: Spell_Cost = Global.spells_name[spell][0]
	var keys := spells_cost.keys()
	keys.shuffle()
	var spells: Array = spells_cost[keys[0]]
	spells.shuffle()
	return spells[0][1]
	pass
	
func get_random_spell_cost() -> Spell_Cost:
	var keys := spells_cost.keys()
	keys.shuffle()
	var spells: Array = spells_cost[keys[0]]
	spells.shuffle()
	return spells[0][0]
	pass

func get_random_cost(length: int, exclude: String) -> String:
	var result := ""
	var numbers: Array[String] = ["1", "2", "3", "4"]
	
	while true:
		result = ""
		for i in range(length):
			var random_number := numbers[randi() % numbers.size()]
			result += random_number
			
		if not exclude.begins_with(result):
			break
	
	return result

func string_to_seconds(format: String) -> int:
	var time_parts := format.split(":")
	return int(time_parts[0]) * 60 + int(time_parts[1])
	
func seconds_to_string(time: int) -> String:
	var seconds: int = time%60
	var minutes: int = (time/60)%60
	var hours: int = (time/60)/60
	
	#returns a string with the format "HH:MM:SS"
	return "%02d:%02d:%02d" % [hours, minutes, seconds]


func _on_player_interact(collider: Node2D) -> void:
	if collider.name == "crafting":
		if UI.get_node("crafting").visible == false:
			UI.get_node("AnimationPlayer").play("crafting")
		else:
			UI.get_node("AnimationPlayer").play_backwards("crafting")
	return
