extends Node

const NUMBER_LEVELS = 12
var current_level = 1
var current_challenge = 0
var completed_levels = [1]

var number_challenges = 10
var completed_challenges = []

func _ready():
	for i in NUMBER_LEVELS:
		completed_levels.append(0)
	for i in number_challenges:
		completed_challenges.append(0)

func update_level_progress(beat_par) -> void:
	if completed_levels[current_level] == 0:
		completed_levels[current_level] = 1
	if beat_par:
		completed_levels[current_level] = 2
	save_state()

func update_challenge_progress(beat_par) -> void:
	if completed_levels[current_challenge] == 0:
		completed_challenges[current_challenge] = 1
	if beat_par:
		completed_levels[current_level] = 3
	save_state()

func load_state() -> void:
	current_level = 1
	pass

func save_state() -> void:
	pass
