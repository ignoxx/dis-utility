extends Control

var Point = load("res://Point.tscn")
onready var item_list = $MarginContainer/HBoxContainer/HistoryPanel/TabContainer/Items/VBoxContainer/ItemList
onready var item_name_text_box = $WindowDialog/HBoxContainer/TxtItemName
onready var item = $MarginContainer/HBoxContainer/ObjectPanel/Item
onready var btn_load_selected = $MarginContainer/HBoxContainer/HistoryPanel/TabContainer/Items/VBoxContainer/HBoxContainer/BtnLoadSelected
onready var lbl_frame = $MarginContainer/HBoxContainer/ToolPanel/TabContainer2/Inspector/VBoxContainer/HBoxContainer2/LblFrameNum
onready var point_list = $MarginContainer/HBoxContainer/ToolPanel/TabContainer2/Inspector/VBoxContainer/ScrollContainer/VBoxContainer/PointList
onready var object_panel = $MarginContainer/HBoxContainer/ObjectPanel
onready var point_data = $MarginContainer/HBoxContainer/ToolPanel/TabContainer2/Inspector/VBoxContainer/ScrollContainer/VBoxContainer/PointData

var selected_index: int

func _ready() -> void:
	load_items()

func load_items() -> void:
	item_list.clear()
	for i in global.item_data["items"]:
		item_list.add_item(i["name"])

func _process(delta: float) -> void:
	if item.current_item and global.selected_point:
		point_data.text = """
		Point: %s
		Position: %s
		""" % [
			global.selected_point.point_name,
			global.selected_point.rect_position - item.rect_size/2
		]

func _on_BtnAddItem_pressed() -> void:
	$WindowDialog.show()
	item_name_text_box.grab_focus()

func _on_FileDialog_files_selected(paths: PoolStringArray) -> void:
	global.add_new_item(paths, {"name": item_name_text_box.text})
	load_items()

func _on_Button_pressed() -> void:
	$WindowDialog.hide()

	if not item_name_text_box.text.empty():
		$FileDialog.show()

func _on_ItemList_item_selected(index: int) -> void:
	btn_load_selected.disabled = false
	selected_index = index

func _on_BtnLoadSelected_pressed() -> void:
	var target_item = global.get_item_by_name(
		item_list.get_item_text(selected_index)
	)

	if target_item:
		print("load target")
		item.current_item = target_item
		item.current_index = 0
		item.update_frame()
		update_frame_label()

		clear_all_points()
		var i = target_item["frames"][str(item.current_index)]
		if i.has("points"):
			load_all_points(i["points"])

func _on_BtnPrevFrame_pressed() -> void:
	save_frame_points()

	item.current_index += 1
	update_frame_label()
	update_points()

func _on_BtnNextFrame_pressed() -> void:
	save_frame_points()

	item.current_index -= 1
	update_frame_label()
	update_points()

func update_frame_label():
	lbl_frame.text = "%s / %s" % [item.current_index, item.get_max_index()]

func _on_ItemList_item_rmb_selected(index: int, at_position: Vector2) -> void:
	$PopupMenu.set_position(get_global_mouse_position() + Vector2(10,0))
	$PopupMenu.show()

func _on_PopupMenu_index_pressed(index: int) -> void:
	if index == 0:
		print("delete")

func _on_BtnAddPoint_pressed() -> void:
	$PointDialog/HBoxContainer/TxtItemName.text = ""
	$PointDialog.show()

func _on_BtnConfirmPointAdd_pressed() -> void:
	var point = Point.instance()
	point.point_name = $PointDialog/HBoxContainer/TxtItemName.text
	point.set_position(item.rect_size/2)
	object_panel.add_child(point)
	$PointDialog.hide()

	# TODO initialize point to every frame
	global.add_new_point(
		item_list.get_item_text(selected_index),
		point.point_name
	)

func clear_all_points() -> void:
	var childs = object_panel.get_children()
	for child in childs:
		if child.get_filename() == Point.get_path():
			child.queue_free()

func load_all_points(frame: Array) -> void:
	if not frame:
		return

	for f in frame:
		var new_point = Point.instance()
		new_point.point_name = f["name"]
		new_point.rect_position = Vector2(f["x"], f["y"]) + item.rect_size/2
		object_panel.add_child(new_point)
		print("Added: %s" % f)

# update points for current frame
func update_points():
	clear_all_points()
	var target_item = global.get_item_by_name(
		item_list.get_item_text(selected_index)
	)

	if target_item:
		var i = target_item["frames"][str(item.current_index)]
		if i.has("points"):
			load_all_points(i["points"])

func save_frame_points() -> void:
	var childs = object_panel.get_children()

	for child in childs:
		if child.get_filename() == Point.get_path():
			global.update_existing_point(
				item_list.get_item_text(selected_index),
				child.point_name,
				item.current_index,
				{
					"x": child.rect_position.x - item.rect_size.x/2,
					"y": child.rect_position.y - item.rect_size.y/2
				}
			)
