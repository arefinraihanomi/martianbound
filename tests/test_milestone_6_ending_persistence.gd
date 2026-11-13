extends Node

func _ready() -> void:
	print("--- COMMENCING MILESTONE 6: MISSION ENDING & PERSISTENCE TEST ---")
	
	# 1. Test Clean Save / Continue Persistence
	GameState.start_new_mission()
	GameState.modify_resource("oxygen", -120.0)
	GameState.modify_resource("power", -200.0)
	GameState.current_sol = 5
	GameState.sol_hour = 14
	GameState.sol_minute = 45
	GameState.current_time_str = "14:45"
	GameState.complete_objective("primary_water")
	GameState.complete_objective("sec_solar")
	GameState.add_discovery({
		"id": "test_deep_core",
		"title": "Subsurface Geothermal Core",
		"category": "GEOLOGY",
		"evidence": "Hydrothermal mineralization traces at 120m depth.",
		"science_xp": 500
	})
	
	var save_ok = GameState.save_game()
	assert(save_ok == true, "GameState.save_game() must succeed")
	assert(GameState.has_save_file() == true, "Save file must exist on disk")
	print("Verified: Active mission state saved to user disk.")
	
	# Reset state and load back
	GameState.start_new_mission()
	assert(GameState.current_sol == 1, "Reset state should have Sol = 1")
	assert(GameState.discoveries.size() == 0, "Reset state should have zero discoveries")
	
	var load_ok = GameState.load_game()
	assert(load_ok == true, "GameState.load_game() must succeed")
	assert(GameState.current_sol == 5, "Loaded Sol must match 5")
	assert(GameState.current_time_str == "14:45", "Loaded time must match 14:45")
	assert(GameState.discoveries.size() == 1, "Loaded discoveries must match 1")
	assert(GameState.get_completed_objectives_count() >= 3, "Loaded objectives must preserve completions")
	print("Verified: Mission state fully restored from save disk.")
	
	# 2. Test Main Menu Continue button state
	GameState.change_screen("main_menu")
	await get_tree().create_timer(0.3).timeout
	var main_node = get_parent()
	var menu_screen = main_node.get("current_screen_node")
	assert(menu_screen != null, "Main menu screen must mount")
	var cont_btn: Button = menu_screen.get("continue_btn")
	assert(cont_btn.disabled == false, "Continue button must be enabled when valid save exists")
	
	# Test Settings popup on Main Menu
	menu_screen._on_settings_pressed()
	var settings_modal = menu_screen.get("settings_modal")
	assert(settings_modal != null and settings_modal.visible == true, "Settings modal must open on main menu")
	settings_modal.visible = false
	print("Verified: Main Menu Continue & Settings popup functioning.")
	
	# 3. Test Simulation HUD Pause & Abort handling
	GameState.change_screen("simulation_hud")
	await get_tree().create_timer(0.3).timeout
	var hud_screen = main_node.get("current_screen_node")
	assert(hud_screen != null, "Simulation HUD must mount")
	
	# Open Pause modal
	hud_screen._toggle_modal(hud_screen.pause_modal)
	assert(hud_screen.pause_modal.visible == true, "Pause modal must open")
	
	# Test Save button from Pause modal
	hud_screen._on_save_pressed()
	assert(hud_screen.save_status_lbl.text.contains("SAVED"), "Pause save button must confirm write")
	
	# Trigger Abort to Mission Report
	hud_screen.btn_abort.emit_signal("pressed")
	await get_tree().create_timer(0.3).timeout
	
	var report_screen = main_node.get("current_screen_node")
	assert(report_screen != null, "Mission Report must mount upon abort/completion")
	assert(report_screen.outcome_label.text.contains("SUCCESS") or report_screen.outcome_label.text.contains("PARTIAL"), "Outcome label must reflect mission status")
	assert(report_screen.obj_summary_box.get_child_count() > 0, "Objectives summary list must render cards")
	assert(report_screen.discoveries_box.get_child_count() > 0, "Discoveries dossier must render cards")
	assert(report_screen.narrative_text.text.length() > 20, "Narrative debrief text must be populated")
	print("Verified: Mission Report generates detailed expedition scorecard and narrative.")
	
	# 4. Test Critical Failure Ending (Life support depletion)
	GameState.resources["oxygen"]["current"] = 0.0
	GameState.last_outcome = "FAILED"
	GameState.last_narrative = "Life support oxygen depleted below survivable pressure."
	report_screen._populate_report()
	assert(report_screen.outcome_label.text.contains("CRITICAL FAILURE"), "Oxygen depletion must trigger CRITICAL FAILURE report")
	print("Verified: Critical failure life support ending verified.")
	
	# 5. Return to Main Menu and Delete Save to test Clean Slate
	report_screen.finish_btn.emit_signal("pressed")
	await get_tree().create_timer(0.3).timeout
	var final_menu = main_node.get("current_screen_node")
	assert(final_menu != null, "Must return to main menu after finishing report")
	
	GameState.delete_save_file()
	assert(GameState.has_save_file() == false, "Save file must be deleted")
	final_menu._update_continue_button()
	assert(final_menu.continue_btn.disabled == true, "Continue button must be disabled when no save exists")
	print("Verified: Save cleanup and disabled continue button verified.")
	
	print("--- MILESTONE 6: ALL MISSION ENDING & PERSISTENCE TESTS PASSED CLEANLY ---")
	get_tree().quit(0)
