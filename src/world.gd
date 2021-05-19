extends TileMap

const TILE_SIZE = 64
export(int) var w = 30
export(int) var h = 12

onready var toggle_button = $HUD/Control/control_buttons/toggle_time
onready var reset_button = $HUD/Control/control_buttons/reset
onready var next_button = $HUD/Control/control_buttons/next_level
onready var generation_display = $HUD/Control/Generation
onready var moves_display = $HUD/Control/moves_display
onready var moves_remaining_display = $HUD/Control/remaining_moves
onready var minimap = $HUD/Control/minimap
onready var textbox = $HUD/Control/textbox
export var timestep = 0.5

var has_target = false
var generation := 0
var moves := 0
var initial_moves_left := 99
var moves_left := 99
var active := false
var initial_state := []
var state := []
var target_state := []

func _ready() -> void:
	next_button.visible = false
	generation_display.text = "Generation: " + str(generation)
	moves_display.text = "Moves: " + str(moves)
	if toggle_button.connect("toggled", self, "_on_play_toggled") != OK:
		push_error("toggle button connect fail")
	if reset_button.connect("pressed", self, "_reset") != OK:
		push_error("reset button connect fail")
	if next_button.connect("pressed", self, "_next_level") != OK:
		push_error("next level button connect fail")
	cell_size.x = TILE_SIZE
	cell_size.y = TILE_SIZE
	define_level(PlayerData.current_level)

func define_level(level):
	if level in Levels.initials:
		initial_state = Levels.initials[level].duplicate(true)
	else:
		fill_grid(initial_state, 0)
	if level in Levels.targets:
		target_state = Levels.targets[level].duplicate(true)
	else:
		fill_grid(target_state, 1)
	if level in Levels.moves_left:
		initial_moves_left = Levels.moves_left[level]
	if level > 0:
		has_target = true
		minimap.update()
	if level in Levels.dialogue:
		textbox.initialize(Levels.dialogue[level])
	_reset()

func fill_grid(grid, value) -> void:
	grid.clear()
	for x in w:
		grid.append([])
		for y in h:
			grid[x].append(value)

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"): # debugging
		print(initial_state)
	if event.is_action_pressed("left_mouse"): # changing tiles
		var pos = (get_local_mouse_position()/TILE_SIZE).floor()
		if pos.x >= 0 and pos.x < w and pos.y >= 0 and pos.y < h and moves_left > 0:
			state[pos.x][pos.y] = 1 - get_cellv(pos)
			set_cellv(pos, 1 - get_cellv(pos))
			moves += 1
			moves_left -= 1
			moves_display.text = "Moves: " + str(moves)
			moves_remaining_display.text = "Moves Left: " + str(moves_left)

func _on_play_toggled(toggled) -> void:
	active = toggled
	if toggled:
		reset_button.disabled = toggled
		toggle_button.text = "Playing"
	else:
		reset_button.disabled = toggled
		toggle_button.text = "Play"

func _reset() -> void:
	generation = 0
	moves = 0
	moves_left = initial_moves_left
	generation_display.text = "Generation: " + str(generation)
	moves_display.text = "Moves: " + str(moves)
	moves_remaining_display.text = "Moves Left: " + str(moves_left)
	state = initial_state.duplicate(true)
	for x in range(w):
		for y in range(h):
			set_cell(x, y, state[x][y])

func _tick() -> void:
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
	if has_target and state == target_state:
		_win()
		has_target = false

func _win() -> void:
	#active = false
	#reset_button.disabled = false
	#toggle_button.text = "Play"
	print("target state reached")
	next_button.visible = true

func _next_level() -> void:
	PlayerData.current_level += 1
	if PlayerData.current_level in Levels.dialogue:
		define_level(PlayerData.current_level)
	next_button.visible = false

var accumulated = 0
func _process(delta):
	if active:
		accumulated += delta
		if accumulated > timestep:
			accumulated = 0
			_tick()
			generation += 1
			generation_display.text = "Generation: " + str(generation)
