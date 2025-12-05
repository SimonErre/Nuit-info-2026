extends Area2D

# === GROUPE D'ÉLÈVES PRO-WINDOWS ===
# Un groupe de 3 élèves fans de Windows qui défient le joueur
# Très difficile à convaincre - ils font perdre des points facilement
# Mais peuvent donner un petit bonus si on a les bons arguments

var player_in_range = false
var is_talking = false
var current_dialogue_id = "start"
var dialogue_ui = null

var dialogues = {
	"start": {
		"text": "Eh toi ! Tu crois vraiment que Linux c'est mieux ? 😏\nWindows c'est la VIE. Tout marche dessus !",
		"options": [
			{"text": "Linux c'est gratuit et open source", "next": "libre_weak", "knowledge_required": 0, "points": 0},
			{"text": "Linux est plus sécurisé", "next": "security_weak", "knowledge_required": 0, "points": 0},
			{"text": "Expliquer la philosophie du libre", "next": "libre_strong", "knowledge_required": 40, "points": 10},
			{"text": "Parler de la souveraineté numérique", "next": "sovereignty", "knowledge_required": 60, "points": 15},
			{"text": "Partir...", "next": "leave", "knowledge_required": 0, "points": 0}
		]
	},
	"libre_weak": {
		"text": "Gratuit ? 🤣 Mon Windows cracké aussi il est gratuit !\nEt l'open source ça veut dire que c'est fait par des amateurs.",
		"failure_text": "T'as vraiment que ça comme argument ?",
		"options": [
			{"text": "L'open source permet l'audit du code", "next": "audit", "knowledge_required": 30, "points": 5},
			{"text": "Les serveurs du monde tournent sur Linux", "next": "servers", "knowledge_required": 50, "points": 10},
			{"text": "Abandonner ce débat", "next": "leave_defeated", "knowledge_required": 0, "points": -3}
		]
	},
	"security_weak": {
		"text": "Sécurisé ? 😂 Personne utilise Linux donc personne fait de virus !\nC'est pas de la sécurité, c'est de l'obscurité !",
		"failure_text": "Argument de noob...",
		"options": [
			{"text": "Architecture Unix = meilleure gestion des droits", "next": "architecture", "knowledge_required": 45, "points": 8},
			{"text": "Les datacenters utilisent Linux", "next": "servers", "knowledge_required": 50, "points": 10},
			{"text": "Laisser tomber...", "next": "leave_defeated", "knowledge_required": 0, "points": -3}
		]
	},
	"libre_strong": {
		"text": "Hmm... Le logiciel libre c'est une philosophie ?\nOk mais concrètement ça change quoi pour MOI ?",
		"is_success": true,
		"options": [
			{"text": "Contrôle total sur tes données", "next": "data_control", "knowledge_required": 35, "points": 8},
			{"text": "Pas de télémétrie intrusive", "next": "telemetry", "knowledge_required": 40, "points": 10},
			{"text": "C'est un choix éthique", "next": "ethics_weak", "knowledge_required": 0, "points": 0}
		]
	},
	"sovereignty": {
		"text": "Souveraineté numérique ? 🤔\nAttends, tu parles des trucs genre RGPD là ?",
		"is_success": true,
		"options": [
			{"text": "Oui, et aussi l'indépendance technologique", "next": "independence", "knowledge_required": 50, "points": 12},
			{"text": "Expliquer les enjeux géopolitiques", "next": "geopolitics", "knowledge_required": 70, "points": 20},
			{"text": "Euh... c'est compliqué", "next": "complicated_fail", "knowledge_required": 0, "points": -2}
		]
	},
	"audit": {
		"text": "Ok l'audit du code... Mais qui va vraiment lire des millions de lignes ?",
		"options": [
			{"text": "La communauté et les experts en sécu", "next": "community", "knowledge_required": 40, "points": 8},
			{"text": "Bonne question...", "next": "good_question_fail", "knowledge_required": 0, "points": -2}
		]
	},
	"servers": {
		"text": "C'est vrai que les serveurs... Même ceux de Microsoft Azure tournent sur Linux... 😅",
		"is_success": true,
		"options": [
			{"text": "Exactement ! Même eux font confiance à Linux", "next": "victory_partial", "knowledge_required": 0, "points": 10},
			{"text": "Android aussi c'est Linux", "next": "android", "knowledge_required": 30, "points": 8}
		]
	},
	"architecture": {
		"text": "Mouais, la gestion des droits Unix c'est peut-être mieux sur le papier...\nMais Windows 11 a fait des progrès !",
		"options": [
			{"text": "Des progrès inspirés de Linux justement", "next": "inspired", "knowledge_required": 55, "points": 12},
			{"text": "C'est pas faux...", "next": "concede_fail", "knowledge_required": 0, "points": -2}
		]
	},
	"data_control": {
		"text": "Le contrôle des données... Ouais c'est vrai que Windows envoie beaucoup de télémétrie...",
		"is_success": true,
		"options": [
			{"text": "Avec Linux, TU décides ce qui sort de ta machine", "next": "victory_partial", "knowledge_required": 0, "points": 8}
		]
	},
	"telemetry": {
		"text": "La télémétrie de Windows... J'avoue que ça me gonfle aussi.\nMais désactiver tout c'est galère !",
		"is_success": true,
		"options": [
			{"text": "Sur Linux c'est désactivé par défaut", "next": "victory_partial", "knowledge_required": 0, "points": 10}
		]
	},
	"ethics_weak": {
		"text": "L'éthique ? 🙄 On parle d'un OS là, pas de philosophie !\nT'es un peu intense non ?",
		"failure_text": "Ok le moralisateur...",
		"options": [
			{"text": "Revenir aux arguments techniques", "next": "start", "knowledge_required": 0, "points": 0},
			{"text": "Partir", "next": "leave", "knowledge_required": 0, "points": 0}
		]
	},
	"independence": {
		"text": "L'indépendance technologique... C'est vrai qu'on dépend beaucoup de Microsoft et Google...",
		"is_success": true,
		"options": [
			{"text": "Voilà ! Le libre c'est la liberté de choix", "next": "victory_good", "knowledge_required": 0, "points": 15}
		]
	},
	"geopolitics": {
		"text": "Wow... Les enjeux géopolitiques du numérique... 🤯\nJ'avais jamais vu ça comme ça. Tu m'as convaincu.",
		"is_victory": true,
		"options": [
			{"text": "Bienvenue du côté du libre ! 🐧", "next": "victory_total", "knowledge_required": 0, "points": 25}
		]
	},
	"complicated_fail": {
		"text": "C'est compliqué ? Bah alors pourquoi tu en parles ? 😏\nReviens quand t'auras des vrais arguments !",
		"is_roast": true,
		"failure_text": "Allez, dégage le pingouin !",
		"options": [
			{"text": "Partir...", "next": "leave_defeated", "knowledge_required": 0, "points": 0}
		]
	},
	"community": {
		"text": "Ok la communauté... C'est vrai que Linus Torvalds il gère.\nBon, peut-être que Linux c'est pas si mal... pour les serveurs.",
		"is_success": true,
		"options": [
			{"text": "Et pour le desktop aussi !", "next": "victory_partial", "knowledge_required": 0, "points": 8}
		]
	},
	"good_question_fail": {
		"text": "HA ! Tu vois que t'as pas de réponse ! 😂\nWindows > Linux, c'est prouvé !",
		"is_roast": true,
		"failure_text": "Échec et mat, le linuxien !",
		"options": [
			{"text": "Fuir ce débat perdu", "next": "leave_defeated", "knowledge_required": 0, "points": 0}
		]
	},
	"android": {
		"text": "Android c'est Linux ?! 😮\nAttends, mon téléphone tourne sur Linux ?!",
		"is_success": true,
		"options": [
			{"text": "Eh oui ! Linux est partout", "next": "victory_partial", "knowledge_required": 0, "points": 10}
		]
	},
	"inspired": {
		"text": "Les améliorations de Windows inspirées de Linux... 😳\nOk tu marques un point là.",
		"is_success": true,
		"options": [
			{"text": "Autant utiliser l'original non ?", "next": "victory_good", "knowledge_required": 0, "points": 15}
		]
	},
	"concede_fail": {
		"text": "AH ! Tu concèdes ! Windows a fait des progrès !\nMerci d'admettre notre supériorité ! 💪",
		"is_roast": true,
		"failure_text": "Linux fanboy DÉTRUIT par la LOGIQUE !",
		"options": [
			{"text": "S'en aller...", "next": "leave_defeated", "knowledge_required": 0, "points": 0}
		]
	},
	"leave": {
		"text": "Ouais c'est ça, fuis ! T'as pas d'arguments ! 😏",
		"options": []
	},
	"leave_defeated": {
		"text": "HAHA ! On a gagné les gars ! 🎉\nUn autre fanboy Linux mis KO !",
		"options": []
	},
	"victory_partial": {
		"text": "Bon ok... Linux c'est peut-être pas si mal.\nMais je garde Windows pour les jeux quand même ! 🎮",
		"is_success": true,
		"options": [
			{"text": "C'est un bon compromis !", "next": "end_good", "knowledge_required": 0, "points": 5}
		]
	},
	"victory_good": {
		"text": "Ok ok... Tu m'as convaincu sur certains points. 😅\nJe vais peut-être essayer une VM Linux...",
		"is_success": true,
		"options": [
			{"text": "C'est un bon début ! 🐧", "next": "end_great", "knowledge_required": 0, "points": 10}
		]
	},
	"victory_total": {
		"text": "🐧 Wow... Tu m'as complètement retourné le cerveau !\nJe vais installer Linux ce soir. Les gars, on switch !",
		"is_victory": true,
		"options": []
	},
	"end_good": {
		"text": "Allez, à plus le linuxien ! Pas mal tes arguments.\nMais la prochaine fois on sera prêts ! 💪",
		"options": []
	},
	"end_great": {
		"text": "Respect ! 👊 T'es le premier à nous tenir tête.\nOn reparlera quand on aura testé Linux !",
		"is_success": true,
		"options": []
	}
}

func _ready():
	add_to_group("npcs")
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		_show_interaction_hint()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		_hide_interaction_hint()

func _show_interaction_hint():
	var hint = get_node_or_null("InteractionHint")
	if hint:
		hint.text = "[E] Parler aux Fans de Windows"
		hint.visible = true

func _hide_interaction_hint():
	var hint = get_node_or_null("InteractionHint")
	if hint:
		hint.visible = false

func _input(event):
	if event.is_action_pressed("interact") and player_in_range and not is_talking:
		start_dialogue()

func start_dialogue():
	is_talking = true
	current_dialogue_id = "start"
	
	# Trouver le DialogueUI
	dialogue_ui = get_tree().get_nodes_in_group("dialogue_ui")[0] if get_tree().get_nodes_in_group("dialogue_ui").size() > 0 else null
	
	if dialogue_ui:
		show_current_dialogue()

func show_current_dialogue():
	var dialogue = dialogues[current_dialogue_id]
	dialogue_ui.show_dialogue(self, dialogue, "👥 Fans de Windows")
	
	# Appliquer le roast si c'est un échec
	if dialogue.get("is_roast", false):
		GameData.on_bad_answer()

func select_option(index: int):
	var dialogue = dialogues[current_dialogue_id]
	
	if index >= dialogue["options"].size():
		end_dialogue()
		return
	
	var option = dialogue["options"][index]
	var required = option.get("knowledge_required", 0)
	
	# Vérifier les connaissances requises
	if required > 0 and GameData.get_knowledge_percentage() < required:
		dialogue_ui.show_insufficient_knowledge(required)
		return
	
	# Appliquer les points
	var points = option.get("points", 0)
	if points != 0:
		if points > 0:
			GameData.on_good_answer(points)
		else:
			GameData.on_bad_answer()
	
	# Passer au dialogue suivant
	var next_id = option.get("next", "")
	if next_id == "" or not dialogues.has(next_id):
		end_dialogue()
		return
	
	current_dialogue_id = next_id
	var next_dialogue = dialogues[current_dialogue_id]
	
	# Vérifier si c'est une fin
	if next_dialogue["options"].size() == 0:
		dialogue_ui.show_dialogue(self, next_dialogue, "👥 Fans de Windows")
		yield(get_tree().create_timer(2.5), "timeout")
		end_dialogue()
		return
	
	show_current_dialogue()

func end_dialogue():
	is_talking = false
	current_dialogue_id = "start"
	if dialogue_ui:
		dialogue_ui.hide_dialogue()
