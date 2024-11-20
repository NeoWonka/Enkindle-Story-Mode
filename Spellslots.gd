extends Node2D

@export var key_input_label: Label

func _process(_delta: float) -> void:
	$slot1.get_node('keys').modulate = Color.BLACK
	$slot2.get_node('keys').modulate = Color.BLACK
	$slot3.get_node('keys').modulate = Color.BLACK
	$slot4.get_node('keys').modulate = Color.BLACK
	if key_input_label.text.length() > 4:
		return
	var chars := key_input_label.text.split()
	if chars[0] == "":
		return
	for i in range(chars.size()):
		var slot: Node2D = get_child(i)
		if slot.get_node('keys/' + chars[i]).visible:
			slot.get_node('keys').modulate = Color.WHITE
