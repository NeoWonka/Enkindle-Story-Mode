@tool
extends Node2D

@export_enum("EarthWheel", "AirWheel", "FireWheel", "WaterWheel") var which_wheel := "FireWheel"

func _on_area_2d_body_entered(_body: Node2D) -> void:
	Global.get(which_wheel).elements_left += 1
	Global.get(which_wheel).current_value = 5
	pass # Replace with function body.

func _process(_delta: float) -> void:
	match which_wheel:
		"EarthWheel":
			$ColorRect.color = Color('9cba63')
		"AirWheel":
			$ColorRect.color = Color.WHITE
		"FireWheel":
			$ColorRect.color = Color('ff7d7d')
		"WaterWheel":
			$ColorRect.color = Color.CYAN
