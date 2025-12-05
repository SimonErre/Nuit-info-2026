extends Panel

var dragging = false
var drag_offset = Vector2()
var is_editing = false

func _ready():
	$TitleBar/CloseButton.connect("pressed", self, "_on_close")
	$TitleBar.connect("gui_input", self, "_on_TitleBar_gui_input")
	$MenuBar/EditButton.connect("pressed", self, "_on_edit_pressed")
	$Content/TextEdit.visible = false
	$Content/TextEdit.connect("focus_exited", self, "_on_edit_finished")

func _on_close():
	visible = false
	is_editing = false
	$Content/TextContent.visible = true
	$Content/TextEdit.visible = false

func _on_edit_pressed():
	if not is_editing:
		# Passer en mode édition
		is_editing = true
		$Content/TextEdit.text = $Content/TextContent.text
		$Content/TextContent.visible = false
		$Content/TextEdit.visible = true
		$Content/TextEdit.grab_focus()
	else:
		# Sauvegarder et quitter le mode édition
		_on_edit_finished()

func _on_edit_finished():
	if is_editing:
		is_editing = false
		$Content/TextContent.text = $Content/TextEdit.text
		$Content/TextContent.visible = true
		$Content/TextEdit.visible = false

func _on_TitleBar_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = $TitleBar.get_local_mouse_position()
			else:
				dragging = false

func _process(_delta):
	if dragging and visible:
		var screen = get_parent()
		var new_pos = screen.get_local_mouse_position() - drag_offset
		var min_pos = Vector2(0, 0)
		var max_pos = screen.rect_size - rect_size
		new_pos.x = clamp(new_pos.x, min_pos.x, max_pos.x)
		new_pos.y = clamp(new_pos.y, min_pos.y, max_pos.y)
		rect_position = new_pos

func _input(event):
	# Détecter le relâchement de la souris même en dehors de la fenêtre
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			dragging = false

func show_notepad(content):
	visible = true
	is_editing = false
	$Content/TextContent.text = content
	$Content/TextContent.visible = true
	$Content/TextEdit.visible = false
