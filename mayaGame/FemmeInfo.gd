# FemmeInfo.gd - La femme de la salle informatique, réticente à Linux
extends Area2D

signal dialogue_started
signal dialogue_ended

var npc_name = "Responsable Informatique"
var npc_id = "femme_info"

var is_player_nearby: bool = false
var dialogue_active: bool = false
var conversation_state: String = "initial"

# États de progression
var has_challenged: bool = false  # A-t-elle lancé le défi ?
var has_been_convinced: bool = false  # A-t-elle été convaincue ?

var dialogues: Dictionary = {}

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	_setup_dialogues()

func _setup_dialogues():
	dialogues = {
		"initial": {
			"text": "*soupire* Pff... Encore une journée de galère. La moitié des PC sont HS parce qu'ils sont pas compatibles Windows 11... 😩",
			"options": [
				{"text": "Vous avez essayé Linux ?", "next": "linux_suggestion", "knowledge_required": 0},
				{"text": "Courage, ça va aller !", "next": "goodbye", "knowledge_required": 0}
			]
		},
		
		"linux_suggestion": {
			"text": "Linux ? 😤 Tu crois que j'ai pas essayé ?! J'ai passé des HEURES à essayer d'installer ce truc ! C'est IMPOSSIBLE !",
			"options": [
				{"text": "C'est pas si compliqué...", "next": "challenge", "knowledge_required": 0},
				{"text": "Ah, dommage...", "next": "goodbye", "knowledge_required": 0}
			]
		},
		
		"challenge": {
			"text": "Pas compliqué ?! 😏 OK monsieur l'expert ! Je te mets au défi !\nInstalle Linux sur le PC là-bas et reviens me voir. On verra si t'es si malin !",
			"is_challenge": true,
			"options": [
				{"text": "Défi accepté ! 💪", "next": "challenge_accepted", "knowledge_required": 0},
				{"text": "Euh... peut-être plus tard", "next": "goodbye", "knowledge_required": 0}
			]
		},
		
		"challenge_accepted": {
			"text": "C'est ça, c'est ça... 🙄 Reviens quand t'auras réussi. Spoiler : tu vas galérer !",
			"is_challenge_start": true,
			"options": []
		},
		
		"waiting": {
			"text": "Alors ? T'as réussi à installer Linux ? 😏 J'attends toujours hein...",
			"options": [
				{"text": "C'est fait, venez voir !", "next": "check_linux", "knowledge_required": 0},
				{"text": "J'y travaille...", "next": "still_waiting", "knowledge_required": 0}
			]
		},
		
		"still_waiting": {
			"text": "Prends ton temps... 😏 Je savais que c'était pas si simple !",
			"options": []
		},
		
		"check_linux": {
			"text": "Voyons voir...",
			"is_check": true,
			"options": []
		},
		
		"not_installed": {
			"text": "Hmm... 🤔 Le PC tourne toujours sous Windows. Tu te moques de moi ?\nVa vraiment installer Linux et reviens !",
			"options": []
		},
		
		"linux_success": {
			"text": "😱 QUOI ?! Ça... ça marche ?! Le PC tourne sous Linux !\nMais... comment t'as fait ça ?!",
			"is_success": true,
			"options": [
				{"text": "C'était pas si dur finalement 😊", "next": "convinced", "knowledge_required": 0}
			]
		},
		
		"convinced": {
			"text": "🤯 Je... je suis impressionnée ! L'interface est jolie, ça a l'air stable...\nMerci ! Tu m'as ouvert les yeux ! Je vais en parler au directeur !\n\n📚 +20 connaissance | ❤️ +15 moral",
			"is_reward": true,
			"options": [
				{"text": "Avec plaisir ! 🐧", "next": "goodbye_happy", "knowledge_required": 0}
			]
		},
		
		"goodbye_happy": {
			"text": "🐧 Merci encore ! Je vais explorer ce nouveau monde Linux !",
			"options": []
		},
		
		"already_convinced": {
			"text": "🐧 Ah c'est toi ! Grâce à toi je suis devenue fan de Linux ! Merci encore !",
			"options": [
				{"text": "Content que ça te plaise !", "next": "goodbye_happy", "knowledge_required": 0}
			]
		},
		
		"pc_destroyed": {
			"text": "😡 QUOI ?! T'AS CASSÉ LE PC ?! Mais t'es MALADE ?!\nC'était le SEUL qui marchait encore ! Tu vas me le payer !!\n\n❤️ -10 moral",
			"is_angry": true,
			"options": []
		},
		
		"goodbye": {
			"text": "*retourne à ses soucis* Mouais, à plus...",
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
		hint.text = "[E] Parler"
		hint.visible = true

func _hide_interaction_hint():
	var hint = get_node_or_null("InteractionHint")
	if hint:
		hint.visible = false

func start_dialogue():
	dialogue_active = true
	
	# Déterminer l'état de la conversation
	if has_been_convinced:
		conversation_state = "already_convinced"
	elif has_challenged:
		conversation_state = "waiting"
	else:
		conversation_state = "initial"
	
	emit_signal("dialogue_started")
	_update_dialogue_ui()

func _check_if_linux_installed() -> bool:
	# Chercher le ComputerUI et vérifier si Linux est installé
	var computer_ui = get_tree().get_root().get_node_or_null("ComputerUI")
	if computer_ui:
		return computer_ui.is_linux
	return false

func _check_if_pc_destroyed() -> bool:
	# Chercher le ComputerUI et vérifier si le PC est détruit
	var computer_ui = get_tree().get_root().get_node_or_null("ComputerUI")
	if computer_ui:
		return computer_ui.is_destroyed
	return false

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
	
	# Gérer le défi
	if dialogues[conversation_state].get("is_challenge_start", false):
		has_challenged = true
		_show_final_dialogue()
		return
	
	# Vérification de l'installation Linux
	if dialogues[conversation_state].get("is_check", false):
		if _check_if_pc_destroyed():
			conversation_state = "pc_destroyed"
			GameData.change_mood(-10)
			_show_final_dialogue()
			return
		elif _check_if_linux_installed():
			conversation_state = "linux_success"
		else:
			conversation_state = "not_installed"
			_show_final_dialogue()
			return
	
	# Récompense finale
	if dialogues[conversation_state].get("is_reward", false) and not has_been_convinced:
		has_been_convinced = true
		GameData.add_knowledge(20, "")
		GameData.change_mood(15)
	
	# Fin de dialogue
	if conversation_state in ["goodbye", "goodbye_happy", "still_waiting"]:
		_show_final_dialogue()
		return
	
	_update_dialogue_ui()

func _show_final_dialogue():
	var dialogue_ui = get_tree().get_nodes_in_group("dialogue_ui")
	if dialogue_ui.size() > 0:
		dialogue_ui[0].show_dialogue(self, dialogues[conversation_state], npc_name)
	yield(get_tree().create_timer(5.0), "timeout")
	end_dialogue()

func end_dialogue():
	dialogue_active = false
	emit_signal("dialogue_ended")
	
	var dialogue_ui = get_tree().get_nodes_in_group("dialogue_ui")
	if dialogue_ui.size() > 0:
		dialogue_ui[0].hide_dialogue()

func interact():
	if not dialogue_active:
		start_dialogue()
