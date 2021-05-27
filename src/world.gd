extends TileMap

const TILE_SIZE = 32
export(int) var w = 60
export(int) var h = 24

onready var hud_control = $HUD
onready var toggle_button = $HUD/Control/control_buttons/toggle_time
onready var reset_button = $HUD/Control/control_buttons/reset
onready var next_button = $HUD/Control/control_buttons/next_level
onready var generation_display = $HUD/Control/left_pane/Generation
onready var moves_display = $HUD/Control/left_pane/moves_display
onready var par_display = $HUD/Control/left_pane/par_display
onready var fast_button = $HUD/Control/left_pane/fast_button
onready var minimap = $HUD/Control/target/minimap
onready var textbox = $HUD/Control/textbox
onready var target_text = $HUD/Control/target/target_label
onready var title = $HUD/Control/level_title
onready var import_button = $HUD/Control/data_loader/import
onready var export_button = $HUD/Control/data_loader/export
onready var input_state = $HUD/Control/data_loader/input_state
export var timestep = 1.0

var has_target = false
var generation := 0
var moves := 0
#var moves_limited = false
var initial_moves_left := 1
var moves_left := 1
var par := 0
var active := false
var initial_state := []
var state := []
var target_state := []

func _ready() -> void:
	next_button.visible = false
	generation_display.text = "Generation: " + str(generation)
	moves_display.text = "Moves: " + str(moves)
	par_display.text = ""
	if toggle_button.connect("toggled", self, "_on_play_toggled") != OK:
		push_error("toggle button connect fail")
	if reset_button.connect("pressed", self, "_reset") != OK:
		push_error("reset button connect fail")
	if next_button.connect("pressed", self, "_next_level") != OK:
		push_error("next level button connect fail")
	if fast_button.connect("toggled", self, "_on_fast_toggled") != OK:
		push_error("fast button connect fail")
	if import_button.connect("pressed", self, "_on_import_pressed") != OK:
		push_error("import button connect fail")
	if export_button.connect("pressed", self, "_on_export_pressed") != OK:
		push_error("export button connect fail")
	cell_size.x = TILE_SIZE
	cell_size.y = TILE_SIZE
	define_level(PlayerData.current_level)

func define_level(level):
	if level in Levels.levels: # Campaign
		populate_grid(target_state, Levels.levels[level]["target"])
		populate_grid(initial_state, Levels.levels[level]["initial"])
		initial_moves_left = Levels.levels[level]["moves_left"]
		par = Levels.levels[level]["par"]
		title.text = Levels.levels[level]["title"]
		if "dialogue" in Levels.levels[level]:
			textbox.initialize(Levels.levels[level]["dialogue"])
	elif level < 0: # Challenge
		populate_grid(target_state, Levels.challenges[PlayerData.current_challenge]["target"])
		populate_grid(initial_state, Levels.challenges[PlayerData.current_challenge]["initial"])
		par = Levels.challenges[PlayerData.current_challenge]["par"]
		title.text = Levels.challenges[PlayerData.current_challenge]["title"]
		has_target = true
		hud_control.set_target_mode()
		minimap.update()
	else: # Exception catch
		hud_control.set_loader_mode()
		fill_grid(initial_state, 0)
		fill_grid(target_state, 1)
		initial_moves_left = 99
		title.text = ""
	if level > 0: # Campaign
		has_target = true
		#moves_limited = true
		hud_control.set_target_mode()
		minimap.update()
	if level > Levels.levels.keys().max():
		title.text = "Game Over"
		print("campaign completed")
		textbox.initialize(Levels.campaign_complete)
		has_target = false
		#moves_limited = false
		par_display.text = ""
	_reset()

func fill_grid(grid, value) -> void:
	grid.clear()
	for x in w:
		grid.append([])
		for y in h:
			grid[x].append(value)

func populate_grid(grid, level_string) -> void:
	var data = level_string.split("a")
	grid.clear()
	for x in w:
		grid.append([])
		for y in h:
			grid[x].append(0)
	for n in data:
		if n != "":
			var x = int(n) % w
			var y = int(n) / w
			if x >= 0 and x < w and y >= 0 and y <= h:
				grid[x][y] = 1

func import_map(grid, data) -> void:
	for x in w:
		for y in h:
			set_cell(x, y, 0)
	for n in data:
		var x = int(n) % w
		var y = int(n) / w
		if x >= 0 and x < w and y >= 0 and y <= h:
			grid[x][y] = 1
			set_cell(x, y, 1)

func _on_import_pressed() -> void:
	var data = input_state.text.split("a")
	import_map(state, data)

func _on_export_pressed() -> void:
	var data = ""
	for x in len(state):
		for y in len(state[x]):
			if state[x][y] == 1:
				data += str(x + w * y)
				data += "a"
	data.erase(data.length() - 1, 1)
	input_state.text = data
	OS.set_clipboard(data)

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"): # debugging
		print("current level: ", PlayerData.current_level)
		print("completed levels: ", PlayerData.completed_levels)
		print("completed challenges: ", PlayerData.completed_challenges)
	if event.is_action_pressed("left_mouse"): # changing tiles
		var pos = (get_local_mouse_position()/TILE_SIZE).floor()
		if pos.x >= 0 and pos.x < w and pos.y >= 0 and pos.y < h and moves_left > 0:
			state[pos.x][pos.y] = 1 - get_cellv(pos)
			set_cellv(pos, 1 - get_cellv(pos))
			moves += 1
			moves_display.text = "Moves: " + str(moves)
			#if moves_limited:
			#	moves_left -= 1
			#	par_display.text = "Par: " + str(par)

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
	if has_target:
		par_display.text = "Par: " + str(par)
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
	print("target state reached")
	target_text.text = "Target Reached!"
	next_button.visible = true
	if PlayerData.current_level > 0:
		PlayerData.update_level_progress(moves <= par)
	elif PlayerData.current_level <= 0:
		PlayerData.update_challenge_progress(moves <= par)

func _next_level() -> void:
	active = false
	toggle_button.pressed = false
	if PlayerData.current_level > 0:
		PlayerData.current_level += 1
		define_level(PlayerData.current_level)
	elif PlayerData.current_level <= 0:
		if get_tree().change_scene("res://src/menus/level_menu.tscn") != OK:
			push_error("fail to load world")
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
