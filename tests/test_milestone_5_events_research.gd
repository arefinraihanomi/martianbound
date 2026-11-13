extends Node

func _ready() -> void:
	print("--- COMMENCING MILESTONE 5: EVENTS, RESEARCH & OBJECTIVES TEST ---")
	
	# 1. Start fresh mission
	GameState.start_new_mission()
	assert(GameState.objectives.size() >= 7, "Default objectives must include at least 7 directives")
	assert(GameState.discoveries.size() == 0, "Initial discoveries should be empty")
	print("Verified: Starting objectives initialized with %d directives." % GameState.objectives.size())
	
	# 2. Test Objective Progression & Chaining
	var initial_completed = GameState.get_completed_objectives_count()
	assert(initial_completed == 1, "Only life_support should be completed at touchdown")
	
	var res_comms = GameState.complete_objective("comms_dish")
	assert(res_comms == true, "Completing comms_dish should succeed")
	assert(GameState.get_completed_objectives_count() == 2)
	
	# Completing primary_water must chain-unlock primary_anomaly
	var res_water = GameState.complete_objective("primary_water")
	assert(res_water == true)
	var anomaly_obj = null
	for o in GameState.objectives:
		if o["id"] == "primary_anomaly":
			anomaly_obj = o
			break
	assert(anomaly_obj != null, "primary_anomaly objective must exist")
	assert(anomaly_obj["status"] == "IN_PROGRESS", "Water borehole completion must advance primary_anomaly to IN_PROGRESS")
	print("Verified: Objective progression and causal chaining functional.")
	
	# 3. Test Research Discoveries & Crew Morale surge
	var initial_vance_morale = GameState.crew_database["vance"]["morale"]
	GameState.add_discovery({
		"id": "orbital_radar_void",
		"title": "Orbital Sub-surface Void Map",
		"category": "ORBITAL RADAR",
		"evidence": "Ground-penetrating synthetic aperture radar reveals a 120-meter cylindrical sub-surface cavity 80 meters below the basalt fault.",
		"science_xp": 450
	})
	assert(GameState.discoveries.size() == 1, "Discovery must be appended to journal")
	assert(GameState.crew_database["vance"]["morale"] >= initial_vance_morale, "Breakthrough discovery must boost crew morale")
	
	var xp_total = GameState.get_total_science_xp()
	print("Total Science XP after 1 discovery and 3 completed objectives: ", xp_total)
	assert(xp_total > 1000, "Science XP should properly aggregate discovery + objective rewards")
	print("Verified: Research discoveries and science XP calculation verified.")
	
	# 4. Mount Simulation HUD and Test POI Interaction & Decision Popups
	GameState.change_screen("simulation_hud")
	await get_tree().create_timer(0.3).timeout
	
	var main_node = get_parent()
	var hud_screen = main_node.get("current_screen_node")
	assert(hud_screen != null, "Simulation HUD must mount")
	
	# Test Comms Dish interaction
	hud_screen._on_poi_interacted("comms_dish")
	var event_modal = hud_screen.get("event_modal")
	assert(event_modal.visible == true, "Interacting with comms dish must open event decision modal")
	var options_box = hud_screen.get("event_options_box")
	assert(options_box.get_child_count() == 2, "Decision popup must present meaningful options with trade-offs")
	
	# Close event modal
	event_modal.visible = false
	
	# Test Basalt Crater Anomaly Interaction
	hud_screen._on_poi_interacted("basalt_anomaly")
	assert(event_modal.visible == true, "Basalt anomaly interaction must trigger breakthrough event modal")
	assert(GameState.discoveries.size() >= 2, "Basalt core discovery must be recorded")
	print("Verified: POI interaction handlers open decision popups with authored trade-offs.")
	event_modal.visible = false
	
	# 5. Test Objectives Modal rendering
	hud_screen._toggle_modal(hud_screen.obj_modal)
	assert(hud_screen.obj_modal.visible == true)
	var obj_list = hud_screen.obj_list_box
	assert(obj_list.get_child_count() > 5, "Objectives modal must render grouped primary and secondary cards")
	print("Verified: Objectives Tracker modal renders active and completed directive cards.")
	hud_screen.obj_modal.visible = false
	
	# 6. Test Research Discoveries & Mission Logs Modal rendering
	hud_screen._toggle_modal(hud_screen.logs_modal)
	assert(hud_screen.logs_modal.visible == true)
	hud_screen.logs_active_tab = "discoveries"
	hud_screen._render_logs_modal()
	assert(hud_screen.logs_list_box.get_child_count() >= 2, "Logs modal should render discovery cards in Discoveries tab")
	
	hud_screen.logs_active_tab = "logs"
	hud_screen._render_logs_modal()
	assert(hud_screen.logs_list_box.get_child_count() > 0, "Logs modal should render mission entries in Logs tab")
	print("Verified: Dual-tab Research Journal & Mission Logs modal functioning.")
	hud_screen.logs_modal.visible = false
	
	# 7. Test Save and Load of Objectives and Discoveries
	var save_ok = GameState.save_game()
	assert(save_ok == true)
	
	# Mutate memory state
	GameState.objectives.clear()
	GameState.discoveries.clear()
	assert(GameState.objectives.size() == 0)
	
	# Reload from save
	var load_ok = GameState.load_game()
	assert(load_ok == true)
	assert(GameState.objectives.size() >= 7, "Objectives must be restored from save file")
	assert(GameState.discoveries.size() >= 2, "Discoveries must be restored from save file")
	print("Verified: Objectives and research discoveries persisted accurately.")
	
	print("--- MILESTONE 5: ALL EVENTS, RESEARCH & OBJECTIVES TESTS PASSED CLEANLY ---")
	get_tree().quit(0)
