# ChatbotUI.gd - Interface de chat corrigée
extends CanvasLayer

var current_npc = null
var conversation_history: Array = []
var is_waiting_response: bool = false
var http_request: HTTPRequest = null

var worker_url = "https://floral-hall-4908.bilal-kigmou.workers.dev/"

var chat_panel: Panel = null
var messages_container: VBoxContainer = null
var messages_scroll: ScrollContainer = null
var input_field: LineEdit = null
var send_button: Button = null
var close_button: Button = null

func _ready():
	add_to_group("chatbot_ui")
	visible = false
	_setup_ui()

func _setup_ui():
	chat_panel = Panel.new()
	chat_panel.anchor_left = 0.15
	chat_panel.anchor_right = 0.85
	chat_panel.anchor_top = 0.1
	chat_panel.anchor_bottom = 0.9
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	panel_style.border_color = Color(0.6, 0.4, 0.8, 1.0)
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 15
	panel_style.corner_radius_top_right = 15
	panel_style.corner_radius_bottom_left = 15
	panel_style.corner_radius_bottom_right = 15
	chat_panel.add_stylebox_override("panel", panel_style)
	add_child(chat_panel)
	
	# Header
	var header = HBoxContainer.new()
	header.anchor_left = 0.02
	header.anchor_right = 0.98
	header.anchor_top = 0.02
	header.anchor_bottom = 0.08
	chat_panel.add_child(header)
	
	var title = Label.new()
	title.text = "🎭 Professeur Jean-Michel Sagesse"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_color_override("font_color", Color(0.8, 0.6, 1.0))
	header.add_child(title)
	
	close_button = Button.new()
	close_button.text = "X"
	close_button.rect_min_size = Vector2(35, 35)
	close_button.connect("pressed", self, "_on_close_pressed")
	# Style du bouton fermer
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.6, 0.2, 0.2, 0.9)
	btn_style.corner_radius_top_left = 5
	btn_style.corner_radius_top_right = 5
	btn_style.corner_radius_bottom_left = 5
	btn_style.corner_radius_bottom_right = 5
	close_button.add_stylebox_override("normal", btn_style)
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.8, 0.3, 0.3, 1.0)
	btn_hover.corner_radius_top_left = 5
	btn_hover.corner_radius_top_right = 5
	btn_hover.corner_radius_bottom_left = 5
	btn_hover.corner_radius_bottom_right = 5
	close_button.add_stylebox_override("hover", btn_hover)
	header.add_child(close_button)
	
	# Zone messages scrollable
	messages_scroll = ScrollContainer.new()
	messages_scroll.anchor_left = 0.02
	messages_scroll.anchor_right = 0.98
	messages_scroll.anchor_top = 0.1
	messages_scroll.anchor_bottom = 0.85
	messages_scroll.scroll_horizontal_enabled = false
	chat_panel.add_child(messages_scroll)
	
	messages_container = VBoxContainer.new()
	messages_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	messages_container.set("custom_constants/separation", 10)
	messages_scroll.add_child(messages_container)
	
	# Zone saisie
	var input_container = HBoxContainer.new()
	input_container.anchor_left = 0.02
	input_container.anchor_right = 0.98
	input_container.anchor_top = 0.87
	input_container.anchor_bottom = 0.96
	input_container.set("custom_constants/separation", 10)
	chat_panel.add_child(input_container)
	
	input_field = LineEdit.new()
	input_field.placeholder_text = "Pose une question au philosophe..."
	input_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_field.connect("text_entered", self, "_on_text_entered")
	input_container.add_child(input_field)
	
	send_button = Button.new()
	send_button.text = "Méditer"
	send_button.rect_min_size = Vector2(80, 0)
	send_button.connect("pressed", self, "_on_send_pressed")
	input_container.add_child(send_button)
	
	# HTTP Request
	http_request = HTTPRequest.new()
	http_request.connect("request_completed", self, "_on_request_completed")
	add_child(http_request)

func open_chat(npc):
	current_npc = npc
	visible = true
	conversation_history.clear()
	_clear_messages()
	_add_message("ia", "Ah, un visiteur ! *ajuste son monocle imaginaire* Je suis le Professeur Jean-Michel Sagesse. Pose-moi une question, et je te répondrai... à ma manière. 🎭")
	input_field.grab_focus()

func close_chat():
	visible = false
	if current_npc:
		current_npc.close_chatbot()
	current_npc = null

func _clear_messages():
	for child in messages_container.get_children():
		child.queue_free()

func _add_message(sender: String, text: String):
	var msg_container = HBoxContainer.new()
	msg_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Calculer la largeur adaptée au texte
	var char_width = 8
	var padding = 30
	var min_width = 80
	var max_width = 400
	var text_width = len(text) * char_width + padding
	var bubble_width = clamp(text_width, min_width, max_width)
	
	# Si le texte est long, on prend la largeur max
	if len(text) > 50:
		bubble_width = max_width
	
	# Bulle de message
	var bubble = Panel.new()
	bubble.rect_min_size = Vector2(bubble_width, 0)
	
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	
	if sender == "user":
		style.bg_color = Color(0.25, 0.55, 0.75, 0.95)
		style.corner_radius_bottom_right = 4
	else:
		style.bg_color = Color(0.35, 0.28, 0.45, 0.95)
		style.corner_radius_bottom_left = 4
	
	bubble.add_stylebox_override("panel", style)
	
	# Texte
	var label = Label.new()
	label.text = text
	label.autowrap = true
	label.rect_position = Vector2(12, 10)
	label.rect_size = Vector2(bubble_width - 24, 0)
	label.add_color_override("font_color", Color(1, 1, 1))
	bubble.add_child(label)
	
	# Ajuster hauteur de la bulle
	call_deferred("_adjust_bubble_height", bubble, label)
	
	# Positionner
	if sender == "user":
		msg_container.add_child(spacer)
		msg_container.add_child(bubble)
	else:
		msg_container.add_child(bubble)
		msg_container.add_child(spacer)
	
	messages_container.add_child(msg_container)
	call_deferred("_scroll_to_bottom")

func _adjust_bubble_height(bubble: Panel, label: Label):
	yield(get_tree(), "idle_frame")
	var lines = label.get_line_count()
	var line_height = 20
	bubble.rect_min_size.y = (lines * line_height) + 24
	label.rect_size.y = lines * line_height

func _scroll_to_bottom():
	yield(get_tree(), "idle_frame")
	messages_scroll.scroll_vertical = 99999

func _on_text_entered(_text: String):
	_send_message()

func _on_send_pressed():
	_send_message()

func _send_message():
	var text = input_field.text.strip_edges()
	if text.empty() or is_waiting_response:
		return
	
	input_field.text = ""
	_add_message("user", text)
	conversation_history.append({"role": "user", "text": text})
	_call_worker_api(text)

func _call_worker_api(user_message: String):
	is_waiting_response = true
	send_button.disabled = true
	_add_message("ia", "🤔 *médite profondément*...")
	
	var headers = ["Content-Type: application/json"]
	var body = JSON.print({"message": user_message})
	
	var error = http_request.request(worker_url, headers, true, HTTPClient.METHOD_POST, body)
	if error != OK:
		_remove_last_message()
		_add_message("ia", "Ma connexion cosmique est perturbée... 🌌")
		is_waiting_response = false
		send_button.disabled = false

func _on_request_completed(result, response_code, _headers, body):
	is_waiting_response = false
	send_button.disabled = false
	_remove_last_message()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		_add_message("ia", "Les ondes philosophiques sont brouillées... 🌀")
		return
	
	var json = JSON.parse(body.get_string_from_utf8())
	if json.error != OK:
		_add_message("ia", "Je n'ai pas compris la réponse de l'univers... 🤷")
		return
	
	var data = json.result
	if data.has("reply"):
		_add_message("ia", data["reply"])
	elif data.has("error"):
		_add_message("ia", "Erreur cosmique : " + str(data["error"]))
	else:
		_add_message("ia", "Le silence est parfois une réponse... 🧘")

func _remove_last_message():
	var count = messages_container.get_child_count()
	if count > 0:
		messages_container.get_child(count - 1).queue_free()

func _on_close_pressed():
	close_chat()

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		close_chat()
