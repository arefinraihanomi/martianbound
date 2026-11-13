extends Node

func _ready() -> void:
	print("--- COMMENCING MILESTONE 3: SURFACE EXPLORATION & WORLD TEST ---")
	
	# 1. Switch to simulation HUD screen
	GameState.change_screen("simulation_hud")
	await get_tree().create_timer(0.3).timeout
	
	var main_node = get_parent()
	var hud_screen = main_node.get("current_screen_node")
	assert(hud_screen != null, "Simulation HUD must be mounted")
	
	var surface = hud_screen.get("mars_surface")
	assert(surface != null, "Mars surface node must be present in HUD")
	
	var player = surface.get("player")
	assert(player != null, "Player must exist on surface")
	assert(player is AstronautPlayer, "Player must be an AstronautPlayer instance")
	print("Verified: Mars surface and AstronautPlayer initialized.")
	
	# 2. Verify all POIs exist
	var pois = surface.get_tree().get_nodes_in_group("interactable")
	var poi_ids: Array[String] = []
	for p in pois:
		poi_ids.append(p.get("poi_id"))
	
	print("Discovered POI IDs: ", poi_ids)
	assert(poi_ids.has("hab_airlock"), "Missing Hab airlock POI")
	assert(poi_ids.has("solar_array"), "Missing solar array POI")
	assert(poi_ids.has("comms_dish"), "Missing comms dish POI")
	assert(poi_ids.has("aquifer_drill"), "Missing aquifer drill POI")
	assert(poi_ids.has("basalt_anomaly"), "Missing basalt anomaly POI")
	assert(poi_ids.has("crate_supplies"), "Missing precursor supply crate POI")
	print("Verified: All 6 required POIs are present and grouped as interactable.")
	
	# 3. Verify Rocks and World Boundaries
	var rocks = surface.get_node_or_null("Rocks")
	assert(rocks != null, "Rock obstacle container must exist")
	assert(rocks.get_child_count() >= 6, "Must have at least 6 rock obstacles")
	
	var boundaries = surface.get_node_or_null("WorldBoundaries")
	assert(boundaries != null, "World perimeter boundaries must exist")
	print("Verified: Physical rock obstacles and world perimeter boundaries active.")
	
	# 4. Verify Radar Minimap
	var minimap = hud_screen.get("minimap")
	assert(minimap != null, "Radar minimap must exist in HUD")
	assert(minimap is RadarMinimap, "Minimap must be RadarMinimap instance")
	assert(minimap.player_node == player, "Minimap must track player node")
	print("Verified: Radar minimap scanner active and linked to player.")
	
	# 5. Verify Player Movement & EVA Oxygen burn
	var initial_o2: float = GameState.resources["oxygen"]["current"]
	var initial_dist: float = player.total_distance_walked
	
	# Simulate movement
	player.velocity = Vector2(100.0, 0.0)
	player.move_and_slide()
	player.emit_signal("moved", 150.0)
	await get_tree().process_frame
	
	assert(player.dust_particles != null, "Dust trail particles must exist on player")
	print("Simulated 150px movement. Initial O2: ", initial_o2, " Current O2: ", GameState.resources["oxygen"]["current"])
	assert(GameState.resources["oxygen"]["current"] < initial_o2, "EVA movement must consume oxygen buffer")
	print("Verified: Player movement and EVA oxygen expenditure functioning.")
	
	# 6. Verify Crate Interaction
	var initial_food: float = GameState.resources["food"]["current"]
	hud_screen._on_poi_interacted("crate_supplies")
	assert(GameState.resources["food"]["current"] > initial_food, "Crate supplies must increase food reserves")
	print("Verified: Ares precursor supply cache interaction successfully restores resources.")
	
	print("--- MILESTONE 3: ALL SURFACE EXPLORATION TESTS PASSED CLEANLY ---")
	get_tree().quit(0)
