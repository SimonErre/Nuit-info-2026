# AdminSys.gd - PNJ qui enseigne la Forge et le RGPD
extends Area2D

signal dialogue_started
signal dialogue_ended

var npc_name = "Admin Système"
var npc_id = "admin_sys"

var is_player_nearby: bool = false
var dialogue_active: bool = false
var conversation_state: String = "initial"
var has_taught_forge: bool = false
var has_taught_rgpd: bool = false

var dialogues: Dictionary = {}

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	_setup_dialogues()

func _setup_dialogues():
	dialogues = {
		"initial": {
			"text": "*tape furieusement sur son clavier* Ah salut ! Tu tombes bien, je suis en train de migrer nos serveurs vers la Forge nationale !",
			"options": [
				{"text": "C'est quoi la Forge nationale ?", "next": "explain_forge", "knowledge_required": 0},
				{"text": "Et le RGPD dans tout ça ?", "next": "explain_rgpd", "knowledge_required": 0},
				{"text": "Je vous laisse travailler", "next": "goodbye", "knowledge_required": 0}
			]
		},
		
		"explain_forge": {
			"text": "La Forge nationale de l'Éducation, c'est comme GitHub mais hébergé par le ministère ! On peut y stocker notre code, nos sites, tout en restant souverain.",
			"options": [
				{"text": "C'est gratuit ?", "next": "forge_gratuit", "knowledge_required": 0},
				{"text": "Pourquoi pas GitHub ?", "next": "forge_vs_github", "knowledge_required": 0}
			]
		},
		
		"forge_gratuit": {
			"text": "Totalement gratuit pour les établissements scolaires ! Et c'est français, donc nos données restent en France. Le rectorat adore ça.",
			"is_success": true,
			"options": [
				{"text": "Super, merci pour l'info !", "next": "learn_forge", "knowledge_required": 0}
			]
		},
		
		"forge_vs_github": {
			"text": "GitHub c'est américain, donc soumis au Cloud Act. Nos données d'élèves pourraient être consultées par les autorités US. La Forge, c'est 100% français et conforme au RGPD !",
			"is_success": true,
			"options": [
				{"text": "Je comprends l'enjeu maintenant !", "next": "learn_forge", "knowledge_required": 0}
			]
		},
		
		"learn_forge": {
			"text": "Tu as pigé le concept ! La Forge, c'est la souveraineté numérique en action. 📚 +15 connaissance, sujet Forge débloqué !",
			"is_success": true,
			"is_reward_forge": true,
			"options": [
				{"text": "Et le RGPD alors ?", "next": "explain_rgpd", "knowledge_required": 0},
				{"text": "Merci, je file !", "next": "goodbye_happy", "knowledge_required": 0}
			]
		},
		
		"explain_rgpd": {
			"text": "Ah le RGPD ! Le Règlement Général sur la Protection des Données. En gros, on doit protéger les données personnelles des élèves et des profs.",
			"options": [
				{"text": "Concrètement, ça change quoi ?", "next": "rgpd_concret", "knowledge_required": 0},
				{"text": "Retour", "next": "initial", "knowledge_required": 0}
			]
		},
		
		"rgpd_concret": {
			"text": "On ne peut plus utiliser n'importe quel service américain ! Google, Microsoft... tout doit être validé ou remplacé par des alternatives souveraines. La Forge et NIRd sont parfaits pour ça !",
			"is_success": true,
			"options": [
				{"text": "C'est logique !", "next": "learn_rgpd", "knowledge_required": 0}
			]
		},
		
		"learn_rgpd": {
			"text": "Exactement ! Tu comprends pourquoi NIRd est important pour la conformité. 📚 +15 connaissance, sujet RGPD débloqué !",
			"is_success": true,
			"is_reward_rgpd": true,
			"options": [
				{"text": "Merci pour ces explications !", "next": "goodbye_happy", "knowledge_required": 0}
			]
		},
		
		"goodbye_happy": {
			"text": "*retourne à son clavier* Pas de quoi ! Et si tu croises le directeur, dis-lui que la migration avance bien !",
			"options": []
		},
		
		"already_taught": {
			"text": "*occupé à compiler* Tu connais déjà la Forge et le RGPD, non ? Va voir d'autres collègues !",
			"options": [
				{"text": "C'est quoi la Forge nationale ?", "next": "explain_forge", "knowledge_required": 0},
				{"text": "Et le RGPD ?", "next": "explain_rgpd", "knowledge_required": 0},
				{"text": "Je vous laisse", "next": "goodbye", "knowledge_required": 0}
			]
		},
		
		"goodbye": {
			"text": "*grommelle* Ouais ouais, à plus...",
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
	has_taught_forge = GameData.has_topic("forge")
	has_taught_rgpd = GameData.has_topic("rgpd")
	
	if has_taught_forge and has_taught_rgpd:
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
	if dialogues[conversation_state].get("is_reward_forge", false) and not has_taught_forge:
		has_taught_forge = true
		GameData.add_knowledge(15, "forge")
		GameData.change_mood(8)
	
	if dialogues[conversation_state].get("is_reward_rgpd", false) and not has_taught_rgpd:
		has_taught_rgpd = true
		GameData.add_knowledge(15, "rgpd")
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
