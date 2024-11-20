@tool
extends Node2D

var current_angle := -1.6
var min_angle := -1.6
var max_angle := 4.7

@export var elements_left := 2:
	set(value):
		elements_left = value
		if elements_left == 0:
			current_value = 0
		elif value < elements_left:
			current_value = 6
		if $Label != null:
			$Label.text = str(value)
@export var current_value: int = 6:
	set(value):
		if value < 1 and elements_left > 0:
			elements_left -= 1
			if elements_left > 0:
				current_value = 6
			else:
				current_value = 0
		else:
			current_value = value
		var temp := ((min_angle * -1) + max_angle) / 100
		# 100 / MAX_VALUE
		current_angle = max_angle - (17 * current_value * temp)
		queue_redraw()

@export var meter_color := Color('#71e958'):
	set(value):
		meter_color = value
		queue_redraw()

func _draw() -> void:
	draw_meter(40, 37/1.2, meter_color, current_angle)

func draw_meter(size: float, width: float, color: Color, current: float) -> void:
	draw_arc(Vector2.ZERO, size, max_angle, min_angle, 800, Color(0,0,0,0.5), width, true)
	draw_arc(Vector2.ZERO, size, max_angle, current, 800, color, width, true)
	pass

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
