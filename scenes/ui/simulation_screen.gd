extends Control


@onready var power_label: Label = $VBoxContainer/PowerLabel
@onready var power_bar: ProgressBar = $VBoxContainer/PowerBar

@onready var water_label: Label = $VBoxContainer/WaterLabel
@onready var water_bar: ProgressBar = $VBoxContainer/WaterBar

@onready var oxygen_label: Label = $VBoxContainer/OxygenLabel
@onready var oxygen_bar: ProgressBar = $VBoxContainer/OxygenBar

@onready var food_label: Label = $VBoxContainer/FoodLabel
@onready var food_bar: ProgressBar = $VBoxContainer/FoodBar

@onready var crew_health_label: Label = $VBoxContainer/CrewHealthLabel
@onready var crew_health_bar: ProgressBar = $VBoxContainer/CrewHealthBar

@onready var shielding_label: Label = $VBoxContainer/ShieldingLabel
@onready var shielding_bar: ProgressBar = $VBoxContainer/ShieldingBar

@onready var mission_time_label: Label = $VBoxContainer/MissionTimeLabel

@onready var finish_button: Button = $VBoxContainer/FinishMissionButton
@onready var mission_status_label: Label = $VBoxContainer/MissionStatusLabel

var event_screen_opened: bool = false

func _ready() -> void:
	update_ui()


func _process(delta: float) -> void:
	MissionSession.process_mission_tick(delta)
	update_ui()

	if MissionSession.active_event != null and not event_screen_opened:
		event_screen_opened = true

		NavigationCoordinator.change_screen(
			"res://scenes/ui/EventScreen.tscn"
		)


func update_ui() -> void:
	if MissionSession.current_mission == null:
		return

	var mission := MissionSession.current_mission
	
	var current_time: int = int(mission.mission_time)
	var minutes: int = current_time / 60
	var seconds: int = current_time % 60

	var total_time: int = int(mission.mission_duration)

	var total_minutes: int = total_time / 60
	var total_seconds: int = total_time % 60

	mission_time_label.text = "Mission Time: %02d:%02d / %02d:%02d" % [
		minutes,
		seconds,
		total_minutes,
		total_seconds
	]

	power_bar.value = mission.power
	power_label.text = "Power: %.1f%%" % mission.power

	water_bar.value = mission.water
	water_label.text = "Water: %.1f%%" % mission.water

	oxygen_bar.value = mission.oxygen
	oxygen_label.text = "Oxygen: %.1f%%" % mission.oxygen

	food_bar.value = mission.food
	food_label.text = "Food: %.1f%%" % mission.food

	crew_health_bar.value = mission.crew_health
	crew_health_label.text = "Crew Health: %.1f%%" % mission.crew_health

	shielding_bar.value = mission.radiation_shielding
	shielding_label.text = "Radiation Shielding: %.1f%%" % mission.radiation_shielding
	
	if mission.mission_completed:
		mission_status_label.text = "Mission Completed"
		finish_button.disabled = true
	elif mission.mission_failed:
		mission_status_label.text = "Mission Failed"
		finish_button.disabled = true
	else:
		mission_status_label.text = "Mission Active"
		finish_button.disabled = false


func _on_finish_pressed() -> void:
	if MissionSession.current_mission == null:
		return

	MissionSession.current_mission.complete_mission()

	var final_score: float = MissionSession.finish_mission()

	print("Mission finished.")
	print("Final score: ", final_score)# Replace with function body.
