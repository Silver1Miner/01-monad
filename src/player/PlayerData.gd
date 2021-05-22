extends Node

var current_level = 1
var challenge_level = 0

var number_challenges = 10
var completed_challenges = []

func _ready():
	pass

func populate_challenge_record() -> void:
	for i in number_challenges:
		completed_challenges.append(0)

func load_state() -> void:
	current_level = 1
	pass

func save_state() -> void:
	pass
