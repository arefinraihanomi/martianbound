extends Node

func _ready() -> void:
	print("--- BEGIN SIMULATION GAMEPLAY & SAVE/LOAD TEST ---")
	
	# 1. Start mission
	GameState.start_new_mission()
	print("Mission started: Sol = ", GameState.current_sol, ", O2 = ", GameState.resources["oxygen"]["current"])
	assert(GameState.current_sol == 1)
	assert(GameState.resources["oxygen"]["current"] == 850.0)
	
	# 2. Test Resource modifications & consumption
	GameState.modify_resource("oxygen", -50.0)
	assert(GameState.resources["oxygen"]["current"] == 800.0)
	GameState.modify_resource("water", -20.0)
	assert(GameState.resources["water"]["current"] == 600.0)
	print("Resources modified successfully.")
	
	# 3. Test Objectives completion
	for obj in GameState.objectives:
		if obj["id"] == "primary_water":
			obj["status"] = "COMPLETED"
		if obj["id"] == "comms_dish":
			obj["status"] = "COMPLETED"
	print("Objectives updated: primary_water and comms_dish marked completed.")
	
	# 4. Test Discovery recording
	GameState.discoveries.append({
		"name": "Anomalous Silicate Basalt Core",
		"location": "Sector 4 Crater",
		"sol": GameState.current_sol,
		"desc": "Layered basalt exhibits unnatural harmonic acoustic resonance."
	})
	assert(GameState.discoveries.size() == 1)
	print("Discovery registered: ", GameState.discoveries[0]["name"])
	
	# 5. Test Local Save & Load
	var save_ok = GameState.save_game()
	assert(save_ok == true)
	assert(GameState.has_save_file() == true)
	print("Save game successful.")
	
	# Change memory values
	GameState.resources["oxygen"]["current"] = 10.0
	GameState.current_sol = 99
	
	# Reload from save
	var load_ok = GameState.load_game()
	assert(load_ok == true)
	assert(GameState.current_sol == 1)
	assert(GameState.resources["oxygen"]["current"] == 800.0)
	assert(GameState.discoveries.size() == 1)
	print("Load game verified: all mission state restored accurately.")
	
	print("--- SIMULATION & PERSISTENCE TEST PASSED SUCCESSFULLY ---")
	get_tree().quit(0)
