extends Camera2D

# Adjust the speed factor to your preference
@export var BASE_SPEED := 100.0
@export var MAX_SPEED := 500.0
@export var SPEED_SCALE := 5.0
@export var EASE_OUT_FACTOR := 0.1

# Speed of the camera movement
@export var SMOOTHING_SPEED := 5.0

# Maximum distance the camera can move towards the mouse
@export var MAX_OFFSET := 200.0
@export var MAX_DISTANCE := 100

@export_category("Tracking Polygons")
@export_file("*.tscn") var current_scene := ""
@export var polygon_restraint_target := ""

#@export
var polygon_restraint: Polygon2D

var velocity := Vector2.ZERO

func change_room(to: String) -> void:
	#var jump_to: Polygon2D = get_node('/root/world').find_child(to)
	polygon_restraint_target = to
	#var jump_to: Polygon2D = Global.CurrentLevel.camera_polygon_restraints[to]
	#for polygon: Polygon2D in Global.CurrentLevel.camera_polygon_restraints[to]:
		#if polygon.name == to:
			#jump_to = polygon
			#break
	#if jump_to == null:
		#return
	polygon_restraint = Global.CurrentLevel.camera_polygon_restraints[to]
	pass

func _ready() -> void:
	if current_scene == "":
		return
	polygon_restraint = Global.CurrentLevel.camera_polygon_restraints[polygon_restraint_target]
	#for polygon: Polygon2D in Global.CurrentLevel.camera_polygon_restraints[polygon_restraint_target].get_children():
		#if polygon.name == polygon_restraint_target:
			#polygon_restraint = polygon
			#break

func _process(delta: float) -> void:
	# Get the global mouse position
	var mouse_global_pos := get_global_mouse_position()

	# Get the global position of the camera
	var camera_global_pos := position

	# Get the player's position
	var player_pos := Global.Player.position

	# Calculate the direction vector from the player to the mouse
	var direction := (mouse_global_pos - player_pos).normalized()

	# Calculate the distance between the player and the mouse
	var distance := player_pos.distance_to(mouse_global_pos)

	# Calculate the target position by adding the direction vector scaled by max_offset to the player's position
	var target_pos: Vector2 = player_pos + direction * min(MAX_OFFSET, distance)

	# Interpolate smoothly towards the target position with friction
	var interpolated_position := camera_global_pos.lerp(target_pos, SMOOTHING_SPEED * delta)

	# Find the closest point within the polygon restraint
	var constrained_position := find_closest_point_to_polygon(interpolated_position, polygon_restraint)

	# Move towards the constrained position
	move_towards_target(constrained_position, delta)
	position = position.snapped(Vector2(0.1, 0.1))

func find_closest_point_to_polygon(point: Vector2, polygon: Polygon2D) -> Vector2:
	if not polygon:
		return point
	if polygon.polygon.size() == 1:
		return polygon.global_position + polygon.polygon[0]
	elif polygon.polygon.size() == 2:
		return Geometry2D.get_closest_point_to_segment(point, polygon.global_position + polygon.polygon[0], polygon.global_position + polygon.polygon[1])
	
	var transformed_points: Array[Vector2] = []
	for p: Vector2 in polygon.polygon:
		transformed_points.append(polygon.global_position + p)
	
	if Geometry2D.is_point_in_polygon(point, transformed_points):
		return point
	
	var closest_point := polygon.global_position + polygon.polygon[0]
	var min_distance := 100000.0
	
	for i: int in range(polygon.polygon.size()):
		var a := transformed_points[i]
		var b := transformed_points[(i + 1) % polygon.polygon.size()]
		var closest := Geometry2D.get_closest_point_to_segment(point, a, b)
		var distance := closest.distance_to(point)
		
		if distance < min_distance:
			min_distance = distance
			closest_point = closest
	
	return closest_point

func move_towards_target(target_position: Vector2, delta: float) -> void:
	var distance_to_target := position.distance_to(target_position)
	if distance_to_target == 0:
		return  # No movement if already at the target
	
	var t: float = clamp(distance_to_target / (BASE_SPEED * SPEED_SCALE), 0.0, 1.0)
	var eased_t := pow(1.0 - t, EASE_OUT_FACTOR)
	
	#print(Global.Player.velocity.distance_to(Vector2.ZERO))
	var speed := BASE_SPEED + (distance_to_target * SPEED_SCALE * eased_t) + Global.Player.velocity.distance_to(Vector2.ZERO)
	#speed = clamp(speed, BASE_SPEED, MAX_SPEED)
	
	# Calculate interpolation factor
	var interpolation_factor: float = min(((speed * delta) / distance_to_target), 1.0)
	position = position.lerp(target_position, interpolation_factor)
