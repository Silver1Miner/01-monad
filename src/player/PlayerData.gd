extends Node

const NUMBER_LEVELS = 12
var current_level = 1
var current_challenge = 0
var completed_levels = [1]

var number_challenges = 3
var completed_challenges = [1]

func _ready():
	for i in NUMBER_LEVELS:
		completed_levels.append(0)
	for i in number_challenges:
		completed_challenges.append(0)
	load_state()

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
		completed_challenges[current_challenge] = 2
	save_state()

func load_state() -> void:
	var save_game = File.new()
	if not save_game.file_exists("user://monad.save"):
		return # Error! We don't have a save to load.
	save_game.open("user://monad.save", File.READ)
	completed_levels = parse_json(save_game.get_line())
	completed_challenges = parse_json(save_game.get_line())
	save_game.close()

func save_state() -> void:
	var save_game = File.new()
	save_game.open("user://monad.save", File.WRITE)
	save_game.store_line(to_json(completed_levels))
	save_game.store_line(to_json(completed_challenges))
	save_game.close()
