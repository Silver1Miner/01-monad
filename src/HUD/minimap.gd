extends Control

var color_map = {
	0: Color.black,
	1: Color.white
}

func _ready():
	pass

func _draw():
	var level = PlayerData.current_level
	draw_set_transform(rect_size / 2, 0, Vector2.ONE)
	if level in Levels.targets:
		for x in range(len(Levels.targets[level])):
			for y in range(len(Levels.targets[level][x])):
				draw_rect(Rect2(Vector2(x,y) * 6, Vector2.ONE * 6), color_map[Levels.targets[level][x][y]])
