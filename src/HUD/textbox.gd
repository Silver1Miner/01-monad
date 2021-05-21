extends Control

var page = "0"
var text_playing = true
var dialogue = {}

onready var text = $textbox/text
onready var nametag = $textbox/nametag
onready var timer = $Timer
onready var next_button = $textbox/next

func _ready() -> void:
	timer.wait_time = 0.05
	timer.autostart = true
	if timer.connect("timeout", self, "_on_timer_timeout") != OK:
		push_error("timer connect fail")
	if next_button.connect("pressed", self, "_on_next_pressed") != OK:
		push_error("next button connect fail")
	visible = false

func initialize(scene) -> void:
	visible = true
	timer.start()
	get_tree().paused = true
	visible = true
	dialogue = scene
	text_playing = true
	page = "0"
	text.set_bbcode(dialogue[page]["text"])
	nametag.set_text(dialogue[page]["name"])
	text.set_visible_characters(0)
	set_process_input(true)

func _on_next_pressed() -> void:
	if text_playing:
		if text.get_visible_characters() > text.get_total_character_count():
			if int(page) < dialogue.size() - 1:
				page = str(int(page) + 1)
				text.set_bbcode(dialogue[page]["text"])
				nametag.set_text(dialogue[page]["name"])
				text.set_visible_characters(0)
			elif int(page) >= dialogue.size() - 1:
				end_text()
		else:
			text.set_visible_characters(text.get_total_character_count())

func _input(event) -> void:
	if text_playing:
	#	if (event.is_action_pressed("ui_cancel") or event.is_action_pressed("left_mouse")):
	#		if text.get_visible_characters() > text.get_total_character_count():
	#			if int(page) < dialogue.size() - 1:
	#				page = str(int(page) + 1)
	#				text.set_bbcode(dialogue[page]["text"])
	#				nametag.set_text(dialogue[page]["name"])
	#				text.set_visible_characters(0)
	#			elif int(page) >= dialogue.size() - 1:
	#				end_text()
	#		else:
	#			text.set_visible_characters(text.get_total_character_count())
		if (event.is_action_pressed("ui_cancel") or event.is_action_pressed("right_mouse")):
			end_text()

func end_text() -> void:
	get_tree().paused = false
	visible = false

func _on_timer_timeout() -> void:
	text.set_visible_characters(text.get_visible_characters()+1)
