extends Control

var current_item: Dictionary
var current_index: int = 0 setget set_index, get_index

func get_max_index() -> int:
	if current_item:
		return current_item["frames"].size() - 1

	return 0

func get_index() -> int:
	current_index = clamp(current_index, 0, get_max_index())
	return current_index

func set_index(value: int) -> void:
	if current_item:
		var max_index = get_max_index()
		value = clamp(value, -1, max_index+1)

		if current_index == max_index and value > current_index:
			current_index = 0

		elif current_index == 0 and value < current_index:
			current_index = max_index

		else:
			current_index = value

	update_frame()

func update_frame() -> void:
	if not current_item:
		return

	var new_texture = ImageTexture.new()
	new_texture.create_from_image(
		global.image_data_load(
		current_item["frames"][str(current_index)]
	))

	$TextureRect.texture = new_texture
