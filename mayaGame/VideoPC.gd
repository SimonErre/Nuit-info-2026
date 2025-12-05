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
		open_computer()

func show_interact_hint(show):
	if has_node("InteractLabel"):
		$InteractLabel.visible = show

func open_computer():
	var video_ui = get_tree().get_root().get_node_or_null("VideoPCUI")
	if video_ui == null:
		var VideoPCUIScene = load("res://VideoPCUI.tscn")
		video_ui = VideoPCUIScene.instance()
		get_tree().get_root().add_child(video_ui)
	
	video_ui.show_computer()
