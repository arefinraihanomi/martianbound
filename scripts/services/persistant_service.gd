class_name PersistenceService
extends RefCounted


const SAVE_PATH := "user://martianbound_save.json"


func save_mission(state: MissionState) -> void:
	var save_data := {
		"mission_time": state.mission_time,
		"crew_count": state.crew_count,
		"crew_health": state.crew_health,

		"power": state.power,
		"water": state.water,
		"oxygen": state.oxygen,
		"food": state.food,

		"radiation_shielding": state.radiation_shielding,
		"budget": state.budget,

		"mission_completed": state.mission_completed,
		"mission_failed": state.mission_failed,
		"failure_reason": state.failure_reason
	}

	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)

	if file == null:
		return

	file.store_string(
		JSON.stringify(save_data)
	)

	file.close()


func load_mission(state: MissionState) -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	if file == null:
		return false

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()

	if json.parse(json_text) != OK:
		return false

	var data: Dictionary = json.data

	state.mission_time = data.get("mission_time", 0.0)
	state.crew_count = data.get("crew_count", 4)
	state.crew_health = data.get("crew_health", 100.0)

	state.power = data.get("power", 100.0)
	state.water = data.get("water", 100.0)
	state.oxygen = data.get("oxygen", 100.0)
	state.food = data.get("food", 100.0)

	state.radiation_shielding = data.get(
		"radiation_shielding",
		100.0
	)

	state.budget = data.get("budget", 1000.0)

	state.mission_completed = data.get(
		"mission_completed",
		false
	)

	state.mission_failed = data.get(
		"mission_failed",
		false
	)

	state.failure_reason = data.get(
		"failure_reason",
		""
	)

	return true
