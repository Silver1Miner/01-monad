extends AudioStreamPlayer

var choices := {}
var time := 0.0

func _ready():
	stream = preload("res://sound/One_to_Two_to_Three.ogg")
	play()

func change_song(id):
	stream = choices[id]
	play()

func _process(_delta):
	time = get_playback_position() + AudioServer.get_time_since_last_mix()
	# Compensate for output latency.
	time -= AudioServer.get_output_latency()
	#print("Time is: ", time)
