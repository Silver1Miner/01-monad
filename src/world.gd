extends Node2D

const TILE_SIZE = 32
export(int) var w = 60
export(int) var h = 24

onready var grid = $TileMap
onready var hud_control = $HUD
onready var toggle_button = $HUD/Control/control_buttons/toggle_time
onready var reset_button = $HUD/Control/control_buttons/reset
onready var next_button = $HUD/Control/control_buttons/next_level
onready var randomize_button = $HUD/Control/control_buttons/randomize
onready var generation_display = $HUD/Control/left_pane/Generation
onready var moves_display = $HUD/Control/left_pane/moves_display
onready var par_display = $HUD/Control/left_pane/par_display
onready var fast_button = $HUD/Control/left_pane/speed/fast_button
onready var minimap = $HUD/Control/target/minimap
onready var textbox = $HUD/Control/textbox
onready var target_text = $HUD/Control/target/target_label
onready var title = $HUD/Control/level_title
onready var import_button = $HUD/Control/data_loader/import
onready var export_button = $HUD/Control/data_loader/export
onready var input_state = $HUD/Control/data_loader/input_state
onready var control_color = $HUD/Control/control_color
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
	change_cell_color(PlayerData.current_color)
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
	if fast_button.connect("value_changed", self, "_on_speed_changed") != OK:
		push_error("fast button connect fail")
	if import_button.connect("pressed", self, "_on_import_pressed") != OK:
		push_error("import button connect fail")
	if export_button.connect("pressed", self, "_on_export_pressed") != OK:
		push_error("export button connect fail")
	if randomize_button.connect("pressed", self, "_on_random_pressed") != OK:
		push_error("randomize button connect fail")
	grid.cell_size.x = TILE_SIZE
	grid.cell_size.y = TILE_SIZE
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
		randomize_button.visible = false
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
		randomize_button.visible = false
		#moves_limited = true
		hud_control.set_target_mode()
		minimap.update()
	if level > Levels.levels.keys().max():
		randomize_button.visible = true
		title.text = "Game Over"
		print("campaign completed")
		textbox.initialize(Levels.campaign_complete)
		has_target = false
		#moves_limited = false
		par_display.text = ""
	_reset()

func fill_grid(grid_state, value) -> void:
	grid_state.clear()
	for x in w:
		grid_state.append([])
		for y in h:
			grid_state[x].append(value)

func populate_grid(grid_state, level_string) -> void:
	var data = level_string.split("a")
	grid_state.clear()
	for x in w:
		grid_state.append([])
		for y in h:
			grid_state[x].append(0)
	for n in data:
		if n != "":
			var x = int(n) % w
			var y = int(n) / w
			if x >= 0 and x < w and y >= 0 and y <= h:
				grid_state[x][y] = 1

func change_cell_color(color) -> void:
	grid.tile_set.tile_set_modulate(1, color)

func import_map(grid_state, data) -> void:
	for x in w:
		for y in h:
			grid.set_cell(x, y, 0)
	for n in data:
		var x = int(n) % w
		var y = int(n) / w
		if x >= 0 and x < w and y >= 0 and y <= h:
			grid_state[x][y] = 1
			grid.set_cell(x, y, 1)

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

var rng = RandomNumberGenerator.new()
func _on_random_pressed() -> void:
	for x in len(state):
		for y in len(state[x]):
			rng.randomize()
			var random_number = rng.randi_range(0, 1)
			state[x][y] = random_number
			grid.set_cell(x, y, random_number)

var drag_enabled = false
var pos = Vector2(0,0)
var pas_rel = Vector2(0,0)
func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"): # debugging
		print("current level: ", PlayerData.current_level)
		print("completed levels: ", PlayerData.completed_levels)
		print("completed challenges: ", PlayerData.completed_challenges)
	if event.is_action_pressed("left_mouse"): # changing tiles
		drag_enabled = true
		pos = (get_local_mouse_position()/TILE_SIZE).floor()
		if pos.x >= 0 and pos.x < w and pos.y >= 0 and pos.y < h and moves_left > 0:
			state[pos.x][pos.y] = 1 - grid.get_cellv(pos)
			grid.set_cellv(pos, 1 - grid.get_cellv(pos))
			$click.play()
			moves += 1
			moves_display.text = "Moves: " + str(moves)
	elif event is InputEventScreenDrag: # mobile dragging
		var rel = (event.position/TILE_SIZE).floor()
		if rel != pas_rel and rel != pos and rel.x >= 0 and rel.x < w and rel.y >= 0 and rel.y < h and moves_left > 0:
			state[rel.x][rel.y] = 1 - grid.get_cellv(rel)
			grid.set_cellv(rel, 1 - grid.get_cellv(rel))
			$click.play()
			moves += 1
			moves_display.text = "Moves: " + str(moves)
		pas_rel = rel
	elif event is InputEventScreenTouch and event.is_pressed(): # mobile touch controls, no dragging
		pos = (event.position/TILE_SIZE).floor()
		if pos.x >= 0 and pos.x < w and pos.y >= 0 and pos.y < h and moves_left > 0:
			state[pos.x][pos.y] = 1 - grid.get_cellv(pos)
			grid.set_cellv(pos, 1 - grid.get_cellv(pos))
			$click.play()
			moves += 1
			moves_display.text = "Moves: " + str(moves)
	if event.is_action_released("left_mouse"):
		drag_enabled = false

func _on_play_toggled(toggled) -> void:
	active = toggled
	if toggled:
		yield(get_tree().create_timer(Music.time - floor(Music.time)), "timeout")
		reset_button.disabled = toggled
		toggle_button.text = "Playing"
	else:
		reset_button.disabled = toggled
		toggle_button.text = "Play"

func _on_speed_changed(value) -> void:
	if value == 1:
		timestep = 1.0
	elif value == 2:
		timestep = 0.5
	elif value == 3:
		timestep = 0.25
	elif value == 4:
		timestep = 0.125

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
			grid.set_cell(x, y, state[x][y])

func _tick() -> void:
	if !active:
		return
	for x in range(w):
		for y in range(h):
			var live_neighbors = 0
			for x_offset in [-1, 0, 1]:
				for y_offset in [-1, 0, 1]:
					if x_offset != y_offset or x_offset != 0:
						if grid.get_cell(x+x_offset,y+y_offset) == 1:
							live_neighbors += 1
			if grid.get_cell(x, y) == 1:
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
			grid.set_cell(x, y, state[x][y])
	if has_target and state == target_state:
		_win()
		has_target = false

func _win() -> void:
	# print("target state reached")
	target_text.text = "Target Reached!"
	control_color.color = Color(100/255.0,100/255.0,100/255.0)
	next_button.visible = true
	if PlayerData.current_level > 0:
		PlayerData.update_level_progress(moves <= par)
	elif PlayerData.current_level <= 0:
		PlayerData.update_challenge_progress(moves <= par)

func _next_level() -> void:
	control_color.color = Color(20/255.0,20/255.0,20/255.0)
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
	if drag_enabled:
		var new_pos = (get_local_mouse_position()/TILE_SIZE).floor()
		if new_pos != pos and new_pos.x >= 0 and new_pos.x < w and new_pos.y >= 0 and new_pos.y < h and moves_left > 0:
			pos = new_pos
			state[pos.x][pos.y] = 1 - grid.get_cellv(pos)
			grid.set_cellv(pos, 1 - grid.get_cellv(pos))
			$click.play()
			moves += 1
			moves_display.text = "Moves: " + str(moves)
	if active:
		accumulated += delta
		if accumulated > timestep:
			accumulated = 0
			_tick()
			generation += 1
			generation_display.text = "Generation: " + str(generation)
