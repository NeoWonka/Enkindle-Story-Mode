@tool
extends ColorRect

#@export_category("Current Scene")
#@export_file("*.tscn") var this_level := ""
#@export var snap_camera_to_polygon := ""
#@export var snap_camera_to_polygon_swap := ""
#
#@export_category("Next Scene")
#@export_file("*.tscn") var connect_to_scene := ""
#@export var next_area_load_radius := 50
#@export var next_area_load_visible := false
#@export var load_next_scene_at: Marker2D = null

@export var switch_to: Polygon2D
@export var enable_enemies_in: Polygon2D
@export var disable_enemies_in: Polygon2D
@export var cameraswitch_visible := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	%cameraswitch/CollisionShape2D.global_position = position
	%cameraswitch/CollisionShape2D.global_position.x += size.x / 2
	%cameraswitch/CollisionShape2D.global_position.y += size.y / 2
	%cameraswitch/CollisionShape2D.shape.size = size
	visible = false

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	%cameraswitch/CollisionShape2D.global_position = position
	%cameraswitch/CollisionShape2D.global_position.x += size.x / 2
	%cameraswitch/CollisionShape2D.global_position.y += size.y / 2
	%cameraswitch/CollisionShape2D.shape.size = size
	%cameraswitch.visible = cameraswitch_visible
	%cameraswitch/CollisionShape2D.visible = cameraswitch_visible


func _on_cameraswitch_body_entered(_body: Node2D) -> void:
	var enable := ""
	if enable_enemies_in:
		enable = enable_enemies_in.name
	var disable := ""
	if disable_enemies_in:
		disable = disable_enemies_in.name
	Global.change_room(switch_to.name, enable, disable)
	set_deferred("monitoring", false)
	pass # Replace with function body.
