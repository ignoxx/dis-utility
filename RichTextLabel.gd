extends TextEdit


func _ready() -> void:
	clear_colors()
	add_keyword_color("if", Color(1, 0.652253, 0.160156))
	add_keyword_color("image_index", Color(1, 0.402344, 0.402344))
	add_keyword_color("argument0", Color(1, 0.402344, 0.402344))
	add_color_region("//", "", Color(0.004639, 0.59375, 0.165724))
