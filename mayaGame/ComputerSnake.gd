extends Area2D

var player_nearby = false
var is_destroyed = false

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
	if player_nearby and not is_destroyed and event.is_action_pressed("interact"):
		open_computer()

func show_interact_hint(show):
	if has_node("InteractLabel"):
		# Ne pas afficher si l'ordinateur est détruit
		$InteractLabel.visible = show and not is_destroyed

func set_destroyed(destroyed):
	is_destroyed = destroyed
	if is_destroyed:
		show_interact_hint(false)

func open_computer():
	if is_destroyed:
		return
	
	# Ouvrir la scène du jeu Snake par-dessus
	var snake_game = get_tree().get_root().get_node_or_null("SnakeGame")
	if snake_game == null:
		var SnakeGameScene = load("res://test snake/SnakeGame.tscn")
		snake_game = SnakeGameScene.instance()
		get_tree().get_root().add_child(snake_game)
