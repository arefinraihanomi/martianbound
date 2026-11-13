extends Control

@onready var new_mission_btn: Button = $Margin/VBox/CenterContent/LeftPanel/VBox/NewMissionBtn
@onready var continue_btn: Button = $Margin/VBox/CenterContent/LeftPanel/VBox/ContinueBtn
@onready var continue_badge: Label = $Margin/VBox/CenterContent/LeftPanel/VBox/ContinueBtn/Margin/HBox/Badge
@onready var archive_btn: Button = $Margin/VBox/CenterContent/LeftPanel/VBox/ArchiveBtn
@onready var settings_btn: Button = $Margin/VBox/CenterContent/LeftPanel/VBox/SettingsBtn
@onready var exit_btn: Button = $Margin/VBox/CenterContent/LeftPanel/VBox/ExitBtn

@onready var crew_count_label: Label = $Margin/VBox/CenterContent/RightPanel/VBox/CrewHeader/CountLabel
@onready var solar_bar: SegmentedBar = $Margin/VBox/CenterContent/RightPanel/VBox/SolarSection/SolarBar
@onready var solar_pct_label: Label = $Margin/VBox/CenterContent/RightPanel/VBox/SolarSection/SolarHeader/PctLabel

# Settings Modal
@onready var settings_modal: PanelContainer = $SettingsModal
@onready var btn_close_settings: Button = $SettingsModal/Margin/VBox/Actions/CloseBtn
@onready var slider_master: HSlider = $SettingsModal/Margin/VBox/AudioSection/MasterVol/Slider
@onready var lbl_master: Label = $SettingsModal/Margin/VBox/AudioSection/MasterVol/Val
@onready var slider_sfx: HSlider = $SettingsModal/Margin/VBox/AudioSection/SfxVol/Slider
@onready var lbl_sfx: Label = $SettingsModal/Margin/VBox/AudioSection/SfxVol/Val
@onready var slider_music: HSlider = $SettingsModal/Margin/VBox/AudioSection/MusicVol/Slider
@onready var lbl_music: Label = $SettingsModal/Margin/VBox/AudioSection/MusicVol/Val

# Cadet Guide Modal
@onready var guide_modal: PanelContainer = $GuideModal
@onready var btn_close_guide: Button = $GuideModal/Margin/VBox/BtnCloseGuide

# NASA Datasets Modal & Footer Badge
@onready var nasa_badge_btn: Button = $Margin/VBox/FooterBar/NasaBadge
@onready var datasets_modal: PanelContainer = $NasaDatasetsModal
@onready var btn_close_datasets: Button = $NasaDatasetsModal/Margin/VBox/BtnCloseDatasets

func _ready() -> void:
	new_mission_btn.pressed.connect(_on_new_mission_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)
	archive_btn.pressed.connect(_on_guide_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	nasa_badge_btn.pressed.connect(_on_datasets_pressed)
	
	btn_close_settings.pressed.connect(func(): settings_modal.visible = false)
	btn_close_guide.pressed.connect(func(): guide_modal.visible = false)
	btn_close_datasets.pressed.connect(func(): datasets_modal.visible = false)
	slider_master.value_changed.connect(func(v): lbl_master.text = "%d%%" % int(v))
	slider_sfx.value_changed.connect(func(v): lbl_sfx.text = "%d%%" % int(v))
	slider_music.value_changed.connect(func(v): lbl_music.text = "%d%%" % int(v))
	
	_update_continue_button()
	_update_telemetry()
	new_mission_btn.grab_focus()

func _update_continue_button() -> void:
	if GameState.has_save_file():
		continue_btn.disabled = false
		continue_badge.text = "SAVED EXPEDITION"
		continue_badge.add_theme_color_override("font_color", GameState.COLOR_CYAN)
	else:
		continue_btn.disabled = true
		continue_badge.text = "NO SAVE FOUND"
		continue_badge.add_theme_color_override("font_color", GameState.COLOR_TEXT_MUTED)

func _update_telemetry() -> void:
	solar_bar.fill_ratio = GameState.solar_efficiency / 100.0
	solar_pct_label.text = "%d%%" % int(GameState.solar_efficiency)
	
	var active_count := 0
	for m in GameState.assigned_roster:
		if m != "":
			active_count += 1
	crew_count_label.text = "%d/4 ACTIVE" % active_count

func _on_new_mission_pressed() -> void:
	GameState.change_screen("mission_briefing")

func _on_continue_pressed() -> void:
	if GameState.load_game():
		GameState.change_screen("simulation_hud")

func _on_settings_pressed() -> void:
	settings_modal.visible = true
	btn_close_settings.grab_focus()

func _on_guide_pressed() -> void:
	guide_modal.visible = true
	btn_close_guide.grab_focus()

func _on_datasets_pressed() -> void:
	datasets_modal.visible = true
	btn_close_datasets.grab_focus()

func _on_exit_pressed() -> void:
	get_tree().quit()
