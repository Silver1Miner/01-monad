extends TileMap

const TILE_SIZE = 64
export(int) var w = 30
export(int) var h = 12

onready var toggle_button = $HUD/Control/toggle_time
onready var reset_button = $HUD/Control/reset
onready var generation_display = $HUD/Control/Generation
onready var moves_display = $HUD/Control/moves_display

var generation := 0
var moves := 0
var active := false
var initial_state := []
var state := []
var target_state := []

func _ready() -> void:
	define_level(1, 1)
	generation_display.text = "Generation: " + str(generation)
	moves_display.text = "Moves: " + str(moves)
	if toggle_button.connect("toggled", self, "_on_play_toggled") != OK:
		push_error("toggle button connect fail")
	if reset_button.connect("pressed", self, "reset") != OK:
		push_error("reset button connect fail")
	cell_size.x = TILE_SIZE
	cell_size.y = TILE_SIZE
	reset()

func define_level(initial, target):
	initial_state = Levels.initials[initial]
	target_state = Levels.targets[target]

func _input(event) -> void:
	if event.is_action_pressed("right_mouse"): # debugging
		print(state)
	if event.is_action_pressed("left_mouse"): # changing tiles
		var pos = (get_local_mouse_position()/TILE_SIZE).floor()
		if pos.x >= 0 and pos.x < w and pos.y >= 0 and pos.y < h:
			state[pos.x][pos.y] = 1 - get_cellv(pos)
			set_cellv(pos, 1 - get_cellv(pos))
			moves += 1
			moves_display.text = "Moves: " + str(moves)

func _on_play_toggled(toggled) -> void:
	active = toggled
	if toggled:
		reset_button.disabled = toggled
		toggle_button.text = "Playing"
	else:
		reset_button.disabled = toggled
		toggle_button.text = "Play"

func reset() -> void:
	generation = 0
	moves = 0
	generation_display.text = "Generation: " + str(generation)
	moves_display.text = "Moves: " + str(moves)
	state = initial_state
	for x in range(w):
		for y in range(h):
			set_cell(x, y, state[x][y])

func tick() -> void:
	if !active:
		return
	for x in range(w):
		for y in range(h):
			var live_neighbors = 0
			for x_offset in [-1, 0, 1]:
				for y_offset in [-1, 0, 1]:
					if x_offset != y_offset or x_offset != 0:
						if get_cell(x+x_offset,y+y_offset) == 1:
							live_neighbors += 1
			if get_cell(x, y) == 1:
				if live_neighbors in [2, 3]:
					state[x][y] = 1
				else:
					state[x][y] = 0
			else:
				if live_neighbors == 3:
					state[x][y] = 1
				else:
					state[x][y] = 0
	for x in range(w):
		for y in range(h):
			set_cell(x, y, state[x][y])
	if state == target_state:
		win()

func win() -> void:
	_on_play_toggled(false)
	print("target state reached")

var accumulated = 0
func _process(delta):
	if active:
		accumulated += delta
		if accumulated > 1.0:
			accumulated = 0
			tick()
			generation += 1
			generation_display.text = "Generation: " + str(generation)
