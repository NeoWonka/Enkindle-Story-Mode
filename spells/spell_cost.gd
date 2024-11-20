class_name Spell_Cost
extends Resource

enum CursorState {
	None,
	Target,
	Special,
}

@export var cost := "1111"
@export var readable_name := ""
@export var cursor_state := CursorState.None

static func to_major_cost(the_cost: String) -> bool:
	var num_earth := the_cost.count("1")
	var num_air   := the_cost.count("2")
	var num_fire  := the_cost.count("3")
	var num_water := the_cost.count("4")
	
	var earth_succeed := true
	var air_succeed   := true
	var fire_succeed  := true
	var water_succeed := true
	
	if num_earth > 0:
		earth_succeed = Global.EarthWheel.elements_left >= num_earth
		
	if num_air > 0:
		air_succeed = Global.AirWheel.elements_left >= num_air
	
	if num_fire > 0:
		fire_succeed = Global.FireWheel.elements_left >= num_fire
	
	if num_water > 0:
		water_succeed = Global.WaterWheel.elements_left >= num_water
	
	var result := earth_succeed and air_succeed and fire_succeed and water_succeed and air_succeed
	if result:
		Global.EarthWheel.elements_left -= num_earth
		Global.AirWheel.elements_left -= num_air
		Global.FireWheel.elements_left -= num_fire
		Global.WaterWheel.elements_left -= num_water
	
	return result

static func to_conditional(the_cost: String) -> bool:
	var num_earth := the_cost.count("1")
	var num_air   := the_cost.count("2")
	var num_fire  := the_cost.count("3")
	var num_water := the_cost.count("4")
	
	var earth_succeed := true
	var air_succeed   := true
	var fire_succeed  := true
	var water_succeed := true
	
	if num_earth > 0:
		earth_succeed = Global.EarthWheel.elements_left > 0 or Global.EarthWheel.current_value > num_earth - 1
		
	if num_air > 0:
		air_succeed = Global.AirWheel.elements_left > 0 or Global.AirWheel.current_value > num_air - 1
	
	if num_fire > 0:
		fire_succeed = Global.FireWheel.elements_left > 0 or Global.FireWheel.current_value > num_fire - 1
	
	if num_water > 0:
		water_succeed = Global.WaterWheel.elements_left > 0 or Global.WaterWheel.current_value > num_water - 1
	
	var result := earth_succeed and air_succeed and fire_succeed and water_succeed and air_succeed
	if result:
		Global.EarthWheel.current_value -= num_earth
		Global.AirWheel.current_value -= num_air
		Global.FireWheel.current_value -= num_fire
		Global.WaterWheel.current_value -= num_water
	
	return result
