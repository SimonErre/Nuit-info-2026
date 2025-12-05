extends Panel

var is_sound_on = true
var phone_popup_scene = preload("res://PhoneInputPopup.tscn")

func _ready():
	$VBoxContainer/SoundButton.connect("pressed", self, "_on_SoundButton_pressed")
	$VBoxContainer/PhoneButton.connect("pressed", self, "_on_PhoneButton_pressed")
	$VBoxContainer/CloseButton.connect("pressed", self, "_on_CloseButton_pressed")
	_update_button_text()
	# Vérifier l'état actuel du son
	is_sound_on = not AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	_update_button_text()

func _update_button_text():
	if is_sound_on:
		$VBoxContainer/SoundButton.text = "🔊 Son : Activé"
	else:
		$VBoxContainer/SoundButton.text = "🔇 Son : Coupé"

func _on_SoundButton_pressed():
	is_sound_on = not is_sound_on
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not is_sound_on)
	_update_button_text()

func _on_PhoneButton_pressed():
	# Ouvrir la popup de vérification de téléphone
	var popup = phone_popup_scene.instance()
	get_tree().get_root().add_child(popup)

func _on_CloseButton_pressed():
	get_parent().queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_parent().queue_free()
