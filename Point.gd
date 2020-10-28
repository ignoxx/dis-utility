extends Control

var point_name: String = "unnamed"

var dragging: bool = false
var offset: Vector2

func _ready() -> void:
	global.connect("on_color_change", self, "change_color")

func _process(delta: float) -> void:
	if(dragging):
		set_position(get_local_mouse_position()+rect_position-offset)

func _on_TextureRect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				dragging = true
				offset = event.position
				global.selected_point = self
			else:
				dragging = false

func change_color(color: Color):
	self.modulate = color.inverted()
