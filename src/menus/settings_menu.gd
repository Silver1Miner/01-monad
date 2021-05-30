extends Control

onready var color_picker = $choices/options/ColorPicker


func _ready():
	if $quit_to_main.connect("pressed", self, "_on_quit_to_main_pressed") != OK:
		push_error("quit to main connect fail")
	if color_picker.connect("color_changed", self, "_on_ColorPicker_color_changed") != OK:
		push_error("ColorPicker connect fail")
	pass

func _on_quit_to_main_pressed() -> void:
	PlayerData.save_state()
	if get_tree().change_scene("res://src/menu.tscn") != OK:
		push_error("fail to load main menu")


func _on_ColorPicker_color_changed(color):
	PlayerData.current_color = color
