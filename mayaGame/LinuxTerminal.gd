extends Panel

var dragging = false
var resizing = false
var drag_offset = Vector2()
var command_history = []
var current_path = "~"
var username = "user"

const MIN_SIZE = Vector2(250, 150)

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
		new_size.x = max(new_size.x, MIN_SIZE.x)
		new_size.y = max(new_size.y, MIN_SIZE.y)
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
	var cmd = command.strip_edges()
	
	if cmd == "":
		$InputLine/CommandInput.text = ""
		return
	
	command_history.append(username + "@linux:" + current_path + "$ " + command)
	
	var response = process_command(cmd.to_lower(), command)
	if response != "":
		command_history.append(response)
	
	update_output()
	$InputLine/CommandInput.text = ""

func process_command(cmd_lower, cmd_original):
	# Commande ls
	if cmd_lower == "ls" or cmd_lower.begins_with("ls "):
		return get_fake_ls()
	
	# Commande cd
	if cmd_lower.begins_with("cd "):
		var path = cmd_original.substr(3).strip_edges()
		if path == "~" or path == "":
			current_path = "~"
			return ""
		elif path == "..":
			if current_path != "~":
				current_path = "~"
			return ""
		else:
			return "bash: cd: " + path + ": Permission denied"
	
	# Commande pwd
	if cmd_lower == "pwd":
		return "/home/" + username
	
	# Commande whoami
	if cmd_lower == "whoami":
		return username
	
	# Commande uname
	if cmd_lower == "uname" or cmd_lower == "uname -a":
		return "Linux localhost 5.15.0-generic #1 SMP x86_64 GNU/Linux"
	
	# Commande help
	if cmd_lower == "help" or cmd_lower == "--help":
		return "Commandes disponibles:\n  ls      - Liste les fichiers\n  cd      - Change de répertoire\n  pwd     - Affiche le répertoire courant\n  whoami  - Affiche l'utilisateur\n  clear   - Efface l'écran\n  neofetch - Affiche les infos système"
	
	# Commande clear
	if cmd_lower == "clear":
		command_history.clear()
		return ""
	
	# Commande neofetch
	if cmd_lower == "neofetch":
		return get_neofetch()
	
	# Commande cat
	if cmd_lower.begins_with("cat "):
		return "cat: " + cmd_original.substr(4) + ": Permission denied"
	
	# Commande sudo
	if cmd_lower.begins_with("sudo "):
		return "[sudo] password for " + username + ": \nSorry, try again."
	
	# Commande inconnue
	return "bash: " + cmd_original.split(" ")[0] + ": command not found"

func get_fake_ls():
	var files = [
		"Desktop    Documents  Downloads  Music",
		"Pictures   Public     Templates  Videos",
		".bashrc    .profile   .config"
	]
	return PoolStringArray(files).join("\n")

func get_neofetch():
	var info = [
		"        #####           " + username + "@linux",
		"       #######          -----------",
		"       ##O#O##          OS: Ubuntu 22.04 LTS",
		"       #######          Kernel: 5.15.0-generic",
		"     ###########        Uptime: 3 hours, 42 mins",
		"    #############       Shell: bash 5.1.16",
		"   ###############      Terminal: /dev/pts/0",
		"   ################     CPU: Intel i5 (4) @ 2.4GHz",
		"  #################     Memory: 1337MB / 8192MB",
		"#####################",
		"#####################",
		"  #################"
	]
	return PoolStringArray(info).join("\n")

func update_output():
	var output_text = ""
	for cmd in command_history:
		output_text += cmd + "\n"
	$Content/ScrollContainer/VBox/OutputText.text = output_text
	
	yield(get_tree(), "idle_frame")
	var scroll = $Content/ScrollContainer
	scroll.scroll_vertical = scroll.get_v_scrollbar().max_value
	
	$InputLine/Prompt.text = username + "@linux:" + current_path + "$"

func show_terminal():
	visible = true
	command_history = []
	current_path = "~"
	update_output()
	$InputLine/CommandInput.text = ""
	$InputLine/CommandInput.grab_focus()
