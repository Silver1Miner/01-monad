extends HBoxContainer

var option_number := 1
onready var button = $Button
onready var picture = $TextureRect

func _ready():
	picture.texture = null

func set_option_number(i) -> void:
	option_number = i

func set_button_text(new_text) -> void:
	button.text = new_text

func add_star() -> void:
	picture.texture = load("res://assets/star.png")

func add_gold_star() -> void:
	picture.texture = load("res://assets/star-gold.png")

func button_pressed() -> void:
	pass
