# DustCleaningUI.gd - Mini-jeu de dépoussiérage de PC réaliste
extends CanvasLayer

signal cleaning_completed

var is_open = false
var just_opened = false

# Zones de poussière à nettoyer
var dust_zones = []
var cleaned_count = 0
var total_dust = 8  # Nombre de zones de poussière

# Position de la souris pour le "souffleur"
var is_cleaning = false
var mouse_pos = Vector2.ZERO

# Particules de poussière qui s'envolent
var flying_particles = []

func _ready():
	$Control.visible = false
	pause_mode = Node.PAUSE_MODE_PROCESS

func show_cleaning():
	is_open = true
	just_opened = true
	cleaned_count = 0
	$Control.visible = true
	$Control/PCCase/SuccessPanel.visible = false
	$Control/Cursor.visible = true
	_create_pc_interior()
	_create_dust_zones()
	_update_progress()
	get_tree().paused = true

func _create_pc_interior():
	# Dessiner les composants de base (non-poussière)
	var interior = $Control/PCCase/Interior
	
	# Nettoyer les anciens éléments
	for child in interior.get_children():
		if child.name != "MotherboardBG":
			child.queue_free()
	
	# Créer le fond de carte mère avec circuits
	_draw_motherboard(interior)
	
	# Ajouter les connexions/câbles
	_draw_cables(interior)

func _draw_motherboard(parent: Control):
	# Fond carte mère (vert PCB)
	var mb_bg = ColorRect.new()
	mb_bg.name = "MotherboardBG"
	mb_bg.rect_position = Vector2(0, 0)
	mb_bg.rect_size = Vector2(400, 360)
	mb_bg.color = Color(0.05, 0.18, 0.08, 1)  # Vert PCB foncé
	parent.add_child(mb_bg)
	mb_bg.show_behind_parent = true
	
	# Lignes de circuit (décoratives)
	var circuits = [
		# Lignes horizontales
		{"from": Vector2(20, 50), "to": Vector2(150, 50)},
		{"from": Vector2(200, 80), "to": Vector2(380, 80)},
		{"from": Vector2(30, 180), "to": Vector2(120, 180)},
		{"from": Vector2(250, 200), "to": Vector2(390, 200)},
		{"from": Vector2(50, 300), "to": Vector2(200, 300)},
		# Lignes verticales
		{"from": Vector2(100, 20), "to": Vector2(100, 100)},
		{"from": Vector2(300, 50), "to": Vector2(300, 150)},
		{"from": Vector2(350, 180), "to": Vector2(350, 280)},
	]
	
	for circuit in circuits:
		var line = Line2D.new()
		line.add_point(circuit.from)
		line.add_point(circuit.to)
		line.width = 1.5
		line.default_color = Color(0.15, 0.35, 0.15, 0.6)
		parent.add_child(line)

func _draw_cables(parent: Control):
	# Câbles d'alimentation (depuis PSU vers composants)
	var cables = [
		{"points": [Vector2(340, 130), Vector2(300, 130), Vector2(300, 90), Vector2(200, 90)], "color": Color(0.8, 0.2, 0.2, 0.7)},  # CPU Power
		{"points": [Vector2(340, 150), Vector2(280, 150), Vector2(280, 220), Vector2(180, 220)], "color": Color(0.8, 0.8, 0.2, 0.7)},  # GPU Power
		{"points": [Vector2(340, 170), Vector2(320, 170), Vector2(320, 290), Vector2(200, 290)], "color": Color(0.2, 0.2, 0.8, 0.7)},  # SATA
	]
	
	for cable_data in cables:
		var cable = Line2D.new()
		cable.name = "Cable"
		for point in cable_data.points:
			cable.add_point(point)
		cable.width = 4
		cable.default_color = cable_data.color
		cable.joint_mode = Line2D.LINE_JOINT_ROUND
		parent.add_child(cable)

func _create_dust_zones():
	# Supprimer les anciennes zones
	for zone in dust_zones:
		if is_instance_valid(zone):
			zone.queue_free()
	dust_zones.clear()
	
	# Composants réalistes avec positions et formes
	var components = [
		{
			"name": "Ventilateur CPU",
			"pos": Vector2(60, 40),
			"size": Vector2(100, 100),
			"icon": "🌀",
			"color": Color(0.3, 0.3, 0.35),
			"shape": "circle"
		},
		{
			"name": "Radiateur CPU",
			"pos": Vector2(55, 35),
			"size": Vector2(110, 110),
			"icon": "═══",
			"color": Color(0.5, 0.5, 0.55),
			"shape": "heatsink"
		},
		{
			"name": "RAM Slot 1",
			"pos": Vector2(185, 30),
			"size": Vector2(20, 90),
			"icon": "▮",
			"color": Color(0.2, 0.5, 0.2),
			"shape": "rect"
		},
		{
			"name": "RAM Slot 2",
			"pos": Vector2(210, 30),
			"size": Vector2(20, 90),
			"icon": "▮",
			"color": Color(0.2, 0.5, 0.2),
			"shape": "rect"
		},
		{
			"name": "Carte Graphique",
			"pos": Vector2(30, 170),
			"size": Vector2(200, 70),
			"icon": "🎮 GPU",
			"color": Color(0.25, 0.25, 0.3),
			"shape": "gpu"
		},
		{
			"name": "Alimentation",
			"pos": Vector2(300, 100),
			"size": Vector2(90, 120),
			"icon": "⚡ PSU",
			"color": Color(0.2, 0.2, 0.22),
			"shape": "psu"
		},
		{
			"name": "Disque SSD",
			"pos": Vector2(250, 270),
			"size": Vector2(80, 50),
			"icon": "💾 SSD",
			"color": Color(0.15, 0.15, 0.2),
			"shape": "rect"
		},
		{
			"name": "Ventilateur Arrière",
			"pos": Vector2(320, 250),
			"size": Vector2(70, 70),
			"icon": "🌀",
			"color": Color(0.25, 0.25, 0.3),
			"shape": "circle"
		}
	]
	
	for comp in components:
		var dust = _create_component_with_dust(comp)
		$Control/PCCase/Interior.add_child(dust)
		dust_zones.append(dust)
	
	total_dust = dust_zones.size()

func _create_component_with_dust(comp: Dictionary) -> Control:
	var container = Control.new()
	container.name = "Comp_" + comp.name.replace(" ", "_")
	container.rect_position = comp.pos
	container.rect_size = comp.size
	container.set_meta("component_name", comp.name)
	container.set_meta("dust_amount", 100.0)
	container.set_meta("is_cleaned", false)
	
	# Fond du composant
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.rect_size = comp.size
	bg.color = comp.color
	container.add_child(bg)
	
	# Bordure
	var border = ReferenceRect.new()
	border.rect_size = comp.size
	border.border_color = Color(0.4, 0.4, 0.45, 0.8)
	border.border_width = 2.0
	border.editor_only = false
	container.add_child(border)
	
	# Détails selon le type
	match comp.shape:
		"circle":
			_add_fan_details(container, comp.size)
		"heatsink":
			_add_heatsink_details(container, comp.size)
		"gpu":
			_add_gpu_details(container, comp.size)
		"psu":
			_add_psu_details(container, comp.size)
	
	# Icône/Label du composant (visible sous la poussière)
	var label = Label.new()
	label.name = "ComponentLabel"
	label.text = comp.icon
	label.rect_position = Vector2(5, comp.size.y / 2 - 10)
	label.rect_size = comp.size - Vector2(10, 0)
	label.align = Label.ALIGN_CENTER
	label.add_color_override("font_color", Color(0.7, 0.7, 0.7, 0.5))
	container.add_child(label)
	
	# Couche de poussière (par-dessus tout)
	var dust_layer = ColorRect.new()
	dust_layer.name = "DustLayer"
	dust_layer.rect_size = comp.size
	dust_layer.color = Color(0.45, 0.38, 0.32, 0.85)
	container.add_child(dust_layer)
	
	# Particules de poussière texturées
	var dust_texture = Label.new()
	dust_texture.name = "DustTexture"
	dust_texture.text = _generate_dust_pattern(comp.size)
	dust_texture.rect_position = Vector2(0, 0)
	dust_texture.rect_size = comp.size
	dust_texture.add_color_override("font_color", Color(0.55, 0.48, 0.42, 0.7))
	container.add_child(dust_texture)
	
	return container

func _add_fan_details(container: Control, size: Vector2):
	# Centre du ventilateur
	var center = ColorRect.new()
	center.rect_position = size / 2 - Vector2(15, 15)
	center.rect_size = Vector2(30, 30)
	center.color = Color(0.15, 0.15, 0.18)
	container.add_child(center)

func _add_heatsink_details(container: Control, size: Vector2):
	# Ailettes du radiateur
	for i in range(8):
		var fin = ColorRect.new()
		fin.rect_position = Vector2(10, 10 + i * 12)
		fin.rect_size = Vector2(size.x - 20, 8)
		fin.color = Color(0.6, 0.6, 0.65, 0.5)
		container.add_child(fin)

func _add_gpu_details(container: Control, size: Vector2):
	# Ventilateurs de la carte graphique
	for i in range(2):
		var fan_bg = ColorRect.new()
		fan_bg.rect_position = Vector2(30 + i * 70, 10)
		fan_bg.rect_size = Vector2(50, 50)
		fan_bg.color = Color(0.15, 0.15, 0.18)
		container.add_child(fan_bg)

func _add_psu_details(container: Control, size: Vector2):
	# Grille de ventilation
	for i in range(4):
		var vent = ColorRect.new()
		vent.rect_position = Vector2(10, 20 + i * 25)
		vent.rect_size = Vector2(size.x - 20, 3)
		vent.color = Color(0.1, 0.1, 0.12)
		container.add_child(vent)

func _generate_dust_pattern(size: Vector2) -> String:
	var pattern = ""
	var rows = int(size.y / 12)
	var cols = int(size.x / 8)
	var chars = ["·", "∘", "°", ".", ",", "'", "~"]
	
	for _y in range(rows):
		for _x in range(cols):
			pattern += chars[randi() % chars.size()]
		pattern += "\n"
	
	return pattern

func _process(_delta):
	if not is_open:
		return
	
	# Mettre à jour la position du curseur personnalisé
	mouse_pos = get_viewport().get_mouse_position()
	$Control/Cursor.rect_position = mouse_pos - Vector2(20, 20)
	
	# Effet visuel quand on nettoie
	if is_cleaning:
		$Control/Cursor/CleanEffect.visible = true
		$Control/Cursor/Icon.text = "💨"
	else:
		$Control/Cursor/CleanEffect.visible = false
		$Control/Cursor/Icon.text = "🧹"

func _input(event):
	if not is_open:
		return
	
	if just_opened:
		if event.is_action_released("interact"):
			just_opened = false
		return
	
	# Fermer avec Echap
	if event.is_action_pressed("ui_cancel"):
		close_cleaning()
		get_tree().set_input_as_handled()
		return
	
	# Clic pour nettoyer
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			is_cleaning = event.pressed
	
	# Mouvement de souris pendant le nettoyage
	if event is InputEventMouseMotion and is_cleaning:
		_clean_at_position(event.position)

func _clean_at_position(global_pos: Vector2):
	var interior = $Control/PCCase/Interior
	var local_pos = global_pos - interior.rect_global_position
	
	for dust in dust_zones:
		if not is_instance_valid(dust):
			continue
		if dust.get_meta("is_cleaned"):
			continue
		
		# Vérifier si on est sur cette zone
		var dust_rect = Rect2(dust.rect_position, dust.rect_size)
		if dust_rect.has_point(local_pos):
			_clean_dust(dust, local_pos - dust.rect_position)
			break

func _clean_dust(component: Control, local_pos: Vector2):
	var current_dust = component.get_meta("dust_amount")
	current_dust -= 5.0  # Réduire de 5% par passage
	
	# Créer effet de particule
	_spawn_dust_particle(component.rect_global_position + local_pos)
	
	if current_dust <= 0:
		current_dust = 0
		component.set_meta("is_cleaned", true)
		cleaned_count += 1
		_show_clean_effect(component)
		_update_progress()
		
		if cleaned_count >= total_dust:
			_on_cleaning_complete()
	else:
		component.set_meta("dust_amount", current_dust)
		# Réduire l'opacité de la poussière
		var dust_layer = component.get_node_or_null("DustLayer")
		if dust_layer:
			dust_layer.color.a = current_dust / 100.0 * 0.85
		
		var dust_texture = component.get_node_or_null("DustTexture")
		if dust_texture:
			dust_texture.modulate.a = current_dust / 100.0

func _spawn_dust_particle(pos: Vector2):
	# Créer une particule de poussière qui s'envole
	var particle = Label.new()
	particle.text = ["·", "∘", "°"][randi() % 3]
	particle.rect_position = pos
	particle.add_color_override("font_color", Color(0.6, 0.5, 0.4, 0.8))
	$Control.add_child(particle)
	
	# Animation
	var tween = Tween.new()
	$Control.add_child(tween)
	
	var end_pos = pos + Vector2(randf() * 40 - 20, -30 - randf() * 20)
	tween.interpolate_property(particle, "rect_position", pos, end_pos, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(particle, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR)
	tween.start()
	
	yield(tween, "tween_all_completed")
	particle.queue_free()
	tween.queue_free()

func _show_clean_effect(component: Control):
	# Cacher la poussière
	var dust_layer = component.get_node_or_null("DustLayer")
	if dust_layer:
		dust_layer.visible = false
	
	var dust_texture = component.get_node_or_null("DustTexture")
	if dust_texture:
		dust_texture.visible = false
	
	# Ajouter indicateur "propre"
	var clean_badge = Label.new()
	clean_badge.name = "CleanBadge"
	clean_badge.text = "✓"
	clean_badge.rect_position = component.rect_size - Vector2(20, 20)
	clean_badge.add_color_override("font_color", Color(0.3, 1.0, 0.3))
	component.add_child(clean_badge)
	
	# Mettre à jour le label
	var label = component.get_node_or_null("ComponentLabel")
	if label:
		label.add_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))

func _update_progress():
	var progress_label = $Control/PCCase/ProgressPanel/ProgressLabel
	var progress_bar = $Control/PCCase/ProgressPanel/Bar
	
	var percent = float(cleaned_count) / float(total_dust) * 100.0
	progress_label.text = "🧹 Nettoyage: %d/%d composants" % [cleaned_count, total_dust]
	progress_bar.value = percent

func _on_cleaning_complete():
	$Control/PCCase/SuccessPanel.visible = true
	$Control/Cursor.visible = false
	
	if GameData.recondition_quest_active:
		GameData.complete_recondition_step("step_repair")

func _on_FinishButton_pressed():
	emit_signal("cleaning_completed")
	close_cleaning()

func close_cleaning():
	is_open = false
	is_cleaning = false
	$Control.visible = false
	$Control/Cursor.visible = false
	get_tree().paused = false
