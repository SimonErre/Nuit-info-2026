extends Area2D

export var knowledge_amount: float = 10.0
export var knowledge_topic: String = "Général"
export var topic_id: String = ""  # ID du sujet à débloquer (markdown, forge, etc.)
var is_collected: bool = false

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if not is_collected and (body.name == "player" or body.is_in_group("player")):
		collect()

func collect():
	is_collected = true
	GameData.add_knowledge(int(knowledge_amount), topic_id)
	GameData.change_mood(3)  # Ramasser un item boost le moral
	
	# Afficher un message de feedback
	print("📚 +" + str(int(knowledge_amount)) + "% connaissance: " + knowledge_topic)
	
	# Animation de disparition
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "scale", scale, scale * 1.5, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()
