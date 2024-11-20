extends Polygon2D

var golems := []
@export var delete_wall: CharacterBody2D
@export var delete_wall2: CharacterBody2D

func _ready() -> void:
	golems = get_children()

func _process(_delta: float) -> void:
	if check():
		if delete_wall and is_instance_valid(delete_wall):
			delete_wall.queue_free()
		if delete_wall2 and is_instance_valid(delete_wall2):
			delete_wall2.queue_free()
	pass

func check() -> bool:
	for child: Node2D in golems:
		if child.HP <= 0:
			continue
		else:
			return false
	return true
