extends Node

var current_mission: MissionState
var current_scenario: ScenarioData

var simulation_engine: SimulationEngine
var event_engine: EventEngine
var scoring: Scoring
var persistence: PersistenceService
var mission_events: Array[EventData] = []
var active_event: EventData



func _ready() -> void:
	simulation_engine = SimulationEngine.new()
	event_engine = EventEngine.new()
	scoring = Scoring.new()
	persistence = PersistenceService.new()

	start_mars_mission()



func load_mission() -> bool:
	if current_mission == null:
		return false

	return persistence.load_mission(current_mission)


func save_mission() -> void:
	if current_mission == null:
		return

	persistence.save_mission(current_mission)


func get_mission_score() -> float:
	if current_mission == null:
		return 0.0

	return scoring.calculate_score(current_mission)


func start_mars_mission() -> void:
	current_scenario = ScenarioData.new(
		"mars_outpost",
		"Mars Outpost Mission",
		"Establish and maintain a sustainable human outpost on Mars."
	)

	current_mission = MissionState.new()

	_apply_scenario_to_mission()
	_setup_mission_events()

func _setup_mission_events() -> void:
	mission_events.clear()

	var solar_storm := EventData.new(
		"solar_storm",
		"Solar Storm",
		"A strong solar storm affects the habitat.",
		20.0
	)

	var reinforce_shielding := DecisionData.new(
		"reinforce_shielding",
		"Reinforce Shielding",
		"Spend budget to strengthen radiation protection."
	)

	reinforce_shielding.budget_effect = -100.0
	reinforce_shielding.shielding_effect = 20.0

	solar_storm.add_decision(reinforce_shielding)

	mission_events.append(solar_storm)

func _apply_scenario_to_mission() -> void:
	current_mission.mission_duration = current_scenario.mission_duration
	current_mission.crew_count = current_scenario.crew_count

	current_mission.power = current_scenario.starting_power
	current_mission.water = current_scenario.starting_water
	current_mission.oxygen = current_scenario.starting_oxygen
	current_mission.food = current_scenario.starting_food

	current_mission.radiation_shielding = current_scenario.starting_shielding
	current_mission.budget = current_scenario.starting_budget


func reset_mission() -> void:
	if current_scenario == null:
		start_mars_mission()
	else:
		current_mission.reset()
		_apply_scenario_to_mission()


func process_mission_tick(delta_time: float) -> void:
	if current_mission == null:
		return

	simulation_engine.process_tick(
		current_mission,
		delta_time
	)

	for event in mission_events:
		check_event(event)



func check_event(event: EventData) -> bool:
	if current_mission == null:
		return false

	var triggered := event_engine.check_event_trigger(
		event,
		current_mission.mission_time
	)

	if triggered:
		active_event = event

	return triggered

func choose_decision(decision: DecisionData) -> bool:
	if current_mission == null:
		return false

	if active_event == null:
		return false

	if not active_event.decisions.has(decision):
		return false

	event_engine.apply_decision(
		current_mission,
		decision
	)

	active_event = null

	return true



func finish_mission() -> float:
	if current_mission == null:
		return 0.0

	var final_score: float = get_mission_score()

	persistence.save_mission(current_mission)

	return final_score
