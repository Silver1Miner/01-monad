extends Control

onready var level_list = $VBoxContainer/level_box/level_list

func _ready():
	if $quit_to_main.connect("pressed", self, "_on_quit_to_main_pressed") != OK:
		push_error("quit to main connect fail")
	_populate_level_list()

func _on_quit_to_main_pressed() -> void:
	if get_tree().change_scene("res://src/menu.tscn") != OK:
		push_error("fail to load main menu")

var level_option = preload("res://src/menus/level_option.tscn")

func _populate_level_list() -> void:
	for i in range(1, len(PlayerData.completed_levels)):
		if PlayerData.completed_levels[i] > 0:
			#var level_option = Button.new()
			var option = level_option.instance()
			level_list.add_child(option)
			#level_option.text = "Level " + str(i)
			option.set_option_number(i)
			option.set_button_text("Level " + str(i))
			if option.button.connect("pressed", self, "_on_level_selected", [i]) != OK:
				push_error("button connect fail")
			#if level_option.connect("pressed", self, "_on_level_selected", [i]) != OK:
			#	push_error("button connect fail")
			if PlayerData.completed_levels[i] > 1:
				option.add_gold_star()
			

func _on_level_selected(index) -> void:
	PlayerData.current_level = index
	if get_tree().change_scene("res://src/world.tscn") != OK:
		push_error("fail to load level")
