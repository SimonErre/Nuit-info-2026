extends Area2D

signal dialogue_started
signal dialogue_ended

var npc_name = "Assistant IA"
var npc_id = "chatteur_ia"

var is_player_nearby: bool = false
var chat_active: bool = false

# Configuration de l'API IA (à personnaliser)
export var api_url: String = "https://api.openai.com/v1/chat/completions"
export var api_key: String = ""  # À remplir avec ta clé API
export var model_name: String = "gpt-3.5-turbo"
export var system_prompt: String = "Tu es un assistant pédagogique dans un jeu vidéo éducatif sur le numérique responsable et la souveraineté numérique. Tu aides les joueurs à comprendre NIRd, le logiciel libre, l'écologie numérique et la souveraineté des données. Réponds de manière concise et engageante, comme un ami qui explique des concepts techniques."

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	_create_visual()

func _create_visual():
	# Créer un sprite pour le PNJ si pas déjà présent
	if not get_node_or_null("Sprite"):
		var sprite = Sprite.new()
		sprite.name = "Sprite"
		# Tu peux changer la texture ici
		add_child(sprite)
	
	# Zone de collision pour détecter le joueur
	if not get_node_or_null("CollisionShape2D"):
		var collision = CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		var shape = CircleShape2D.new()
		shape.radius = 50
		collision.shape = shape
		add_child(collision)
	
	# Hint d'interaction
	if not get_node_or_null("InteractionHint"):
		var hint = Label.new()
		hint.name = "InteractionHint"
		hint.text = "[E] Parler à l'" + npc_name
		hint.rect_position = Vector2(-60, -80)
		hint.visible = false
		hint.add_color_override("font_color", Color(1, 1, 0.8))
		add_child(hint)
	
	# Icône IA au-dessus du PNJ
	if not get_node_or_null("IAIcon"):
		var icon = Label.new()
		icon.name = "IAIcon"
		icon.text = "🤖"
		icon.rect_position = Vector2(-10, -50)
		add_child(icon)

func _on_body_entered(body):
	if body.name == "player" or body.is_in_group("player"):
		is_player_nearby = true
		_show_interaction_hint()

func _on_body_exited(body):
	if body.name == "player" or body.is_in_group("player"):
		is_player_nearby = false
		_hide_interaction_hint()

func _input(event):
	if is_player_nearby and event.is_action_pressed("interact"):
		if not chat_active:
			open_chatbot()

func _show_interaction_hint():
	var hint = get_node_or_null("InteractionHint")
	if hint:
		hint.text = "[E] Parler à l'" + npc_name
		hint.visible = true

func _hide_interaction_hint():
	var hint = get_node_or_null("InteractionHint")
	if hint:
		hint.visible = false

func open_chatbot():
	chat_active = true
	emit_signal("dialogue_started")
	
	# Chercher ou créer le ChatbotUI
	var chatbot_ui = get_tree().get_nodes_in_group("chatbot_ui")
	if chatbot_ui.size() > 0:
		chatbot_ui[0].open_chat(self)
	else:
		# Créer dynamiquement le ChatbotUI si pas présent
		var chatbot_scene = load("res://ChatbotUI.tscn")
		if chatbot_scene:
			var chatbot = chatbot_scene.instance()
			get_tree().current_scene.add_child(chatbot)
			chatbot.open_chat(self)

func close_chatbot():
	chat_active = false
	emit_signal("dialogue_ended")

func get_api_config() -> Dictionary:
	return {
		"url": api_url,
		"key": api_key,
		"model": model_name,
		"system_prompt": system_prompt
	}

func interact():
	if not chat_active:
		open_chatbot()
