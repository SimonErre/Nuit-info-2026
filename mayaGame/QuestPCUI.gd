# QuestPCUI.gd - Interface pour le PC de quête (récupération et effacement)
extends CanvasLayer

var is_open = false
var just_opened = false
var is_erasing = false

func _ready():
	$Control.visible = false
	pause_mode = Node.PAUSE_MODE_PROCESS

func show_message(title: String, message: String):
	is_open = true
	just_opened = true
	$Control.visible = true
	$Control/Panel/Title.text = title
	$Control/Panel/Message.text = message
	$Control/Panel/ErasePanel.visible = false
	$Control/Panel/MessagePanel.visible = true
	get_tree().paused = true

func show_erase_data():
	is_open = true
	just_opened = true
	is_erasing = false
	$Control.visible = true
	$Control/Panel/Title.text = "🔒 Effacement Sécurisé"
	$Control/Panel/MessagePanel.visible = false
	$Control/Panel/ErasePanel.visible = true
	$Control/Panel/ErasePanel/ProgressBar.value = 0
	$Control/Panel/ErasePanel/StatusLabel.text = "Prêt à effacer les données..."
	$Control/Panel/ErasePanel/StartButton.visible = true
	$Control/Panel/ErasePanel/StartButton.disabled = false
	get_tree().paused = true

func _on_StartButton_pressed():
	if is_erasing:
		return
	is_erasing = true
	$Control/Panel/ErasePanel/StartButton.disabled = true
	_run_erase_animation()

func _run_erase_animation():
	var progress_bar = $Control/Panel/ErasePanel/ProgressBar
	var status_label = $Control/Panel/ErasePanel/StatusLabel
	
	var steps = [
		{"percent": 10, "text": "🔍 Analyse des partitions..."},
		{"percent": 25, "text": "🗑️ Suppression des fichiers utilisateur..."},
		{"percent": 40, "text": "🔐 Effacement des mots de passe..."},
		{"percent": 55, "text": "📧 Nettoyage des emails et historique..."},
		{"percent": 70, "text": "🖼️ Suppression des photos et documents..."},
		{"percent": 85, "text": "🔄 Réécriture des secteurs..."},
		{"percent": 100, "text": "✅ Effacement terminé !"}
	]
	
	for step in steps:
		progress_bar.value = step.percent
		status_label.text = step.text
		yield(get_tree().create_timer(0.5), "timeout")
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Compléter l'étape
	GameData.complete_recondition_step("step_erase_data")
	
	# Afficher message de succès
	$Control/Panel/ErasePanel/StartButton.visible = false
	status_label.text = "✅ Données effacées de manière sécurisée !\n\nRetourne voir l'Élève Écolo !"
	status_label.add_color_override("font_color", Color(0.5, 1.0, 0.5))
	
	is_erasing = false

func _input(event):
	if not is_open:
		return
	
	if just_opened:
		if event.is_action_released("interact"):
			just_opened = false
		return
	
	if is_erasing:
		return  # Ne pas fermer pendant l'effacement
	
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact"):
		close_ui()
		get_tree().set_input_as_handled()

func _on_CloseButton_pressed():
	if not is_erasing:
		close_ui()

func close_ui():
	is_open = false
	$Control.visible = false
	get_tree().paused = false
