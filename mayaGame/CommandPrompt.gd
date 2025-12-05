extends Panel

var dragging = false
var resizing = false
var drag_offset = Vector2()
var command_history = []
var current_path = "C:\\Users\\Admin"
var computer_destroyed = false

const MIN_SIZE = Vector2(250, 150)

signal computer_deleted
signal linux_install_started

func _ready():
	$TitleBar/CloseButton.connect("pressed", self, "_on_close")
	$TitleBar.connect("gui_input", self, "_on_TitleBar_gui_input")
	$InputLine/CommandInput.connect("text_entered", self, "_on_command_entered")
	$ResizeHandle.connect("gui_input", self, "_on_ResizeHandle_gui_input")

func _on_close():
	visible = false

func _on_TitleBar_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = $TitleBar.get_local_mouse_position()
			else:
				dragging = false

func _on_ResizeHandle_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				resizing = true
			else:
				resizing = false

func _process(_delta):
	if not visible:
		return
	
	var screen = get_parent()
	
	if dragging:
		var new_pos = screen.get_local_mouse_position() - drag_offset
		var min_pos = Vector2(0, 0)
		var max_pos = screen.rect_size - rect_size
		new_pos.x = clamp(new_pos.x, min_pos.x, max_pos.x)
		new_pos.y = clamp(new_pos.y, min_pos.y, max_pos.y)
		rect_position = new_pos
	
	if resizing:
		var mouse_pos = screen.get_local_mouse_position()
		var new_size = mouse_pos - rect_position
		# Appliquer la taille minimum
		new_size.x = max(new_size.x, MIN_SIZE.x)
		new_size.y = max(new_size.y, MIN_SIZE.y)
		# Ne pas dépasser l'écran
		var max_size = screen.rect_size - rect_position
		new_size.x = min(new_size.x, max_size.x)
		new_size.y = min(new_size.y, max_size.y)
		rect_size = new_size

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			dragging = false
			resizing = false

func _on_command_entered(command):
	var cmd = command.strip_edges().to_lower()
	
	if cmd == "":
		$InputLine/CommandInput.text = ""
		return
	
	# Ajouter la commande à l'historique
	command_history.append(current_path + "> " + command)
	
	# Traiter la commande
	var response = process_command(cmd, command)
	if response != "":
		command_history.append(response)
	
	update_output()
	$InputLine/CommandInput.text = ""

func process_command(cmd_lower, cmd_original):
	# Commande d'installation Linux
	if cmd_lower == "wsl --install" or cmd_lower == "install linux" or cmd_lower == "wsl --install -d ubuntu":
		# Bloquer l'installation si la quête est active et que l'effacement n'est pas fait
		if GameData.recondition_quest_active and not GameData.is_recondition_step_done("step_erase_data"):
			return "⚠️ ERREUR: Impossible d'installer Linux.\n\nLes données personnelles doivent d'abord être effacées\npour respecter le RGPD.\n\nUtilisez le panneau 'Effacer les données' avant d'installer."
		emit_signal("linux_install_started")
		return "Installation de Linux en cours..."
	
	# Commande de suppression totale
	if cmd_lower.find("rm -rf") != -1 or cmd_lower.find("rm -r") != -1 or cmd_lower.find("del /f /s /q") != -1 or cmd_lower.find("format c:") != -1 or cmd_lower.find("rd /s /q") != -1:
		computer_destroyed = true
		emit_signal("computer_deleted")
		return "Suppression en cours...\nERREUR FATALE: Système corrompu.\n[ÉCRAN BLEU DE LA MORT]"
	
	# Commande dir
	if cmd_lower == "dir" or cmd_lower.begins_with("dir "):
		return get_fake_dir()
	
	# Commande ls (linux)
	if cmd_lower == "ls" or cmd_lower.begins_with("ls "):
		return get_fake_dir()
	
	# Commande cd
	if cmd_lower.begins_with("cd "):
		var path = cmd_original.substr(3).strip_edges()
		if path == ".." or path == "\\":
			return ""
		return "Accès refusé à '" + path + "'.\nVous n'avez pas les permissions nécessaires."
	
	# Commande help
	if cmd_lower == "help":
		return "Commandes disponibles:\n  dir          - Affiche le contenu du répertoire\n  cd           - Change de répertoire\n  help         - Affiche cette aide\n  cls          - Efface l'écran\n  wsl --install - Installe Linux (Ubuntu)"
	
	# Commande cls (clear screen)
	if cmd_lower == "cls" or cmd_lower == "clear":
		command_history.clear()
		return ""
	
	# Commande inconnue
	return "'" + cmd_original.split(" ")[0] + "' n'est pas reconnu en tant que commande interne\nou externe, un programme exécutable ou un fichier de commandes."

func get_fake_dir():
	var fake_files = [
		" Répertoire de " + current_path + "\n",
		"",
		"05/12/2025  09:14    <DIR>          .",
		"05/12/2025  09:14    <DIR>          ..",
		"03/11/2025  14:22    <DIR>          Documents",
		"28/10/2025  08:45    <DIR>          Downloads",
		"15/09/2025  16:33             2 048 notes.txt",
		"22/11/2025  11:17            15 360 rapport.docx",
		"01/12/2025  19:44    <DIR>          secrets",
		"04/12/2025  23:59               666 mysterieux.dat",
		"               3 fichier(s)           18 074 octets",
		"               5 Rép(s)  127 458 304 000 octets libres"
	]
	return PoolStringArray(fake_files).join("\n")

func update_output():
	var output_text = "Microsoft Windows [Version 10.0.19045]\n(c) Microsoft Corporation. Tous droits réservés.\n\n"
	for cmd in command_history:
		output_text += cmd + "\n"
	$Content/ScrollContainer/VBox/OutputText.text = output_text
	
	# Scroll vers le bas automatiquement
	yield(get_tree(), "idle_frame")
	var scroll = $Content/ScrollContainer
	scroll.scroll_vertical = scroll.get_v_scrollbar().max_value
	
	# Mettre à jour le prompt
	$InputLine/Prompt.text = current_path + ">"

func show_cmd():
	visible = true
	computer_destroyed = false
	command_history = []
	current_path = "C:\\Users\\Admin"
	update_output()
	$InputLine/CommandInput.text = ""
	$InputLine/CommandInput.grab_focus()
