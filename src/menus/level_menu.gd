extends Control

onready var level_list = $VBoxContainer/level_box/level_list

func _ready():
	if $quit_to_main.connect("pressed", self, "_on_quit_to_main_pressed") != OK:
		push_error("quit to main connect fail")
	_populate_level_list()

func _on_quit_to_main_pressed() -> void:
	if get_tree().change_scene("res://src/menu.tscn") != OK:
		push_error("fail to load main menu")

func _populate_level_list() -> void:
	for i in range(1, len(PlayerData.completed_levels)):
		if PlayerData.completed_levels[i] > 0:
			var level_option = Button.new()
			level_option.text = "Level " + str(i)
			if level_option.connect("pressed", self, "_on_level_selected", [i]) != OK:
				push_error("button connect fail")
			level_list.add_child(level_option)

func _on_level_selected(index) -> void:
	PlayerData.current_level = index
	if get_tree().change_scene("res://src/world.tscn") != OK:
		push_error("fail to load level")
