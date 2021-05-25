extends Control

var w = 60
var h = 24
var color_map := {
	0: Color.black,
	1: Color.white
}
var grid := []

func _ready():
	pass

func populate_grid(level_string) -> void:
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

func _draw():
	var level = PlayerData.current_level
	draw_set_transform(rect_size / 2, 0, Vector2.ONE)
	if level in Levels.levels:
		populate_grid(Levels.levels[level]["target"])
		for x in w:
			for y in h:
				draw_rect(Rect2(Vector2(x,y) * 6, Vector2.ONE * 6), color_map[grid[x][y]])
