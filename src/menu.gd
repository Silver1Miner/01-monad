extends Control


func _ready() -> void:
	if $menu_options/free.connect("pressed", self, "_on_free_pressed") != OK: push_error("free button connect fail")
	if $menu_options/quit.connect("pressed", self, "_on_quit_pressed") != OK: push_error("quit button connect fail")
	pass

func _on_free_pressed() -> void:
	if get_tree().change_scene("res://src/world.tscn") != OK: push_error("fail to load free play")

func _on_quit_pressed() -> void:
	get_tree().quit()
