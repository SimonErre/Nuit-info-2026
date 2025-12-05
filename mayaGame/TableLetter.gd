extends Area2D

var player_nearby = false

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_nearby = true
		if has_node("InteractLabel"):
			$InteractLabel.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_nearby = false
		if has_node("InteractLabel"):
			$InteractLabel.visible = false

func _input(event):
	if player_nearby and event.is_action_pressed("interact"):
		open_letter()

func open_letter():
	var dialogue_ui = get_tree().get_nodes_in_group("dialogue_ui")
	if dialogue_ui.size() > 0:
		dialogue_ui[0].show_nird_letter()
