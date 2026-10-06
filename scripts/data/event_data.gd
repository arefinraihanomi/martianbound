class_name EventData
extends RefCounted


var event_id: String
var event_name: String
var description: String

var decisions: Array[DecisionData] = []
var trigger_time: float


func _init(
	id: String,
	name: String,
	event_description: String,
	time: float
) -> void:
	event_id = id
	event_name = name
	description = event_description
	trigger_time = time

func add_decision(decision: DecisionData) -> void:
	decisions.append(decision)
