extends Area2D

var player_nearby = false
var is_cleaned = false  # Si le PC a été nettoyé

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_nearby = true
		show_interact_hint(true)

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_nearby = false
		show_interact_hint(false)

func _input(event):
	if player_nearby and event.is_action_pressed("interact"):
		# Si quête active et étape "réparer", ouvrir le mini-jeu
		if GameData.recondition_quest_active and GameData.get_current_recondition_step() == "step_repair":
			open_cleaning_game()
		else:
			show_bsod()

func show_interact_hint(show):
	if has_node("InteractLabel"):
		# Changer le texte selon le contexte
		if show:
			if GameData.recondition_quest_active and GameData.get_current_recondition_step() == "step_repair":
				$InteractLabel.text = "[E] 🔧 Nettoyer le PC"
			else:
				$InteractLabel.text = "[E] Utiliser"
		$InteractLabel.visible = show

func show_bsod():
	var bsod_ui = get_tree().get_root().get_node_or_null("ObsoletePCUI")
	if bsod_ui == null:
		var BSODScene = load("res://ObsoletePCUI.tscn")
		bsod_ui = BSODScene.instance()
		get_tree().get_root().add_child(bsod_ui)
	
	bsod_ui.show_bsod()

func open_cleaning_game():
	var cleaning_ui = get_tree().get_root().get_node_or_null("DustCleaningUI")
	if cleaning_ui == null:
		var CleaningScene = load("res://DustCleaningUI.tscn")
		cleaning_ui = CleaningScene.instance()
		get_tree().get_root().add_child(cleaning_ui)
		# Connecter le signal de fin
		cleaning_ui.connect("cleaning_completed", self, "_on_cleaning_completed")
	
	cleaning_ui.show_cleaning()

func _on_cleaning_completed():
	is_cleaned = true
	# Mettre à jour le hint
	if has_node("InteractLabel"):
		$InteractLabel.text = "[E] ✅ PC nettoyé !"
