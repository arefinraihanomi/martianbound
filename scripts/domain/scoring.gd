class_name Scoring
extends RefCounted


func calculate_score(state: MissionState) -> float:
	var score: float = 0.0

	# Crew health
	score += state.crew_health * 0.30

	# Resources
	score += state.power * 0.15
	score += state.water * 0.15
	score += state.oxygen * 0.15
	score += state.food * 0.10

	# Radiation protection
	score += state.radiation_shielding * 0.10

	# Remaining budget
	var budget_score: float = min(state.budget / 10.0, 100.0)
	score += budget_score * 0.05

	return clamp(score, 0.0, 100.0)
