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
	
	var computer_ui = get_tree().get_root().get_node_or_null("ComputerUI")
	if computer_ui == null:
		var ComputerUIScene = load("res://ComputerUI.tscn")
		computer_ui = ComputerUIScene.instance()
		get_tree().get_root().add_child(computer_ui)
	
	computer_ui.show_computer(self)
