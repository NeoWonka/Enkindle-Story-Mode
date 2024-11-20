class_name Level
extends Node2D

signal polygon_restraints_found

func _ready() -> void:
	Global.audios[name] = $AudioStreamPlayer
	if find_child("darkness"):
		$darkness.color = Color('#363636')
	for child in get_children():
		if child is Polygon2D:
			Global.CurrentLevel.camera_polygon_restraints[child.name] = child
			child.color.a = 0

func _process(_delta: float) -> void:
	var seconds: int = Global.time_left%60
	var minutes: int = (Global.time_left/60)%60
	var hours: int = (Global.time_left/60)/60
	
	#returns a string with the format "HH:MM:SS"
	if find_child("time_left"):
		$time_left.text = "%02d:%02d:%02d" % [hours, minutes, seconds]

func darkness_visible() -> void:
	$darkness.visible = true
