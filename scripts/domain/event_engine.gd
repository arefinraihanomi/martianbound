class_name EventEngine
extends RefCounted

var triggered_events: Array[String] = []


func can_trigger_event(
	event_id: String
) -> bool:
	return not triggered_events.has(event_id)


func check_event_trigger(
	event: EventData,
	mission_time: float
) -> bool:
	if not can_trigger_event(event.event_id):
		return false

	if mission_time < event.trigger_time:
		return false

	return trigger_event(event)


func trigger_event(
	event: EventData
) -> bool:
	if not can_trigger_event(event.event_id):
		return false

	triggered_events.append(event.event_id)

	print("Event triggered: ", event.event_name)

	return true


func apply_event(state: MissionState, event: EventData) -> void:
	if state.mission_completed or state.mission_failed:
		return

	for decision in event.decisions:
		print("Available decision: ", decision.decision_name)


func apply_decision(
	state: MissionState,
	decision: DecisionData
) -> void:
	if state.mission_completed or state.mission_failed:
		return

	state.power += decision.power_effect
	state.water += decision.water_effect
	state.oxygen += decision.oxygen_effect
	state.food += decision.food_effect

	state.radiation_shielding += decision.shielding_effect
	state.budget += decision.budget_effect
	state.crew_health += decision.crew_health_effect

	_clamp_state(state)


func _clamp_state(state: MissionState) -> void:
	state.power = clamp(state.power, 0.0, 100.0)
	state.water = clamp(state.water, 0.0, 100.0)
	state.oxygen = clamp(state.oxygen, 0.0, 100.0)
	state.food = clamp(state.food, 0.0, 100.0)

	state.radiation_shielding = clamp(
		state.radiation_shielding,
		0.0,
		100.0
	)

	state.crew_health = clamp(
		state.crew_health,
		0.0,
		100.0
	)

	state.budget = max(state.budget, 0.0)
