extends TileMap

func _ready() -> void:
	for child in get_children():
		if child is Polygon2D:
			Global.CurrentLevel.camera_polygon_restraints[child.name] = child
			child.color.a = 0


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass
