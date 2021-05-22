extends TileMap

const TILE_SIZE = 32
export(int) var w = 60
export(int) var h = 24

onready var toggle_button = $HUD/Control/control_buttons/toggle_time
onready var reset_button = $HUD/Control/control_buttons/reset
onready var next_button = $HUD/Control/control_buttons/next_level
onready var generation_display = $HUD/Control/left_pane/Generation
onready var moves_display = $HUD/Control/left_pane/moves_display
onready var moves_remaining_display = $HUD/Control/left_pane/remaining_moves
onready var fast_button = $HUD/Control/left_pane/fast_button
onready var minimap = $HUD/Control/minimap
onready var textbox = $HUD/Control/textbox
onready var target_text = $HUD/Control/target
onready var title = $HUD/Control/level_title
export var timestep = 1.0

var has_target = false
var generation := 0
var moves := 0
var moves_limited = false
var initial_moves_left := 1
var moves_left := 1
var active := false
var initial_state := []
var state := []
var target_state := []

func _ready() -> void:
	next_button.visible = false
	generation_display.text = "Generation: " + str(generation)
	moves_display.text = "Moves: " + str(moves)
	moves_remaining_display.text = ""
	if toggle_button.connect("toggled", self, "_on_play_toggled") != OK:
		push_error("toggle button connect fail")
	if reset_button.connect("pressed", self, "_reset") != OK:
		push_error("reset button connect fail")
	if next_button.connect("pressed", self, "_next_level") != OK:
		push_error("next level button connect fail")
	if fast_button.connect("toggled", self, "_on_fast_toggled") != OK:
		push_error("fast button connect fail")
	cell_size.x = TILE_SIZE
	cell_size.y = TILE_SIZE
	define_level(PlayerData.current_level)

func define_level(level):
	if level in Levels.levels:
		initial_state = Levels.levels[level]["initial"].duplicate(true)
		target_state = Levels.levels[level]["target"].duplicate(true)
		initial_moves_left = Levels.levels[level]["moves_left"]
		title.text = Levels.levels[level]["title"]
		textbox.initialize(Levels.levels[level]["dialogue"])
	else:
		fill_grid(initial_state, 0)
		fill_grid(target_state, 1)
		initial_moves_left = 99
		title.text = ""
	if level > Levels.levels.keys().max():
		title.text = "Game Over"
		print("campaign completed")
	if level > 0:
		has_target = true
		moves_limited = true
		minimap.update()
	_reset()

func fill_grid(grid, value) -> void:
	grid.clear()
	for x in w:
		grid.append([])
		for y in h:
			grid[x].append(value)

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"): # debugging
		OS.set_clipboard(str(state))
		print(PlayerData.current_level)
	if event.is_action_pressed("left_mouse"): # changing tiles
		var pos = (get_local_mouse_position()/TILE_SIZE).floor()
		if pos.x >= 0 and pos.x < w and pos.y >= 0 and pos.y < h and moves_left > 0:
			state[pos.x][pos.y] = 1 - get_cellv(pos)
			set_cellv(pos, 1 - get_cellv(pos))
			moves += 1
			moves_display.text = "Moves: " + str(moves)
			if moves_limited:
				moves_left -= 1
				moves_remaining_display.text = "Moves Left: " + str(moves_left)

func _on_play_toggled(toggled) -> void:
	active = toggled
	if toggled:
		reset_button.disabled = toggled
		toggle_button.text = "Playing"
	else:
		reset_button.disabled = toggled
		toggle_button.text = "Play"

func _on_fast_toggled(toggled) -> void:
	if toggled:
		timestep = 0.25
	else:
		timestep = 1.0

func _reset() -> void:
	target_text.text = "Target"
	active = false
	generation = 0
	moves = 0
	moves_left = initial_moves_left
	generation_display.text = "Generation: " + str(generation)
	moves_display.text = "Moves: " + str(moves)
	if moves_limited:
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
	target_text.text = "Target Reached!"
	next_button.visible = true

func _next_level() -> void:
	active = false
	toggle_button.pressed = false
	PlayerData.current_level += 1
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
