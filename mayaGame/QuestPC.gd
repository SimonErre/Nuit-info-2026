# QuestPC.gd - PC dédié à la quête de reconditionnement (étapes 1 et 2)
extends Area2D

var player_nearby = false
var is_collected = false  # Si le PC a été récupéré pour la quête

func _ready():
	add_to_group("quest_objects")
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_nearby = true
		_update_hint()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_nearby = false
		if has_node("InteractLabel"):
			$InteractLabel.visible = false

func _input(event):
	if player_nearby and event.is_action_pressed("interact"):
		_handle_interaction()

func _update_hint():
	if not has_node("InteractLabel"):
		return
	
	if not GameData.recondition_quest_active:
		$InteractLabel.text = "[E] Examiner"
		$InteractLabel.visible = true
		return
	
	var current_step = GameData.get_current_recondition_step()
	match current_step:
		"step_collect_pc":
			$InteractLabel.text = "[E] 📦 Récupérer le PC"
		"step_erase_data":
			$InteractLabel.text = "[E] 🔒 Effacer les données"
		_:
			$InteractLabel.text = "[E] ✅ PC traité"
	
	$InteractLabel.visible = true

func _handle_interaction():
	if not GameData.recondition_quest_active:
		_show_no_quest_message()
		return
	
	var current_step = GameData.get_current_recondition_step()
	
	match current_step:
		"step_collect_pc":
			_collect_pc()
		"step_erase_data":
			_open_erase_ui()
		_:
			_show_already_done_message()

func _show_no_quest_message():
	# Afficher un message simple
	var ui = _get_or_create_quest_pc_ui()
	ui.show_message("Vieux PC", "Ce PC semble hors d'usage... Peut-être que quelqu'un pourrait t'apprendre à le reconditionner ?")

func _show_already_done_message():
	var ui = _get_or_create_quest_pc_ui()
	ui.show_message("PC en cours de traitement", "Tu as déjà effectué les premières étapes sur ce PC !")

func _collect_pc():
	GameData.complete_recondition_step("step_collect_pc")
	var ui = _get_or_create_quest_pc_ui()
	ui.show_message("✅ PC Récupéré !", "Tu as récupéré le vieux PC !\n\nRetourne voir l'Élève Écolo pour la prochaine étape.")
	is_collected = true
	_update_hint()

func _open_erase_ui():
	var ui = _get_or_create_quest_pc_ui()
	ui.show_erase_data()

func _get_or_create_quest_pc_ui():
	var ui = get_tree().get_root().get_node_or_null("QuestPCUI")
	if ui == null:
		var UIScene = load("res://QuestPCUI.tscn")
		ui = UIScene.instance()
		get_tree().get_root().add_child(ui)
	return ui
