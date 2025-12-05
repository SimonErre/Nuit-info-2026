extends Panel

# Configuration du cadran rotatif frustrant
const DIAL_CENTER = Vector2(200, 200)
const DIAL_RADIUS = 180.0
const HOLE_RADIUS = 25.0
const FINGER_STOP_ANGLE = 30.0  # Angle de la butée
const ROTATION_SPEED_DECAY = 0.92
const MIN_ROTATION_FOR_DIGIT = 0.8  # Rotation minimale requise (en radians)

# Les chiffres sur le cadran (dans le sens horaire, comme les vrais téléphones)
const DIAL_DIGITS = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
const DIGIT_ANGLES = []  # Calculés dans _ready

# État du cadran
var current_rotation = 0.0  # Rotation actuelle du cadran
var target_rotation = 0.0   # Rotation cible (retour)
var is_dragging = false
var drag_start_angle = 0.0
var rotation_at_drag_start = 0.0
var selected_hole = -1  # Trou sélectionné (-1 = aucun)
var is_returning = false  # Le cadran revient à sa position
var rotation_during_drag = 0.0  # Rotation effectuée pendant ce drag

# Numéro de téléphone entré
var phone_digits = []
const PHONE_LENGTH = 10

# Effets de frustration
var shake_offset = Vector2.ZERO
var shake_timer = 0.0
var error_message = ""
var error_timer = 0.0
var click_positions = []  # Sons de clic pendant la rotation
var last_click_angle = 0.0

# Complications supplémentaires!
var gravity_enabled = false  # Le cadran "tombe" si on le lâche trop tôt
var wind_force = 0.0  # Vent qui pousse le cadran
var wind_timer = 0.0
var fatigue_level = 0.0  # Plus on tourne, plus c'est dur
var hand_cramp_timer = 0.0  # La "main" se fatigue
var is_cramped = false
var wrong_number_count = 0  # Nombre d'erreurs

# Couleurs
const COLOR_DIAL_BG = Color(0.15, 0.15, 0.15, 1.0)
const COLOR_DIAL_RING = Color(0.3, 0.3, 0.3, 1.0)
const COLOR_HOLE = Color(0.1, 0.1, 0.1, 1.0)
const COLOR_HOLE_HOVER = Color(0.2, 0.3, 0.4, 1.0)
const COLOR_HOLE_SELECTED = Color(0.3, 0.5, 0.7, 1.0)
const COLOR_DIGIT = Color(0.9, 0.9, 0.9, 1.0)
const COLOR_FINGER_STOP = Color(0.6, 0.2, 0.2, 1.0)
const COLOR_SUCCESS = Color(0.2, 0.8, 0.2, 1.0)

func _ready():
	$BackspaceButton.connect("pressed", self, "_on_backspace")
	$CloseButton.connect("pressed", self, "_on_close")
	
	# Activer les complications après quelques chiffres
	set_process(true)
	set_process_input(true)
	
	_update_phone_display()
	
	# Message d'accueil frustrant
	_show_hint("Astuce: Insérez votre doigt dans le trou du chiffre souhaité,\ntournez jusqu'à la butée rouge, puis relâchez.")

func _process(delta):
	# Shake effect
	if shake_timer > 0:
		shake_timer -= delta
		shake_offset = Vector2(rand_range(-3, 3), rand_range(-3, 3))
	else:
		shake_offset = Vector2.ZERO
	
	# Error message timer
	if error_timer > 0:
		error_timer -= delta
		if error_timer <= 0:
			error_message = ""
	
	# Retour du cadran à sa position initiale
	if is_returning and not is_dragging:
		var return_speed = 4.0
		# Le cadran revient avec un effet de ressort
		current_rotation = lerp(current_rotation, 0.0, delta * return_speed)
		
		# Clics pendant le retour
		var click_interval = 0.3  # Radians entre chaque clic
		if abs(current_rotation - last_click_angle) > click_interval:
			last_click_angle = current_rotation
			_play_click()
		
		if abs(current_rotation) < 0.05:
			current_rotation = 0.0
			is_returning = false
			last_click_angle = 0.0
	
	# Effets de vent (après 3 chiffres)
	if phone_digits.size() >= 3:
		wind_timer += delta
		wind_force = sin(wind_timer * 2.0) * 0.02 * (phone_digits.size() - 2)
		if is_dragging:
			current_rotation += wind_force
	
	# Crampe de la main (après 5 chiffres)
	if phone_digits.size() >= 5 and is_dragging:
		hand_cramp_timer += delta
		if hand_cramp_timer > 3.0 and not is_cramped:
			is_cramped = true
			_show_error("Votre main commence à fatiguer...")
			hand_cramp_timer = 0.0
	
	if is_cramped:
		hand_cramp_timer += delta
		if hand_cramp_timer > 1.5:
			is_cramped = false
			hand_cramp_timer = 0.0
	
	# Fatigue (le cadran devient plus lourd)
	if is_dragging:
		fatigue_level = min(fatigue_level + delta * 0.1, 0.5)
	else:
		fatigue_level = max(fatigue_level - delta * 0.2, 0.0)
	
	update()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.position)
			else:
				_end_drag()
	
	elif event is InputEventMouseMotion:
		if is_dragging and not is_cramped:
			_update_drag(event.position)
	
	if event.is_action_pressed("ui_cancel"):
		_on_close()

func _get_dial_area_position():
	return $DialArea.rect_global_position

func _get_local_mouse_pos(global_pos):
	return global_pos - _get_dial_area_position()

func _get_angle_from_center(pos):
	var local_pos = pos - DIAL_CENTER
	return atan2(local_pos.y, local_pos.x)

func _get_hole_positions():
	var positions = []
	var angle_step = TAU / 10.0
	var start_angle = -PI / 2.0 + 0.3  # Décalage pour commencer par 1
	
	for i in range(10):
		var angle = start_angle + i * angle_step
		var hole_distance = DIAL_RADIUS - 45.0
		var pos = DIAL_CENTER + Vector2(cos(angle), sin(angle)) * hole_distance
		positions.append({"pos": pos, "angle": angle, "digit": DIAL_DIGITS[i]})
	
	return positions

func _get_hole_at_position(pos):
	var holes = _get_hole_positions()
	for i in range(holes.size()):
		var hole = holes[i]
		# Appliquer la rotation actuelle
		var rotated_pos = _rotate_point(hole["pos"], DIAL_CENTER, current_rotation)
		if pos.distance_to(rotated_pos) < HOLE_RADIUS:
			return i
	return -1

func _rotate_point(point, center, angle):
	var offset = point - center
	var rotated = Vector2(
		offset.x * cos(angle) - offset.y * sin(angle),
		offset.x * sin(angle) + offset.y * cos(angle)
	)
	return center + rotated

func _start_drag(global_pos):
	var local_pos = _get_local_mouse_pos(global_pos)
	
	# Vérifier si on clique dans un trou
	var hole = _get_hole_at_position(local_pos)
	if hole != -1:
		selected_hole = hole
		is_dragging = true
		is_returning = false
		drag_start_angle = _get_angle_from_center(local_pos)
		rotation_at_drag_start = current_rotation
		rotation_during_drag = 0.0
		_play_click()

func _update_drag(global_pos):
	if not is_dragging:
		return
	
	var local_pos = _get_local_mouse_pos(global_pos)
	var current_angle = _get_angle_from_center(local_pos)
	
	# Calculer la différence d'angle (seulement sens horaire!)
	var angle_diff = current_angle - drag_start_angle
	
	# Normaliser l'angle
	while angle_diff > PI:
		angle_diff -= TAU
	while angle_diff < -PI:
		angle_diff += TAU
	
	# Seulement permettre la rotation dans le sens horaire (positif)
	if angle_diff > 0:
		# Appliquer la fatigue
		angle_diff *= (1.0 - fatigue_level)
		
		var new_rotation = rotation_at_drag_start + angle_diff
		
		# Limiter la rotation maximale basée sur le chiffre sélectionné
		var max_rotation = _get_max_rotation_for_digit(selected_hole)
		new_rotation = min(new_rotation, max_rotation)
		
		# Appliquer si on avance
		if new_rotation > current_rotation:
			# Clics pendant la rotation
			var click_interval = 0.2
			if abs(new_rotation - last_click_angle) > click_interval:
				last_click_angle = new_rotation
				_play_click()
			
			current_rotation = new_rotation
			rotation_during_drag = new_rotation - rotation_at_drag_start

func _get_max_rotation_for_digit(digit_index):
	# Plus le chiffre est élevé, plus il faut tourner loin
	# 1 = peu de rotation, 0 = beaucoup de rotation
	var digit_value = int(DIAL_DIGITS[digit_index])
	if digit_value == 0:
		digit_value = 10
	
	# La rotation nécessaire augmente avec le chiffre
	return (digit_value * 0.28) + 0.5

func _end_drag():
	if not is_dragging:
		return
	
	is_dragging = false
	
	# Vérifier si la rotation était suffisante
	var required_rotation = _get_max_rotation_for_digit(selected_hole) * 0.85
	
	if rotation_during_drag >= required_rotation:
		# Succès! Ajouter le chiffre
		_add_digit(DIAL_DIGITS[selected_hole])
		_show_hint("Chiffre " + DIAL_DIGITS[selected_hole] + " enregistré!")
	elif rotation_during_drag > 0.3:
		# Pas assez loin
		_show_error("Rotation insuffisante! Tournez jusqu'à la butée rouge.")
		_shake()
		wrong_number_count += 1
	
	# Le cadran revient
	is_returning = true
	selected_hole = -1
	rotation_during_drag = 0.0

func _add_digit(digit):
	if phone_digits.size() < PHONE_LENGTH:
		phone_digits.append(digit)
		_update_phone_display()
		
		# Vérifier si le numéro est complet
		if phone_digits.size() == PHONE_LENGTH:
			_check_phone_number()

func _update_phone_display():
	var display = "Numéro: "
	for i in range(PHONE_LENGTH):
		if i < phone_digits.size():
			display += phone_digits[i] + " "
		else:
			display += "_ "
	$PhoneDisplay.text = display
	
	# Mettre à jour le statut
	$StatusLabel.text = "Chiffres entrés: " + str(phone_digits.size()) + "/" + str(PHONE_LENGTH)
	
	# Ajouter des messages de frustration progressifs
	if phone_digits.size() == 3:
		$StatusLabel.text += " - Attention, le vent se lève..."
	elif phone_digits.size() == 5:
		$StatusLabel.text += " - Votre main fatigue..."
	elif phone_digits.size() == 7:
		$StatusLabel.text += " - Encore un peu de courage!"
	elif phone_digits.size() == 9:
		$StatusLabel.text += " - Dernier chiffre!"

func _check_phone_number():
	var number = ""
	for d in phone_digits:
		number += d
	
	# Vérifier le format (doit commencer par 06 ou 07)
	if number.begins_with("06") or number.begins_with("07"):
		_show_success()
	else:
		_show_error("Numéro invalide! Doit commencer par 06 ou 07.\nRecommencez...")
		_shake()
		phone_digits.clear()
		_update_phone_display()
		wrong_number_count += 3

func _show_success():
	$StatusLabel.text = "✓ NUMÉRO VÉRIFIÉ! Accès aux paramètres autorisé."
	$StatusLabel.add_color_override("font_color", COLOR_SUCCESS)
	_show_hint("Félicitations! Vous avez survécu à " + str(wrong_number_count) + " erreur(s).")
	
	# Désactiver le cadran
	set_process_input(false)
	
	# Afficher un message de victoire après un délai
	yield(get_tree().create_timer(2.0), "timeout")
	_on_close()

func _on_backspace():
	if phone_digits.size() > 0:
		phone_digits.pop_back()
		_update_phone_display()
		_show_hint("Chiffre effacé. Plus que " + str(PHONE_LENGTH - phone_digits.size()) + " à entrer...")

func _on_close():
	get_parent().queue_free()

func _shake():
	shake_timer = 0.3

func _show_error(msg):
	error_message = msg
	error_timer = 3.0
	$HintLabel.add_color_override("font_color", Color(1, 0.3, 0.3, 1))
	$HintLabel.text = msg

func _show_hint(msg):
	$HintLabel.add_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	$HintLabel.text = msg

func _play_click():
	# Simuler un son de clic (visuel seulement si pas de son)
	pass

func _draw():
	var dial_area_offset = $DialArea.rect_position + shake_offset
	
	# Fond du cadran
	draw_circle(dial_area_offset + DIAL_CENTER, DIAL_RADIUS + 10, COLOR_DIAL_RING)
	draw_circle(dial_area_offset + DIAL_CENTER, DIAL_RADIUS - 10, COLOR_DIAL_BG)
	
	# Centre du cadran
	draw_circle(dial_area_offset + DIAL_CENTER, 40, COLOR_DIAL_RING)
	draw_circle(dial_area_offset + DIAL_CENTER, 35, Color(0.05, 0.05, 0.05, 1))
	
	# Butée (finger stop)
	var stop_angle = -PI/2 - 0.3
	var stop_start = dial_area_offset + DIAL_CENTER + Vector2(cos(stop_angle), sin(stop_angle)) * (DIAL_RADIUS - 70)
	var stop_end = dial_area_offset + DIAL_CENTER + Vector2(cos(stop_angle), sin(stop_angle)) * (DIAL_RADIUS + 5)
	draw_line(stop_start, stop_end, COLOR_FINGER_STOP, 4.0)
	
	# Dessiner les trous et les chiffres
	var holes = _get_hole_positions()
	for i in range(holes.size()):
		var hole = holes[i]
		var base_pos = hole["pos"]
		
		# Appliquer la rotation du cadran
		var rotated_pos = _rotate_point(base_pos, DIAL_CENTER, current_rotation)
		var draw_pos = dial_area_offset + rotated_pos
		
		# Couleur du trou
		var hole_color = COLOR_HOLE
		if i == selected_hole:
			hole_color = COLOR_HOLE_SELECTED
		
		# Dessiner le trou
		draw_circle(draw_pos, HOLE_RADIUS, hole_color)
		draw_circle(draw_pos, HOLE_RADIUS - 3, Color(0.05, 0.05, 0.05, 1))
		
		# Dessiner le chiffre (au-dessus du trou, fixe)
		var label_offset = Vector2(-8, -HOLE_RADIUS - 20)
		var digit_pos = dial_area_offset + rotated_pos + label_offset
		
		# Dessiner le chiffre avec draw_string n'est pas disponible simplement,
		# donc on utilise une approche différente - dessiner un cercle coloré avec le numéro
		var num_bg_pos = dial_area_offset + _rotate_point(base_pos + Vector2(0, -HOLE_RADIUS - 15), DIAL_CENTER, current_rotation)
		draw_circle(num_bg_pos, 12, Color(0.2, 0.2, 0.2, 0.8))
	
	# Indicateur de vent
	if abs(wind_force) > 0.005:
		var wind_indicator_pos = dial_area_offset + Vector2(350, 50)
		var wind_arrow_end = wind_indicator_pos + Vector2(wind_force * 500, 0)
		draw_line(wind_indicator_pos, wind_arrow_end, Color(0.5, 0.7, 1.0, 0.7), 2.0)
		
	# Indicateur de fatigue
	if fatigue_level > 0.1:
		var fatigue_bar_pos = dial_area_offset + Vector2(20, 380)
		var fatigue_width = fatigue_level * 100
		draw_rect(Rect2(fatigue_bar_pos, Vector2(100, 10)), Color(0.3, 0.3, 0.3, 0.5))
		draw_rect(Rect2(fatigue_bar_pos, Vector2(fatigue_width, 10)), Color(1.0, 0.5, 0.2, 0.8))
	
	# Indicateur de crampe
	if is_cramped:
		draw_circle(dial_area_offset + DIAL_CENTER, DIAL_RADIUS + 20, Color(1, 0, 0, 0.2 + sin(OS.get_ticks_msec() * 0.01) * 0.1))
	
	# Afficher les chiffres autour du cadran (position fixe, pas de rotation)
	# On les dessine comme texte simple
	_draw_dial_numbers(dial_area_offset)

func _draw_dial_numbers(offset):
	# Les numéros sont affichés en position fixe autour du cadran
	var font = Control.new().get_font("font")
	var holes = _get_hole_positions()
	
	for i in range(holes.size()):
		var hole = holes[i]
		var base_pos = hole["pos"]
		var rotated_pos = _rotate_point(base_pos, DIAL_CENTER, current_rotation)
		
		# Position du numéro (légèrement au-dessus du trou rotatif)
		var num_pos = offset + rotated_pos + Vector2(-5, -HOLE_RADIUS - 8)
		
		# Dessiner un petit fond pour le numéro
		draw_circle(offset + rotated_pos + Vector2(0, -HOLE_RADIUS - 12), 10, Color(0.15, 0.15, 0.15, 0.9))
