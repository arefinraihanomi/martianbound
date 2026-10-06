class_name MissionState
extends RefCounted

# Mission information
var mission_time: float = 0.0
var mission_duration: float = 100.0

# Crew
var crew_count: int = 4
var crew_health: float = 100.0

# Resources
var power: float = 100.0
var water: float = 100.0
var oxygen: float = 100.0
var food: float = 100.0

# Protection
var radiation_shielding: float = 100.0

# Mission management
var budget: float = 1000.0

# Mission status
var mission_completed: bool = false
var mission_failed: bool = false
var failure_reason: String = ""


func reset() -> void:
	mission_time = 0.0
	crew_health = 100.0

	power = 100.0
	water = 100.0
	oxygen = 100.0
	food = 100.0

	radiation_shielding = 100.0
	budget = 1000.0

	mission_completed = false
	mission_failed = false
	failure_reason = ""


func fail_mission(reason: String) -> void:
	mission_failed = true
	failure_reason = reason


func complete_mission() -> void:
	mission_completed = true
