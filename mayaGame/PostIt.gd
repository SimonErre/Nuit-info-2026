extends ColorRect

var dragging = false
var drag_offset = Vector2()

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = get_local_mouse_position()
			else:
				dragging = false

func _process(_delta):
	if dragging:
		var parent = get_parent()
		var new_pos = parent.get_local_mouse_position() - drag_offset
		# Limiter au moniteur
		var min_pos = Vector2(-50, -50)
		var max_pos = parent.rect_size - rect_size + Vector2(50, 50)
		new_pos.x = clamp(new_pos.x, min_pos.x, max_pos.x)
		new_pos.y = clamp(new_pos.y, min_pos.y, max_pos.y)
		rect_position = new_pos

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			dragging = false
