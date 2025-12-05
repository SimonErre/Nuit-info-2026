extends CanvasLayer

var is_open = false
var just_opened = false
var is_destroyed = false
var is_linux = false  # Si Linux est installé
var computer_node = null  # Référence à l'objet Computer dans le jeu

func _ready():
	hide_computer()
	# Connecter le signal pour ouvrir le fichier
	$Control/Monitor/Screen/DesktopIcon.connect("file_opened", self, "_on_file_opened")
	$Control/Monitor/Screen/CmdIcon.connect("file_opened", self, "_on_cmd_opened")
	$Control/Monitor/Screen/CommandPrompt.connect("computer_deleted", self, "_on_computer_deleted")
	$Control/Monitor/Screen/CommandPrompt.connect("linux_install_started", self, "_on_linux_install")
	$Control/Monitor/LinuxDesktop/TerminalIcon.connect("file_opened", self, "_on_linux_terminal_opened")

func _on_file_opened():
	$Control/Monitor/Screen/Notepad.show_notepad("snake")

func _on_cmd_opened():
	$Control/Monitor/Screen/CommandPrompt.show_cmd()

func _on_linux_terminal_opened():
	$Control/Monitor/LinuxDesktop/LinuxTerminal.show_terminal()

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

func _on_linux_install():
	# Animation de chargement dans le cmd
	var cmd = $Control/Monitor/Screen/CommandPrompt
	cmd.command_history.append("")
	cmd.command_history.append("Téléchargement d'Ubuntu...")
	cmd.update_output()
	
	yield(get_tree().create_timer(0.5), "timeout")
	cmd.command_history.append("[##########----------] 50%")
	cmd.update_output()
	
	yield(get_tree().create_timer(0.5), "timeout")
	cmd.command_history.append("[####################] 100%")
	cmd.update_output()
	
	yield(get_tree().create_timer(0.5), "timeout")
	cmd.command_history.append("Installation terminée. Redémarrage...")
	cmd.update_output()
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	# Écran noir pendant 2 secondes
	$Control/Monitor/Screen.visible = false
	$Control/Monitor/Taskbar.visible = false
	$Control/Monitor/LinuxBoot.visible = true
	$Control/Monitor/LinuxBoot/BootText.text = ""
	
	yield(get_tree().create_timer(2.0), "timeout")
	
	# Séquence de boot Linux
	var boot_messages = [
		"[    0.000000] Linux version 5.15.0-generic",
		"[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz",
		"[    0.001234] Initializing cgroup subsys cpuset",
		"[    0.002345] Initializing cgroup subsys cpu",
		"[    0.045678] CPU: Intel(R) Core(TM) i5 @ 2.40GHz",
		"[    0.123456] Memory: 8192MB available",
		"[    0.234567] Mounting root filesystem...",
		"[    0.345678] systemd[1]: Started Journal Service.",
		"[    0.456789] systemd[1]: Reached target Multi-User System.",
		"[    1.000000] Ubuntu 22.04 LTS",
		"",
		"Welcome to Ubuntu 22.04 LTS!",
		""
	]
	
	for msg in boot_messages:
		$Control/Monitor/LinuxBoot/BootText.text += msg + "\n"
		yield(get_tree().create_timer(0.15), "timeout")
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Passer à Linux
	is_linux = true
	$Control/Monitor/LinuxBoot.visible = false
	show_linux_desktop()

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
	$Control/CloseHint.visible = true
	
	if is_linux:
		# Afficher le bureau Linux
		show_linux_desktop()
	else:
		# Afficher Windows
		$Control/Monitor/Screen.visible = true
		$Control/Monitor/Taskbar.visible = true
		$Control/Monitor/BSOD.visible = false
		$Control/Monitor/LinuxBoot.visible = false
		$Control/Monitor/LinuxDesktop.visible = false
	
	get_tree().paused = true

func show_linux_desktop():
	$Control/Monitor/Screen.visible = false
	$Control/Monitor/Taskbar.visible = false
	$Control/Monitor/BSOD.visible = false
	$Control/Monitor/LinuxBoot.visible = false
	$Control/Monitor/LinuxDesktop.visible = true
	$Control/Monitor/LinuxDesktop/LinuxTerminal.visible = false

func hide_computer():
	is_open = false
	$Control.visible = false
	# Fermer les fenêtres Windows
	$Control/Monitor/Screen/Notepad.visible = false
	$Control/Monitor/Screen/CommandPrompt.visible = false
	# Cacher les écrans
	$Control/Monitor/LinuxBoot.visible = false
	$Control/Monitor/LinuxDesktop.visible = false
	$Control/Monitor/BSOD.visible = false
	get_tree().paused = false
