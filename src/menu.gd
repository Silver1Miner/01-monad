extends Control


func _ready() -> void:
	if $menu_options/free.connect("pressed", self, "_on_free_pressed") != OK:
		push_error("free button connect fail")
	if $menu_options/quit.connect("pressed", self, "_on_quit_pressed") != OK:
		push_error("quit button connect fail")
	if $menu_options/new_game.connect("pressed", self, "_on_new_game_pressed") != OK:
		push_error("new game button connect fail")
	if $menu_options/level_select.connect("pressed", self, "_on_level_select_pressed") != OK:
		push_error("level select button connect fail")
	if $menu_options/settings.connect("pressed", self, "_on_settings_pressed") != OK:
		push_error("settings button connect fail")

func _on_new_game_pressed() -> void:
	PlayerData.current_level = 1
	if get_tree().change_scene("res://src/world.tscn") != OK:
		push_error("fail to load world")

func _on_level_select_pressed() -> void:
	if get_tree().change_scene("res://src/menus/level_menu.tscn") != OK:
		push_error("fail to load world")

func _on_free_pressed() -> void:
	PlayerData.current_level = 0
	if get_tree().change_scene("res://src/world.tscn") != OK:
		push_error("fail to load world")

func _on_settings_pressed() -> void:
	if get_tree().change_scene("res://src/menus/settings_menu.tscn") != OK:
		push_error("fail to load trophies")

func _on_quit_pressed() -> void:
	get_tree().quit()
