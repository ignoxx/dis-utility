extends TextureRect

func _draw() -> void:
	draw_line(Vector2(0,rect_size.y/2), Vector2(rect_size.x, rect_size.y/2), Color.white)
	draw_line(Vector2(rect_size.x/2, 0), Vector2(rect_size.x/2, rect_size.y), Color.white)
