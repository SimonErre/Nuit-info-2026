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
	$Control/Monitor/Screen/NirdLetterIcon.connect("file_opened", self, "_on_nird_letter_opened")
	$Control/Monitor/Screen/CommandPrompt.connect("computer_deleted", self, "_on_computer_deleted")
	$Control/Monitor/Screen/CommandPrompt.connect("linux_install_started", self, "_on_linux_install")
	$Control/Monitor/LinuxDesktop/TerminalIcon.connect("file_opened", self, "_on_linux_terminal_opened")

func _on_file_opened():
	$Control/Monitor/Screen/Notepad.show_notepad("snake")

func _on_cmd_opened():
	$Control/Monitor/Screen/CommandPrompt.show_cmd()

func _on_nird_letter_opened():
	# Afficher la lettre du NIRD dans le Notepad
	var letter_content = """════════════════════════════════════════════
         📜 LETTRE DU NIRD 📜
════════════════════════════════════════════

Cher(e) étudiant(e),

Bienvenue dans ce lycée où le numérique règne 
en maître ! Vous êtes un membre du NIRD 
(Numérique Inclusif, Responsable et Durable), 
un collectif engagé pour promouvoir les 
logiciels libres.

────────────────────────────────────────────
🎯 VOTRE MISSION :
────────────────────────────────────────────
Convaincre le Directeur d'adopter les 
logiciels libres et open source dans 
l'établissement.

────────────────────────────────────────────
📚 COMMENT Y PARVENIR :
────────────────────────────────────────────
• Parlez aux professeurs et élèves pour 
  acquérir des connaissances
• Apprenez sur le Markdown, le RGPD, 
  l'écologie numérique, la souveraineté...
• Débloquez de nouveaux arguments pour 
  votre débat final avec le Directeur
• Utilisez les ordinateurs et livres 
  pour vous informer

────────────────────────────────────────────
⚠️ ATTENTION :
────────────────────────────────────────────
• Votre Moral représente vos points de vie
  Ne le laissez pas tomber à zéro !
• Le Directeur peut vous roaster si vous 
  manquez de connaissances
• Enchaînez les bonnes réponses pour des 
  combos puissants !

────────────────────────────────────────────

Bonne chance dans votre quête pour le libre !

                        — Le NIRD 🐧

════════════════════════════════════════════"""
	$Control/Monitor/Screen/Notepad.show_notepad(letter_content)
	$Control/Monitor/Screen/Notepad/TitleBar/TitleLabel.text = "Bloc-notes - Lettre_NIRD.txt"

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
	
	# === QUÊTE RECONDITIONNEMENT: Étape 1 - Récupérer le PC ===
	if GameData.recondition_quest_active and not GameData.is_recondition_step_done("step_collect_pc"):
		GameData.complete_recondition_step("step_collect_pc")
		_show_quest_notification("✅ PC récupéré ! Retourne voir l'Élève Écolo !")
	
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
		
		# === QUÊTE: Afficher menu contextuel si en quête ===
		_check_quest_computer_actions()
	
	get_tree().paused = true

func _check_quest_computer_actions():
	# Si quête active, afficher les options selon l'étape
	if not GameData.recondition_quest_active:
		return
	
	var current_step = GameData.get_current_recondition_step()
	
	# Créer ou récupérer le panneau de quête
	var quest_panel = $Control/Monitor/Screen.get_node_or_null("QuestPanel")
	if quest_panel:
		quest_panel.queue_free()
	
	# Selon l'étape, afficher différentes actions
	match current_step:
		"step_erase_data":
			_show_quest_action_panel("🔒 EFFACER LES DONNÉES", "Lancer l'effacement sécurisé ?", "erase_data")

func _show_quest_action_panel(title: String, description: String, action: String):
	var panel = Panel.new()
	panel.name = "QuestPanel"
	panel.rect_position = Vector2(150, 100)
	panel.rect_size = Vector2(300, 180)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.3, 0.1, 0.95)
	style.border_color = Color(0.3, 0.8, 0.3)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.rect_position = Vector2(10, 10)
	vbox.rect_size = Vector2(280, 160)
	panel.add_child(vbox)
	
	var title_label = Label.new()
	title_label.text = title
	title_label.align = Label.ALIGN_CENTER
	title_label.add_color_override("font_color", Color(0.5, 1.0, 0.5))
	vbox.add_child(title_label)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	var desc_label = Label.new()
	desc_label.text = description
	desc_label.align = Label.ALIGN_CENTER
	desc_label.autowrap = true
	vbox.add_child(desc_label)
	
	var spacer = Control.new()
	spacer.rect_min_size = Vector2(0, 20)
	vbox.add_child(spacer)
	
	var btn = Button.new()
	btn.text = "▶ Exécuter"
	btn.connect("pressed", self, "_on_quest_action", [action])
	vbox.add_child(btn)
	
	$Control/Monitor/Screen.add_child(panel)

func _on_quest_action(action: String):
	var quest_panel = $Control/Monitor/Screen.get_node_or_null("QuestPanel")
	if quest_panel:
		quest_panel.queue_free()
	
	match action:
		"erase_data":
			_execute_erase_data()

func _execute_erase_data():
	# Animation d'effacement
	var progress_panel = _create_progress_panel("🔒 Effacement sécurisé en cours...")
	$Control/Monitor/Screen.add_child(progress_panel)
	
	var progress_bar = progress_panel.get_node("ProgressBar")
	for i in range(101):
		progress_bar.value = i
		yield(get_tree().create_timer(0.02), "timeout")
	
	progress_panel.queue_free()
	
	GameData.complete_recondition_step("step_erase_data")
	_show_quest_notification("✅ Données effacées ! Retourne voir l'Élève Écolo !")

func _create_progress_panel(title: String) -> Panel:
	var panel = Panel.new()
	panel.name = "ProgressPanel"
	panel.rect_position = Vector2(100, 150)
	panel.rect_size = Vector2(400, 100)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	style.border_color = Color(0.4, 0.6, 0.8)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	panel.add_stylebox_override("panel", style)
	
	var label = Label.new()
	label.name = "Label"
	label.text = title
	label.rect_position = Vector2(10, 15)
	label.rect_size = Vector2(380, 30)
	label.align = Label.ALIGN_CENTER
	panel.add_child(label)
	
	var progress = ProgressBar.new()
	progress.name = "ProgressBar"
	progress.rect_position = Vector2(20, 55)
	progress.rect_size = Vector2(360, 25)
	progress.min_value = 0
	progress.max_value = 100
	progress.value = 0
	panel.add_child(progress)
	
	return panel

func _show_quest_notification(text: String):
	# Afficher une notification de quête
	var notif = Label.new()
	notif.name = "QuestNotification"
	notif.text = text
	notif.rect_position = Vector2(50, 20)
	notif.rect_size = Vector2(500, 40)
	notif.align = Label.ALIGN_CENTER
	notif.add_color_override("font_color", Color(0.5, 1.0, 0.5))
	
	# Style avec fond
	var panel = Panel.new()
	panel.name = "NotifPanel"
	panel.rect_position = Vector2(40, 15)
	panel.rect_size = Vector2(520, 50)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.3, 0.1, 0.9)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	panel.add_stylebox_override("panel", style)
	
	$Control/Monitor.add_child(panel)
	$Control/Monitor.add_child(notif)
	
	yield(get_tree().create_timer(3.0), "timeout")
	
	if is_instance_valid(notif):
		notif.queue_free()
	if is_instance_valid(panel):
		panel.queue_free()

func show_linux_desktop():
	$Control/Monitor/Screen.visible = false
	$Control/Monitor/Taskbar.visible = false
	$Control/Monitor/BSOD.visible = false
	$Control/Monitor/LinuxBoot.visible = false
	$Control/Monitor/LinuxDesktop.visible = true
	$Control/Monitor/LinuxDesktop/LinuxTerminal.visible = false
	
	# === QUÊTE: Afficher le panneau d'effacement même sur Linux si pas encore fait ===
	if GameData.recondition_quest_active:
		var current_step = GameData.get_current_recondition_step()
		if current_step == "step_erase_data":
			_show_linux_quest_panel()

func _show_linux_quest_panel():
	# Supprimer l'ancien panneau s'il existe
	var old_panel = $Control/Monitor/LinuxDesktop.get_node_or_null("QuestPanel")
	if old_panel:
		old_panel.queue_free()
	
	var panel = Panel.new()
	panel.name = "QuestPanel"
	panel.rect_position = Vector2(150, 100)
	panel.rect_size = Vector2(300, 200)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.1, 0.1, 0.95)
	style.border_color = Color(0.9, 0.4, 0.3)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.rect_position = Vector2(10, 10)
	vbox.rect_size = Vector2(280, 180)
	panel.add_child(vbox)
	
	var warning = Label.new()
	warning.text = "⚠️ ATTENTION"
	warning.align = Label.ALIGN_CENTER
	warning.add_color_override("font_color", Color(1.0, 0.5, 0.3))
	vbox.add_child(warning)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	var desc = Label.new()
	desc.text = "Linux a été installé AVANT\nl'effacement des données !\n\nVous devez quand même effacer\nles anciennes données pour\nrespecter le RGPD."
	desc.align = Label.ALIGN_CENTER
	desc.autowrap = true
	vbox.add_child(desc)
	
	var spacer = Control.new()
	spacer.rect_min_size = Vector2(0, 10)
	vbox.add_child(spacer)
	
	var btn = Button.new()
	btn.text = "🔒 Effacer les anciennes données"
	btn.connect("pressed", self, "_on_linux_erase_data")
	vbox.add_child(btn)
	
	$Control/Monitor/LinuxDesktop.add_child(panel)

func _on_linux_erase_data():
	var quest_panel = $Control/Monitor/LinuxDesktop.get_node_or_null("QuestPanel")
	if quest_panel:
		quest_panel.queue_free()
	
	# Animation d'effacement sur Linux
	var progress_panel = _create_progress_panel("🔒 Effacement sécurisé (shred)...")
	$Control/Monitor/LinuxDesktop.add_child(progress_panel)
	
	var progress_bar = progress_panel.get_node("ProgressBar")
	for i in range(101):
		progress_bar.value = i
		yield(get_tree().create_timer(0.02), "timeout")
	
	progress_panel.queue_free()
	
	GameData.complete_recondition_step("step_erase_data")
	_show_quest_notification("✅ Données effacées ! Retourne voir l'Élève Écolo !")

func hide_computer():
	is_open = false
	$Control.visible = false
	# Fermer les fenêtres Windows
	$Control/Monitor/Screen/Notepad.visible = false
	$Control/Monitor/Screen/CommandPrompt.visible = false
	# Supprimer les panneaux de quête
	var quest_panel = $Control/Monitor/Screen.get_node_or_null("QuestPanel")
	if quest_panel:
		quest_panel.queue_free()
	# Cacher les écrans
	$Control/Monitor/LinuxBoot.visible = false
	$Control/Monitor/LinuxDesktop.visible = false
	$Control/Monitor/BSOD.visible = false
	get_tree().paused = false
