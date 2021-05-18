extends Control

var color_map = {
	0: Color.black,
	1: Color.white
}
var level = PlayerData.current_level

func _ready():
	pass

func _draw():
	draw_set_transform(rect_size / 2, 0, Vector2.ONE)

	for x in range(len(Levels.targets[level])):
		for y in range(len(Levels.targets[level][x])):
			draw_rect(Rect2(Vector2(x,y) * 12, Vector2.ONE * 12), color_map[Levels.targets[level][x][y]])
