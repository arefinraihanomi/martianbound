extends Node

func _ready() -> void:
	print("--- BEGIN MILESTONE 2: MISSION SETUP VERIFICATION TEST ---")
	
	# Test 1: Duration & Difficulty Staged Resources Scaling
	GameState.expedition_duration = 45
	GameState.difficulty = "HARD"
	var res_hard_45 = GameState.calculate_staged_resources()
	assert(res_hard_45["oxygen"]["current"] == 850.0)
	assert(res_hard_45["water"]["current"] == 620.0)
	
	GameState.difficulty = "NORMAL"
	var res_norm_45 = GameState.calculate_staged_resources()
	assert(res_norm_45["oxygen"]["current"] == 850.0 * 1.2) # 1020.0
	
	GameState.expedition_duration = 180
	GameState.difficulty = "HARD"
	var res_hard_180 = GameState.calculate_staged_resources()
	assert(res_hard_180["oxygen"]["current"] == 24000.0)
	assert(res_hard_180["food"]["current"] == 720.0)
	print("Test 1 Passed: Staged resources calculate and scale accurately.")
	
	# Test 2: Dynamic Timeline Phases
	GameState.expedition_duration = 45
	var timeline_45 = GameState.get_mission_timeline()
	assert(timeline_45.size() == 4)
	assert(timeline_45[0]["name"] == "LANDING")
	assert(timeline_45[3]["name"] == "RETURN STAGING")
	print("Test 2 Passed: Dynamic timeline phase generation verified.")
	
	# Test 3: Crew Roster Rules & Validation
	GameState.assigned_roster = ["vance", "chen", "thorne", ""]
	assert(GameState.is_roster_complete() == false)
	
	GameState.assign_candidate_to_slot("rostova", 3)
	assert(GameState.is_roster_complete() == true)
	
	# Test 4: Team Readiness & Advisory Feedback
	var readiness = GameState.calculate_team_readiness()
	assert(readiness["viable"] > 70)
	var advisory = GameState.get_directive_advisory()
	assert("Dr. Elena Rostova" in advisory)
	
	# Remove scientist to test deficit
	GameState.unassign_slot(3)
	var advisory_deficit = GameState.get_directive_advisory()
	assert("DEFICIT" in advisory_deficit)
	print("Test 4 Passed: Team readiness and dynamic advisories verified.")
	
	# Reassign for clean state
	GameState.assign_candidate_to_slot("rostova", 3)
	
	# Test 5: Outpost Selection
	GameState.selected_site_id = "site_b"
	var site_b_data = GameState.get_selected_site_data()
	assert(site_b_data["title"] == "SITE-B: VALLES MARINERIS")
	
	GameState.selected_site_id = "site_a"
	var site_a_data = GameState.get_selected_site_data()
	assert(site_a_data["title"] == "SITE-A: ACIDALIA PLANITIA")
	print("Test 5 Passed: Site selection database verified.")
	
	# Test 6: Hand-off to Simulation via start_new_mission()
	GameState.start_new_mission()
	assert(GameState.current_sol == 1)
	assert(GameState.radiation_mSv == 0.24)
	assert(GameState.mission_logs.size() >= 2)
	print("Test 6 Passed: Mission setup cleanly deployed to simulation.")
	
	print("--- MILESTONE 2: ALL MISSION SETUP TESTS PASSED SUCCESSFULLY ---")
	get_tree().quit(0)
