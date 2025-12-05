# ProfMaths.gd - PNJ qui enseigne le Markdown
extends Area2D

signal dialogue_started
signal dialogue_ended

var npc_name = "Prof de Maths"
var npc_id = "prof_maths"

var is_player_nearby: bool = false
var dialogue_active: bool = false
var conversation_state: String = "initial"
var has_taught: bool = false

var dialogues: Dictionary = {}

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	_setup_dialogues()

func _setup_dialogues():
	dialogues = {
		"initial": {
			"text": "Ah, un élève ! Tu sais, j'ai découvert un truc génial pour rédiger mes cours : le Markdown !",
			"options": [
				{"text": "C'est quoi le Markdown ?", "next": "explain_markdown", "knowledge_required": 0},
				{"text": "Je dois y aller", "next": "goodbye", "knowledge_required": 0}
			]
		},
		
		"explain_markdown": {
			"text": "Le Markdown, c'est un langage de balisage super simple ! Tu écris du texte avec des symboles comme # pour les titres ou ** pour le gras. Pas besoin de Word !",
			"options": [
				{"text": "Ça sert à quoi concrètement ?", "next": "markdown_use", "knowledge_required": 0},
				{"text": "Intéressant, merci !", "next": "learn_success", "knowledge_required": 0}
			]
		},
		
		"markdown_use": {
			"text": "Ça permet de créer des documents pérennes ! Pas de format propriétaire, c'est du texte brut. Ça se lit partout, ça se versione facilement avec Git, et c'est écolo car super léger !",
			"is_success": true,
			"options": [
				{"text": "Je comprends mieux maintenant !", "next": "learn_success", "knowledge_required": 0}
			]
		},
		
		"learn_success": {
			"text": "Content de t'avoir aidé ! Tu as l'air de comprendre le sujet maintenant. 📚 +20 connaissance, sujet Markdown débloqué !",
			"is_success": true,
			"is_reward": true,
			"options": [
				{"text": "Merci professeur !", "next": "goodbye_happy", "knowledge_required": 0}
			]
		},
		
		"goodbye_happy": {
			"text": "Bonne chance pour ton projet ! Et n'oublie pas : le Markdown, c'est la vie !",
			"options": []
		},
		
		"already_taught": {
			"text": "Tu maîtrises déjà le Markdown ! Va voir d'autres profs pour compléter tes connaissances.",
			"options": [
				{"text": "D'accord, merci !", "next": "goodbye", "knowledge_required": 0}
			]
		},
		
		"goodbye": {
			"text": "À bientôt !",
			"options": []
		}
	}

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
		if not dialogue_active:
			start_dialogue()

func _show_interaction_hint():
	var hint = get_node_or_null("InteractionHint")
	if hint:
		hint.text = "[E] Parler au " + npc_name
		hint.visible = true

func _hide_interaction_hint():
	var hint = get_node_or_null("InteractionHint")
	if hint:
		hint.visible = false

func start_dialogue():
	dialogue_active = true
	
	# Si déjà enseigné, dialogue différent
	if has_taught or GameData.has_topic("markdown"):
		conversation_state = "already_taught"
	else:
		conversation_state = "initial"
	
	emit_signal("dialogue_started")
	_update_dialogue_ui()

func _update_dialogue_ui():
	var dialogue_ui = get_tree().get_nodes_in_group("dialogue_ui")
	if dialogue_ui.size() > 0:
		dialogue_ui[0].show_dialogue(self, dialogues[conversation_state], npc_name)

func select_option(option_index: int):
	if not dialogues.has(conversation_state):
		end_dialogue()
		return
	
	var current_dialogue = dialogues[conversation_state]
	
	if option_index < 0 or option_index >= current_dialogue["options"].size():
		return
	
	var selected_option = current_dialogue["options"][option_index]
	conversation_state = selected_option["next"]
	
	# Donner la récompense
	if dialogues[conversation_state].get("is_reward", false) and not has_taught:
		has_taught = true
		GameData.add_knowledge(20, "markdown")
		GameData.change_mood(10)  # Apprendre rend content !
	
	# Fin de dialogue
	if conversation_state == "goodbye" or conversation_state == "goodbye_happy":
		end_dialogue()
		return
	
	_update_dialogue_ui()

func end_dialogue():
	dialogue_active = false
	emit_signal("dialogue_ended")
	
	var dialogue_ui = get_tree().get_nodes_in_group("dialogue_ui")
	if dialogue_ui.size() > 0:
		dialogue_ui[0].hide_dialogue()

func interact():
	if not dialogue_active:
		start_dialogue()
