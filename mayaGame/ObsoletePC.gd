extends Area2D

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
		show_bsod()

func show_interact_hint(show):
	if has_node("InteractLabel"):
		$InteractLabel.visible = show

func show_bsod():
	var bsod_ui = get_tree().get_root().get_node_or_null("ObsoletePCUI")
	if bsod_ui == null:
		var BSODScene = load("res://ObsoletePCUI.tscn")
		bsod_ui = BSODScene.instance()
		get_tree().get_root().add_child(bsod_ui)
	
	bsod_ui.show_bsod()
