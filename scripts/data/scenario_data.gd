class_name ScenarioData
extends RefCounted


var scenario_id: String
var scenario_name: String
var description: String

var mission_duration: float = 100.0
var crew_count: int = 4

var starting_power: float = 100.0
var starting_water: float = 100.0
var starting_oxygen: float = 100.0
var starting_food: float = 100.0

var starting_shielding: float = 100.0
var starting_budget: float = 1000.0


func _init(
	id: String,
	name: String,
	scenario_description: String
) -> void:
	scenario_id = id
	scenario_name = name
	description = scenario_description
