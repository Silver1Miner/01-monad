extends AudioStreamPlayer

var choices = {}

func _ready():
	stream = preload("res://sound/One_to_Two_to_Three.ogg")
	play()

func change_song(id):
	stream = choices[id]
	play()
