extends Control

func play(anim: String) -> void:
	$AnimationPlayer.play(anim)
	
func stop() -> void:
	$AnimationPlayer.stop()
