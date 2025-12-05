# NPC.gd - Script générique pour tout PNJ avec dialogue
# Peut être utilisé pour les profs, les élèves, etc. (sauf Director qui a sa propre logique)
extends Area2D

signal dialogue_started
signal dialogue_ended

# === CONFIGURATION DU PNJ (à modifier dans l'éditeur) ===
export(String) var npc_name = "PNJ"
export(String) var npc_id = "generic_npc"
export(bool) var is_boss = false  # Le boss a des mécaniques spéciales
export(bool) var can_give_knowledge = true
export(int) var knowledge_reward = 0  # Connaissance donnée après conversation réussie
export(String) var topic_to_unlock = ""  # Sujet débloqué après conversation

# === VARIABLES D'ÉTAT ===
var is_player_nearby: bool = false
var dialogue_active: bool = false
var conversation_state: String = "initial"
var conversation_completed: bool = false

# === DIALOGUES (à surcharger ou charger depuis un fichier) ===
var dialogues: Dictionary = {}

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	
	# Charger les dialogues par défaut si non définis
	if dialogues.empty():
		_setup_default_dialogues()

func _setup_default_dialogues():
	# Dialogues par défaut - à surcharger dans les classes enfants
	dialogues = {
		"initial": {
			"text": "Bonjour, je suis " + npc_name + ". Comment puis-je vous aider ?",
			"options": [
				{"text": "Parler", "next": "talk", "knowledge_required": 0},
				{"text": "Au revoir", "next": "goodbye", "knowledge_required": 0}
			]
		},
		"talk": {
			"text": "Intéressant...",
			"options": [
				{"text": "Merci", "next": "goodbye", "knowledge_required": 0}
			]
		},
		"goodbye": {
			"text": "Au revoir !",
			"options": []
		}
	}

# === DÉTECTION DU JOUEUR ===
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
		hint.text = "[E] Parler à " + npc_name
		hint.visible = true

func _hide_interaction_hint():
	var hint = get_node_or_null("InteractionHint")
	if hint:
		hint.visible = false

# === SYSTÈME DE DIALOGUE ===
func start_dialogue():
	dialogue_active = true
	conversation_state = "initial"
	
	if is_boss:
		GameData.reset_conversation_stats()
	
	emit_signal("dialogue_started")
	_update_dialogue_ui()

func _update_dialogue_ui():
	var dialogue_ui = get_tree().get_nodes_in_group("dialogue_ui")
	if dialogue_ui.size() > 0:
		dialogue_ui[0].show_dialogue(self, dialogues[conversation_state], npc_name)
	else:
		print("ERREUR: Aucune UI de dialogue trouvée!")

func select_option(option_index: int):
	if not dialogues.has(conversation_state):
		end_dialogue()
		return
	
	var current_dialogue = dialogues[conversation_state]
	
	if option_index < 0 or option_index >= current_dialogue["options"].size():
		return
	
	var selected_option = current_dialogue["options"][option_index]
	var next_state = selected_option["next"]
	var knowledge_req = selected_option.get("knowledge_required", 0)
	var points_value = selected_option.get("points", 0)
	
	# === VÉRIFICATION CONNAISSANCE ===
	if GameData.get_knowledge_percentage() < knowledge_req:
		_handle_failure(selected_option)
		return
	
	# === SUCCÈS ===
	if points_value > 0 and is_boss:
		GameData.on_good_answer(points_value)
	
	# === RÉCOMPENSE DE CONNAISSANCE (pour PNJ non-boss) ===
	if selected_option.has("knowledge_gain"):
		var gain = selected_option["knowledge_gain"]
		var topic = selected_option.get("topic", "")
		GameData.add_knowledge(gain, topic)
		GameData.change_mood(3)  # Apprendre des trucs rend content
	
	# === LOGIQUE SPÉCIALE BOSS ===
	if next_state == "check_conviction" and is_boss:
		if GameData.can_convince_director():
			conversation_state = "convinced"
		else:
			conversation_state = "not_convinced"
			GameData.on_bad_answer()
	else:
		conversation_state = next_state
	
	# === VÉRIFIER GAME OVER ===
	if is_boss and GameData.is_game_over():
		_handle_game_over()
		return
	
	# === FIN DE DIALOGUE ===
	if conversation_state == "goodbye":
		_on_conversation_end(false)
		end_dialogue()
		return
	
	if conversation_state == "end_success":
		_on_conversation_end(true)
		_show_victory()
		return
	
	_update_dialogue_ui()

func _handle_failure(option: Dictionary):
	if is_boss:
		GameData.on_bad_answer()
		
		# Vérifier game over
		if GameData.is_game_over():
			_handle_game_over()
			return
	
	# Afficher le roast
	if option.has("failure_text"):
		dialogues["roast_state"] = {
			"text": option["failure_text"],
			"is_roast": true,
			"options": [
				{"text": "Je vais aller réviser...", "next": "initial", "knowledge_required": 0}
			]
		}
		conversation_state = "roast_state"
		_update_dialogue_ui()
	else:
		var dialogue_ui = get_tree().get_nodes_in_group("dialogue_ui")
		if dialogue_ui.size() > 0:
			dialogue_ui[0].show_insufficient_knowledge(option.get("knowledge_required", 0))

func _handle_game_over():
	dialogue_active = false
	emit_signal("dialogue_ended")
	
	var dialogue_ui = get_tree().get_nodes_in_group("dialogue_ui")
	if dialogue_ui.size() > 0:
		dialogue_ui[0].show_game_over()

func _on_conversation_end(success: bool):
	if not conversation_completed and success:
		conversation_completed = true
		
		# Donner les récompenses
		if knowledge_reward > 0:
			GameData.add_knowledge(knowledge_reward, topic_to_unlock)
		
		if topic_to_unlock != "":
			print("🎓 Sujet maîtrisé: " + topic_to_unlock)

func _show_victory():
	dialogue_active = false
	emit_signal("dialogue_ended")
	
	var dialogue_ui = get_tree().get_nodes_in_group("dialogue_ui")
	if dialogue_ui.size() > 0:
		dialogue_ui[0].show_victory()

func end_dialogue():
	dialogue_active = false
	emit_signal("dialogue_ended")
	
	var dialogue_ui = get_tree().get_nodes_in_group("dialogue_ui")
	if dialogue_ui.size() > 0:
		dialogue_ui[0].hide_dialogue()

func interact():
	if not dialogue_active:
		start_dialogue()
