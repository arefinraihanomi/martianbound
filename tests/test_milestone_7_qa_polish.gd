extends Node

func _ready() -> void:
	print("=================================================================")
	print("--- COMMENCING MILESTONE 7: FULL END-TO-END QA & POLISH AUDIT ---")
	print("=================================================================")
	
	# --- PHASE 1: LAUNCH & MAIN MENU AUDIT ---
	GameState.start_new_mission()
	GameState.change_screen("main_menu")
	await get_tree().create_timer(0.2).timeout
	
	var main = get_parent()
	var menu = main.get("current_screen_node")
	assert(menu != null, "QA FAIL: Main menu must mount")
	assert(menu.has_node("GuideModal"), "QA FAIL: Cadet Field Guide modal must exist")
	assert(menu.has_node("SettingsModal"), "QA FAIL: Settings modal must exist")
	
	# Test opening Guide Modal and closing
	menu._on_guide_pressed()
	assert(menu.guide_modal.visible == true, "QA FAIL: Cadet Field Guide must open")
	menu.guide_modal.visible = false
	
	# Test opening Settings Modal and closing
	menu._on_settings_pressed()
	assert(menu.settings_modal.visible == true, "QA FAIL: Settings must open")
	menu.settings_modal.visible = false
	
	# Test opening NASA Datasets Modal and closing
	menu._on_datasets_pressed()
	assert(menu.datasets_modal.visible == true, "QA FAIL: NASA Datasets Modal must open from main menu footer")
	menu.datasets_modal.visible = false
	print("PASS: Phase 1 — Main Menu, Cadet Guide & NASA Datasets Modals verified.")
	
	# --- PHASE 2: MISSION BRIEFING AUDIT ---
	GameState.change_screen("mission_briefing")
	await get_tree().create_timer(0.2).timeout
	var briefing = main.get("current_screen_node")
	assert(briefing != null, "QA FAIL: Mission Briefing must mount")
	print("PASS: Phase 2 — Mission Briefing verified.")
	
	# --- PHASE 3: CREW SELECTION AUDIT ---
	GameState.change_screen("crew_selection")
	await get_tree().create_timer(0.2).timeout
	var crew_sel = main.get("current_screen_node")
	assert(crew_sel != null, "QA FAIL: Crew Selection must mount")
	assert(GameState.is_roster_complete() == true, "QA FAIL: Default assigned roster must be complete (4 members)")
	var readiness = GameState.calculate_team_readiness()
	assert(readiness["viable"] >= 70, "QA FAIL: Assigned crew readiness must be viable (> 70%)")
	print("PASS: Phase 3 — Crew Selection & Radar metrics verified.")
	
	# --- PHASE 4: MISSION PLANNER AUDIT ---
	GameState.change_screen("mission_planner")
	await get_tree().create_timer(0.2).timeout
	var planner = main.get("current_screen_node")
	assert(planner != null, "QA FAIL: Mission Planner must mount")
	var phases = GameState.get_mission_timeline()
	assert(phases.size() == 4, "QA FAIL: Proportional timeline must contain 4 phases")
	print("PASS: Phase 4 — Mission Planner & 1-Sol timeline verified.")
	
	# --- PHASE 5: OUTPOST SELECTION AUDIT ---
	GameState.change_screen("outpost_selection")
	await get_tree().create_timer(0.2).timeout
	var outpost = main.get("current_screen_node")
	assert(outpost != null, "QA FAIL: Outpost Selection must mount")
	var site = GameState.get_selected_site_data()
	assert(site["id"] == "site_a", "QA FAIL: Selected outpost should default to Site A (Acidalia Planitia)")
	print("PASS: Phase 5 — Outpost Selection & NASA site parameters verified.")
	
	# --- PHASE 6: SURFACE SIMULATION & NASA OPEN DATA MECHANICS AUDIT ---
	GameState.change_screen("simulation_hud")
	await get_tree().create_timer(0.3).timeout
	var hud = main.get("current_screen_node")
	assert(hud != null, "QA FAIL: Simulation HUD must mount")
	assert(hud.mars_surface != null, "QA FAIL: Mars Surface viewport must render")
	assert(hud.mars_surface.player != null, "QA FAIL: Astronaut Player must exist in world")
	
	# Test Player EVA Movement & Oxygen Burn
	var o2_init = GameState.resources["oxygen"]["current"]
	hud._on_player_moved(100.0)
	assert(GameState.resources["oxygen"]["current"] < o2_init, "QA FAIL: EVA walking must consume oxygen buffer")
	
	# Test All 6 Points of Interest (POIs) with kid-friendly emoji trade-offs
	hud._on_poi_interacted("hab_airlock")
	assert(hud.event_modal.visible == true, "QA FAIL: Hab airlock modal must trigger")
	hud.event_modal.visible = false
	
	hud._on_poi_interacted("solar_array")
	assert(hud.event_modal.visible == true, "QA FAIL: Solar array modal must trigger")
	hud.event_modal.visible = false
	
	hud._on_poi_interacted("comms_dish")
	assert(hud.event_modal.visible == true, "QA FAIL: Comms dish modal must trigger")
	hud.event_modal.visible = false
	
	hud._on_poi_interacted("aquifer_drill")
	assert(hud.event_modal.visible == true, "QA FAIL: Aquifer drill modal must trigger")
	hud.event_modal.visible = false
	
	hud._on_poi_interacted("crate_supplies")
	assert(hud.event_modal.visible == true, "QA FAIL: Supply crate modal must trigger")
	hud.event_modal.visible = false
	
	hud._on_poi_interacted("basalt_anomaly")
	assert(hud.event_modal.visible == true, "QA FAIL: Basalt anomaly modal must trigger")
	hud.event_modal.visible = false
	
	# Verify scientific discoveries recorded
	assert(GameState.discoveries.size() >= 3, "QA FAIL: POI interactions must log scientific discoveries")
	print("PASS: Phase 6 — Mars Surface EVA, 6 POI interactions, and scientific discovery logging verified.")
	
	# --- PHASE 7: SOL DIURNAL PROGRESSION, SPACE WEATHER & REST AUDIT ---
	# Fast forward through day to trigger NASA DONKI SEP solar flare (at 13:00)
	GameState.sol_hour = 12
	GameState.sol_minute = 45
	GameState.simulation_step(15)
	assert(GameState.weather_type == "SOLAR_EVENT", "QA FAIL: 13:00 must trigger NASA DONKI SEP Solar Flare")
	assert(GameState.radiation_mSv > 1.0, "QA FAIL: Solar Flare must elevate radiation above 1.0 mSv/h")
	
	# Test crew restorative sleep in Hab
	var rest_res = GameState.rest_crew(4)
	assert(rest_res["success"] == true, "QA FAIL: Crew rest cycle must succeed")
	print("PASS: Phase 7 — NASA DONKI space weather flare and NASA OSDR restorative sleep verified.")
	
	# --- PHASE 8: MISSION REPORT & DEBRIEF DOSSIER AUDIT ---
	GameState.last_outcome = "SUCCESS"
	GameState.last_narrative = "Full 1-Sol expedition mission directives achieved with zero fatalities."
	GameState.change_screen("mission_report")
	await get_tree().create_timer(0.2).timeout
	var report = main.get("current_screen_node")
	assert(report != null, "QA FAIL: Mission Report must mount")
	assert(report.outcome_label.text.contains("SUCCESS"), "QA FAIL: Report must reflect SUCCESS status")
	assert(report.obj_summary_box.get_child_count() > 0, "QA FAIL: Objectives scorecard must render")
	assert(report.discoveries_box.get_child_count() > 0, "QA FAIL: Discoveries dossier must render")
	print("PASS: Phase 8 — Mission Report & Mission Control debrief dossier verified.")
	
	# --- PHASE 9: SAVE / CONTINUE CYCLE & MENU RETURN AUDIT ---
	GameState.save_game()
	assert(GameState.has_save_file() == true, "QA FAIL: Save file must exist")
	
	report.finish_btn.emit_signal("pressed")
	await get_tree().create_timer(0.2).timeout
	var final_menu = main.get("current_screen_node")
	assert(final_menu != null, "QA FAIL: Must return to Main Menu after report")
	assert(final_menu.continue_btn.disabled == false, "QA FAIL: Continue button must be enabled with save")
	
	GameState.delete_save_file()
	assert(GameState.has_save_file() == false, "QA FAIL: Save file cleanup must succeed")
	final_menu._update_continue_button()
	assert(final_menu.continue_btn.disabled == true, "QA FAIL: Continue button must disable when save is removed")
	print("PASS: Phase 9 — Save persistence, continue flow, and memory cleanup verified.")
	
	print("=================================================================")
	print("--- ALL MILESTONE 7 QA & POLISH CRITERIA MET WITH ZERO ERRORS ---")
	print("=================================================================")
	get_tree().quit(0)
