extends Control

onready var item_list = $MarginContainer/HBoxContainer/HistoryPanel/TabContainer/Items/VBoxContainer/ItemList
onready var item_name_text_box = $WindowDialog/HBoxContainer/TxtItemName
onready var item = $MarginContainer/HBoxContainer/ObjectPanel/Item
onready var btn_load_selected = $MarginContainer/HBoxContainer/HistoryPanel/TabContainer/Items/VBoxContainer/HBoxContainer/BtnLoadSelected
onready var lbl_frame = $MarginContainer/HBoxContainer/ToolPanel/TabContainer2/Inspector/VBoxContainer/HBoxContainer2/LblFrameNum


var selected_index: int

func _ready() -> void:
	load_items()

func load_items() -> void:
	item_list.clear()
	for item in global.item_data:
		item_list.add_item(item["name"])

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
	if not selected_index:
		return

	var target_item = global.get_item_by_name(
		item_list.get_item_text(selected_index)
	)

	if target_item:
		item.current_item = target_item
		item.current_index = 0
		item.update_frame()
		update_frame_label()


func _on_BtnPrevFrame_pressed() -> void:
	item.current_index += 1
	update_frame_label()


func _on_BtnNextFrame_pressed() -> void:
	item.current_index -= 1
	update_frame_label()

func update_frame_label():
	lbl_frame.text = "%s / %s" % [item.current_index, item.get_max_index()]
