extends Control

onready var level_list = $VBoxContainer/level_box/level_list
onready var challenge_list = $VBoxContainer/challenge_box/challenge_list

func _ready():
	if $quit_to_main.connect("pressed", self, "_on_quit_to_main_pressed") != OK:
		push_error("quit to main connect fail")
	if $clear_progress.connect("pressed", self, "_on_clear_progress_pressed") != OK:
		push_error("clear progress connect fail")
	_populate_level_list()
	_populate_challenge_list()

func _on_quit_to_main_pressed() -> void:
	if get_tree().change_scene("res://src/menu.tscn") != OK:
		push_error("fail to load main menu")

var level_option = preload("res://src/menus/level_option.tscn")

func _on_clear_progress_pressed() -> void:
	PlayerData.reset()
	_populate_level_list()
	_populate_challenge_list()

func _populate_level_list() -> void:
	for n in level_list.get_children():
		level_list.remove_child(n)
		n.queue_free()
	for i in range(1, len(PlayerData.completed_levels)):
		if PlayerData.completed_levels[i] > 0:
			var option = level_option.instance()
			level_list.add_child(option)
			option.set_option_number(i)
			option.set_button_text("Level " + str(i))
			if option.button.connect("pressed", self, "_on_level_selected", [i]) != OK:
				push_error("button connect fail")
			if PlayerData.completed_levels[i] > 1:
				option.add_gold_star()

func _populate_challenge_list() -> void:
	for n in challenge_list.get_children():
		challenge_list.remove_child(n)
		n.queue_free()
	for i in range(1, len(PlayerData.completed_challenges)):
		var option = level_option.instance()
		challenge_list.add_child(option)
		option.set_option_number(i)
		option.set_button_text("Challenge " + str(i))
		if option.button.connect("pressed", self, "_on_challenge_selected", [i]) != OK:
			push_error("button connect fail")
		if PlayerData.completed_challenges[i] == 1:
			option.add_star()
		elif PlayerData.completed_challenges[i] == 2:
			option.add_gold_star()

func _on_challenge_selected(index) -> void:
	PlayerData.current_level = -1
	PlayerData.current_challenge = index
	if get_tree().change_scene("res://src/world.tscn") != OK:
		push_error("fail to load level")

func _on_level_selected(index) -> void:
	PlayerData.current_level = index
	if get_tree().change_scene("res://src/world.tscn") != OK:
		push_error("fail to load level")
