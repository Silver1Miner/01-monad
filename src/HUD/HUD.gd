extends CanvasLayer


func _ready():
	if $Control/quit_to_main.connect("pressed", self, "_on_quit_to_main_pressed") != OK:
		push_error("quit to main connect fail")
	if $Control/left_pane/speed/fast_button.connect("value_changed", self, "_on_speed_value_changed") != OK:
		push_error("speed dispaly connect fail")
	$Control/left_pane/speed/speed_display.text = str($Control/left_pane/speed/fast_button.value)
	pass

func _on_quit_to_main_pressed() -> void:
	get_tree().paused = false
	if get_tree().change_scene("res://src/menu.tscn") != OK:
		push_error("fail to load main menu")

func _on_speed_value_changed(value) -> void:
	$Control/left_pane/speed/speed_display.text = str(value)

func set_target_mode() -> void:
	$Control/target.visible = true
	$Control/data_loader.visible = false

func set_loader_mode() -> void:
	$Control/target.visible = false
	$Control/data_loader.visible = true
