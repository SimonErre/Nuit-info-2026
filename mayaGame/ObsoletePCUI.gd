extends CanvasLayer

var is_open = false
var just_opened = false

func _ready():
	$Control.visible = false

func show_bsod():
	is_open = true
	just_opened = true
	$Control.visible = true
	get_tree().paused = true

func _input(event):
	if is_open:
		if just_opened:
			if event.is_action_released("interact"):
				just_opened = false
			return
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact"):
			close_bsod()
			get_tree().set_input_as_handled()

func close_bsod():
	is_open = false
	$Control.visible = false
	get_tree().paused = false
