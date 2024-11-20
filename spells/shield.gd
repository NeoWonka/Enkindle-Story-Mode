extends Spell

@export var SHIELD_TIMER := 1.0
@export var POWER_SHIELD_DURATION := 0.5
@export var POWER_SHIELD_DAMAGE := 2.5

func _ready() -> void:
	position = Vector2.ZERO
	Global.Player.damage_multiplier = 0.0

func _process(_delta: float) -> void:
	var timer := get_tree().create_timer(SHIELD_TIMER)
	var powershield_timer := get_tree().create_timer(POWER_SHIELD_DURATION)
	timer.timeout.connect(_on_timer_timeout)
	powershield_timer.timeout.connect(_on_powershield_drop)
	return

func _on_timer_timeout() -> void:
	Global.Player.damage_multiplier = 1.0
	queue_free()

func _on_powershield_drop() -> void:
	$Sprite2D.frame = 0
	$reflect.monitoring = false

func _on_reflect_area_entered(area: Area2D) -> void:
	var effect := Effect.new()
	effect.damage = POWER_SHIELD_DAMAGE
	area.get_parent().apply_effect(effect)
	pass # Replace with function body.
