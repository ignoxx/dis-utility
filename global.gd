extends Node

var selected_point: Control

var item_data: Dictionary setget , get_item_data
var item_data_save_path: String = "user://item_data.dis"

func get_item_by_name(item_name: String) -> Dictionary:
	for item in item_data["items"]:
		if item.has("name") and item["name"] == item_name:
			return item

	return {}

func get_item_data() -> Dictionary:
	if not item_data:
		item_data = item_data_load()

	return item_data

func add_new_item(frame_paths: PoolStringArray, data: Dictionary):
	# check if name already in use
	for item in item_data["items"]:
		if item["name"] == data["name"]:
			return

	var new_item_data = {
		"name": data["name"],
		"frames": {}
	}

	for i in range(frame_paths.size()):
		new_item_data["frames"][str(i)] = {"img": image_file_load(frame_paths[i])}

	print(item_data)
	item_data["items"].append(new_item_data)
	item_data_save()

func add_new_point(item_name: String, point_name: String) -> void:
	# check if point already exists
	for item in item_data["items"]:
		if item["name"] == item_name:
			var i = item["frames"]["0"]
			if i.has("points"):
				for point in i["points"]:
					if point.has("name") and point["name"] == point_name:
						print("point already exists, aborting..")
						return

	# add new point (initialize)
	for item in item_data["items"]:
		if item["name"] == item_name:
			for i in range(item["frames"].size()):
				var ii = item["frames"][str(i)]
				if ii.has("points"):
					ii["points"].append({
						"name": point_name,
						"x": 0,
						"y": 0
					})
				else:
					ii["points"] = [{
						"name": point_name,
						"x": 0,
						"y": 0
					}]
			break

func update_existing_point(item_name: String, point_name: String, frame_number: int, data: Dictionary) -> void:
	for item in item_data["items"]:
		if item["name"] == item_name:
			for i in item["frames"][str(frame_number)]["points"]:
				if i["name"] == point_name:
					i["x"] = data["x"]
					i["y"] = data["y"]
					print("updated: %s" % i)
			break

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

func item_data_load() -> Dictionary:
	var result = get_file_content(item_data_save_path)

	if not result.empty():
		return JSON.parse(result).get_result()
	else:
		return {"items": []}

func item_data_save() -> void:
	var file = File.new()
	file.open(item_data_save_path, File.WRITE)
	file.store_string(JSON.print(item_data))
	file.close()

func get_file_content(path: String) -> String:
	var file: File = File.new()
	var content: String

	if file.file_exists(path):
		file.open(path, File.READ)
		content = file.get_as_text()
		file.close()
	else:
		return ""

	return content

func update_points_in_item(item_name: String, frame: String, points_data: Dictionary):
	for item in get_item_data():
		if item["name"] == item_name:
			item["points"][frame] = points_data

	item_data_save()

func generate_code_for_item(item_name: String) -> String:
	var frame_line_template = "if (argument0.image_index == %s) { fx = %s; fy = %s;}\n" # frame number, x, y

	var output: String = "// -------------- %s -------------- \n" % item_name
	var points_output: Dictionary = {}

	var item = get_item_by_name(item_name)

	if not item:
		return ""

	for frame in range(item["frames"].size()):
		if item["frames"][str(frame)].has("points"):
			for point in item["frames"][str(frame)]["points"]:
				if not points_output.has(point["name"]):
					points_output[point["name"]] = ""
				points_output[point["name"]] += frame_line_template % [frame, point["x"], point["y"]]

	for o in points_output:
		output += "\n// -------- points for %s --------\n" % o
		output += points_output[o]
	return output
