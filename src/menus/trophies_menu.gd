extends Control


func _ready():
	if $quit_to_main.connect("pressed", self, "_on_quit_to_main_pressed") != OK:
		push_error("quit to main connect fail")
	pass

func _on_quit_to_main_pressed() -> void:
	if get_tree().change_scene("res://src/menu.tscn") != OK:
		push_error("fail to load main menu")
