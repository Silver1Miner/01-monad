extends Control


func _ready() -> void:
	if $menu_options/free.connect("pressed", self, "_on_free_pressed") != OK:
		push_error("free button connect fail")
	if $menu_options/quit.connect("pressed", self, "_on_quit_pressed") != OK:
		push_error("quit button connect fail")
	if $menu_options/new_game.connect("pressed", self, "_on_new_game_pressed") != OK:
		push_error("new game button connect fail")
	if $menu_options/trophies.connect("pressed", self, "_on_trophies_pressed") != OK:
		push_error("trophies button connect fail")
	if $menu_options/challenge_select.connect("pressed", self, "_on_challenge_pressed") != OK:
		push_error("challenge button connect fail")

func _on_new_game_pressed() -> void:
	PlayerData.current_level = 1
	if get_tree().change_scene("res://src/world.tscn") != OK:
		push_error("fail to load world")

func _on_challenge_pressed() -> void:
	if get_tree().change_scene("res://src/menus/challenge_menu.tscn") != OK:
		push_error("fail to load challenges")

func _on_free_pressed() -> void:
	PlayerData.current_level = 0
	if get_tree().change_scene("res://src/world.tscn") != OK:
		push_error("fail to load world")

func _on_trophies_pressed() -> void:
	if get_tree().change_scene("res://src/menus/trophies_menu.tscn") != OK:
		push_error("fail to laod trophies")

func _on_quit_pressed() -> void:
	get_tree().quit()
