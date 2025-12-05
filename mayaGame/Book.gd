extends Area2D

# Contenu du livre - peut être personnalisé pour chaque livre
export(String, MULTILINE) var book_title = "Livre Mystérieux"
export(String, MULTILINE) var book_content = "Ceci est le contenu du livre.\n\nVous pouvez écrire plusieurs pages ici.\n\nAppuyez sur Échap pour fermer."

var player_nearby = false

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
		open_book()

func show_interact_hint(show):
	if has_node("InteractLabel"):
		$InteractLabel.visible = show

func open_book():
	# Trouver ou créer l'UI du livre
	var book_ui = get_tree().get_root().get_node_or_null("BookUI")
	if book_ui == null:
		var BookUIScene = load("res://BookUI.tscn")
		book_ui = BookUIScene.instance()
		get_tree().get_root().add_child(book_ui)
	
	book_ui.show_book(book_title, book_content)
