extends CanvasLayer

var is_open = false
var just_opened = false
var is_destroyed = false
var computer_node = null  # Référence à l'objet Computer dans le jeu

func _ready():
	hide_computer()
	# Connecter le signal pour ouvrir le fichier
	$Control/Monitor/Screen/DesktopIcon.connect("file_opened", self, "_on_file_opened")
	$Control/Monitor/Screen/CmdIcon.connect("file_opened", self, "_on_cmd_opened")
	$Control/Monitor/Screen/CommandPrompt.connect("computer_deleted", self, "_on_computer_deleted")

func _on_file_opened():
	$Control/Monitor/Screen/Notepad.show_notepad("snake")

func _on_cmd_opened():
	$Control/Monitor/Screen/CommandPrompt.show_cmd()

func _on_computer_deleted():
	# Afficher l'écran bleu
	$Control/Monitor/Screen.visible = false
	$Control/Monitor/Taskbar.visible = false
	$Control/Monitor/BSOD.visible = true
	$Control/CloseHint.visible = false
	
	# Attendre 3 secondes puis détruire l'ordinateur
	yield(get_tree().create_timer(3.0), "timeout")
	is_destroyed = true
	
	# Désactiver le hint sur l'objet Computer
	if computer_node and is_instance_valid(computer_node):
		computer_node.set_destroyed(true)
	
	hide_computer()

func _input(event):
	if is_open:
		if just_opened:
			if event.is_action_released("interact"):
				just_opened = false
			return
		if event.is_action_pressed("ui_cancel") and not is_destroyed:
			hide_computer()
			get_tree().set_input_as_handled()

func show_computer(computer_ref = null):
	if is_destroyed:
		return  # L'ordinateur est détruit, on ne peut plus l'utiliser
	computer_node = computer_ref
	is_open = true
	just_opened = true
	$Control.visible = true
	$Control/Monitor/Screen.visible = true
	$Control/Monitor/Taskbar.visible = true
	$Control/Monitor/BSOD.visible = false
	$Control/CloseHint.visible = true
	get_tree().paused = true

func hide_computer():
	is_open = false
	$Control.visible = false
	# Fermer les fenêtres
	$Control/Monitor/Screen/Notepad.visible = false
	$Control/Monitor/Screen/CommandPrompt.visible = false
	get_tree().paused = false
