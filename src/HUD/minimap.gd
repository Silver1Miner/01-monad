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
	if level in Levels.levels:
		for x in range(len(Levels.levels[level]['target'])):
			for y in range(len(Levels.levels[level]['target'][x])):
				draw_rect(Rect2(Vector2(x,y) * 6, Vector2.ONE * 6), color_map[Levels.levels[level]['target'][x][y]])
