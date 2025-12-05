# EleveEcolo.gd - PNJ étudiant passionné d'écologie numérique
extends Area2D

signal dialogue_started
signal dialogue_ended

var npc_name = "Élève Écolo"
var npc_id = "eleve_ecolo"

var is_player_nearby: bool = false
var dialogue_active: bool = false
var conversation_state: String = "initial"
var has_taught_ecology: bool = false
var has_taught_sovereignty: bool = false

var dialogues: Dictionary = {}

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	_setup_dialogues()

func _setup_dialogues():
	dialogues = {
		"initial": {
			"text": "*en train de coller des stickers 'Free Software'* Oh salut ! Tu savais que le numérique pollue autant que l'aviation ?",
			"options": [
				{"text": "Sérieusement ?!", "next": "explain_ecology", "knowledge_required": 0},
				{"text": "C'est quoi ces stickers ?", "next": "explain_opensource", "knowledge_required": 0},
				{"text": "Je passais juste...", "next": "goodbye", "knowledge_required": 0}
			]
		},
		
		"explain_ecology": {
			"text": "Ouais ! Les datacenters, les serveurs qui tournent 24/7, les vidéos en streaming... Tout ça a un coût carbone énorme !",
			"options": [
				{"text": "On peut faire quelque chose ?", "next": "ecology_solution", "knowledge_required": 0},
				{"text": "Retour", "next": "initial", "knowledge_required": 0}
			]
		},
		
		"ecology_solution": {
			"text": "Bien sûr ! Utiliser des sites légers, éviter le cloud américain énergivore, privilégier les formats texte comme le Markdown plutôt que les gros fichiers Word...",
			"is_success": true,
			"options": [
				{"text": "Donc NIRd c'est écolo ?", "next": "nird_ecology", "knowledge_required": 0}
			]
		},
		
		"nird_ecology": {
			"text": "Exactement ! NIRd génère des sites statiques ultra-légers. Pas de base de données qui tourne, pas de serveur PHP... Juste des fichiers HTML servis rapidement !",
			"is_success": true,
			"options": [
				{"text": "Je comprends l'enjeu écologique !", "next": "learn_ecology", "knowledge_required": 0}
			]
		},
		
		"learn_ecology": {
			"text": "Bienvenue dans la team green IT ! 🌱 📚 +15 connaissance, sujet Écologie débloqué !",
			"is_success": true,
			"is_reward_ecology": true,
			"options": [
				{"text": "Et ces stickers Free Software ?", "next": "explain_opensource", "knowledge_required": 0},
				{"text": "Merci pour les infos !", "next": "goodbye_happy", "knowledge_required": 0}
			]
		},
		
		"explain_opensource": {
			"text": "Le logiciel libre ! C'est un mouvement pour que le code soit accessible à tous. Pas de licence payante, pas de dépendance à une entreprise...",
			"options": [
				{"text": "Mais c'est gratuit du coup ?", "next": "opensource_free", "knowledge_required": 0},
				{"text": "C'est quoi le rapport avec la souveraineté ?", "next": "opensource_sovereignty", "knowledge_required": 0}
			]
		},
		
		"opensource_free": {
			"text": "Pas forcément ! 'Libre' ne veut pas dire 'gratuit'. Ça veut dire que tu peux voir le code, le modifier, le redistribuer. C'est une question de LIBERTÉ, pas de prix !",
			"is_success": true,
			"options": [
				{"text": "Et pour l'Éducation nationale ?", "next": "opensource_sovereignty", "knowledge_required": 0}
			]
		},
		
		"opensource_sovereignty": {
			"text": "C'est ça la souveraineté numérique ! On ne dépend plus de Microsoft ou Google. On maîtrise nos outils, nos données, notre destin numérique !",
			"is_success": true,
			"options": [
				{"text": "C'est pour ça que NIRd est important !", "next": "learn_sovereignty", "knowledge_required": 0}
			]
		},
		
		"learn_sovereignty": {
			"text": "Tu as tout compris ! NIRd c'est la souveraineté en action : open source, hébergé en France, sans dépendance aux GAFAM. ✊ 📚 +15 connaissance, sujet Souveraineté débloqué !",
			"is_success": true,
			"is_reward_sovereignty": true,
			"options": [
				{"text": "Merci camarade !", "next": "goodbye_happy", "knowledge_required": 0}
			]
		},
		
		"goodbye_happy": {
			"text": "*lève le poing* Power to the people ! Et bonne chance avec le directeur, il est pas facile à convaincre !",
			"options": []
		},
		
		"already_taught": {
			"text": "*continue de coller des stickers* Tu connais déjà le topo ! Va répandre la bonne parole !",
			"options": [
				{"text": "Rappelle-moi les trucs écolos ?", "next": "explain_ecology", "knowledge_required": 0},
				{"text": "C'était quoi la souveraineté déjà ?", "next": "explain_opensource", "knowledge_required": 0},
				{"text": "À plus !", "next": "goodbye", "knowledge_required": 0}
			]
		},
		
		"goodbye": {
			"text": "*retourne à ses stickers* Salut !",
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
		hint.text = "[E] Parler à l'" + npc_name
		hint.visible = true

func _hide_interaction_hint():
	var hint = get_node_or_null("InteractionHint")
	if hint:
		hint.visible = false

func start_dialogue():
	dialogue_active = true
	has_taught_ecology = GameData.has_topic("ecology")
	has_taught_sovereignty = GameData.has_topic("sovereignty")
	
	if has_taught_ecology and has_taught_sovereignty:
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
	
	# Récompenses
	if dialogues[conversation_state].get("is_reward_ecology", false) and not has_taught_ecology:
		has_taught_ecology = true
		GameData.add_knowledge(15, "ecology")
		GameData.change_mood(8)
	
	if dialogues[conversation_state].get("is_reward_sovereignty", false) and not has_taught_sovereignty:
		has_taught_sovereignty = true
		GameData.add_knowledge(15, "sovereignty")
		GameData.change_mood(8)
	
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
