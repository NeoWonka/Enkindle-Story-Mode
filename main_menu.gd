extends Control

func _on_button_pressed() -> void:
	$Label.visible = false
	$skip.visible = true
	$VBoxContainer.visible = false
	$global_text.play("a_intro")
	await $global_text.get_node("AnimationPlayer").animation_finished
	$AudioStreamPlayer.stop()
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		$global_text.stop()
		$AudioStreamPlayer.stop()
		visible = false
