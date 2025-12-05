extends CanvasLayer

var current_npc = null
var current_npc_name = "PNJ"
var option_buttons = []
var dialogue_bubble = null  # Bulle qui suit le PNJ

var intro_letter_shown = false

func _ready():
	add_to_group("dialogue_ui")
	hide_dialogue()
	setup_minimal_stats()
	# Connecter les signaux de GameData
	GameData.connect("combo_changed", self, "_on_combo_changed")
	GameData.connect("roasted", self, "_on_roasted")
	GameData.connect("game_over", self, "_on_game_over")
	# Afficher la lettre d'introduction après un court délai
	yield(get_tree().create_timer(0.5), "timeout")
	show_intro_letter()

func setup_minimal_stats():
	# === PANNEAU DE STATS EN HAUT À GAUCHE ===
	var stats_panel = Panel.new()
	stats_panel.name = "StatsPanel"
	stats_panel.anchor_left = 0.01
	stats_panel.anchor_right = 0.25
	stats_panel.anchor_top = 0.02
	stats_panel.anchor_bottom = 0.25
	
	# Style du panneau
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.08, 0.12, 0.85)
	panel_style.border_color = Color(0.3, 0.4, 0.5, 0.8)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	panel_style.shadow_color = Color(0, 0, 0, 0.4)
	panel_style.shadow_size = 4
	stats_panel.add_stylebox_override("panel", panel_style)
	add_child(stats_panel)
	
	# Container vertical pour empiler les éléments
	var stats_vbox = VBoxContainer.new()
	stats_vbox.name = "StatsBar"
	stats_vbox.anchor_left = 0.05
	stats_vbox.anchor_right = 0.95
	stats_vbox.anchor_top = 0.05
	stats_vbox.anchor_bottom = 0.95
	stats_vbox.set("custom_constants/separation", 8)
	stats_panel.add_child(stats_vbox)
	
	# === MORAL (HP) - Barre horizontale ===
	var mood_container = VBoxContainer.new()
	mood_container.name = "MoodContainer"
	stats_vbox.add_child(mood_container)
	
	var mood_header = HBoxContainer.new()
	mood_header.name = "MoodHeader"
	mood_container.add_child(mood_header)
	
	var mood_icon = Label.new()
	mood_icon.text = "❤️ Moral"
	mood_icon.add_color_override("font_color", Color(1.0, 0.5, 0.5))
	mood_header.add_child(mood_icon)
	
	var mood_label = Label.new()
	mood_label.name = "MoodLabel"
	mood_label.text = "50"
	mood_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mood_label.align = Label.ALIGN_RIGHT
	mood_label.add_color_override("font_color", Color(1, 0.9, 0.9))
	mood_header.add_child(mood_label)
	
	# Barre de progression Moral
	var mood_bar_bg = Panel.new()
	mood_bar_bg.name = "MoodBarBG"
	mood_bar_bg.rect_min_size = Vector2(0, 14)
	var mood_bg_style = StyleBoxFlat.new()
	mood_bg_style.bg_color = Color(0.2, 0.1, 0.1, 1.0)
	mood_bg_style.corner_radius_top_left = 7
	mood_bg_style.corner_radius_top_right = 7
	mood_bg_style.corner_radius_bottom_left = 7
	mood_bg_style.corner_radius_bottom_right = 7
	mood_bar_bg.add_stylebox_override("panel", mood_bg_style)
	mood_container.add_child(mood_bar_bg)
	
	var mood_bar = ProgressBar.new()
	mood_bar.name = "MoodBar"
	mood_bar.min_value = 0
	mood_bar.max_value = 100
	mood_bar.value = 50
	mood_bar.percent_visible = false
	mood_bar.anchor_right = 1.0
	mood_bar.anchor_bottom = 1.0
	mood_bar.margin_left = 2
	mood_bar.margin_right = -2
	mood_bar.margin_top = 2
	mood_bar.margin_bottom = -2
	
	var mood_bar_style = StyleBoxFlat.new()
	mood_bar_style.bg_color = Color(0.2, 0.85, 0.3, 1.0)
	mood_bar_style.corner_radius_top_left = 5
	mood_bar_style.corner_radius_top_right = 5
	mood_bar_style.corner_radius_bottom_left = 5
	mood_bar_style.corner_radius_bottom_right = 5
	mood_bar.add_stylebox_override("fg", mood_bar_style)
	
	var mood_bar_empty = StyleBoxFlat.new()
	mood_bar_empty.bg_color = Color(0, 0, 0, 0)
	mood_bar.add_stylebox_override("bg", mood_bar_empty)
	mood_bar_bg.add_child(mood_bar)
	
	# === CONNAISSANCE - Barre horizontale ===
	var knowledge_container = VBoxContainer.new()
	knowledge_container.name = "KnowledgeContainer"
	stats_vbox.add_child(knowledge_container)
	
	var knowledge_header = HBoxContainer.new()
	knowledge_header.name = "KnowledgeHeader"
	knowledge_container.add_child(knowledge_header)
	
	var knowledge_icon = Label.new()
	knowledge_icon.text = "📚 Savoir"
	knowledge_icon.add_color_override("font_color", Color(0.4, 0.7, 1.0))
	knowledge_header.add_child(knowledge_icon)
	
	var knowledge_label = Label.new()
	knowledge_label.name = "KnowledgeLabel"
	knowledge_label.text = "0%"
	knowledge_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	knowledge_label.align = Label.ALIGN_RIGHT
	knowledge_label.add_color_override("font_color", Color(0.8, 0.9, 1.0))
	knowledge_header.add_child(knowledge_label)
	
	# Barre de progression Savoir
	var knowledge_bar_bg = Panel.new()
	knowledge_bar_bg.name = "KnowledgeBarBG"
	knowledge_bar_bg.rect_min_size = Vector2(0, 14)
	var knowledge_bg_style = StyleBoxFlat.new()
	knowledge_bg_style.bg_color = Color(0.1, 0.1, 0.25, 1.0)
	knowledge_bg_style.corner_radius_top_left = 7
	knowledge_bg_style.corner_radius_top_right = 7
	knowledge_bg_style.corner_radius_bottom_left = 7
	knowledge_bg_style.corner_radius_bottom_right = 7
	knowledge_bar_bg.add_stylebox_override("panel", knowledge_bg_style)
	knowledge_container.add_child(knowledge_bar_bg)
	
	var knowledge_bar = ProgressBar.new()
	knowledge_bar.name = "KnowledgeBar"
	knowledge_bar.min_value = 0
	knowledge_bar.max_value = 100
	knowledge_bar.value = 0
	knowledge_bar.percent_visible = false
	knowledge_bar.anchor_right = 1.0
	knowledge_bar.anchor_bottom = 1.0
	knowledge_bar.margin_left = 2
	knowledge_bar.margin_right = -2
	knowledge_bar.margin_top = 2
	knowledge_bar.margin_bottom = -2
	
	var knowledge_bar_style = StyleBoxFlat.new()
	knowledge_bar_style.bg_color = Color(0.3, 0.6, 1.0, 1.0)
	knowledge_bar_style.corner_radius_top_left = 5
	knowledge_bar_style.corner_radius_top_right = 5
	knowledge_bar_style.corner_radius_bottom_left = 5
	knowledge_bar_style.corner_radius_bottom_right = 5
	knowledge_bar.add_stylebox_override("fg", knowledge_bar_style)
	
	var knowledge_bar_empty = StyleBoxFlat.new()
	knowledge_bar_empty.bg_color = Color(0, 0, 0, 0)
	knowledge_bar.add_stylebox_override("bg", knowledge_bar_empty)
	knowledge_bar_bg.add_child(knowledge_bar)
	
	# === Séparateur ===
	var separator = HSeparator.new()
	separator.modulate = Color(0.4, 0.5, 0.6, 0.5)
	stats_vbox.add_child(separator)
	
	# === COMBO & POINTS - Ligne horizontale ===
	var combo_points_row = HBoxContainer.new()
	combo_points_row.name = "ComboContainer"
	stats_vbox.add_child(combo_points_row)
	
	var combo_label = Label.new()
	combo_label.name = "ComboLabel"
	combo_label.text = "🔥 x0"
	combo_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	combo_label.add_color_override("font_color", Color(0.5, 0.5, 0.5))
	combo_points_row.add_child(combo_label)
	
	var points_label = Label.new()
	points_label.name = "PointsLabel"
	points_label.text = "⭐ 0 pts"
	points_label.align = Label.ALIGN_RIGHT
	points_label.add_color_override("font_color", Color(1.0, 0.85, 0.4))
	combo_points_row.add_child(points_label)
	
	# === SUJETS - Ligne horizontale ===
	var topics_row = HBoxContainer.new()
	topics_row.name = "TopicsContainer"
	stats_vbox.add_child(topics_row)
	
	var topics_label = Label.new()
	topics_label.name = "TopicsLabel"
	topics_label.text = "🎓 Sujets"
	topics_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topics_label.add_color_override("font_color", Color(0.7, 0.7, 0.7))
	topics_row.add_child(topics_label)
	
	var topics_count = Label.new()
	topics_count.name = "TopicsCount"
	topics_count.text = "0 / 6"
	topics_count.align = Label.ALIGN_RIGHT
	topics_count.add_color_override("font_color", Color(0.9, 0.9, 0.9))
	topics_row.add_child(topics_count)
	
	# === FEEDBACK CENTRAL (pour combos/roasts) ===
	var feedback = Label.new()
	feedback.name = "ComboFeedback"
	feedback.anchor_left = 0.3
	feedback.anchor_right = 0.7
	feedback.anchor_top = 0.4
	feedback.anchor_bottom = 0.5
	feedback.align = Label.ALIGN_CENTER
	feedback.valign = Label.VALIGN_CENTER
	feedback.visible = false
	add_child(feedback)

func update_all_stats():
	update_mood_gauge()
	update_knowledge_gauge()
	update_points_display()
	update_topics_display()

func update_mood_gauge():
	var mood_container = get_node_or_null("StatsPanel/StatsBar/MoodContainer")
	if not mood_container:
		return
	var mood_bar = mood_container.get_node_or_null("MoodBarBG/MoodBar")
	var mood_label = mood_container.get_node_or_null("MoodHeader/MoodLabel")
	
	if mood_bar and mood_label:
		var mood = GameData.get_mood()
		mood_bar.value = mood
		mood_label.text = str(int(mood))
		
		# Style de la barre selon les HP avec dégradé de couleurs
		var bar_style = mood_bar.get_stylebox("fg") as StyleBoxFlat
		if bar_style:
			if mood >= 70:
				bar_style.bg_color = Color(0.2, 0.9, 0.3, 1.0)  # Vert
			elif mood >= 40:
				bar_style.bg_color = Color(0.9, 0.9, 0.2, 1.0)  # Jaune
			elif mood >= 20:
				bar_style.bg_color = Color(0.95, 0.5, 0.1, 1.0)  # Orange
			else:
				bar_style.bg_color = Color(0.95, 0.2, 0.2, 1.0)  # Rouge

func update_knowledge_gauge():
	var knowledge_container = get_node_or_null("StatsPanel/StatsBar/KnowledgeContainer")
	if not knowledge_container:
		return
	var knowledge_bar = knowledge_container.get_node_or_null("KnowledgeBarBG/KnowledgeBar")
	var knowledge_label = knowledge_container.get_node_or_null("KnowledgeHeader/KnowledgeLabel")
	
	if knowledge_bar and knowledge_label:
		var knowledge = GameData.get_knowledge_percentage()
		knowledge_bar.value = knowledge
		knowledge_label.text = str(int(knowledge)) + "%"
		
		# Style de la barre selon le niveau
		var bar_style = knowledge_bar.get_stylebox("fg") as StyleBoxFlat
		if bar_style:
			if knowledge >= 75:
				bar_style.bg_color = Color(0.3, 0.95, 0.5, 1.0)  # Vert brillant
				knowledge_label.add_color_override("font_color", Color(0.5, 1.0, 0.5))
			else:
				bar_style.bg_color = Color(0.3, 0.6, 1.0, 1.0)  # Bleu
				knowledge_label.add_color_override("font_color", Color(0.8, 0.9, 1.0))

func update_points_display():
	var combo_container = get_node_or_null("StatsPanel/StatsBar/ComboContainer")
	if not combo_container:
		return
	var combo_label = combo_container.get_node_or_null("ComboLabel")
	var points_label = combo_container.get_node_or_null("PointsLabel")
	
	if combo_label:
		var combo = GameData.get_combo()
		combo_label.text = "🔥 x" + str(combo)
		if combo > 0:
			combo_label.add_color_override("font_color", Color(1.0, 0.5, 0.0))
		else:
			combo_label.add_color_override("font_color", Color(0.5, 0.5, 0.5))
	
	if points_label:
		points_label.text = "⭐ " + str(GameData.get_argument_points()) + " pts"

func update_topics_display():
	var topics_container = get_node_or_null("StatsPanel/StatsBar/TopicsContainer")
	if not topics_container:
		return
	var topics_count = topics_container.get_node_or_null("TopicsCount")
	var topics_label = topics_container.get_node_or_null("TopicsLabel")
	if topics_count:
		var count = GameData.get_unlocked_topics_count()
		topics_count.text = str(count) + " / 6"
		if count >= 2:
			topics_count.add_color_override("font_color", Color(0.5, 1.0, 0.5))
			if topics_label:
				topics_label.add_color_override("font_color", Color(0.5, 1.0, 0.5))

func _on_combo_changed(new_combo: int):
	var feedback = get_node_or_null("ComboFeedback")
	if feedback and new_combo > 1:
		feedback.visible = true
		feedback.text = "🔥 COMBO x" + str(new_combo) + " ! 🔥"
		feedback.add_color_override("font_color", Color(1.0, 0.5, 0.0))
		yield(get_tree().create_timer(1.2), "timeout")
		feedback.visible = false

func _on_roasted():
	var feedback = get_node_or_null("ComboFeedback")
	if feedback:
		feedback.visible = true
		var damage = 15 + GameData.get_roast_count() * 3
		feedback.text = "💀 ROASTED ! -" + str(damage) + " HP 💀"
		feedback.add_color_override("font_color", Color(1.0, 0.2, 0.2))
		yield(get_tree().create_timer(1.2), "timeout")
		feedback.visible = false

func _on_game_over():
	show_game_over()

# === LETTRE D'INTRODUCTION ===
func show_intro_letter():
	if intro_letter_shown:
		return
	intro_letter_shown = true
	_create_and_show_letter(true)

func show_nird_letter():
	# Fonction pour relire la lettre depuis l'ordinateur
	_create_and_show_letter(false)

func _create_and_show_letter(is_first_time: bool):
	visible = true
	
	# Supprimer l'ancienne bulle si elle existe
	if dialogue_bubble:
		dialogue_bubble.queue_free()
	
	# Créer le panneau de la lettre
	var letter = Control.new()
	letter.name = "IntroLetter"
	letter.anchor_left = 0.1
	letter.anchor_right = 0.9
	letter.anchor_top = 0.1
	letter.anchor_bottom = 0.9
	
	# Fond de la lettre (style parchemin)
	var bg = Panel.new()
	bg.name = "LetterBG"
	bg.anchor_left = 0
	bg.anchor_right = 1
	bg.anchor_top = 0
	bg.anchor_bottom = 1
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.92, 0.85, 0.98)
	style.border_color = Color(0.6, 0.5, 0.3, 1.0)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 8
	bg.add_stylebox_override("panel", style)
	letter.add_child(bg)
	
	# Contenu de la lettre
	var content = VBoxContainer.new()
	content.name = "LetterContent"
	content.anchor_left = 0.05
	content.anchor_right = 0.95
	content.anchor_top = 0.05
	content.anchor_bottom = 0.85
	content.set("custom_constants/separation", 15)
	letter.add_child(content)
	
	# Titre de la lettre
	var title = Label.new()
	title.text = "📜 Lettre de Bienvenue"
	title.align = Label.ALIGN_CENTER
	title.add_color_override("font_color", Color(0.3, 0.2, 0.1))
	content.add_child(title)
	
	# Séparateur
	var sep = HSeparator.new()
	sep.modulate = Color(0.6, 0.5, 0.3)
	content.add_child(sep)
	
	# Corps de la lettre
	var body = RichTextLabel.new()
	body.name = "LetterBody"
	body.bbcode_enabled = true
	body.bbcode_text = """Cher(e) étudiant(e),

Bienvenue dans ce lycée où le numérique règne en maître ! Vous êtes un membre du [b]NIRD[/b] (Numérique Inclusif, Responsable et Durable), un collectif engagé pour promouvoir les logiciels libres.

[color=#8B4513]🎯 Votre mission :[/color]
Convaincre le [b]Directeur[/b] d'adopter les logiciels libres et open source dans l'établissement.

[color=#8B4513]📚 Comment y parvenir :[/color]
• Parlez aux [b]professeurs[/b] et [b]élèves[/b] pour acquérir des connaissances
• Apprenez sur le [b]Markdown[/b], le [b]RGPD[/b], l'[b]écologie numérique[/b], la [b]souveraineté numérique[/b]...
• Débloquez de nouveaux [b]arguments[/b] pour votre débat final avec le Directeur
• Utilisez les [b]ordinateurs[/b] et [b]livres[/b] pour vous informer

[color=#8B4513]⚠️ Attention :[/color]
• Votre [b]Moral[/b] représente vos points de vie - ne le laissez pas tomber à zéro !
• Le Directeur peut vous [b]roaster[/b] si vous manquez de connaissances
• Enchaînez les bonnes réponses pour des [b]combos[/b] puissants !

[color=#228B22]Bonne chance dans votre quête pour le libre ![/color]

— Le NIRD 🐧"""
	body.scroll_active = true
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_color_override("default_color", Color(0.2, 0.15, 0.1))
	content.add_child(body)
	
	# Bouton pour fermer
	var close_btn = Button.new()
	close_btn.name = "CloseButton"
	close_btn.text = "📖 Commencer l'aventure !" if is_first_time else "✓ Fermer"
	close_btn.anchor_left = 0.3
	close_btn.anchor_right = 0.7
	close_btn.anchor_top = 0.88
	close_btn.anchor_bottom = 0.95
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.3, 0.5, 0.3, 0.9)
	btn_style.corner_radius_top_left = 8
	btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_left = 8
	btn_style.corner_radius_bottom_right = 8
	close_btn.add_stylebox_override("normal", btn_style)
	
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.4, 0.6, 0.4, 1.0)
	btn_hover.corner_radius_top_left = 8
	btn_hover.corner_radius_top_right = 8
	btn_hover.corner_radius_bottom_left = 8
	btn_hover.corner_radius_bottom_right = 8
	close_btn.add_stylebox_override("hover", btn_hover)
	
	close_btn.connect("pressed", self, "_on_intro_letter_closed")
	letter.add_child(close_btn)
	
	dialogue_bubble = letter
	add_child(letter)

func _on_intro_letter_closed():
	if dialogue_bubble:
		dialogue_bubble.queue_free()
		dialogue_bubble = null
	# Ne pas mettre visible = false pour garder le panneau des stats visible

# === BULLE DE DIALOGUE AU-DESSUS DU PNJ (CLAMPÉE À L'ÉCRAN) ===
func show_dialogue(npc, dialogue_data, npc_name_str = "PNJ"):
	current_npc = npc
	current_npc_name = npc_name_str
	visible = true
	
	# Supprimer l'ancienne bulle si elle existe
	if dialogue_bubble:
		dialogue_bubble.queue_free()
	
	# Créer la bulle de dialogue
	dialogue_bubble = _create_dialogue_bubble(dialogue_data)
	
	# Ajouter la bulle au CanvasLayer (UI) plutôt qu'au NPC
	# Cela permet de la clamper à l'écran
	add_child(dialogue_bubble)
	
	# Positionner la bulle au-dessus du NPC (sera mis à jour dans _process)
	_update_bubble_position()
	
	update_all_stats()

func _update_bubble_position():
	if not dialogue_bubble or not current_npc:
		return
	
	# Obtenir la position du NPC en coordonnées écran
	var viewport = get_viewport()
	var canvas_transform = viewport.canvas_transform
	var npc_screen_pos = canvas_transform.xform(current_npc.global_position)
	
	# Taille de la bulle et de l'écran
	var bubble_size = dialogue_bubble.rect_size
	var screen_size = viewport.size
	
	# Marge pour la barre de stats en haut
	var top_margin = 80  # Espace pour la barre de stats
	var side_margin = 10
	var bottom_margin = 20
	
	# Position idéale : au-dessus du NPC, centrée horizontalement
	var ideal_x = npc_screen_pos.x - bubble_size.x / 2
	var ideal_y = npc_screen_pos.y - bubble_size.y - 60  # 60px au-dessus du PNJ
	
	# Clamper horizontalement
	var clamped_x = clamp(ideal_x, side_margin, screen_size.x - bubble_size.x - side_margin)
	
	# Gestion verticale - TOUJOURS essayer de mettre au-dessus
	var clamped_y = ideal_y
	var arrow = dialogue_bubble.get_node_or_null("BubbleArrow")
	
	# Si pas assez de place au-dessus, placer juste sous la barre de stats
	if ideal_y < top_margin:
		clamped_y = top_margin
		# La flèche pointe vers le bas (vers le PNJ qui est en dessous)
		if arrow:
			arrow.text = "▼"
			var bg = dialogue_bubble.get_node_or_null("BubbleBG")
			if bg:
				arrow.rect_position.y = bg.rect_size.y - 5
	else:
		# La flèche pointe vers le bas normalement
		if arrow:
			arrow.text = "▼"
			var bg = dialogue_bubble.get_node_or_null("BubbleBG")
			if bg:
				arrow.rect_position.y = bg.rect_size.y - 5
	
	# Si la bulle sort en bas de l'écran, la remonter
	if clamped_y + bubble_size.y > screen_size.y - bottom_margin:
		clamped_y = screen_size.y - bubble_size.y - bottom_margin
	
	dialogue_bubble.rect_position = Vector2(clamped_x, clamped_y)

func _create_dialogue_bubble(dialogue_data) -> Control:
	# Container principal de la bulle
	var bubble = Control.new()
	bubble.name = "DialogueBubble"
	bubble.rect_size = Vector2(480, 280)
	
	# Fond de la bulle (NinePatchRect simulé avec Panel)
	var bg = Panel.new()
	bg.name = "BubbleBG"
	bg.rect_position = Vector2(0, 0)
	bg.rect_size = Vector2(480, 250)
	
	# Style de la bulle
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.border_color = Color(0.4, 0.6, 0.8, 1.0)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 4
	bg.add_stylebox_override("panel", style)
	bubble.add_child(bg)
	
	# Triangle/flèche vers le personnage
	var arrow = Label.new()
	arrow.name = "BubbleArrow"
	arrow.text = "▼"
	arrow.rect_position = Vector2(230, 245)
	arrow.add_color_override("font_color", Color(0.4, 0.6, 0.8, 1.0))
	bubble.add_child(arrow)
	
	# Nom du PNJ
	var name_label = Label.new()
	name_label.name = "NPCName"
	name_label.text = current_npc_name
	name_label.rect_position = Vector2(10, 8)
	name_label.rect_size = Vector2(460, 20)
	name_label.add_color_override("font_color", Color(0.9, 0.7, 0.3))
	bubble.add_child(name_label)
	
	# Ligne de séparation
	var separator = ColorRect.new()
	separator.rect_position = Vector2(10, 28)
	separator.rect_size = Vector2(460, 1)
	separator.color = Color(0.4, 0.5, 0.6, 0.5)
	bubble.add_child(separator)
	
	# Texte du dialogue - utilise RichTextLabel pour meilleur contrôle
	var text_label = RichTextLabel.new()
	text_label.name = "DialogueText"
	text_label.bbcode_enabled = false
	text_label.text = dialogue_data["text"]
	text_label.rect_position = Vector2(10, 35)
	text_label.rect_size = Vector2(460, 70)
	text_label.scroll_active = false
	text_label.add_color_override("default_color", Color(1, 1, 1))
	
	# Colorer selon le type
	if dialogue_data.get("is_roast", false):
		text_label.add_color_override("default_color", Color(1.0, 0.4, 0.4))
		style.border_color = Color(0.8, 0.3, 0.3)
	elif dialogue_data.get("is_success", false):
		text_label.add_color_override("default_color", Color(0.4, 1.0, 0.4))
		style.border_color = Color(0.3, 0.8, 0.3)
	elif dialogue_data.get("is_victory", false):
		text_label.add_color_override("default_color", Color(1.0, 0.9, 0.3))
		style.border_color = Color(0.9, 0.8, 0.2)
	
	bubble.add_child(text_label)
	
	# Options de dialogue
	var options_start_y = 110
	for i in range(dialogue_data["options"].size()):
		var option = dialogue_data["options"][i]
		var btn = Button.new()
		btn.name = "Option" + str(i)
		btn.rect_position = Vector2(10, options_start_y + i * 30)
		btn.rect_size = Vector2(460, 27)
		
		var required = option.get("knowledge_required", 0)
		var points = option.get("points", 0)
		
		if required > 0:
			var current_knowledge = GameData.get_knowledge_percentage()
			if current_knowledge >= required:
				btn.text = "► " + option["text"]
				if points > 0:
					btn.text += " [+" + str(points) + "]"
			else:
				btn.text = "🔒 " + option["text"] + " [" + str(required) + "%]"
				btn.modulate = Color(0.6, 0.6, 0.6)
		else:
			btn.text = "► " + option["text"]
		
		# Style du bouton
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.2, 0.25, 0.35, 0.8)
		btn_style.corner_radius_top_left = 4
		btn_style.corner_radius_top_right = 4
		btn_style.corner_radius_bottom_left = 4
		btn_style.corner_radius_bottom_right = 4
		btn.add_stylebox_override("normal", btn_style)
		
		var btn_hover = StyleBoxFlat.new()
		btn_hover.bg_color = Color(0.3, 0.4, 0.5, 0.9)
		btn_hover.corner_radius_top_left = 4
		btn_hover.corner_radius_top_right = 4
		btn_hover.corner_radius_bottom_left = 4
		btn_hover.corner_radius_bottom_right = 4
		btn.add_stylebox_override("hover", btn_hover)
		
		btn.connect("pressed", self, "_on_option_pressed", [i])
		bubble.add_child(btn)
		option_buttons.append(btn)
	
	# Ajuster la taille de la bulle selon le nombre d'options
	var bubble_height = 120 + dialogue_data["options"].size() * 30
	bg.rect_size.y = bubble_height
	bubble.rect_size = Vector2(480, bubble_height + 25)
	arrow.rect_position.y = bubble_height - 5
	
	return bubble

func show_insufficient_knowledge(required: int):
	if dialogue_bubble:
		var text_label = dialogue_bubble.get_node_or_null("DialogueText")
		if text_label:
			var current = GameData.get_knowledge_percentage()
			text_label.text = "⚠️ Connaissances insuffisantes!\n(" + str(int(current)) + "% / " + str(required) + "% requis)"
			text_label.add_color_override("font_color", Color(1.0, 0.5, 0.3))

func show_victory():
	visible = true
	
	if dialogue_bubble:
		dialogue_bubble.queue_free()
	
	# Créer l'écran de victoire complet
	_create_victory_screen()

func _create_victory_screen():
	var victory_screen = Control.new()
	victory_screen.name = "VictoryScreen"
	victory_screen.anchor_right = 1.0
	victory_screen.anchor_bottom = 1.0
	
	# Fond semi-transparent avec dégradé
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0.05, 0.1, 0.15, 0.95)
	victory_screen.add_child(bg)
	
	# Container principal centré
	var main_container = Control.new()
	main_container.name = "MainContainer"
	main_container.anchor_left = 0.1
	main_container.anchor_right = 0.9
	main_container.anchor_top = 0.05
	main_container.anchor_bottom = 0.95
	victory_screen.add_child(main_container)
	
	# Panneau principal style parchemin/certificat
	var certificate = Panel.new()
	certificate.name = "Certificate"
	certificate.anchor_right = 1.0
	certificate.anchor_bottom = 1.0
	
	var cert_style = StyleBoxFlat.new()
	cert_style.bg_color = Color(0.98, 0.96, 0.90, 1.0)
	cert_style.border_color = Color(0.6, 0.5, 0.2, 1.0)
	cert_style.border_width_left = 4
	cert_style.border_width_right = 4
	cert_style.border_width_top = 4
	cert_style.border_width_bottom = 4
	cert_style.corner_radius_top_left = 10
	cert_style.corner_radius_top_right = 10
	cert_style.corner_radius_bottom_left = 10
	cert_style.corner_radius_bottom_right = 10
	cert_style.shadow_color = Color(0, 0, 0, 0.5)
	cert_style.shadow_size = 10
	certificate.add_stylebox_override("panel", cert_style)
	main_container.add_child(certificate)
	
	# Bordure dorée intérieure
	var inner_border = Panel.new()
	inner_border.anchor_left = 0.02
	inner_border.anchor_right = 0.98
	inner_border.anchor_top = 0.02
	inner_border.anchor_bottom = 0.98
	var inner_style = StyleBoxFlat.new()
	inner_style.bg_color = Color(0, 0, 0, 0)
	inner_style.border_color = Color(0.8, 0.7, 0.3, 0.8)
	inner_style.border_width_left = 2
	inner_style.border_width_right = 2
	inner_style.border_width_top = 2
	inner_style.border_width_bottom = 2
	inner_border.add_stylebox_override("panel", inner_style)
	certificate.add_child(inner_border)
	
	# Contenu scrollable
	var scroll = ScrollContainer.new()
	scroll.anchor_left = 0.05
	scroll.anchor_right = 0.95
	scroll.anchor_top = 0.05
	scroll.anchor_bottom = 0.88
	certificate.add_child(scroll)
	
	var content = VBoxContainer.new()
	content.name = "Content"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.set("custom_constants/separation", 15)
	scroll.add_child(content)
	
	# === EN-TÊTE ===
	var header = Label.new()
	header.text = "🏆 CERTIFICAT DE VICTOIRE 🏆"
	header.align = Label.ALIGN_CENTER
	header.add_color_override("font_color", Color(0.5, 0.4, 0.1))
	content.add_child(header)
	
	# Séparateur décoratif
	var sep1 = Label.new()
	sep1.text = "═══════════════════════════════"
	sep1.align = Label.ALIGN_CENTER
	sep1.add_color_override("font_color", Color(0.7, 0.6, 0.3))
	content.add_child(sep1)
	
	# === MESSAGE DE VICTOIRE ===
	var victory_msg = RichTextLabel.new()
	victory_msg.bbcode_enabled = true
	victory_msg.fit_content_height = true
	victory_msg.scroll_active = false
	victory_msg.bbcode_text = """[center][color=#2E7D32]🎉 FÉLICITATIONS ! 🎉[/color]

Vous avez réussi à convaincre le Directeur !

Le lycée va adopter les [b]logiciels libres[/b] grâce à vos arguments 
sur le Markdown, le RGPD, l'écologie numérique et la souveraineté ![/center]"""
	victory_msg.add_color_override("default_color", Color(0.2, 0.15, 0.1))
	content.add_child(victory_msg)
	
	# === STATISTIQUES ===
	var stats_title = Label.new()
	stats_title.text = "📊 VOS STATISTIQUES"
	stats_title.align = Label.ALIGN_CENTER
	stats_title.add_color_override("font_color", Color(0.4, 0.3, 0.1))
	content.add_child(stats_title)
	
	var stats_panel = Panel.new()
	var stats_style = StyleBoxFlat.new()
	stats_style.bg_color = Color(0.95, 0.93, 0.85, 1.0)
	stats_style.border_color = Color(0.7, 0.6, 0.4, 0.5)
	stats_style.border_width_left = 1
	stats_style.border_width_right = 1
	stats_style.border_width_top = 1
	stats_style.border_width_bottom = 1
	stats_style.corner_radius_top_left = 5
	stats_style.corner_radius_top_right = 5
	stats_style.corner_radius_bottom_left = 5
	stats_style.corner_radius_bottom_right = 5
	stats_style.content_margin_left = 15
	stats_style.content_margin_right = 15
	stats_style.content_margin_top = 10
	stats_style.content_margin_bottom = 10
	stats_panel.add_stylebox_override("panel", stats_style)
	content.add_child(stats_panel)
	
	var stats_vbox = VBoxContainer.new()
	stats_vbox.set("custom_constants/separation", 5)
	stats_panel.add_child(stats_vbox)
	
	var stats = [
		["⭐ Points d'argument", str(GameData.get_argument_points())],
		["📚 Connaissance", str(GameData.get_knowledge_percentage()) + "%"],
		["❤️ Moral final", str(GameData.get_mood())],
		["🔥 Combo max", "x" + str(GameData.max_combo)],
		["✅ Bonnes réponses", str(GameData.total_good_answers)],
		["💀 Roasts subis", str(GameData.get_roast_count())],
		["🎓 Sujets maîtrisés", str(GameData.get_unlocked_topics_count()) + "/6"]
	]
	
	for stat in stats:
		var stat_row = HBoxContainer.new()
		stats_vbox.add_child(stat_row)
		
		var label = Label.new()
		label.text = stat[0]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_color_override("font_color", Color(0.3, 0.25, 0.15))
		stat_row.add_child(label)
		
		var value = Label.new()
		value.text = stat[1]
		value.add_color_override("font_color", Color(0.2, 0.4, 0.6))
		stat_row.add_child(value)
	
	# === NOTE FINALE ===
	var grade = GameData.get_final_grade()
	var grade_color = Color(0.2, 0.6, 0.3)
	if grade.begins_with("S"):
		grade_color = Color(1.0, 0.8, 0.0)
	elif grade.begins_with("A"):
		grade_color = Color(0.3, 0.7, 0.3)
	elif grade.begins_with("B"):
		grade_color = Color(0.3, 0.5, 0.8)
	elif grade.begins_with("C"):
		grade_color = Color(0.6, 0.6, 0.3)
	elif grade.begins_with("D"):
		grade_color = Color(0.8, 0.5, 0.2)
	else:
		grade_color = Color(0.8, 0.3, 0.3)
	
	var grade_label = Label.new()
	grade_label.text = "🏅 NOTE FINALE: " + grade
	grade_label.align = Label.ALIGN_CENTER
	grade_label.add_color_override("font_color", grade_color)
	content.add_child(grade_label)
	
	# === LETTRE DU NIRD ===
	var letter_title = Label.new()
	letter_title.text = "📜 MESSAGE DU NIRD"
	letter_title.align = Label.ALIGN_CENTER
	letter_title.add_color_override("font_color", Color(0.4, 0.3, 0.1))
	content.add_child(letter_title)
	
	var letter_panel = Panel.new()
	letter_panel.rect_min_size = Vector2(0, 200)
	var letter_style = StyleBoxFlat.new()
	letter_style.bg_color = Color(1.0, 0.98, 0.9, 1.0)
	letter_style.border_color = Color(0.6, 0.5, 0.3, 0.8)
	letter_style.border_width_left = 2
	letter_style.border_width_right = 2
	letter_style.border_width_top = 2
	letter_style.border_width_bottom = 2
	letter_panel.add_stylebox_override("panel", letter_style)
	content.add_child(letter_panel)
	
	var letter_text = RichTextLabel.new()
	letter_text.anchor_left = 0.05
	letter_text.anchor_right = 0.95
	letter_text.anchor_top = 0.05
	letter_text.anchor_bottom = 0.95
	letter_text.bbcode_enabled = true
	
	var letter_content = _get_victory_letter_content(grade)
	letter_text.bbcode_text = letter_content
	letter_text.add_color_override("default_color", Color(0.25, 0.2, 0.15))
	letter_text.scroll_active = true
	letter_panel.add_child(letter_text)
	
	# === SUJETS DÉBLOQUÉS ===
	var topics_title = Label.new()
	topics_title.text = "🎓 SUJETS MAÎTRISÉS"
	topics_title.align = Label.ALIGN_CENTER
	topics_title.add_color_override("font_color", Color(0.4, 0.3, 0.1))
	content.add_child(topics_title)
	
	var topics_container = HBoxContainer.new()
	topics_container.alignment = BoxContainer.ALIGN_CENTER
	topics_container.set("custom_constants/separation", 10)
	content.add_child(topics_container)
	
	var topic_names = {
		"markdown": "📝 Markdown",
		"forge": "🔧 Forge",
		"rgpd": "🔒 RGPD",
		"ecology": "🌱 Écologie",
		"sovereignty": "🏛️ Souveraineté",
		"accessibility": "♿ Accessibilité"
	}
	
	for topic_id in GameData.unlocked_topics:
		var badge = Label.new()
		if GameData.unlocked_topics[topic_id]:
			badge.text = topic_names.get(topic_id, topic_id)
			badge.add_color_override("font_color", Color(0.2, 0.5, 0.3))
		else:
			badge.text = "🔒 ???"
			badge.add_color_override("font_color", Color(0.5, 0.5, 0.5))
		topics_container.add_child(badge)
	
	# Séparateur final
	var sep2 = Label.new()
	sep2.text = "═══════════════════════════════"
	sep2.align = Label.ALIGN_CENTER
	sep2.add_color_override("font_color", Color(0.7, 0.6, 0.3))
	content.add_child(sep2)
	
	# Signature
	var signature = Label.new()
	signature.text = "— Le NIRD 🐧"
	signature.align = Label.ALIGN_CENTER
	signature.add_color_override("font_color", Color(0.4, 0.35, 0.2))
	content.add_child(signature)
	
	# === BOUTONS ===
	var buttons_container = HBoxContainer.new()
	buttons_container.anchor_left = 0.2
	buttons_container.anchor_right = 0.8
	buttons_container.anchor_top = 0.90
	buttons_container.anchor_bottom = 0.97
	buttons_container.alignment = BoxContainer.ALIGN_CENTER
	buttons_container.set("custom_constants/separation", 20)
	certificate.add_child(buttons_container)
	
	# Bouton Rejouer
	var replay_btn = Button.new()
	replay_btn.text = "🔄 Nouvelle Partie"
	replay_btn.rect_min_size = Vector2(150, 35)
	var replay_style = StyleBoxFlat.new()
	replay_style.bg_color = Color(0.3, 0.5, 0.7, 1.0)
	replay_style.corner_radius_top_left = 5
	replay_style.corner_radius_top_right = 5
	replay_style.corner_radius_bottom_left = 5
	replay_style.corner_radius_bottom_right = 5
	replay_btn.add_stylebox_override("normal", replay_style)
	var replay_hover = StyleBoxFlat.new()
	replay_hover.bg_color = Color(0.4, 0.6, 0.8, 1.0)
	replay_hover.corner_radius_top_left = 5
	replay_hover.corner_radius_top_right = 5
	replay_hover.corner_radius_bottom_left = 5
	replay_hover.corner_radius_bottom_right = 5
	replay_btn.add_stylebox_override("hover", replay_hover)
	replay_btn.connect("pressed", self, "_on_replay_pressed")
	buttons_container.add_child(replay_btn)
	
	dialogue_bubble = victory_screen
	add_child(victory_screen)

func _get_victory_letter_content(grade: String) -> String:
	var intro = "Cher(e) membre du NIRD,\n\n"
	var body = ""
	var outro = "\n\nLe monde du libre vous remercie !\n\n"
	
	if grade.begins_with("S"):
		body = """[color=#FFD700]EXTRAORDINAIRE ![/color]

Votre performance est [b]légendaire[/b] ! Vous avez non seulement convaincu le Directeur, mais vous l'avez transformé en fervent défenseur du logiciel libre !

Richard Stallman lui-même serait fier de vous. Vous êtes désormais nommé(e) [b]Ambassadeur(rice) du Libre[/b] !

🏆 Vous recevez le [b]Tux d'Or[/b] ! 🐧✨"""
	elif grade.begins_with("A"):
		body = """[color=#4CAF50]EXCELLENT ![/color]

Votre argumentation était [b]remarquable[/b] ! Le Directeur est totalement convaincu et commence déjà à installer LibreOffice sur son ordinateur.

Vous êtes un(e) véritable ambassadeur(rice) du monde libre. Le NIRD est fier de vous compter parmi ses membres les plus actifs !

🎖️ Vous recevez la [b]Médaille du Libre[/b] !"""
	elif grade.begins_with("B"):
		body = """[color=#2196F3]TRÈS BIEN ![/color]

Belle performance ! Vous avez su présenter des arguments [b]solides[/b] et le Directeur a été convaincu par votre passion.

Le lycée va progressivement adopter les logiciels libres. C'est une belle victoire pour la communauté !

📜 Vous recevez le [b]Diplôme du Libre[/b] !"""
	elif grade.begins_with("C"):
		body = """[color=#FFC107]CORRECT ![/color]

Vous avez réussi votre mission, même si le chemin fut difficile. Le Directeur a accepté de [b]tester[/b] les logiciels libres.

C'est un premier pas important ! Continuez à apprendre et à défendre vos convictions.

📋 Vous recevez le [b]Certificat du Libre[/b] !"""
	else:
		body = """[color=#FF9800]PASSABLE...[/color]

Ce fut difficile, mais vous avez quand même réussi ! Le Directeur accepte à contrecœur d'installer [b]un seul[/b] logiciel libre à titre d'essai.

Ne vous découragez pas ! L'important est d'avoir planté la graine du changement.

📝 Vous recevez une [b]Attestation de participation[/b]."""
	
	return intro + body + outro

func show_game_over():
	visible = true
	
	if dialogue_bubble:
		dialogue_bubble.queue_free()
	
	var game_over_data = {
		"text": "💀 GAME OVER 💀\nVotre moral est à zéro...\n\nLe directeur vous a achevé.\nVous fuyez son bureau, humilié.\n\n💡 Parlez aux PNJ pour apprendre!",
		"is_roast": true,
		"options": [
			{"text": "🔄 Réessayer", "knowledge_required": 0}
		]
	}
	
	dialogue_bubble = _create_dialogue_bubble(game_over_data)
	if current_npc:
		current_npc.add_child(dialogue_bubble)
	
	var replay_btn = dialogue_bubble.get_node_or_null("Option0")
	if replay_btn:
		replay_btn.disconnect("pressed", self, "_on_option_pressed")
		replay_btn.connect("pressed", self, "_on_replay_pressed")

func _on_replay_pressed():
	GameData.reset_all()
	hide_dialogue()
	get_tree().reload_current_scene()

func _is_player_in_top_left_room() -> bool:
	# Vérifie si le joueur est dans la zone en haut à gauche de la carte
	var player = get_tree().get_nodes_in_group("player")
	if player.size() == 0:
		return false
	
	var player_pos = player[0].global_position
	# Zone approximative de la pièce en haut à gauche (ajuster si nécessaire)
	return player_pos.x < -180 and player_pos.y < -100

func _update_stats_panel_position():
	var stats_panel = get_node_or_null("StatsPanel")
	if not stats_panel:
		return
	
	if _is_player_in_top_left_room():
		# Déplacer le panneau à droite
		stats_panel.anchor_left = 0.75
		stats_panel.anchor_right = 0.99
		stats_panel.anchor_top = 0.02
		stats_panel.anchor_bottom = 0.25
	else:
		# Position normale en haut à gauche
		stats_panel.anchor_left = 0.01
		stats_panel.anchor_right = 0.25
		stats_panel.anchor_top = 0.02
		stats_panel.anchor_bottom = 0.25

func hide_dialogue():
	if dialogue_bubble:
		dialogue_bubble.queue_free()
		dialogue_bubble = null
	current_npc = null
	option_buttons.clear()

func _on_option_pressed(option_index: int):
	if current_npc:
		current_npc.select_option(option_index)

func _process(_delta):
	update_all_stats()
	# Mettre à jour la position de la bulle pour qu'elle reste clampée
	_update_bubble_position()
	# Déplacer le panneau de stats si le joueur est dans la pièce en haut à gauche
	_update_stats_panel_position()
