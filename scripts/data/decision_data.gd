class_name DecisionData
extends RefCounted


var decision_id: String
var decision_name: String
var description: String

var power_effect: float = 0.0
var water_effect: float = 0.0
var oxygen_effect: float = 0.0
var food_effect: float = 0.0

var shielding_effect: float = 0.0
var budget_effect: float = 0.0
var crew_health_effect: float = 0.0


func _init(
	id: String,
	name: String,
	decision_description: String
) -> void:
	decision_id = id
	decision_name = name
	description = decision_description
