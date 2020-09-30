extends Node

var item_data: Array setget , get_item_data
var item_data_save_path: String = "user://item_data.dis"

func get_item_by_name(item_name: String) -> Dictionary:
	for item in item_data:
		if item["name"] == item_name:
			return item

	return {}

func get_item_data() -> Array:
	if not item_data:
		item_data = item_data_load()

	return item_data

func add_new_item(frame_paths: PoolStringArray, data: Dictionary):
	# check if name already in use
	for item in item_data:
		if item["name"] == data["name"]:
			return

	var new_item_data = {
		"name": data["name"],
		"frames": {}
	}

	for i in range(frame_paths.size()):
		new_item_data["frames"][str(i)] = image_file_load(frame_paths[i])

	item_data.append(new_item_data)
	item_data_save()

func image_data_load(content: String) -> Image:
	var image: Image = Image.new()
	image.load_png_from_buffer(Marshalls.base64_to_raw(content))
	return image

func image_file_load(path: String) -> String:
	var file = File.new()
	file.open(path, File.READ)
	var content = Marshalls.raw_to_base64(file.get_buffer(file.get_len()))
	file.close()
	return content

func item_data_load() -> Array:
	var result = get_file_content(item_data_save_path)

	if result:
		return JSON.parse(result).get_result()["default"]
	return []

func item_data_save() -> void:
	var file = File.new()
	file.open(item_data_save_path, File.WRITE)
	file.store_string(JSON.print({"default": item_data}))
	file.close()

func get_file_content(path: String) -> String:
	var file: File = File.new()
	var content: String

	if file.file_exists(path):
		file.open(path, File.READ)
		content = file.get_as_text()
		file.close()
	else:
		return "{}"

	return content
