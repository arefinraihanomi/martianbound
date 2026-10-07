extends Control


@onready var event_title_label: Label = $ColorRect/VBoxContainer/EventTitleLabel
@onready var event_description_label: Label = $ColorRect/VBoxContainer/EventDescriptionLabel

@onready var decision_title_label: Label = $ColorRect/VBoxContainer/DecisionTitleLabel
@onready var decision_description_label: Label = $ColorRect/VBoxContainer/DecisionDescriptionLabel

@onready var decision_button: Button = $ColorRect/VBoxContainer/DecisionButton


func _ready() -> void:
	decision_button.pressed.connect(_on_decision_pressed)
	update_event_ui()


func update_event_ui() -> void:
	var event: EventData = MissionSession.active_event

	if event == null:
		return

	event_title_label.text = event.event_name
	event_description_label.text = event.description

	if event.decisions.is_empty():
		decision_button.disabled = true
		return

	var decision: DecisionData = event.decisions[0]

	decision_title_label.text = decision.decision_name
	decision_description_label.text = decision.description
	decision_button.text = decision.decision_name


func _on_decision_pressed() -> void:
	var event: EventData = MissionSession.active_event

	if event == null:
		return

	if event.decisions.is_empty():
		return

	var decision: DecisionData = event.decisions[0]

	var success: bool = MissionSession.choose_decision(decision)

	print("Decision selected: ", decision.decision_name)
	print("Decision applied: ", success)
