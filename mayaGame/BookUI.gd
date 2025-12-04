extends CanvasLayer

var is_open = false
var current_page = 0
var pages = []
var book_title = ""
var just_opened = false

const CHARS_PER_PAGE = 280

func _ready():
	hide_book()
	$Control/BookContainer/BookPanel/PrevButton.connect("pressed", self, "_on_prev_pressed")
	$Control/BookContainer/BookPanel/NextButton.connect("pressed", self, "_on_next_pressed")

func _input(event):
	if is_open:
		if just_opened:
			# Ignorer le premier input après ouverture
			if event.is_action_released("interact"):
				just_opened = false
			return
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact"):
			hide_book()
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_left"):
			_on_prev_pressed()
		elif event.is_action_pressed("ui_right"):
			_on_next_pressed()

func show_book(title, content):
	is_open = true
	just_opened = true
	book_title = title
	current_page = 0
	
	# Diviser le contenu en pages
	pages = split_into_pages(content)
	
	$Control.visible = true
	update_pages()
	
	# Mettre le jeu en pause
	get_tree().paused = true

func hide_book():
	is_open = false
	$Control.visible = false
	
	# Reprendre le jeu
	get_tree().paused = false

func split_into_pages(content):
	var result = []
	var paragraphs = content.split("\n\n")
	var current_text = ""
	
	for para in paragraphs:
		if current_text.length() + para.length() > CHARS_PER_PAGE:
			if current_text != "":
				result.append(current_text.strip_edges())
			current_text = para
		else:
			if current_text != "":
				current_text += "\n\n"
			current_text += para
	
	if current_text != "":
		result.append(current_text.strip_edges())
	
	# S'assurer qu'on a au moins 2 pages
	if result.size() == 0:
		result.append("")
	if result.size() % 2 == 1:
		result.append("")
	
	return result

func update_pages():
	var left_idx = current_page * 2
	var right_idx = current_page * 2 + 1
	
	# Page gauche (avec titre sur la première page)
	if left_idx == 0:
		$Control/BookContainer/BookPanel/LeftPage/LeftContent/TitleLabel.text = book_title
		$Control/BookContainer/BookPanel/LeftPage/LeftContent/TitleLabel.visible = true
		$Control/BookContainer/BookPanel/LeftPage/LeftContent/HSeparator.visible = true
	else:
		$Control/BookContainer/BookPanel/LeftPage/LeftContent/TitleLabel.visible = false
		$Control/BookContainer/BookPanel/LeftPage/LeftContent/HSeparator.visible = false
	
	if left_idx < pages.size():
		$Control/BookContainer/BookPanel/LeftPage/LeftContent/LeftText.text = pages[left_idx]
	else:
		$Control/BookContainer/BookPanel/LeftPage/LeftContent/LeftText.text = ""
	
	# Page droite
	if right_idx < pages.size():
		$Control/BookContainer/BookPanel/RightPage/RightContent/RightText.text = pages[right_idx]
	else:
		$Control/BookContainer/BookPanel/RightPage/RightContent/RightText.text = ""
	
	# Numéros de page
	$Control/BookContainer/BookPanel/LeftPage/LeftPageNum.text = str(left_idx + 1)
	$Control/BookContainer/BookPanel/RightPage/RightPageNum.text = str(right_idx + 1)
	
	# Activer/désactiver les boutons de navigation
	$Control/BookContainer/BookPanel/PrevButton.disabled = (current_page == 0)
	$Control/BookContainer/BookPanel/NextButton.disabled = (right_idx >= pages.size() - 1)

func _on_prev_pressed():
	if current_page > 0:
		current_page -= 1
		update_pages()

func _on_next_pressed():
	if current_page * 2 + 2 < pages.size():
		current_page += 1
		update_pages()
