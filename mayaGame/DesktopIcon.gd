extends Control

# Pour le drag and drop
var dragging = false
var drag_offset = Vector2()

signal file_opened

func _ready():
	# S'assurer que les enfants ne bloquent pas les clics
	mouse_filter = Control.MOUSE_FILTER_STOP
	for child in get_children():
		set_mouse_filter_recursive(child)

func set_mouse_filter_recursive(node):
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_PASS
		for child in node.get_children():
			set_mouse_filter_recursive(child)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				# Double clic pour ouvrir
				if event.doubleclick:
					emit_signal("file_opened")
				else:
					# Commencer le drag
					dragging = true
					drag_offset = get_local_mouse_position()
			else:
				dragging = false

func _process(_delta):
	if dragging:
		# Déplacer l'icône en suivant la souris
		var parent = get_parent()
		var new_pos = parent.get_local_mouse_position() - drag_offset
		# Limiter au bureau (écran)
		var min_pos = Vector2(0, 0)
		var max_pos = parent.rect_size - rect_size
		new_pos.x = clamp(new_pos.x, min_pos.x, max_pos.x)
		new_pos.y = clamp(new_pos.y, min_pos.y, max_pos.y)
		rect_position = new_pos

func _input(event):
	# Détecter le relâchement de la souris même en dehors du contrôle
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			dragging = false
