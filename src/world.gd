extends TileMap

const TILE_SIZE = 64
export(int) var w = 96
export(int) var h = 54

var active = false
var state = []

func _ready() -> void:
	cell_size.x = TILE_SIZE
	cell_size.y = TILE_SIZE
	for x in range(w):
		var t = []
		for y in range(h):
			set_cell(x, y, 0)
			t.append(0)
		state.append(t)

func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		active = !active
		print("playing is ", active)
	if event.is_action_pressed("ui_accept"):
		pass
	if event.is_action_pressed("left_mouse"):
		var pos = (get_local_mouse_position()/TILE_SIZE).floor()
		set_cellv(pos, 1 - get_cellv(pos))
		pass

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
		if accumulated > 0.3:
			accumulated = 0
			tick()
