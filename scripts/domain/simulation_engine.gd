class_name SimulationEngine
extends RefCounted


func process_tick(state: MissionState, delta_time: float) -> void:
	if state.mission_completed or state.mission_failed:
		return

	state.mission_time += delta_time

	_consume_resources(state, delta_time)
	_update_crew_health(state)
	_check_mission_status(state)


func _consume_resources(state: MissionState, delta_time: float) -> void:
	# Crew consumes basic resources over time
	state.oxygen -= 0.5 * delta_time
	state.water -= 0.3 * delta_time
	state.food -= 0.2 * delta_time

	# Base power consumption
	state.power -= 0.4 * delta_time

	# Keep values within valid range
	state.oxygen = max(state.oxygen, 0.0)
	state.water = max(state.water, 0.0)
	state.food = max(state.food, 0.0)
	state.power = max(state.power, 0.0)


func _update_crew_health(state: MissionState) -> void:
	# Crew health decreases when essential resources are critically low
	if state.oxygen <= 0.0:
		state.crew_health -= 5.0

	if state.water <= 0.0:
		state.crew_health -= 3.0

	if state.food <= 0.0:
		state.crew_health -= 2.0

	state.crew_health = clamp(state.crew_health, 0.0, 100.0)


func _check_mission_status(state: MissionState) -> void:
	if state.crew_health <= 0.0:
		state.fail_mission("Crew health reached zero.")
		return

	if state.power <= 0.0:
		state.fail_mission("Power ran out.")
		return

	if state.mission_time >= state.mission_duration:
		state.complete_mission()
