extends Control

@onready var back_btn: Button = $Margin/VBox/BottomDock/BackBtn
@onready var confirm_btn: Button = $Margin/VBox/BottomDock/ConfirmBtn

@onready var site_a_card: PanelContainer = $Margin/VBox/SiteCards/SiteA
@onready var site_b_card: PanelContainer = $Margin/VBox/SiteCards/SiteB
@onready var site_c_card: PanelContainer = $Margin/VBox/SiteCards/SiteC
@onready var site_d_card: PanelContainer = $Margin/VBox/SiteCards/SiteD

# Previews & details
@onready var preview_title: Label = $Margin/VBox/MiddleSection/OpticalFeed/VBox/Hdr/Title
@onready var radar_coords: Label = $Margin/VBox/MiddleSection/RadarSurvey/VBox/Ftr/Coords
@onready var radar_topo: Label = $Margin/VBox/MiddleSection/RadarSurvey/VBox/Ftr/Topo
@onready var terrain_safety: Label = $Margin/VBox/LowerSection/TerrainCard/VBox/Hdr/Safety
@onready var terrain_class: Label = $Margin/VBox/LowerSection/TerrainCard/VBox/Grid/T1

var current_site: String = "site_a"

func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	confirm_btn.pressed.connect(_on_confirm_pressed)
	
	_setup_card(site_a_card, "site_a")
	_setup_card(site_b_card, "site_b")
	_setup_card(site_c_card, "site_c")
	_setup_card(site_d_card, "site_d")
	
	_select_site(GameState.selected_site_id)
	confirm_btn.grab_focus()

func _setup_card(card: PanelContainer, site_id: String) -> void:
	card.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_select_site(site_id)
	)

func _select_site(site_id: String) -> void:
	if site_id == "site_d": # Restricted in MVP
		confirm_btn.disabled = true
		confirm_btn.text = "LANDING PROHIBITED"
		confirm_btn.add_theme_color_override("font_color", GameState.COLOR_RED)
		site_a_card.is_highlighted = false
		site_b_card.is_highlighted = false
		site_c_card.is_highlighted = false
		site_d_card.is_highlighted = true
		preview_title.text = "📷 LOCATION PREVIEW — SITE-D NOCTIS LABYRINTHUS"
		radar_coords.text = "LAT/LONG: 07.2° S 258.8° E"
		radar_topo.text = "TOPOGRAPHY: DUST MAZE / VORTEX"
		terrain_safety.text = "LOCATION SAFETY: 22% [CRITICAL]"
		terrain_safety.add_theme_color_override("font_color", GameState.COLOR_RED)
		terrain_class.text = "Classification: Severe Dust Maze Hazard"
		return
		
	confirm_btn.disabled = false
	confirm_btn.text = "CONFIRM LANDING ZONE  ▶"
	confirm_btn.add_theme_color_override("font_color", GameState.COLOR_CYAN)
	
	current_site = site_id
	GameState.selected_site_id = site_id
	
	site_a_card.is_highlighted = (site_id == "site_a")
	site_b_card.is_highlighted = (site_id == "site_b")
	site_c_card.is_highlighted = (site_id == "site_c")
	site_d_card.is_highlighted = false
	
	var data = GameState.get_selected_site_data()
	preview_title.text = "📷 LOCATION PREVIEW — " + data["title"]
	radar_coords.text = "LAT/LONG: " + data["coords"]
	radar_topo.text = "TOPOGRAPHY: " + data["terrain"].to_upper()
	terrain_safety.text = "LOCATION SAFETY: %d%% [%s]" % [data["safety_index"], data["grade"]]
	terrain_safety.add_theme_color_override("font_color", GameState.COLOR_GREEN if data["safety_index"] >= 80 else GameState.COLOR_AMBER)
	terrain_class.text = "Classification: " + data["terrain"]

func _on_back_pressed() -> void:
	GameState.change_screen("mission_planner")

func _on_confirm_pressed() -> void:
	GameState.start_new_mission()
	GameState.change_screen("simulation_hud")
