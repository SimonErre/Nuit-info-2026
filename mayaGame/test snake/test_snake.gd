extends Node2D

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                    🐍 LINUX TERMINAL SNAKE 🐍                             ║
# ║         Un easter egg secret activé uniquement sur Linux                  ║
# ║              Thème: Hacker Terminal / Matrix Style                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# === CONFIGURATION DU JEU ===
var CELL_SIZE = 20
var GRID_WIDTH = 30
var GRID_HEIGHT = 20
const INITIAL_SPEED = 0.15
const SPEED_INCREASE = 0.005
const MIN_SPEED = 0.05

# === PLEIN ÉCRAN ===
var screen_size = Vector2.ZERO
var game_offset = Vector2.ZERO
var return_to_menu_timer = 0.0
const RETURN_DELAY = 3.0

# === ÉTATS DU SYSTÈME ===
enum State {
	LOGIN,           # Écran de mot de passe
	OS_CHOICE,       # Choix Linux/Windows
	WINDOWS_VIRUS,   # Attaque virus Windows
	SNAKE_GAME,      # Jeu Snake (Linux)
	GAME_OVER        # Fin de partie
}
var current_state = State.LOGIN

# === LOGIN ===
var password_input = ""
var password_cursor_visible = true
var password_cursor_timer = 0.0
var login_error = false
var login_error_timer = 0.0
const CORRECT_PASSWORD = "snake"

# === CHOIX OS ===
var selected_os = 0  # 0 = Linux, 1 = Windows
var os_choice_anim = 0.0

# === VIRUS WINDOWS ===
var virus_popups = []
var virus_timer = 0.0
var virus_spawn_rate = 0.3
var shutdown_progress = 0.0
var shutdown_started = false
var glitch_intensity = 0.0
const VIRUS_MESSAGES = [
	"VIRUS DETECTED!",
	"YOUR PC IS INFECTED",
	"TROJAN.MALWARE.EXE",
	"RANSOMWARE ALERT",
	"HACKED BY ANONYMOUS",
	"SYSTEM32 DELETED",
	"BITCOIN MINING...",
	"STEALING DATA...",
	"FORMATTING C:\\",
	"ERROR 0x0000DEAD",
	"BLUE SCREEN INCOMING",
	"RIP WINDOWS",
	"KERNEL PANIC",
	"MEMORY CORRUPTED",
	"FBI OPEN UP!",
	"CALL 1-800-SCAM",
	"SEND $500 IN BTC",
	"WEBCAM ACTIVATED",
	"PASSWORDS LEAKED",
	"NICE TRY WINDOWS USER"
]

# === COULEURS ===
const COLOR_BACKGROUND = Color(0.05, 0.05, 0.08, 1.0)
const COLOR_DESKTOP = Color(0.0, 0.3, 0.5, 1.0)
const COLOR_POPUP_BG = Color(0.15, 0.15, 0.2, 0.95)
const COLOR_POPUP_BORDER = Color(0.3, 0.3, 0.4, 1.0)
const COLOR_POPUP_TITLE = Color(0.2, 0.2, 0.3, 1.0)
const COLOR_SNAKE_HEAD = Color(0.0, 1.0, 0.4, 1.0)
const COLOR_SNAKE_BODY = Color(0.0, 0.8, 0.3, 1.0)
const COLOR_SNAKE_TAIL = Color(0.0, 0.5, 0.2, 1.0)
const COLOR_FOOD = Color(1.0, 0.2, 0.3, 1.0)
const COLOR_BONUS = Color(1.0, 0.8, 0.0, 1.0)
const COLOR_GRID = Color(0.1, 0.2, 0.1, 0.3)
const COLOR_TEXT = Color(0.0, 1.0, 0.4, 1.0)
const COLOR_GLOW = Color(0.0, 1.0, 0.4, 0.3)
const COLOR_WHITE = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_RED = Color(1.0, 0.2, 0.2, 1.0)
const COLOR_LINUX = Color(0.9, 0.6, 0.1, 1.0)
const COLOR_WINDOWS = Color(0.0, 0.5, 1.0, 1.0)

# === MESSAGES HACKER ===
const HACKER_MESSAGES = [
	"[ACCESS GRANTED]",
	"[FIREWALL BYPASSED]",
	"[DECRYPTING...]",
	"[ROOT ACCESS]",
	"[SUDO SNAKE]",
	"[chmod +x snake]",
	"[./run_snake.sh]",
	"[KERNEL PANIC... jk]",
	"[rm -rf /boredom]",
	"[apt-get install fun]"
]

const DEATH_MESSAGES = [
	"[SEGMENTATION FAULT]",
	"[CORE DUMPED]",
	"[STACK OVERFLOW]",
	"[BUFFER OVERFLOW]",
	"[NULL POINTER]",
	"[KERNEL PANIC]",
	"[FATAL ERROR]",
	"[SYSTEM CRASH]"
]

# === SYSTÈME DE FORMES (CHALLENGE) ===
# Liste des formes à reproduire avec la traînée
const SHAPE_DEFINITIONS = [
	# Rectangle horizontal 2x4
	{"name": "Rectangle 2x4", "width": 4, "height": 2, "trail_needed": 8, "pattern": [
		Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(3, 0),
		Vector2(0, 1), Vector2(1, 1), Vector2(2, 1), Vector2(3, 1)
	]},
	# Carré 2x2
	{"name": "Carré 2x2", "width": 2, "height": 2, "trail_needed": 4, "pattern": [
		Vector2(0, 0), Vector2(1, 0),
		Vector2(0, 1), Vector2(1, 1)
	]},
	# Lettre L
	{"name": "Lettre L", "width": 2, "height": 3, "trail_needed": 4, "pattern": [
		Vector2(0, 0),
		Vector2(0, 1),
		Vector2(0, 2), Vector2(1, 2)
	]},
	# Grand L 2x5
	{"name": "Ligne 2x4", "width": 4, "height": 3, "trail_needed": 6, "pattern": [
		Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(3, 0), 
		Vector2(0, 1),
		Vector2(0, 2),
	]},
	# Rectangle vertical 4x2
	{"name": "Rectangle 4x2", "width": 2, "height": 4, "trail_needed": 8, "pattern": [
		Vector2(0, 0), Vector2(1, 0),
		Vector2(0, 1), Vector2(1, 1),
		Vector2(0, 2), Vector2(1, 2),
		Vector2(0, 3), Vector2(1, 3)
	]}
]

var current_shape = null  # Forme actuelle à reproduire
var shape_validated = false  # Si la forme a été validée
var shapes_completed = 0  # Nombre de formes complétées
var show_hint = false  # Afficher les indices (après 3 pommes)
var apples_eaten = 0  # Compteur de pommes mangées
var hint_flash_timer = 0.0  # Timer pour le flash de victoire de forme
var shape_match_progress = 0.0  # Progression de correspondance (0-1)
var shape_victory_popup = false  # Afficher le popup de victoire
var shape_victory_timer = 0.0  # Timer pour le popup de victoire
const SHAPE_VICTORY_DURATION = 3.0  # Durée du popup de victoire
var game_won = false  # Le joueur a gagné le jeu!
var victory_celebration_timer = 0.0  # Timer pour la célébration
const VICTORY_CELEBRATION_DURATION = 8.0  # Durée de la célébration finale
var firework_timer = 0.0  # Timer pour les feux d'artifice

# === VARIABLES DU JEU SNAKE ===
var snake_body = []
var snake_trail = []  # Traînée du serpent
var TRAIL_LENGTH = 15  # La traînée reste N déplacements (variable maintenant)
var direction = Vector2.RIGHT
var next_direction = Vector2.RIGHT
var food_position = Vector2.ZERO
var bonus_position = Vector2.ZERO
var bonus_active = false
var bonus_timer = 0.0
var score = 0
var high_score = 0
var game_speed = INITIAL_SPEED
var move_timer = 0.0
var game_active = false
var game_over = false
var game_paused = false

# === MAPPING DES DIRECTIONS (change à chaque niveau) ===
var direction_mapping = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT
}
var direction_names = ["up", "down", "left", "right"]  # Pour l'affichage

# === EFFETS VISUELS ===
var particles = []
var matrix_rain = []
var glow_intensity = 0.0
var screen_shake = Vector2.ZERO
var flash_alpha = 0.0
var startup_animation = 0.0
var startup_complete = false

# === NŒUDS ===
var font: Font

func _ready():
	randomize()
	_setup_fullscreen()
	_init_matrix_rain()
	_create_font()
	current_state = State.LOGIN
	
	# S'assurer que cette scène est au-dessus de tout
	z_index = 100

func _setup_fullscreen():
	# Utiliser la taille de la fenêtre/viewport au lieu du plein écran
	yield(get_tree(), "idle_frame")
	
	# Obtenir la taille de la fenêtre
	screen_size = get_viewport().get_visible_rect().size
	if screen_size == Vector2.ZERO:
		screen_size = OS.window_size
	if screen_size == Vector2.ZERO:
		screen_size = Vector2(1920, 1080)
	
	var margin = 100
	var available_width = screen_size.x - margin * 2
	var available_height = screen_size.y - margin * 2
	
	CELL_SIZE = int(min(available_width / 40, available_height / 25))
	CELL_SIZE = max(CELL_SIZE, 15)
	
	GRID_WIDTH = int(available_width / CELL_SIZE)
	GRID_HEIGHT = int(available_height / CELL_SIZE)
	
	game_offset = Vector2(
		(screen_size.x - GRID_WIDTH * CELL_SIZE) / 2,
		(screen_size.y - GRID_HEIGHT * CELL_SIZE) / 2
	)
	
	# Positionner le node à l'origine
	position = Vector2.ZERO
	
	matrix_rain.clear()
	_init_matrix_rain()

func _create_font():
	font = Control.new().get_font("font")

func _init_matrix_rain():
	for i in range(GRID_WIDTH):
		matrix_rain.append({
			"y": randf() * GRID_HEIGHT,
			"speed": 0.5 + randf() * 1.5,
			"chars": _generate_matrix_column()
		})

func _generate_matrix_column():
	var chars = []
	var length = 5 + randi() % 10
	for i in range(length):
		chars.append(_random_matrix_char())
	return chars

func _random_matrix_char():
	var charset = "01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
	return charset[randi() % charset.length()]

func _input(event):
	match current_state:
		State.LOGIN:
			_handle_login_input(event)
		State.OS_CHOICE:
			_handle_os_choice_input(event)
		State.WINDOWS_VIRUS:
			_handle_virus_input(event)
		State.SNAKE_GAME, State.GAME_OVER:
			_handle_snake_input(event)

func _handle_login_input(event):
	if event is InputEventKey and event.pressed:
		var scancode = event.scancode
		
		# Entrée = valider
		if scancode == KEY_ENTER or scancode == KEY_KP_ENTER:
			if password_input.to_lower() == CORRECT_PASSWORD:
				current_state = State.OS_CHOICE
				os_choice_anim = 0.0
				flash_alpha = 0.5
			else:
				login_error = true
				login_error_timer = 2.0
				password_input = ""
			return
		
		# Backspace = effacer
		if scancode == KEY_BACKSPACE:
			if password_input.length() > 0:
				password_input = password_input.substr(0, password_input.length() - 1)
			return
		
		# Escape = fermer le jeu Snake
		if scancode == KEY_ESCAPE:
			_close_snake_game()
			return
		
		# Lettres et chiffres
		var char_typed = ""
		if scancode >= KEY_A and scancode <= KEY_Z:
			char_typed = char(scancode).to_lower()
			if event.shift:
				char_typed = char_typed.to_upper()
		elif scancode >= KEY_0 and scancode <= KEY_9:
			char_typed = char(scancode)
		
		if char_typed != "" and password_input.length() < 20:
			password_input += char_typed

func _handle_os_choice_input(event):
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_LEFT, KEY_A:
				selected_os = 0  # Linux
			KEY_RIGHT, KEY_D:
				selected_os = 1  # Windows
			KEY_ENTER, KEY_KP_ENTER:
				if selected_os == 0:
					# Linux sélectionné -> Snake
					_start_snake_game()
				else:
					# Windows sélectionné -> Virus!
					_start_virus_attack()
			KEY_ESCAPE:
				_close_snake_game()

func _handle_virus_input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ESCAPE:
			# Permet de forcer la fermeture pendant le virus
			if shutdown_progress > 0.8:
				_close_snake_game()

func _handle_snake_input(event):
	if event is InputEventKey and event.pressed:
		var key = ""
		match event.scancode:
			KEY_UP, KEY_W: key = "up"
			KEY_DOWN, KEY_S: key = "down"
			KEY_LEFT, KEY_A: key = "left"
			KEY_RIGHT, KEY_D: key = "right"
			KEY_P: key = "p"
			KEY_ESCAPE: key = "escape"
		
		if current_state == State.SNAKE_GAME:
			if game_active and not game_over and not game_paused:
				# Utiliser le mapping des directions
				if key in direction_mapping:
					var mapped_dir = direction_mapping[key]
					# Vérifier qu'on ne va pas dans la direction opposée
					if mapped_dir != -direction:
						next_direction = mapped_dir
			
			if key == "p" and game_active and not game_over:
				game_paused = not game_paused
			
			if key == "escape":
				_close_snake_game()

func _start_snake_game():
	current_state = State.SNAKE_GAME
	game_active = true
	game_over = false
	game_paused = false
	score = 0
	game_speed = INITIAL_SPEED
	direction = Vector2.RIGHT
	next_direction = Vector2.RIGHT
	startup_animation = 0.0
	startup_complete = false
	
	# Réinitialiser le mapping des directions (classique au début)
	_reset_direction_mapping()
	
	snake_body.clear()
	snake_trail.clear()  # Réinitialiser la traînée
	var start_pos = Vector2(GRID_WIDTH / 2, GRID_HEIGHT / 2)
	for i in range(4):
		snake_body.append(start_pos - Vector2(i, 0))
	
	_spawn_food()
	bonus_active = false
	flash_alpha = 1.0
	
	# Initialiser le système de formes
	apples_eaten = 0
	show_hint = false
	shape_validated = false
	hint_flash_timer = 0.0
	_select_random_shape()

func _select_random_shape():
	# Niveau 4 = forme complexe aléatoire finale!
	if shapes_completed >= 3:
		current_shape = _generate_complex_random_shape()
		print("[FINAL CHALLENGE] Forme complexe générée: ", current_shape["name"])
	else:
		# Sélectionner une forme aléatoire normale
		var shape_index = randi() % SHAPE_DEFINITIONS.size()
		current_shape = SHAPE_DEFINITIONS[shape_index].duplicate()
		print("[SHAPE CHALLENGE] Nouvelle forme: ", current_shape["name"])
	
	TRAIL_LENGTH = current_shape["trail_needed"]
	shape_match_progress = 0.0

func _generate_complex_random_shape():
	# Générer une forme complexe aléatoire pour le niveau 4
	var shape_types = [
		"SERPENT",
		"LABYRINTHE", 
		"SPIRALE",
		"ESCALIER",
		"ZIGZAG"
	]
	var shape_type = shape_types[randi() % shape_types.size()]
	var pattern = []
	
	match shape_type:
		"SERPENT":
			# Forme de serpent ondulé
			pattern = [
				Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(3, 0),
															Vector2(3, 1),
				Vector2(0, 2), Vector2(1, 2), Vector2(2, 2), Vector2(3, 2),
				Vector2(0, 3),
				Vector2(0, 4), Vector2(1, 4), Vector2(2, 4), Vector2(3, 4)
			]
		"ESCALIER":
			# Forme d'escalier
			pattern = [
				Vector2(0, 0), Vector2(1, 0),
							   Vector2(1, 1), Vector2(2, 1),
											  Vector2(2, 2), Vector2(3, 2),
															 Vector2(3, 3), Vector2(4, 3),
																			Vector2(4, 4), Vector2(5, 4)
			]
		"ZIGZAG":
			# Forme en zigzag
			pattern = [
				Vector2(0, 0),
				Vector2(0, 1), Vector2(1, 1),
							   Vector2(1, 2), Vector2(2, 2),
											  Vector2(2, 3), Vector2(3, 3),
															 Vector2(3, 4),
															 Vector2(3, 5), Vector2(4, 5)
			]
	
	# Calculer les dimensions
	var max_x = 0
	var max_y = 0
	for pos in pattern:
		if pos.x > max_x:
			max_x = pos.x
		if pos.y > max_y:
			max_y = pos.y
	
	return {
		"name": "★ " + shape_type + " FINAL ★",
		"width": int(max_x) + 1,
		"height": int(max_y) + 1,
		"trail_needed": pattern.size(),
		"pattern": pattern,
		"is_final": true
	}

func _start_virus_attack():
	current_state = State.WINDOWS_VIRUS
	virus_popups.clear()
	virus_timer = 0.0
	shutdown_progress = 0.0
	shutdown_started = false
	glitch_intensity = 0.0
	
	# Spawn quelques popups initiaux
	for i in range(3):
		_spawn_virus_popup()

func _spawn_virus_popup():
	var popup_width = 200 + randi() % 150
	var popup_height = 100 + randi() % 80
	var popup = {
		"x": randf() * (screen_size.x - popup_width),
		"y": randf() * (screen_size.y - popup_height),
		"width": popup_width,
		"height": popup_height,
		"message": VIRUS_MESSAGES[randi() % VIRUS_MESSAGES.size()],
		"color": Color(randf() * 0.5 + 0.5, randf() * 0.3, randf() * 0.3, 1.0),
		"shake": Vector2.ZERO,
		"life": 10.0 + randf() * 5.0,
		"velocity": Vector2(randf() * 100 - 50, randf() * 100 - 50)
	}
	virus_popups.append(popup)

func _reset_to_login():
	current_state = State.LOGIN
	password_input = ""
	login_error = false
	game_active = false
	game_over = false
	snake_body.clear()
	particles.clear()
	virus_popups.clear()

func _close_snake_game():
	# Fermer proprement la scène Snake et retourner au jeu principal
	# Remonter au parent (CanvasLayer) puis supprimer
	var parent = get_parent()
	if parent:
		parent.queue_free()
	else:
		queue_free()

func _process(delta):
	# Animation de la pluie Matrix (toujours active)
	_update_matrix_rain(delta)
	
	# Effets visuels généraux
	_update_particles(delta)
	glow_intensity = 0.5 + sin(OS.get_ticks_msec() / 200.0) * 0.3
	
	if flash_alpha > 0:
		flash_alpha -= delta * 2
	
	screen_shake = screen_shake.move_toward(Vector2.ZERO, delta * 50)
	
	if login_error_timer > 0:
		login_error_timer -= delta
		if login_error_timer <= 0:
			login_error = false
	
	# Curseur clignotant
	password_cursor_timer += delta
	if password_cursor_timer >= 0.5:
		password_cursor_timer = 0.0
		password_cursor_visible = not password_cursor_visible
	
	# Animation choix OS
	if current_state == State.OS_CHOICE:
		os_choice_anim += delta
	
	# Logique selon l'état
	match current_state:
		State.WINDOWS_VIRUS:
			_update_virus(delta)
		State.SNAKE_GAME:
			_update_snake_game(delta)
		State.GAME_OVER:
			if return_to_menu_timer > 0:
				return_to_menu_timer -= delta
				if return_to_menu_timer <= 0:
					_reset_to_login()
	
	update()

func _update_virus(delta):
	virus_timer += delta
	glitch_intensity = min(glitch_intensity + delta * 0.1, 1.0)
	
	# Spawn de nouveaux popups
	if virus_timer >= virus_spawn_rate:
		virus_timer = 0.0
		virus_spawn_rate = max(0.05, virus_spawn_rate - 0.02)
		_spawn_virus_popup()
		_spawn_virus_popup()
	
	# Mise à jour des popups
	for popup in virus_popups:
		popup["x"] += popup["velocity"].x * delta
		popup["y"] += popup["velocity"].y * delta
		popup["shake"] = Vector2(randf() * 4 - 2, randf() * 4 - 2) * glitch_intensity
		
		# Rebondir sur les bords
		if popup["x"] < 0 or popup["x"] + popup["width"] > screen_size.x:
			popup["velocity"].x *= -1
		if popup["y"] < 0 or popup["y"] + popup["height"] > screen_size.y:
			popup["velocity"].y *= -1
	
	# Après un moment, commencer le shutdown
	if virus_popups.size() > 15 and not shutdown_started:
		shutdown_started = true
	
	if shutdown_started:
		shutdown_progress += delta * 0.15
		if shutdown_progress >= 1.0:
			# Retour au login
			_reset_to_login()

func _update_snake_game(delta):
	if game_active and not startup_complete:
		startup_animation += delta * 2
		if startup_animation >= 1.0:
			startup_complete = true
	
	if bonus_active:
		bonus_timer -= delta
		if bonus_timer <= 0:
			bonus_active = false
	
	# Timer pour le flash de victoire de forme
	if hint_flash_timer > 0:
		hint_flash_timer -= delta
	
	# Timer pour le popup de victoire de forme
	if shape_victory_popup:
		shape_victory_timer -= delta
		if shape_victory_timer <= 0:
			shape_victory_popup = false
			_restart_with_new_shape()
	
	# Célébration de victoire finale
	if game_won:
		victory_celebration_timer -= delta
		firework_timer += delta
		
		# Spawner des feux d'artifice régulièrement
		if fmod(firework_timer, 0.15) < delta:
			var random_pos = Vector2(randi() % GRID_WIDTH, randi() % GRID_HEIGHT)
			_spawn_firework_at(random_pos)
			screen_shake = Vector2(randf() * 3, randf() * 3)
		
		if victory_celebration_timer <= 0:
			# Retour au menu après la célébration
			_reset_to_login()
			game_won = false
	
	if game_active and not game_over and not game_paused and startup_complete:
		move_timer += delta
		if move_timer >= game_speed:
			move_timer = 0
			_move_snake()

func _update_matrix_rain(delta):
	for column in matrix_rain:
		column["y"] += column["speed"] * delta * 10
		if column["y"] > GRID_HEIGHT + 10:
			column["y"] = -5
			column["chars"] = _generate_matrix_column()

func _update_particles(delta):
	var i = particles.size() - 1
	while i >= 0:
		var p = particles[i]
		p["pos"] += p["vel"] * delta
		p["vel"] *= 0.95
		p["life"] -= delta
		if p["life"] <= 0:
			particles.remove(i)
		i -= 1

func _move_snake():
	direction = next_direction
	var new_head = snake_body[0] + direction
	
	new_head.x = fmod(new_head.x + GRID_WIDTH, GRID_WIDTH)
	new_head.y = fmod(new_head.y + GRID_HEIGHT, GRID_HEIGHT)
	
	for i in range(1, snake_body.size()):
		if new_head == snake_body[i]:
			_snake_game_over()
			return
	
	# Ajouter la position actuelle de la queue à la traînée
	var tail_pos = snake_body[snake_body.size() - 1]
	snake_trail.insert(0, {"pos": tail_pos, "age": 0})
	
	# Vieillir et nettoyer la traînée
	var i = snake_trail.size() - 1
	while i >= 0:
		snake_trail[i]["age"] += 1
		if snake_trail[i]["age"] > TRAIL_LENGTH:
			snake_trail.remove(i)
		i -= 1
	
	snake_body.insert(0, new_head)
	
	if new_head == food_position:
		_eat_food()
	elif bonus_active and new_head == bonus_position:
		_eat_bonus()
	else:
		snake_body.pop_back()
	
	# Vérifier la forme après chaque mouvement
	_check_shape_match()

func _check_shape_match():
	# Ne vérifier la forme qu'à partir de 3 pommes mangées
	if apples_eaten < 3:
		return
	
	# Vérifier si la traînée correspond à la forme cible
	if current_shape == null:
		return
	
	if snake_trail.size() < current_shape["trail_needed"]:
		shape_match_progress = float(snake_trail.size()) / float(current_shape["trail_needed"])
		return
	
	# Extraire les positions de la traînée (les N plus récentes)
	var trail_positions = []
	for idx in range(min(snake_trail.size(), current_shape["trail_needed"])):
		trail_positions.append(snake_trail[idx]["pos"])
	
	# Normaliser les positions (trouver le coin min)
	var min_x = 999999
	var min_y = 999999
	for pos in trail_positions:
		if pos.x < min_x:
			min_x = pos.x
		if pos.y < min_y:
			min_y = pos.y
	
	# Normaliser les positions de la traînée
	var normalized_trail = []
	for pos in trail_positions:
		normalized_trail.append(Vector2(pos.x - min_x, pos.y - min_y))
	
	# Comparer avec le pattern de la forme (essayer les 4 rotations et les symétries)
	var pattern = current_shape["pattern"]
	var rotations = [pattern]
	
	# Générer les 4 rotations
	for r in range(3):
		var last_rotation = rotations[rotations.size() - 1]
		var rotated = _rotate_pattern_90(last_rotation)
		rotations.append(rotated)
	
	# Ajouter les symétries horizontales
	var num_rotations = rotations.size()
	for r in range(num_rotations):
		var mirrored = _mirror_pattern(rotations[r])
		rotations.append(mirrored)
	
	# Vérifier chaque variante
	for variant in rotations:
		# Normaliser le pattern
		var norm_pattern = _normalize_pattern(variant)
		
		# Vérifier si les positions correspondent
		if _patterns_match(normalized_trail, norm_pattern):
			_shape_completed()
			return
	
	# Calculer la progression (combien de positions correspondent)
	var best_match = 0
	for variant in rotations:
		var norm_pattern = _normalize_pattern(variant)
		var matches = 0
		for pos in normalized_trail:
			for ppos in norm_pattern:
				if pos == ppos:
					matches += 1
					break
		if matches > best_match:
			best_match = matches
	shape_match_progress = float(best_match) / float(current_shape["pattern"].size())

func _rotate_pattern_90(pattern):
	# Rotation 90° horaire: (x, y) -> (y, -x)
	var rotated = []
	for pos in pattern:
		rotated.append(Vector2(pos.y, -pos.x))
	return rotated

func _mirror_pattern(pattern):
	# Miroir horizontal: (x, y) -> (-x, y)
	var mirrored = []
	for pos in pattern:
		mirrored.append(Vector2(-pos.x, pos.y))
	return mirrored

func _normalize_pattern(pattern):
	# Trouver le coin min
	var min_x = 999999
	var min_y = 999999
	for pos in pattern:
		if pos.x < min_x:
			min_x = pos.x
		if pos.y < min_y:
			min_y = pos.y
	
	# Normaliser
	var normalized = []
	for pos in pattern:
		normalized.append(Vector2(pos.x - min_x, pos.y - min_y))
	return normalized

func _patterns_match(trail_positions, pattern):
	if trail_positions.size() != pattern.size():
		return false
	
	# Vérifier que chaque position du pattern est dans la traînée
	for ppos in pattern:
		var found = false
		for tpos in trail_positions:
			if ppos == tpos:
				found = true
				break
		if not found:
			return false
	return true

func _shape_completed():
	# La forme a été reproduite!
	shapes_completed += 1
	score += 100 * shapes_completed  # Bonus croissant
	flash_alpha = 1.0
	hint_flash_timer = 2.0
	screen_shake = Vector2(5, 5)
	
	# Particules de victoire
	for pos_data in snake_trail:
		_spawn_particles_at(pos_data["pos"], COLOR_BONUS)
	
	# Vérifier si c'était le niveau final (niveau 4)
	if current_shape.has("is_final") and current_shape["is_final"]:
		# VICTOIRE FINALE!
		game_won = true
		game_paused = true
		victory_celebration_timer = VICTORY_CELEBRATION_DURATION
		firework_timer = 0.0
		screen_shake = Vector2(15, 15)
		flash_alpha = 1.5
		
		# Explosion de particules!
		for i in range(50):
			var random_pos = Vector2(randi() % GRID_WIDTH, randi() % GRID_HEIGHT)
			_spawn_firework_at(random_pos)
	else:
		# Mettre le jeu en pause et afficher le popup normal
		game_paused = true
		shape_victory_popup = true
		shape_victory_timer = SHAPE_VICTORY_DURATION

func _spawn_firework_at(pos):
	# Créer un feu d'artifice coloré
	var colors = [
		Color(1.0, 0.2, 0.2, 1.0),  # Rouge
		Color(0.2, 1.0, 0.2, 1.0),  # Vert
		Color(0.2, 0.2, 1.0, 1.0),  # Bleu
		Color(1.0, 1.0, 0.2, 1.0),  # Jaune
		Color(1.0, 0.2, 1.0, 1.0),  # Magenta
		Color(0.2, 1.0, 1.0, 1.0),  # Cyan
		Color(1.0, 0.5, 0.0, 1.0),  # Orange
		Color(1.0, 1.0, 1.0, 1.0)   # Blanc
	]
	var color = colors[randi() % colors.size()]
	
	for i in range(12):
		var angle = i * (PI * 2 / 12)
		var speed = 150 + randf() * 100
		particles.append({
			"pos": Vector2(pos.x * CELL_SIZE + CELL_SIZE/2 + game_offset.x, 
						   pos.y * CELL_SIZE + CELL_SIZE/2 + game_offset.y),
			"vel": Vector2(cos(angle) * speed, sin(angle) * speed),
			"life": 1.0 + randf() * 0.5,
			"color": color,
			"size": 4 + randf() * 4
		})

func _restart_with_new_shape():
	# Garder le score et high score, recommencer avec nouvelle forme
	game_paused = false
	game_speed = INITIAL_SPEED
	direction = Vector2.RIGHT
	next_direction = Vector2.RIGHT
	
	# Randomiser les directions pour ce nouveau niveau!
	_randomize_direction_mapping()
	
	snake_body.clear()
	snake_trail.clear()
	var start_pos = Vector2(GRID_WIDTH / 2, GRID_HEIGHT / 2)
	for i in range(4):
		snake_body.append(start_pos - Vector2(i, 0))
	
	_spawn_food()
	bonus_active = false
	
	# Nouvelle forme aléatoire
	apples_eaten = 0
	show_hint = false
	_select_random_shape()

func _reset_direction_mapping():
	# Mapping classique (début du jeu)
	direction_mapping = {
		"up": Vector2.UP,
		"down": Vector2.DOWN,
		"left": Vector2.LEFT,
		"right": Vector2.RIGHT
	}

func _randomize_direction_mapping():
	# Sauvegarder l'ancien mapping pour comparaison
	var old_mapping = direction_mapping.duplicate()
	
	# Mélanger jusqu'à obtenir un mapping différent
	var is_same = true
	while is_same:
		# Mélanger aléatoirement les directions
		var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		var keys = ["up", "down", "left", "right"]
		
		# Mélanger le tableau des directions
		for i in range(directions.size() - 1, 0, -1):
			var j = randi() % (i + 1)
			var temp = directions[i]
			directions[i] = directions[j]
			directions[j] = temp
		
		# Assigner les nouvelles directions
		for i in range(keys.size()):
			direction_mapping[keys[i]] = directions[i]
		
		# Vérifier si le mapping est différent
		is_same = true
		for key in keys:
			if direction_mapping[key] != old_mapping[key]:
				is_same = false
				break
	
	# Créer les noms pour l'affichage
	direction_names = []
	var keys = ["up", "down", "left", "right"]
	for key in keys:
		var dir = direction_mapping[key]
		if dir == Vector2.UP:
			direction_names.append("↑")
		elif dir == Vector2.DOWN:
			direction_names.append("↓")
		elif dir == Vector2.LEFT:
			direction_names.append("←")
		else:
			direction_names.append("→")
	
	print("[DIRECTIONS RANDOMIZED] UP->", direction_mapping["up"], " DOWN->", direction_mapping["down"], 
		" LEFT->", direction_mapping["left"], " RIGHT->", direction_mapping["right"])

func _eat_food():
	score += 10
	_spawn_particles_at(food_position, COLOR_FOOD)
	_spawn_food()
	
	game_speed = max(MIN_SPEED, game_speed - SPEED_INCREASE)
	
	# Compteur de pommes pour les indices
	apples_eaten += 1
	if apples_eaten >= 3 and not show_hint:
		show_hint = true
	
	if randi() % 5 == 0 and not bonus_active:
		_spawn_bonus()

func _eat_bonus():
	score += 50
	bonus_active = false
	flash_alpha = 0.5
	_spawn_particles_at(bonus_position, COLOR_BONUS)
	
	for i in range(3):
		snake_body.append(snake_body[snake_body.size() - 1])

func _spawn_food():
	var valid = false
	while not valid:
		food_position = Vector2(randi() % GRID_WIDTH, randi() % GRID_HEIGHT)
		valid = true
		for segment in snake_body:
			if segment == food_position:
				valid = false
				break

func _spawn_bonus():
	bonus_active = true
	bonus_timer = 5.0
	var valid = false
	while not valid:
		bonus_position = Vector2(randi() % GRID_WIDTH, randi() % GRID_HEIGHT)
		valid = true
		for segment in snake_body:
			if segment == bonus_position:
				valid = false
				break
		if bonus_position == food_position:
			valid = false

func _spawn_particles_at(pos, color):
	for i in range(15):
		particles.append({
			"pos": Vector2(pos.x * CELL_SIZE + CELL_SIZE/2 + game_offset.x, pos.y * CELL_SIZE + CELL_SIZE/2 + game_offset.y),
			"vel": Vector2(randf() * 200 - 100, randf() * 200 - 100),
			"life": 0.5 + randf() * 0.3,
			"color": color,
			"size": 2 + randf() * 4
		})

func _snake_game_over():
	current_state = State.GAME_OVER
	game_over = true
	screen_shake = Vector2(10, 10)
	flash_alpha = 1.0
	return_to_menu_timer = RETURN_DELAY
	
	if score > high_score:
		high_score = score
	
	for segment in snake_body:
		_spawn_particles_at(segment, COLOR_SNAKE_BODY)

# ═══════════════════════════════════════════════════════════════════════════
# DESSIN
# ═══════════════════════════════════════════════════════════════════════════

func _draw():
	# Fond
	draw_rect(Rect2(0, 0, screen_size.x, screen_size.y), COLOR_BACKGROUND)
	
	match current_state:
		State.LOGIN:
			_draw_login_popup()
		State.OS_CHOICE:
			_draw_os_choice_popup()
		State.WINDOWS_VIRUS:
			_draw_virus_screen()
		State.SNAKE_GAME, State.GAME_OVER:
			_draw_snake_game()
	
	# Particules (toujours au-dessus)
	_draw_particles()
	
	# Flash effect
	if flash_alpha > 0:
		draw_rect(Rect2(0, 0, screen_size.x, screen_size.y), 
			Color(1.0, 1.0, 1.0, flash_alpha * 0.5))

func _draw_login_popup():
	var popup_width = 400
	var popup_height = 200
	var popup_x = (screen_size.x - popup_width) / 2
	var popup_y = (screen_size.y - popup_height) / 2
	
	# Ombre
	draw_rect(Rect2(popup_x + 5, popup_y + 5, popup_width, popup_height), Color(0, 0, 0, 0.5))
	
	# Fond du popup
	draw_rect(Rect2(popup_x, popup_y, popup_width, popup_height), COLOR_POPUP_BG)
	
	# Barre de titre
	draw_rect(Rect2(popup_x, popup_y, popup_width, 30), COLOR_POPUP_TITLE)
	draw_rect(Rect2(popup_x, popup_y, popup_width, popup_height), COLOR_POPUP_BORDER, false, 2)
	
	# Titre
	var title = "SYSTEM LOGIN"
	draw_string(font, Vector2(popup_x + 15, popup_y + 20), title, COLOR_WHITE)
	
	# Bouton fermer (décoratif)
	draw_rect(Rect2(popup_x + popup_width - 25, popup_y + 5, 20, 20), COLOR_RED)
	draw_string(font, Vector2(popup_x + popup_width - 21, popup_y + 20), "X", COLOR_WHITE)
	
	# Icône utilisateur (ASCII art simple)
	var user_y = popup_y + 60
	draw_string(font, Vector2(popup_x + 30, user_y), "  ___  ", COLOR_TEXT)
	draw_string(font, Vector2(popup_x + 30, user_y + 15), " /o o\\ ", COLOR_TEXT)
	draw_string(font, Vector2(popup_x + 30, user_y + 30), " \\_-_/ ", COLOR_TEXT)
	draw_string(font, Vector2(popup_x + 30, user_y + 45), "  /|\\  ", COLOR_TEXT)
	
	# Label mot de passe
	draw_string(font, Vector2(popup_x + 120, popup_y + 70), "Enter Password:", COLOR_WHITE)
	
	# Champ de mot de passe
	var field_x = popup_x + 120
	var field_y = popup_y + 85
	var field_width = 220
	var field_height = 30
	
	draw_rect(Rect2(field_x, field_y, field_width, field_height), Color(0.1, 0.1, 0.15, 1.0))
	draw_rect(Rect2(field_x, field_y, field_width, field_height), COLOR_TEXT, false, 2)
	
	# Afficher les astérisques
	var display_text = ""
	for i in range(password_input.length()):
		display_text += "*"
	
	# Curseur clignotant
	if password_cursor_visible:
		display_text += "|"
	
	draw_string(font, Vector2(field_x + 10, field_y + 20), display_text, COLOR_TEXT)
	
	# Message d'erreur
	if login_error:
		var error_blink = abs(sin(OS.get_ticks_msec() / 100.0))
		var error_color = Color(1.0, 0.2, 0.2, error_blink)
		draw_string(font, Vector2(popup_x + 120, popup_y + 135), "ACCESS DENIED!", error_color)
	
	# Instructions
	draw_string(font, Vector2(popup_x + 100, popup_y + 170), "[ENTER] to confirm  [ESC] to quit", Color(0.5, 0.5, 0.5, 1.0))

func _draw_os_choice_popup():
	var popup_width = 500
	var popup_height = 300
	var popup_x = (screen_size.x - popup_width) / 2
	var popup_y = (screen_size.y - popup_height) / 2
	
	# Animation d'entrée
	var anim_scale = min(os_choice_anim * 3, 1.0)
	popup_width *= anim_scale
	popup_height *= anim_scale
	popup_x = (screen_size.x - popup_width) / 2
	popup_y = (screen_size.y - popup_height) / 2
	
	if anim_scale < 1.0:
		return
	
	# Ombre
	draw_rect(Rect2(popup_x + 5, popup_y + 5, popup_width, popup_height), Color(0, 0, 0, 0.5))
	
	# Fond du popup
	draw_rect(Rect2(popup_x, popup_y, popup_width, popup_height), COLOR_POPUP_BG)
	
	# Barre de titre
	draw_rect(Rect2(popup_x, popup_y, popup_width, 30), COLOR_POPUP_TITLE)
	draw_rect(Rect2(popup_x, popup_y, popup_width, popup_height), COLOR_POPUP_BORDER, false, 2)
	
	# Titre
	var title = "SELECT OPERATING SYSTEM"
	draw_string(font, Vector2(popup_x + 15, popup_y + 20), title, COLOR_WHITE)
	
	# Bouton fermer
	draw_rect(Rect2(popup_x + popup_width - 25, popup_y + 5, 20, 20), COLOR_RED)
	draw_string(font, Vector2(popup_x + popup_width - 21, popup_y + 20), "X", COLOR_WHITE)
	
	# Options OS
	var option_width = 180
	var option_height = 180
	var linux_x = popup_x + 50
	var windows_x = popup_x + popup_width - option_width - 50
	var option_y = popup_y + 60
	
	# Linux option
	var linux_selected = (selected_os == 0)
	var linux_color = COLOR_LINUX if linux_selected else Color(0.3, 0.3, 0.3, 1.0)
	var linux_border = 4 if linux_selected else 2
	
	if linux_selected:
		# Glow effect
		draw_rect(Rect2(linux_x - 5, option_y - 5, option_width + 10, option_height + 10), 
			Color(linux_color.r, linux_color.g, linux_color.b, 0.3))
	
	draw_rect(Rect2(linux_x, option_y, option_width, option_height), Color(0.1, 0.1, 0.1, 1.0))
	draw_rect(Rect2(linux_x, option_y, option_width, option_height), linux_color, false, linux_border)
	
	# Tux ASCII art
	var tux_x = linux_x + 50
	var tux_y = option_y + 20
	draw_string(font, Vector2(tux_x, tux_y), "   .--.   ", linux_color)
	draw_string(font, Vector2(tux_x, tux_y + 12), "  |o_o |  ", linux_color)
	draw_string(font, Vector2(tux_x, tux_y + 24), "  |:_/ |  ", linux_color)
	draw_string(font, Vector2(tux_x, tux_y + 36), " //   \\ \\ ", linux_color)
	draw_string(font, Vector2(tux_x, tux_y + 48), "(|     | )", linux_color)
	draw_string(font, Vector2(tux_x, tux_y + 60), "/'\\_   _/`\\", linux_color)
	draw_string(font, Vector2(tux_x, tux_y + 72), "\\___)=(___/", linux_color)
	
	draw_string(font, Vector2(linux_x + 60, option_y + option_height - 20), "LINUX", linux_color)
	
	# Windows option
	var windows_selected = (selected_os == 1)
	var windows_color = COLOR_WINDOWS if windows_selected else Color(0.3, 0.3, 0.3, 1.0)
	var windows_border = 4 if windows_selected else 2
	
	if windows_selected:
		draw_rect(Rect2(windows_x - 5, option_y - 5, option_width + 10, option_height + 10), 
			Color(windows_color.r, windows_color.g, windows_color.b, 0.3))
	
	draw_rect(Rect2(windows_x, option_y, option_width, option_height), Color(0.1, 0.1, 0.1, 1.0))
	draw_rect(Rect2(windows_x, option_y, option_width, option_height), windows_color, false, windows_border)
	
	# Windows logo ASCII
	var win_x = windows_x + 40
	var win_y = option_y + 30
	draw_string(font, Vector2(win_x, win_y), "####  ####", windows_color)
	draw_string(font, Vector2(win_x, win_y + 15), "####  ####", windows_color)
	draw_string(font, Vector2(win_x, win_y + 30), "          ", windows_color)
	draw_string(font, Vector2(win_x, win_y + 45), "####  ####", windows_color)
	draw_string(font, Vector2(win_x, win_y + 60), "####  ####", windows_color)
	
	draw_string(font, Vector2(windows_x + 50, option_y + option_height - 20), "WINDOWS", windows_color)
	
	# Instructions
	var blink = abs(sin(OS.get_ticks_msec() / 300.0))
	var inst_color = Color(0.7, 0.7, 0.7, blink)
	draw_string(font, Vector2(popup_x + 100, popup_y + popup_height - 25), 
		"[LEFT/RIGHT] select  [ENTER] confirm", inst_color)

func _draw_virus_screen():
	# Fond Windows bleu (avec glitch)
	var bg_color = COLOR_DESKTOP
	if glitch_intensity > 0.5:
		bg_color = Color(
			bg_color.r + randf() * glitch_intensity * 0.3,
			bg_color.g + randf() * glitch_intensity * 0.2,
			bg_color.b + randf() * glitch_intensity * 0.3,
			1.0
		)
	draw_rect(Rect2(0, 0, screen_size.x, screen_size.y), bg_color)
	
	# Effet de lignes de scan
	if glitch_intensity > 0.3:
		for i in range(int(glitch_intensity * 20)):
			var y = randf() * screen_size.y
			var alpha = randf() * 0.3 * glitch_intensity
			draw_rect(Rect2(0, y, screen_size.x, 2), Color(1, 1, 1, alpha))
	
	# Dessiner tous les popups
	for popup in virus_popups:
		_draw_virus_popup(popup)
	
	# Barre de shutdown si active
	if shutdown_started:
		_draw_shutdown_screen()

func _draw_virus_popup(popup):
	var x = popup["x"] + popup["shake"].x
	var y = popup["y"] + popup["shake"].y
	var w = popup["width"]
	var h = popup["height"]
	
	# Ombre
	draw_rect(Rect2(x + 3, y + 3, w, h), Color(0, 0, 0, 0.5))
	
	# Fond
	draw_rect(Rect2(x, y, w, h), Color(0.9, 0.9, 0.9, 1.0))
	
	# Barre de titre rouge
	draw_rect(Rect2(x, y, w, 25), popup["color"])
	
	# Bordure
	draw_rect(Rect2(x, y, w, h), Color(0.3, 0.3, 0.3, 1.0), false, 2)
	
	# Titre
	var title = "WARNING"
	draw_string(font, Vector2(x + 5, y + 17), title, COLOR_WHITE)
	
	# Bouton X
	draw_rect(Rect2(x + w - 22, y + 3, 19, 19), Color(0.8, 0.2, 0.2, 1.0))
	draw_string(font, Vector2(x + w - 18, y + 17), "X", COLOR_WHITE)
	
	# Icône d'alerte
	var icon_y = y + 45
	draw_string(font, Vector2(x + 15, icon_y), "  /!\\  ", COLOR_RED)
	draw_string(font, Vector2(x + 15, icon_y + 15), " /___\\ ", COLOR_RED)
	
	# Message
	draw_string(font, Vector2(x + 70, y + 55), popup["message"], Color(0.1, 0.1, 0.1, 1.0))
	
	# Faux bouton OK
	var btn_x = x + w/2 - 30
	var btn_y = y + h - 35
	draw_rect(Rect2(btn_x, btn_y, 60, 25), Color(0.8, 0.8, 0.8, 1.0))
	draw_rect(Rect2(btn_x, btn_y, 60, 25), Color(0.3, 0.3, 0.3, 1.0), false, 1)
	draw_string(font, Vector2(btn_x + 20, btn_y + 17), "OK", Color(0.1, 0.1, 0.1, 1.0))

func _draw_shutdown_screen():
	# Overlay sombre
	var overlay_alpha = shutdown_progress * 0.9
	draw_rect(Rect2(0, 0, screen_size.x, screen_size.y), Color(0, 0, 0, overlay_alpha))
	
	# Message de shutdown
	var center_x = screen_size.x / 2
	var center_y = screen_size.y / 2
	
	var shutdown_text = "SHUTTING DOWN..."
	var text_width = shutdown_text.length() * 10
	draw_string(font, Vector2(center_x - text_width/2, center_y - 50), shutdown_text, COLOR_WHITE)
	
	# Barre de progression
	var bar_width = 300
	var bar_height = 20
	var bar_x = center_x - bar_width/2
	var bar_y = center_y
	
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color(0.2, 0.2, 0.2, 1.0))
	draw_rect(Rect2(bar_x, bar_y, bar_width * shutdown_progress, bar_height), COLOR_RED)
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), COLOR_WHITE, false, 2)
	
	# Pourcentage
	var percent = str(int(shutdown_progress * 100)) + "%"
	draw_string(font, Vector2(center_x - 15, center_y + 50), percent, COLOR_WHITE)
	
	# Message final
	if shutdown_progress > 0.7:
		var blink = abs(sin(OS.get_ticks_msec() / 100.0))
		var final_msg = "SHOULD HAVE CHOSEN LINUX!"
		draw_string(font, Vector2(center_x - final_msg.length() * 4, center_y + 100), 
			final_msg, Color(1.0, blink, blink, 1.0))

func _draw_snake_game():
	var offset = screen_shake + game_offset
	
	# Pluie Matrix
	_draw_matrix_rain(offset)
	
	# Grille
	_draw_grid(offset)
	
	# Bordure
	_draw_terminal_border(offset)
	
	if game_active and startup_complete:
		# Dessiner la traînée EN PREMIER (derrière le serpent)
		_draw_snake_trail(offset)
		_draw_snake(offset)
		_draw_food(offset)
		if bonus_active:
			_draw_bonus(offset)
	
	# Afficher les indices de forme si activés
	if show_hint and current_shape != null:
		_draw_shape_hint(offset)
	
	# Afficher le popup de victoire de forme
	if shape_victory_popup:
		_draw_shape_victory_popup()
	
	# Afficher la célébration de victoire finale
	if game_won:
		_draw_victory_celebration()
	
	_draw_snake_ui(offset)

func _draw_snake_trail(offset):
	# Couleur de la traînée selon la progression
	var base_color = Color(0.0, 0.6, 1.0, 0.4)  # Cyan par défaut
	
	# Modifier la couleur selon le match progress
	if show_hint and current_shape != null:
		if shape_match_progress >= 1.0:
			# Forme complète - or brillant
			base_color = Color(1.0, 0.8, 0.0, 0.7)
		elif shape_match_progress >= 0.5:
			# Bonne progression - vert
			base_color = Color(0.0, 1.0, 0.5, 0.5)
	
	for trail_segment in snake_trail:
		var pos = Vector2(trail_segment["pos"].x * CELL_SIZE, trail_segment["pos"].y * CELL_SIZE) + offset
		
		# Taille uniforme (petite, comme la fin de la traînée précédente)
		var segment_size = (CELL_SIZE - 4) * 0.5
		
		# Dessiner le segment de traînée
		var center = pos + Vector2(CELL_SIZE/2, CELL_SIZE/2)
		var rect_pos = center - Vector2(segment_size/2, segment_size/2)
		draw_rect(Rect2(rect_pos, Vector2(segment_size, segment_size)), base_color)

func _draw_shape_hint(offset):
	# Panneau d'indices en haut à droite
	var panel_width = 220
	var panel_height = 180
	var panel_x = offset.x + GRID_WIDTH * CELL_SIZE - panel_width - 10
	var panel_y = offset.y + 40
	
	# Fond semi-transparent
	draw_rect(Rect2(panel_x, panel_y, panel_width, panel_height), Color(0.0, 0.1, 0.2, 0.85))
	draw_rect(Rect2(panel_x, panel_y, panel_width, panel_height), COLOR_BONUS, false, 2)
	
	# Titre
	var title_blink = 0.7 + abs(sin(OS.get_ticks_msec() / 300.0)) * 0.3
	var title_color = Color(COLOR_BONUS.r, COLOR_BONUS.g, COLOR_BONUS.b, title_blink)
	draw_string(font, Vector2(panel_x + 10, panel_y + 20), "[SHAPE CHALLENGE]", title_color)
	
	# Nom de la forme
	draw_string(font, Vector2(panel_x + 10, panel_y + 45), "Target: " + current_shape["name"], COLOR_WHITE)
	
	# Dimensions
	var dim_text = "Size: " + str(current_shape["width"]) + "x" + str(current_shape["height"])
	draw_string(font, Vector2(panel_x + 10, panel_y + 65), dim_text, COLOR_TEXT)
	
	# Traînée nécessaire
	var trail_text = "Trail needed: " + str(current_shape["trail_needed"])
	draw_string(font, Vector2(panel_x + 10, panel_y + 85), trail_text, COLOR_TEXT)
	
	# Traînée actuelle
	var current_trail = "Current trail: " + str(snake_trail.size())
	var trail_color = COLOR_TEXT
	if snake_trail.size() >= current_shape["trail_needed"]:
		trail_color = COLOR_SNAKE_HEAD
	draw_string(font, Vector2(panel_x + 10, panel_y + 105), current_trail, trail_color)
	
	# Barre de progression
	var bar_x = panel_x + 10
	var bar_y = panel_y + 120
	var bar_width = panel_width - 20
	var bar_height = 15
	
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color(0.1, 0.1, 0.1, 1.0))
	
	var progress_color = COLOR_FOOD
	if shape_match_progress >= 0.5:
		progress_color = Color(1.0, 0.8, 0.0, 1.0)  # Jaune
	if shape_match_progress >= 1.0:
		progress_color = COLOR_SNAKE_HEAD  # Vert
	
	draw_rect(Rect2(bar_x, bar_y, bar_width * shape_match_progress, bar_height), progress_color)
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), COLOR_TEXT, false, 1)
	
	# Texte de progression
	var progress_text = str(int(shape_match_progress * 100)) + "% match"
	draw_string(font, Vector2(panel_x + 10, panel_y + 155), progress_text, COLOR_WHITE)
	
	# Dessiner la forme cible en miniature
	_draw_shape_preview(panel_x + panel_width - 70, panel_y + 45, 50)

func _draw_shape_preview(x, y, size):
	# Dessiner une miniature de la forme cible
	if current_shape == null:
		return
	
	# Calculer la taille de cellule pour la prévisualisation
	var max_dim = max(current_shape["width"], current_shape["height"])
	var cell_size = size / max_dim
	
	# Fond
	draw_rect(Rect2(x, y, size, size), Color(0.05, 0.05, 0.1, 0.8))
	draw_rect(Rect2(x, y, size, size), COLOR_TEXT, false, 1)
	
	# Dessiner le pattern
	var pattern = current_shape["pattern"]
	var blink = 0.6 + abs(sin(OS.get_ticks_msec() / 200.0)) * 0.4
	var shape_color = Color(0.0, 0.8, 1.0, blink)
	
	for pos in pattern:
		var px = x + pos.x * cell_size + 2
		var py = y + pos.y * cell_size + 2
		var ps = cell_size - 4
		if ps > 2:
			draw_rect(Rect2(px, py, ps, ps), shape_color)

func _draw_shape_victory_popup():
	# Overlay sombre
	draw_rect(Rect2(0, 0, screen_size.x, screen_size.y), Color(0, 0, 0, 0.7))
	
	# Dimensions du popup
	var popup_width = 450
	var popup_height = 280
	var popup_x = (screen_size.x - popup_width) / 2
	var popup_y = (screen_size.y - popup_height) / 2
	
	# Animation d'entrée (bounce)
	var anim_progress = 1.0 - (shape_victory_timer / SHAPE_VICTORY_DURATION)
	var scale = 1.0
	if anim_progress < 0.2:
		scale = anim_progress * 5.0  # De 0 à 1 en 0.2s
		scale = min(scale * 1.2, 1.0)  # Petit bounce
	
	popup_width *= scale
	popup_height *= scale
	popup_x = (screen_size.x - popup_width) / 2
	popup_y = (screen_size.y - popup_height) / 2
	
	if scale < 0.1:
		return
	
	# Glow doré autour du popup
	var glow_pulse = 0.3 + abs(sin(OS.get_ticks_msec() / 150.0)) * 0.4
	for i in range(3):
		var glow_offset = (3 - i) * 8
		draw_rect(Rect2(popup_x - glow_offset, popup_y - glow_offset, 
			popup_width + glow_offset * 2, popup_height + glow_offset * 2), 
			Color(1.0, 0.8, 0.0, glow_pulse * (0.1 + i * 0.05)))
	
	# Ombre
	draw_rect(Rect2(popup_x + 8, popup_y + 8, popup_width, popup_height), Color(0, 0, 0, 0.6))
	
	# Fond du popup (gradient simulé)
	draw_rect(Rect2(popup_x, popup_y, popup_width, popup_height), Color(0.1, 0.15, 0.2, 0.98))
	
	# Barre de titre dorée
	draw_rect(Rect2(popup_x, popup_y, popup_width, 35), Color(0.8, 0.6, 0.0, 1.0))
	
	# Bordure dorée
	draw_rect(Rect2(popup_x, popup_y, popup_width, popup_height), COLOR_BONUS, false, 3)
	
	# Titre
	var title = "★ SHAPE COMPLETE! ★"
	var title_blink = 0.8 + abs(sin(OS.get_ticks_msec() / 100.0)) * 0.2
	draw_string(font, Vector2(popup_x + popup_width/2 - title.length() * 4.5, popup_y + 24), 
		title, Color(1.0, 1.0, 1.0, title_blink))
	
	# Icône de succès (checkmark simplifié)
	var check_y = popup_y + 55
	var check_color = Color(0.0, 1.0, 0.4, 1.0)
	draw_string(font, Vector2(popup_x + 30, check_y), "   [OK]   ", check_color)
	draw_string(font, Vector2(popup_x + 30, check_y + 20), "  SUCCESS ", check_color)
	draw_string(font, Vector2(popup_x + 30, check_y + 40), "    !!    ", check_color)
	
	# Informations sur la forme réussie
	var info_x = popup_x + 140
	var info_y = popup_y + 60
	
	draw_string(font, Vector2(info_x, info_y), "Shape: " + current_shape["name"], COLOR_WHITE)
	draw_string(font, Vector2(info_x, info_y + 25), "Size: " + str(current_shape["width"]) + "x" + str(current_shape["height"]), COLOR_TEXT)
	
	# Bonus gagné
	var bonus_text = "BONUS: +" + str(100 * shapes_completed) + " pts"
	var bonus_color = Color(1.0, 0.8, 0.0, 1.0)
	draw_string(font, Vector2(info_x, info_y + 50), bonus_text, bonus_color)
	
	# Compteur de formes
	var shapes_text = "Shapes completed: " + str(shapes_completed)
	draw_string(font, Vector2(info_x, info_y + 75), shapes_text, COLOR_WHITE)
	
	# Dessiner la forme réussie en miniature
	_draw_shape_preview(popup_x + popup_width - 100, popup_y + 60, 80)
	
	# Barre de progression pour le countdown
	var bar_x = popup_x + 20
	var bar_y = popup_y + popup_height - 50
	var bar_width = popup_width - 40
	var bar_height = 12
	var progress = shape_victory_timer / SHAPE_VICTORY_DURATION
	
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color(0.1, 0.1, 0.1, 1.0))
	draw_rect(Rect2(bar_x, bar_y, bar_width * progress, bar_height), COLOR_BONUS)
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), COLOR_WHITE, false, 1)
	
	# Message de continuation
	var continue_blink = abs(sin(OS.get_ticks_msec() / 300.0))
	var continue_text = "Next challenge in " + str(int(ceil(shape_victory_timer))) + "..."
	var continue_color = Color(0.7, 0.7, 0.7, 0.5 + continue_blink * 0.5)
	draw_string(font, Vector2(popup_x + popup_width/2 - continue_text.length() * 4, popup_y + popup_height - 25), 
		continue_text, continue_color)

func _draw_victory_celebration():
	# Overlay avec dégradé arc-en-ciel pulsant
	var rainbow_phase = OS.get_ticks_msec() / 500.0
	var overlay_color = Color(
		0.5 + sin(rainbow_phase) * 0.2,
		0.5 + sin(rainbow_phase + 2) * 0.2,
		0.5 + sin(rainbow_phase + 4) * 0.2,
		0.3
	)
	draw_rect(Rect2(0, 0, screen_size.x, screen_size.y), overlay_color)
	
	# Grande bannière centrale
	var banner_width = 700
	var banner_height = 400
	var banner_x = (screen_size.x - banner_width) / 2
	var banner_y = (screen_size.y - banner_height) / 2
	
	# Animation de scale pulsante
	var pulse = 1.0 + sin(OS.get_ticks_msec() / 150.0) * 0.05
	banner_width *= pulse
	banner_height *= pulse
	banner_x = (screen_size.x - banner_width) / 2
	banner_y = (screen_size.y - banner_height) / 2
	
	# Glow arc-en-ciel autour de la bannière
	for i in range(5):
		var glow_offset = (5 - i) * 12
		var glow_phase = rainbow_phase + i * 0.5
		var glow_color = Color(
			0.5 + sin(glow_phase) * 0.5,
			0.5 + sin(glow_phase + 2) * 0.5,
			0.5 + sin(glow_phase + 4) * 0.5,
			0.15 + i * 0.03
		)
		draw_rect(Rect2(banner_x - glow_offset, banner_y - glow_offset, 
			banner_width + glow_offset * 2, banner_height + glow_offset * 2), glow_color)
	
	# Fond de la bannière
	draw_rect(Rect2(banner_x, banner_y, banner_width, banner_height), Color(0.05, 0.05, 0.1, 0.95))
	
	# Bordure dorée brillante
	var gold_blink = 0.7 + abs(sin(OS.get_ticks_msec() / 100.0)) * 0.3
	draw_rect(Rect2(banner_x, banner_y, banner_width, banner_height), 
		Color(1.0, 0.8, 0.0, gold_blink), false, 5)
	
	# Étoiles décoratives qui bougent
	var star_chars = ["★", "✦", "✧", "✶", "✴", "✵"]
	for i in range(20):
		var star_x = banner_x + (hash(i * 7) % int(banner_width))
		var star_y = banner_y + (hash(i * 13) % int(banner_height))
		var star_phase = OS.get_ticks_msec() / 200.0 + i
		var star_alpha = 0.3 + abs(sin(star_phase)) * 0.7
		var star_color = Color(1.0, 1.0, 0.5, star_alpha)
		draw_string(font, Vector2(star_x, star_y), star_chars[i % star_chars.size()], star_color)
	
	# Titre principal gigantesque
	var title1 = "🎉 CONGRATULATIONS! 🎉"
	var title1_x = banner_x + banner_width/2 - title1.length() * 6
	var title1_color = Color(1.0, 0.9, 0.0, gold_blink)
	draw_string(font, Vector2(title1_x, banner_y + 50), title1, title1_color)
	
	var title2 = "YOU WON THE GAME!"
	var title2_x = banner_x + banner_width/2 - title2.length() * 6
	var title2_blink = abs(sin(OS.get_ticks_msec() / 150.0))
	var title2_color = Color(0.0, 1.0, 0.5, 0.7 + title2_blink * 0.3)
	draw_string(font, Vector2(title2_x, banner_y + 90), title2, title2_color)
	
	# Stats finales
	var stats_y = banner_y + 140
	draw_string(font, Vector2(banner_x + 50, stats_y), "FINAL SCORE: " + str(score), COLOR_WHITE)
	draw_string(font, Vector2(banner_x + 50, stats_y + 30), "SHAPES COMPLETED: " + str(shapes_completed), COLOR_TEXT)
	draw_string(font, Vector2(banner_x + 50, stats_y + 60), "FINAL CHALLENGE: " + current_shape["name"], COLOR_BONUS)
	
	# Message de félicitations
	var congrats_messages = [
		"You are a TRUE LINUX MASTER!",
		"The Snake bows to your skill!",
		"Incredible reflexes!",
		"You conquered the terminal!"
	]
	var msg_index = int(OS.get_ticks_msec() / 2000) % congrats_messages.size()
	var congrats_blink = 0.5 + abs(sin(OS.get_ticks_msec() / 200.0)) * 0.5
	draw_string(font, Vector2(banner_x + 50, stats_y + 110), 
		congrats_messages[msg_index], Color(0.5, 1.0, 0.5, congrats_blink))
	
	# ASCII art de trophée
	var trophy_x = banner_x + banner_width - 180
	var trophy_y = banner_y + 130
	var trophy_color = Color(1.0, 0.85, 0.0, gold_blink)
	draw_string(font, Vector2(trophy_x, trophy_y), "     ___     ", trophy_color)
	draw_string(font, Vector2(trophy_x, trophy_y + 15), "    |   |    ", trophy_color)
	draw_string(font, Vector2(trophy_x, trophy_y + 30), " )__|   |__( ", trophy_color)
	draw_string(font, Vector2(trophy_x, trophy_y + 45), "(___________)", trophy_color)
	draw_string(font, Vector2(trophy_x, trophy_y + 60), "    |   |    ", trophy_color)
	draw_string(font, Vector2(trophy_x, trophy_y + 75), "   /|   |\\   ", trophy_color)
	draw_string(font, Vector2(trophy_x, trophy_y + 90), "  /_|___|_\\  ", trophy_color)
	
	# Barre de countdown pour retour au menu
	var bar_x = banner_x + 50
	var bar_y = banner_y + banner_height - 60
	var bar_width_inner = banner_width - 100
	var bar_height_inner = 20
	var progress = victory_celebration_timer / VICTORY_CELEBRATION_DURATION
	
	draw_rect(Rect2(bar_x, bar_y, bar_width_inner, bar_height_inner), Color(0.1, 0.1, 0.1, 1.0))
	
	# Barre arc-en-ciel
	var rainbow_progress_color = Color(
		0.5 + sin(rainbow_phase * 2) * 0.5,
		0.5 + sin(rainbow_phase * 2 + 2) * 0.5,
		0.5 + sin(rainbow_phase * 2 + 4) * 0.5,
		1.0
	)
	draw_rect(Rect2(bar_x, bar_y, bar_width_inner * progress, bar_height_inner), rainbow_progress_color)
	draw_rect(Rect2(bar_x, bar_y, bar_width_inner, bar_height_inner), COLOR_WHITE, false, 2)
	
	# Texte de retour
	var return_text = "Returning to menu in " + str(int(ceil(victory_celebration_timer))) + "..."
	draw_string(font, Vector2(banner_x + banner_width/2 - return_text.length() * 4, banner_y + banner_height - 25), 
		return_text, COLOR_WHITE)

func _draw_matrix_rain(offset):
	for i in range(matrix_rain.size()):
		var column = matrix_rain[i]
		var x = i * CELL_SIZE + offset.x
		for j in range(column["chars"].size()):
			var y = (column["y"] + j) * CELL_SIZE + offset.y
			if y >= 0 and y < GRID_HEIGHT * CELL_SIZE + offset.y:
				var alpha = 1.0 - (j / float(column["chars"].size()))
				var color = Color(0.0, 0.5 + alpha * 0.3, 0.2, alpha * 0.3)
				draw_rect(Rect2(x + 8, y + 8, 4, 4), color)

func _draw_grid(offset):
	for x in range(GRID_WIDTH + 1):
		draw_line(
			Vector2(x * CELL_SIZE, 0) + offset,
			Vector2(x * CELL_SIZE, GRID_HEIGHT * CELL_SIZE) + offset,
			COLOR_GRID, 1
		)
	for y in range(GRID_HEIGHT + 1):
		draw_line(
			Vector2(0, y * CELL_SIZE) + offset,
			Vector2(GRID_WIDTH * CELL_SIZE, y * CELL_SIZE) + offset,
			COLOR_GRID, 1
		)

func _draw_terminal_border(offset):
	var border_color = Color(COLOR_SNAKE_HEAD.r, COLOR_SNAKE_HEAD.g, COLOR_SNAKE_HEAD.b, glow_intensity)
	var rect = Rect2(offset, Vector2(GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE))
	
	for i in range(3):
		var glow_rect = Rect2(rect.position - Vector2(i, i), rect.size + Vector2(i*2, i*2))
		draw_rect(glow_rect, Color(border_color.r, border_color.g, border_color.b, 0.1 - i * 0.03), false, 2)
	
	draw_rect(rect, border_color, false, 2)

func _draw_snake(offset):
	for i in range(snake_body.size()):
		var segment = snake_body[i]
		var pos = Vector2(segment.x * CELL_SIZE, segment.y * CELL_SIZE) + offset
		var rect = Rect2(pos + Vector2(1, 1), Vector2(CELL_SIZE - 2, CELL_SIZE - 2))
		
		var t = float(i) / max(snake_body.size() - 1, 1)
		var color = COLOR_SNAKE_HEAD.linear_interpolate(COLOR_SNAKE_TAIL, t)
		
		if i == 0:
			var pulse = 1.0 + sin(OS.get_ticks_msec() / 100.0) * 0.1
			rect = Rect2(pos + Vector2(1, 1) * (1 - pulse * 0.1), Vector2(CELL_SIZE - 2, CELL_SIZE - 2) * pulse)
			draw_rect(Rect2(pos - Vector2(2, 2), Vector2(CELL_SIZE + 4, CELL_SIZE + 4)), COLOR_GLOW)
		
		draw_rect(rect, color)
		
		if i == 0:
			_draw_snake_eyes(pos)

func _draw_snake_eyes(pos):
	var eye_color = Color(0.0, 0.0, 0.0)
	var pupil_color = COLOR_FOOD
	var eye_size = 4
	var pupil_size = 2
	
	var eye1_pos = pos + Vector2(CELL_SIZE * 0.3, CELL_SIZE * 0.3)
	var eye2_pos = pos + Vector2(CELL_SIZE * 0.7, CELL_SIZE * 0.3)
	
	match direction:
		Vector2.UP:
			eye1_pos = pos + Vector2(CELL_SIZE * 0.3, CELL_SIZE * 0.3)
			eye2_pos = pos + Vector2(CELL_SIZE * 0.7, CELL_SIZE * 0.3)
		Vector2.DOWN:
			eye1_pos = pos + Vector2(CELL_SIZE * 0.3, CELL_SIZE * 0.7)
			eye2_pos = pos + Vector2(CELL_SIZE * 0.7, CELL_SIZE * 0.7)
		Vector2.LEFT:
			eye1_pos = pos + Vector2(CELL_SIZE * 0.3, CELL_SIZE * 0.3)
			eye2_pos = pos + Vector2(CELL_SIZE * 0.3, CELL_SIZE * 0.7)
		Vector2.RIGHT:
			eye1_pos = pos + Vector2(CELL_SIZE * 0.7, CELL_SIZE * 0.3)
			eye2_pos = pos + Vector2(CELL_SIZE * 0.7, CELL_SIZE * 0.7)
	
	draw_circle(eye1_pos, eye_size, eye_color)
	draw_circle(eye2_pos, eye_size, eye_color)
	draw_circle(eye1_pos, pupil_size, pupil_color)
	draw_circle(eye2_pos, pupil_size, pupil_color)

func _draw_food(offset):
	var pos = Vector2(food_position.x * CELL_SIZE, food_position.y * CELL_SIZE) + offset
	var pulse = 1.0 + sin(OS.get_ticks_msec() / 150.0) * 0.2
	var size = (CELL_SIZE - 4) * pulse
	var center = pos + Vector2(CELL_SIZE/2, CELL_SIZE/2)
	
	draw_circle(center, size * 0.8, Color(COLOR_FOOD.r, COLOR_FOOD.g, COLOR_FOOD.b, 0.3))
	
	var points = PoolVector2Array([
		center + Vector2(0, -size/2),
		center + Vector2(size/2, 0),
		center + Vector2(0, size/2),
		center + Vector2(-size/2, 0)
	])
	draw_colored_polygon(points, COLOR_FOOD)

func _draw_bonus(offset):
	var pos = Vector2(bonus_position.x * CELL_SIZE, bonus_position.y * CELL_SIZE) + offset
	var pulse = 1.0 + sin(OS.get_ticks_msec() / 80.0) * 0.3
	var size = (CELL_SIZE - 2) * pulse
	var center = pos + Vector2(CELL_SIZE/2, CELL_SIZE/2)
	
	var blink = abs(sin(OS.get_ticks_msec() / 100.0))
	var color = Color(COLOR_BONUS.r, COLOR_BONUS.g, COLOR_BONUS.b, 0.5 + blink * 0.5)
	
	draw_circle(center, size, Color(color.r, color.g, color.b, 0.3))
	_draw_star(center, size * 0.5, 5, color)
	
	var timer_width = (bonus_timer / 5.0) * CELL_SIZE
	draw_rect(Rect2(pos.x, pos.y + CELL_SIZE + 2, timer_width, 3), color)

func _draw_star(center, radius, points, color):
	var angle_step = PI * 2 / points
	var half_step = angle_step / 2
	var inner_radius = radius * 0.5
	
	var star_points = PoolVector2Array()
	for i in range(points):
		var angle = -PI/2 + i * angle_step
		star_points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		star_points.append(center + Vector2(cos(angle + half_step), sin(angle + half_step)) * inner_radius)
	
	draw_colored_polygon(star_points, color)

func _draw_particles():
	for p in particles:
		var alpha = p["life"]
		var color = Color(p["color"].r, p["color"].g, p["color"].b, alpha)
		draw_circle(p["pos"], p["size"] * alpha, color)

func _draw_snake_ui(offset):
	var text_color = COLOR_TEXT
	var y_offset = offset.y - 30
	
	draw_string(font, Vector2(offset.x + 10, y_offset), "SCORE: " + str(score), text_color)
	
	# Afficher le nombre de formes complétées
	if shapes_completed > 0:
		var shapes_text = "SHAPES: " + str(shapes_completed)
		draw_string(font, Vector2(offset.x + 180, y_offset), shapes_text, COLOR_BONUS)
	
	draw_string(font, Vector2(offset.x + GRID_WIDTH * CELL_SIZE - 150, y_offset), "HIGH: " + str(high_score), text_color)
	
	if current_state == State.GAME_OVER:
		var countdown = ceil(return_to_menu_timer)
		var disconnect_msg = "[DISCONNECTING IN " + str(countdown) + "...]"
		var disc_x = offset.x + (GRID_WIDTH * CELL_SIZE - disconnect_msg.length() * 8) / 2
		var blink = abs(sin(OS.get_ticks_msec() / 200.0))
		var disc_color = Color(COLOR_FOOD.r, COLOR_FOOD.g, COLOR_FOOD.b, blink)
		draw_string(font, Vector2(disc_x, offset.y + GRID_HEIGHT * CELL_SIZE / 2 + 40), disconnect_msg, disc_color)
		
		var bar_width = GRID_WIDTH * CELL_SIZE * 0.6
		var bar_height = 10
		var bar_x = offset.x + (GRID_WIDTH * CELL_SIZE - bar_width) / 2
		var bar_y = offset.y + GRID_HEIGHT * CELL_SIZE / 2 + 60
		var progress = 1.0 - (return_to_menu_timer / RETURN_DELAY)
		
		draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color(0.2, 0.2, 0.2, 0.8))
		draw_rect(Rect2(bar_x, bar_y, bar_width * progress, bar_height), COLOR_FOOD)
		draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), text_color, false, 2)
	
	if game_paused:
		draw_rect(Rect2(offset.x, offset.y, GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE), Color(0, 0, 0, 0.5))
		var pause_text = "[ PAUSED ]"
		var pause_x = offset.x + (GRID_WIDTH * CELL_SIZE - pause_text.length() * 10) / 2
		draw_string(font, Vector2(pause_x, offset.y + GRID_HEIGHT * CELL_SIZE / 2), pause_text, text_color)
