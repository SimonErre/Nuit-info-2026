# Chatteur.gd - PNJ Philosophe du Dimanche
extends Area2D

signal dialogue_started
signal dialogue_ended

var npc_name = "Philosophe"
var npc_id = "philosophe"

var is_player_nearby: bool = false
var chat_active: bool = false

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body.name == "player" or body.is_in_group("player"):
		is_player_nearby = true
		var hint = get_node_or_null("InteractionHint")
		if hint:
			hint.text = "[E] Consulter le Philosophe 🎭"
			hint.visible = true

func _on_body_exited(body):
	if body.name == "player" or body.is_in_group("player"):
		is_player_nearby = false
		var hint = get_node_or_null("InteractionHint")
		if hint:
			hint.visible = false

func _input(event):
	if is_player_nearby and event.is_action_pressed("interact"):
		if not chat_active:
			open_chatbot()

func open_chatbot():
	chat_active = true
	emit_signal("dialogue_started")
	
	var chatbot_ui = get_tree().get_nodes_in_group("chatbot_ui")
	if chatbot_ui.size() > 0:
		chatbot_ui[0].open_chat(self)
	else:
		var chatbot_scene = load("res://ChatbotUI.tscn")
		if chatbot_scene:
			var chatbot = chatbot_scene.instance()
			get_tree().current_scene.add_child(chatbot)
			chatbot.open_chat(self)

func close_chatbot():
	chat_active = false
	emit_signal("dialogue_ended")

func interact():
	if not chat_active:
		open_chatbot()
