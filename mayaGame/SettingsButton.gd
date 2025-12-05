extends TextureButton

var sound_popup_scene = preload("res://SoundPopup.tscn")
var popup_open = false

func _ready():
	connect("pressed", self, "_on_pressed")
	hint_tooltip = "Paramètres"

func _on_pressed():
	if not popup_open:
		popup_open = true
		var popup = sound_popup_scene.instance()
		popup.connect("tree_exited", self, "_on_popup_closed")
		get_tree().get_root().add_child(popup)

func _on_popup_closed():
	popup_open = false
