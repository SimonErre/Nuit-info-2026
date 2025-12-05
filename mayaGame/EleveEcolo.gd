# EleveEcolo.gd - PNJ étudiant passionné d'écologie numérique
# QUÊTE DE RECONDITIONNEMENT - Multi-étapes à travers la map
extends Area2D

signal dialogue_started
signal dialogue_ended

var npc_name = "🌱 Élève Écolo"
var npc_id = "eleve_ecolo"

var is_player_nearby: bool = false
var dialogue_active: bool = false
var conversation_state: String = "initial"
var has_taught_ecology: bool = false
var has_taught_sovereignty: bool = false

var dialogues: Dictionary = {}

func _ready():
	add_to_group("npcs")
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	_setup_dialogues()

func _setup_dialogues():
	dialogues = {
		# === INTRODUCTION ===
		"initial": {
			"text": "*en train de coller des stickers 'Free Software'* Oh salut ! Tu savais que le numérique pollue autant que l'aviation ? 🌍",
			"options": [
				{"text": "T'as pas un truc à faire ?", "next": "propose_quest", "knowledge_required": 0},
				{"text": "Je passais juste...", "next": "goodbye", "knowledge_required": 0}
			]
		},
		
		"learn_ecology": {
			"text": "Bienvenue dans la team green IT ! 🌱\n\n📚 +15 connaissance\n🎓 Sujet Écologie débloqué !",
			"is_success": true,
			"is_reward_ecology": true,
			"options": [
				{"text": "Tu parlais de reconditionnement ?", "next": "propose_quest", "knowledge_required": 0},
				{"text": "C'est quoi ces stickers Free Software ?", "next": "explain_opensource", "knowledge_required": 0},
				{"text": "Merci pour les infos !", "next": "goodbye_happy", "knowledge_required": 0}
			]
		},
		
		"propose_quest": {
			"text": "Le reconditionnement ? C'est donner une seconde vie aux vieux PC ! On les nettoie, on efface les données, on installe Linux... Et hop, un PC comme neuf pour ceux qui en ont besoin ! 🖥️♻️",
			"options": [
				{"text": "Ça a l'air cool ! Je peux aider ?", "next": "quest_accept", "knowledge_required": 0},
				{"text": "C'est quoi les avantages ?", "next": "quest_benefits", "knowledge_required": 0},
				{"text": "Pas maintenant...", "next": "goodbye", "knowledge_required": 0}
			]
		},
		
		"quest_benefits": {
			"text": "🌍 C'est INCLUSIF : tous les élèves peuvent participer, apprendre en faisant !\n🎓 C'est RESPONSABLE : on apprend l'éthique, la protection des données\n♻️ C'est DURABLE : moins de déchets, plus de solidarité !",
			"is_success": true,
			"options": [
				{"text": "OK je suis convaincu ! On fait comment ?", "next": "quest_accept", "knowledge_required": 0},
				{"text": "Intéressant mais pas maintenant", "next": "goodbye", "knowledge_required": 0}
			]
		},
		
		"quest_accept": {
			"text": "Génial ! 🎉 Voici ta mission de reconditionnement :\n\n📋 ÉTAPE 1/4 : Récupérer un vieux PC\n➡️ Va à l'ordinateur dans la salle informatique !",
			"is_success": true,
			"is_quest_start": true,
			"options": [
				{"text": "C'est parti ! 💪", "next": "quest_started", "knowledge_required": 0}
			]
		},
		
		"quest_started": {
			"text": "*te donne une checklist* Bonne chance ! Reviens me voir quand tu auras fini toutes les étapes. Chaque PC sauvé = un déchet en moins ! 🌱",
			"options": []
		},
		
		# === RETOURS PENDANT LA QUÊTE ===
		"quest_progress_1": {
			"text": "Tu as récupéré le PC ? Super ! 💻\n\n📋 ÉTAPE 2/4 : Effacer les données\n➡️ Retourne à l'ordinateur et lance l'effacement sécurisé !\n\n⚠️ C'est crucial pour protéger la vie privée !",
			"options": [
				{"text": "J'y vais !", "next": "goodbye_quest", "knowledge_required": 0},
				{"text": "Pourquoi c'est important ?", "next": "explain_data_erase", "knowledge_required": 0}
			]
		},
		
		"explain_data_erase": {
			"text": "L'effacement sécurisé garantit que PERSONNE ne peut récupérer les anciennes données. Photos, mots de passe, documents... C'est une question d'éthique et de RGPD ! 🔒",
			"is_success": true,
			"options": [
				{"text": "Compris, j'y vais !", "next": "goodbye_quest", "knowledge_required": 0}
			]
		},
		
		"quest_progress_2": {
			"text": "Données effacées ? Parfait ! 🔒\n\n📋 ÉTAPE 3/4 : Nettoyer et réparer le PC\n➡️ Va sur un VIEUX PC dans la salle en haut a gauche pour le dépoussiérer !",
			"options": [
				{"text": "Je m'en occupe !", "next": "goodbye_quest", "knowledge_required": 0},
				{"text": "Qu'est-ce qu'il faut faire ?", "next": "explain_repair", "knowledge_required": 0}
			]
		},
		
		"explain_repair": {
			"text": "Le nettoyage c'est :\n🧹 Dépoussiérer l'intérieur\n🔧 Vérifier les composants\n💾 Tester la RAM et le disque\n🌡️ Changer la pâte thermique si besoin\n\nUn PC propre = un PC qui dure !",
			"is_success": true,
			"options": [
				{"text": "OK, je vais nettoyer !", "next": "goodbye_quest", "knowledge_required": 0}
			]
		},
		
		"quest_progress_3": {
			"text": "PC nettoyé et réparé ! 🔧\n\n📋 ÉTAPE 4/4 : Livrer le PC !\n➡️ Reviens me voir pour finaliser !",
			"options": [
				{"text": "Je suis prêt pour la livraison !", "next": "quest_complete", "knowledge_required": 0}
			]
		},
		
		# === QUÊTE TERMINÉE ===
		"quest_complete": {
			"text": "🎉 INCROYABLE ! Tu as reconditionné ton premier PC !\n\nCe PC va maintenant aider une famille qui n'avait pas les moyens d'en acheter un neuf. Tu as fait une vraie différence ! 🌍💚",
			"is_success": true,
			"is_quest_complete": true,
			"options": [
				{"text": "C'était une super expérience !", "next": "quest_reward", "knowledge_required": 0}
			]
		},
		
		"quest_reward": {
			"text": "Tu as appris :\n✓ L'importance du réemploi\n✓ La protection des données (RGPD)\n✓ La maintenance matérielle\n\n📚 +20 connaissance !\n🎓 Sujet Reconditionnement débloqué !\n❤️ +10 moral !\n\n*te donne un sticker '♻️ I reconditioned a PC'*",
			"is_success": true,
			"is_reward_reconditioning": true,
			"options": [
				{"text": "Merci pour tout ! 🌱", "next": "post_quest", "knowledge_required": 0}
			]
		},
		
		"post_quest": {
			"text": "*fier* Tu fais maintenant partie du mouvement ! Chaque PC sauvé = moins de déchets + plus de solidarité. Continue à répandre les valeurs du libre ! ✊🐧",
			"options": []
		},
		
		# === DIALOGUES APRÈS QUÊTE ===
		"quest_already_done": {
			"text": "*admirant ton sticker* Ah, un vrai reconditionneur ! 🌱 Tu veux qu'on reparle d'écologie ou de souveraineté ?",
			"options": [
				{"text": "Parle-moi d'écologie numérique", "next": "explain_ecology", "knowledge_required": 0},
				{"text": "Parle-moi de souveraineté", "next": "explain_opensource", "knowledge_required": 0},
				{"text": "Je passais juste dire bonjour !", "next": "goodbye_happy", "knowledge_required": 0}
			]
		},
		
		# === GOODBYES ===
		"goodbye_happy": {
			"text": "*lève le poing* Power to the people ! Et bonne chance avec le directeur ! 🐧✊",
			"options": []
		},
		
		"goodbye_quest": {
			"text": "*t'encourage* Allez, tu peux le faire ! Je compte sur toi ! 💪🌱",
			"options": []
		},
		
		"goodbye": {
			"text": "*retourne à ses stickers* Salut ! Reviens si tu veux aider la planète ! 🌍",
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
		if GameData.recondition_quest_active and not GameData.recondition_quest_completed:
			hint.text = "[E] 🌱 Quête en cours..."
		else:
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
	
	# Déterminer l'état de conversation selon la quête
	if GameData.recondition_quest_completed:
		conversation_state = "quest_already_done"
	elif GameData.recondition_quest_active:
		# Vérifier l'étape actuelle de la quête
		var current_step = GameData.get_current_recondition_step()
		match current_step:
			"step_collect_pc":
				conversation_state = "quest_started"  # Rappel de l'étape 1
			"step_erase_data":
				conversation_state = "quest_progress_1"
			"step_repair":
				conversation_state = "quest_progress_2"
			"step_deliver":
				conversation_state = "quest_progress_3"
			"completed":
				conversation_state = "quest_complete"
			_:
				conversation_state = "initial"
	elif has_taught_ecology and has_taught_sovereignty:
		conversation_state = "propose_quest"  # Propose directement la quête
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
	
	# Vérifier le dialogue actuel pour les récompenses
	var next_dialogue = dialogues.get(conversation_state, {})
	
	# Récompense écologie
	if next_dialogue.get("is_reward_ecology", false) and not has_taught_ecology:
		has_taught_ecology = true
		GameData.add_knowledge(15, "ecology")
		GameData.change_mood(8)
	
	# Récompense souveraineté
	if next_dialogue.get("is_reward_sovereignty", false) and not has_taught_sovereignty:
		has_taught_sovereignty = true
		GameData.add_knowledge(15, "sovereignty")
		GameData.change_mood(8)
	
	# Démarrage de la quête
	if next_dialogue.get("is_quest_start", false):
		GameData.start_recondition_quest()
	
	# Récompense reconditionnement (fin de quête)
	if next_dialogue.get("is_reward_reconditioning", false) and not GameData.recondition_quest_completed:
		GameData.recondition_quest_completed = true
		GameData.add_knowledge(20, "reconditioning")
		GameData.change_mood(10)
	
	# Fin de dialogue
	if conversation_state in ["goodbye", "goodbye_happy", "goodbye_quest", "quest_started", "post_quest"]:
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
