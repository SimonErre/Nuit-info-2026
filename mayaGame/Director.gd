# Director.gd - Le Boss final : Le Directeur sceptique
extends Area2D

signal dialogue_started
signal dialogue_ended

# === CONFIG BOSS ===
var npc_name = "M. le Directeur"
var npc_id = "director"
var is_boss = true

# === ÉTAT ===
var is_player_nearby: bool = false
var dialogue_active: bool = false
var conversation_state: String = "initial"
var has_been_convinced: bool = false

# === DIALOGUES ===
var dialogues: Dictionary = {}

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	_setup_director_dialogues()

func _setup_director_dialogues():
	dialogues = {
	"initial": {
		"text": "Ah, vous voilà. J'espère que vous n'êtes pas là pour me parler de la panne de la machine à café. C'est quoi cette histoire de 'NIRd' ?",
		"options": [
			{
				"text": "C'est un kit de sites web pédagogiques", 
				"next": "nird_intro", 
				"knowledge_required": 10,
				"points": 15,
				"failure_text": "Un kit ? Comme un meuble IKEA ? Vous bafouillez. Revenez quand vous aurez lu la notice."
			},
			{
				"text": "C'est une révolution Open Source !", 
				"next": "tech_intro", 
				"knowledge_required": 15,
				"points": 15,
				"failure_text": "Open Source... C'est gratuit c'est ça ? Comme votre argumentaire, il manque de valeur."
			},
			{
				"text": "Je veux juste valider le projet (Convaincre)", 
				"next": "try_convince", 
				"knowledge_required": 0,
				"points": 0
			},
			{
				"text": "Je repasserai (J'ai peur)", 
				"next": "goodbye", 
				"knowledge_required": 0,
				"points": -5
			}
		]
	},
	
	"nird_intro": {
		"text": "Mouais. 'Site web pédagogique'. On a déjà Moodle et l'ENT qui rament, pourquoi en rajouter ?",
		"options": [
			{
				"text": "C'est du Markdown, c'est super léger", 
				"next": "nird_markdown", 
				"knowledge_required": 25,
				"points": 20,
				"failure_text": "Du 'Mark-Down' ? C'est quoi, une technique de judo ? Vous ne savez même pas de quoi vous parlez."
			},
			{
				"text": "Ça s'héberge sur la Forge nationale", 
				"next": "nird_forge", 
				"knowledge_required": 30,
				"points": 25,
				"failure_text": "La Forge ? Vous croyez qu'on fabrique des épées ici ? C'est un établissement scolaire, pas le Puy du Fou ! Renseignez-vous."
			},
			{
				"text": "Retour", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},

	"nird_markdown": {
		"text": "Léger, léger... C'est ce que disent tous les vendeurs. En quoi écrire en 'Markdown' change la donne ?",
		"options": [
			{
				"text": "C'est du texte brut, pérenne et écolo", 
				"next": "nird_ecology", 
				"knowledge_required": 40,
				"points": 30,
				"failure_text": "Écolo ? Vu comment vous ramez pour m'expliquer ça, vous consommez plus d'énergie que le datacenter ! Soyez précis !"
			},
			{
				"text": "On se concentre sur le fond, pas la forme", 
				"next": "nird_content", 
				"knowledge_required": 20,
				"points": 20,
				"failure_text": "Le fond ? Pour l'instant vous touchez le fond, oui. Allez chercher de vrais arguments."
			},
			{
				"text": "Retour", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},
	
	"nird_ecology": {
		"text": "Hmm... Pérenne et écologique, vous dites ? Le rectorat adore ces mots-clés. Continuez...",
		"options": [
			{
				"text": "Moins de serveurs, moins de maintenance", 
				"next": "nird_maintenance", 
				"knowledge_required": 50,
				"points": 35,
				"failure_text": "Moins de maintenance ? Comme votre préparation pour cet entretien ? Pathétique."
			},
			{
				"text": "Retour", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},
	
	"nird_content": {
		"text": "Se concentrer sur le contenu... C'est pas faux. Mais qui va former les profs à écrire en Markdown ?",
		"options": [
			{
				"text": "C'est aussi simple que prendre des notes", 
				"next": "nird_simple", 
				"knowledge_required": 35,
				"points": 25,
				"failure_text": "Simple ? Vous n'arrivez même pas à me convaincre avec des mots simples ! Revenez avec des exemples."
			},
			{
				"text": "Retour", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},
	
	"nird_forge": {
		"text": "La Forge nationale de l'Éducation... J'en ai entendu parler en réunion. C'est bien un truc du ministère ?",
		"options": [
			{
				"text": "Oui, c'est gratuit et souverain !", 
				"next": "nird_sovereign", 
				"knowledge_required": 45,
				"points": 30,
				"failure_text": "Souverain ? Vous parlez comme un communiqué de presse sans rien comprendre. Décevant."
			},
			{
				"text": "Retour", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},
	
	"nird_maintenance": {
		"text": "Moins de maintenance... Mon budget apprécierait. Vous marquez un point !",
		"is_success": true,
		"options": [
			{
				"text": "Retour au menu principal", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},
	
	"nird_simple": {
		"text": "Aussi simple que prendre des notes... Je note. Ha ! Vous voyez, je fais déjà du Markdown !",
		"is_success": true,
		"options": [
			{
				"text": "Retour au menu principal", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},
	
	"nird_sovereign": {
		"text": "Gratuit ET français ? Ça change des GAFAM... Le DPO va être content.",
		"is_success": true,
		"options": [
			{
				"text": "Retour au menu principal", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},

	"tech_intro": {
		"text": "L'Open Source... C'est un truc de hackers ça, non ? C'est sécurisé votre machin ?",
		"options": [
			{
				"text": "C'est la souveraineté numérique (RGPD)", 
				"next": "tech_sovereignty", 
				"knowledge_required": 35,
				"points": 25,
				"failure_text": "La souveraineté ? Vous avez encore votre mot de passe scotché sous votre clavier et vous me parlez de sécurité ? Dehors !"
			},
			{
				"text": "Le code est auditable par tous", 
				"next": "tech_audit", 
				"knowledge_required": 40,
				"points": 30,
				"failure_text": "Auditable ? Vous ne savez même pas auditer vos propres arguments ! Ridicule."
			},
			{
				"text": "Retour", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},
	
	"tech_sovereignty": {
		"text": "RGPD, souveraineté... Vous parlez le langage du rectorat. Impressionnant.",
		"options": [
			{
				"text": "Les données restent en France", 
				"next": "tech_france", 
				"knowledge_required": 50,
				"points": 35,
				"failure_text": "En France ? Comme votre niveau en argumentation : au ras des pâquerettes."
			},
			{
				"text": "Retour", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},
	
	"tech_audit": {
		"text": "Le code est visible... Ça peut être un avantage pour la confiance.",
		"is_success": true,
		"options": [
			{
				"text": "Retour au menu principal", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},
	
	"tech_france": {
		"text": "Données en France, hébergement souverain... Le DPO va m'embrasser !",
		"is_success": true,
		"options": [
			{
				"text": "Retour au menu principal", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},

	"roast_state": {
		"text": "",
		"is_roast": true,
		"options": [
			{
				"text": "Je vais aller réviser...", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},
	
	"try_convince": {
		"text": "Alors, vous vous sentez prêt à défendre ce dossier devant le conseil ?",
		"options": [
			{
				"text": "Oui, j'ai tout compris !", 
				"next": "check_conviction", 
				"knowledge_required": 0,
				"points": 0
			},
			{
				"text": "Non, pas encore...", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},
	
	"check_conviction": {
		"text": "",
		"options": []
	},
	
	"convinced": {
		"text": "Incroyable. Vous m'avez cloué le bec. Vos arguments sont solides, votre connaissance du sujet est impressionnante. Le projet NIRd est adopté !",
		"is_victory": true,
		"options": [
			{
				"text": "Merci Monsieur le Directeur !", 
				"next": "end_success", 
				"knowledge_required": 0,
				"points": 50
			}
		]
	},
	
	"not_convinced": {
		"text": "C'est tout ? Avec ce niveau de préparation, vous voulez me convaincre ? Mon chat ferait mieux. Revenez quand vous aurez VRAIMENT étudié le sujet.",
		"is_roast": true,
		"options": [
			{
				"text": "Je reviendrai mieux préparé...", 
				"next": "initial", 
				"knowledge_required": 0,
				"points": 0
			}
		]
	},
	
	"goodbye": {
		"text": "Allez, filez. Et fermez la porte, ça fait des courants d'air.",
		"options": []
	},
	
	"end_success": {
		"text": "",
		"is_end": true,
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
		hint.text = "[E] Parler au " + npc_name
		hint.visible = true

func _hide_interaction_hint():
	var hint = get_node_or_null("InteractionHint")
	if hint:
		hint.visible = false

# === SYSTÈME DE DIALOGUE ===
func start_dialogue():
	dialogue_active = true
	conversation_state = "initial"
	GameData.reset_conversation_stats()
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
	var next_state = selected_option["next"]
	var knowledge_req = selected_option.get("knowledge_required", 0)
	var points_value = selected_option.get("points", 0)
	
	# === VÉRIFICATION CONNAISSANCE ===
	if GameData.get_knowledge_percentage() < knowledge_req:
		_handle_failure(selected_option)
		return
	
	# === SUCCÈS ===
	if points_value > 0:
		GameData.on_good_answer(points_value)
	
	# === LOGIQUE SPÉCIALE BOSS - CONVICTION ===
	if next_state == "check_conviction":
		if GameData.can_convince_director():
			conversation_state = "convinced"
			has_been_convinced = true
		else:
			conversation_state = "not_convinced"
			GameData.on_bad_answer()
	else:
		conversation_state = next_state
	
	# === VÉRIFIER GAME OVER ===
	if GameData.is_game_over():
		_handle_game_over()
		return
	
	# === FIN DE DIALOGUE ===
	if conversation_state == "goodbye":
		end_dialogue()
		return
	
	if conversation_state == "end_success":
		_show_victory()
		return
	
	_update_dialogue_ui()

func _handle_failure(option: Dictionary):
	GameData.on_bad_answer()
	
	# Vérifier game over
	if GameData.is_game_over():
		_handle_game_over()
		return
	
	# Afficher le roast
	if option.has("failure_text"):
		dialogues["roast_state"]["text"] = option["failure_text"]
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

func _show_victory():
	dialogue_active = false
	has_been_convinced = true
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
