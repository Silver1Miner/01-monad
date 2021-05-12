extends TileMap

const TILE_SIZE = 64
export(int) var w = 30
export(int) var h = 12

#export(int) var camera_zoom = 1
onready var camera = $Camera2D

var generation = 0
var active = false
var state = []
var target_state = []

func _ready() -> void:
	$HUD/Control/Label.text = "Playing is " + str(active)
	$HUD/Control/Generation.text = "Generation: " + str(generation)
	cell_size.x = TILE_SIZE
	cell_size.y = TILE_SIZE
	#var world_size_x = w * TILE_SIZE
	#var world_size_y = h * TILE_SIZE
	#camera.position = Vector2(world_size_x, world_size_y)/2
	#camera.zoom = Vector2(world_size_x, world_size_y)/Vector2(1280,720) * camera_zoom
	for x in range(w):
		var t = []
		for y in range(h):
			set_cell(x, y, 0)
			t.append(0)
		state.append(t)

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("right_mouse"):
		var pos = (get_local_mouse_position()/TILE_SIZE).floor()
		if pos.x >= 0 and pos.x < w and pos.y >= 0 and pos.y < h:
			active = !active
			$HUD/Control/Label.text = "Playing is " + str(active)
	if event.is_action_pressed("ui_accept"):
		print(state)
	if event.is_action_pressed("left_mouse"):
		var pos = (get_local_mouse_position()/TILE_SIZE).floor()
		if pos.x >= 0 and pos.x < w and pos.y >= 0 and pos.y < h:
			state[pos.x][pos.y] = 1 - get_cellv(pos)
			set_cellv(pos, 1 - get_cellv(pos))

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

var accumulated = 0

func _process(delta):
	if active:
		accumulated += delta
		if accumulated > 1.0:
			accumulated = 0
			if state != target_state:
				tick()
				generation += 1
				$HUD/Control/Generation.text = "Generation: " + str(generation)

func print_state() -> void:
	print(state)
