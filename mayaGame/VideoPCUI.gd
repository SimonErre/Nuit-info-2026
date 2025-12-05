extends CanvasLayer

var is_open = false
var just_opened = false
var video_url = "https://www.youtube.com/watch?v=76T8oubek-c"

func _ready():
	hide_computer()
	$Control/Monitor/Screen/VideoIcon.connect("file_opened", self, "_on_video_opened")
	$Control/Monitor/Screen/VideoPlayer/TitleBar/CloseBtn.connect("pressed", self, "_on_close_video")
	$Control/Monitor/Screen/VideoPlayer/CopyBtn.connect("pressed", self, "_on_copy_link")

func _on_video_opened():
	$Control/Monitor/Screen/VideoPlayer.visible = true

func _on_close_video():
	$Control/Monitor/Screen/VideoPlayer.visible = false

func _on_copy_link():
	OS.set_clipboard(video_url)
	$Control/Monitor/Screen/VideoPlayer/CopyBtn.text = "Copié !"

func _input(event):
	if is_open:
		if just_opened:
			if event.is_action_released("interact"):
				just_opened = false
			return
		if event.is_action_pressed("ui_cancel"):
			hide_computer()
			get_tree().set_input_as_handled()

func show_computer():
	is_open = true
	just_opened = true
	$Control.visible = true
	$Control/CloseHint.visible = true
	$Control/Monitor/Screen.visible = true
	$Control/Monitor/Taskbar.visible = true
	get_tree().paused = true

func hide_computer():
	is_open = false
	$Control.visible = false
	$Control/Monitor/Screen/VideoPlayer.visible = false
	$Control/Monitor/Screen/VideoPlayer/CopyBtn.text = "Copier le lien"
	get_tree().paused = false
