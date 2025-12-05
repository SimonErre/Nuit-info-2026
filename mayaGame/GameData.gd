extends Node

# === STATS DU JOUEUR ===
var knowledge_points: int = 0      # Connaissance accumulée (0-100)
var mood_points: int = 50          # Points de vie / Moral (0-100)
var max_mood: int = 100
var max_knowledge: int = 100

# === INVENTAIRE D'ARGUMENTS DÉBLOQUÉS ===
var unlocked_topics: Dictionary = {
	"markdown": false,
	"forge": false,
	"rgpd": false,
	"ecology": false,
	"sovereignty": false,
	"accessibility": false
}

# === STATISTIQUES DE COMBAT ===
var combo_count: int = 0
var max_combo: int = 0
var total_good_answers: int = 0
var total_bad_answers: int = 0
var roast_count: int = 0
var argument_points: int = 0

# === CONSTANTES ===
const CONVICTION_THRESHOLD: int = 75
const MIN_TOPICS_REQUIRED: int = 2

# === SIGNAUX ===
signal stats_updated
signal knowledge_changed(new_value)
signal mood_changed(new_value)
signal topic_unlocked(topic_id)
signal combo_changed(new_combo)
signal roasted
signal game_over

func _ready():
	print("🎮 GameData initialisé - Moral: " + str(mood_points) + " | Connaissance: " + str(knowledge_points))

func _input(event):
	# Cheat code: Ctrl + M pour maximiser les stats
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_M and event.control:
			activate_cheat_mode()

func activate_cheat_mode():
	print("🔓 MODE TRICHE ACTIVÉ!")
	
	# Maximiser les stats
	knowledge_points = max_knowledge
	mood_points = max_mood
	argument_points = 100
	
	# Débloquer tous les sujets
	for key in unlocked_topics:
		unlocked_topics[key] = true
		emit_signal("topic_unlocked", key)
	
	emit_signal("knowledge_changed", knowledge_points)
	emit_signal("mood_changed", mood_points)
	emit_signal("stats_updated")
	
	print("📊 Stats maximisées: Moral=" + str(mood_points) + " | Connaissance=" + str(knowledge_points))
	print("🎓 Tous les sujets débloqués!")

# === GESTION CONNAISSANCE ===
func add_knowledge(amount: int, topic_id: String = "") -> void:
	var old_value = knowledge_points
	knowledge_points = int(clamp(knowledge_points + amount, 0, max_knowledge))
	
	if topic_id != "" and topic_id in unlocked_topics:
		if not unlocked_topics[topic_id]:
			unlocked_topics[topic_id] = true
			emit_signal("topic_unlocked", topic_id)
			print("🎓 Sujet débloqué: " + topic_id)
	
	emit_signal("knowledge_changed", knowledge_points)
	emit_signal("stats_updated")
	print("📚 Connaissance: " + str(old_value) + " → " + str(knowledge_points))

func get_knowledge_percentage() -> int:
	return knowledge_points

func has_topic(topic_id: String) -> bool:
	return unlocked_topics.get(topic_id, false)

func get_unlocked_topics_count() -> int:
	var count = 0
	for key in unlocked_topics:
		if unlocked_topics[key]:
			count += 1
	return count

func get_unlocked_topics_list() -> Array:
	var list = []
	for key in unlocked_topics:
		if unlocked_topics[key]:
			list.append(key)
	return list

# === GESTION HUMEUR / MORAL (HP du joueur) ===
func change_mood(amount: int) -> void:
	var old_value = mood_points
	mood_points = int(clamp(mood_points + amount, 0, max_mood))
	
	emit_signal("mood_changed", mood_points)
	emit_signal("stats_updated")
	
	var emoji = "😊" if amount > 0 else "😰"
	print(emoji + " Moral: " + str(old_value) + " → " + str(mood_points))
	
	if mood_points <= 0:
		emit_signal("game_over")
		print("💀 GAME OVER: Vous craquez sous la pression!")

func get_mood() -> int:
	return mood_points

func get_mood_percentage() -> float:
	return float(mood_points) / float(max_mood) * 100.0

func get_mood_description() -> String:
	if mood_points >= 80:
		return "Confiant"
	elif mood_points >= 60:
		return "Serein"
	elif mood_points >= 40:
		return "Stressé"
	elif mood_points >= 20:
		return "Anxieux"
	else:
		return "Paniqué"

func is_game_over() -> bool:
	return mood_points <= 0

# Compatibilité avec l'ancien système
func get_director_mood() -> float:
	return float(mood_points - 50) * 2.0  # Convertit 0-100 en -100 à +100

# === INTERACTION COMBAT (DIALOGUE BOSS) ===
func on_good_answer(points_value: int = 10) -> void:
	combo_count += 1
	if combo_count > max_combo:
		max_combo = combo_count
	
	# Bonus de combo !
	var combo_multiplier = 1.0 + (combo_count - 1) * 0.15
	var final_points = int(points_value * combo_multiplier)
	argument_points += final_points
	
	# Une bonne réponse remonte le moral !
	var mood_gain = 3 + combo_count * 2
	change_mood(mood_gain)
	
	total_good_answers += 1
	
	emit_signal("combo_changed", combo_count)
	emit_signal("stats_updated")
	print("✅ Bonne réponse! Combo x" + str(combo_count) + " | +" + str(final_points) + " pts | +" + str(mood_gain) + " moral")

func on_bad_answer() -> void:
	combo_count = 0
	roast_count += 1
	total_bad_answers += 1
	
	# Dégâts réduits et plafonnés pour une expérience plus équilibrée
	var damage = min(8 + roast_count, 15)  # Entre 9 et 15 max
	change_mood(-damage)
	
	# Petite pénalité de points
	argument_points = int(max(0, argument_points - 2))
	
	emit_signal("combo_changed", combo_count)
	emit_signal("roasted")
	emit_signal("stats_updated")
	print("💀 ROAST! -" + str(damage) + " moral | Combo perdu")

func get_combo() -> int:
	return combo_count

func get_argument_points() -> int:
	return argument_points

func get_roast_count() -> int:
	return roast_count

# === CONDITION DE VICTOIRE ===
func can_convince_director() -> bool:
	var topics_mastered = get_unlocked_topics_count()
	var has_enough_knowledge = knowledge_points >= CONVICTION_THRESHOLD
	var has_enough_topics = topics_mastered >= MIN_TOPICS_REQUIRED
	var has_good_mood = mood_points > 15
	
	print("🎯 Vérification conviction:")
	print("   - Connaissance: " + str(knowledge_points) + "/" + str(CONVICTION_THRESHOLD))
	print("   - Sujets débloqués: " + str(topics_mastered) + "/" + str(MIN_TOPICS_REQUIRED))
	print("   - Moral: " + str(mood_points) + " (min 15)")
	
	return has_enough_knowledge and has_enough_topics and has_good_mood

# === GRADE FINAL ===
func get_final_grade() -> String:
	var score = argument_points + mood_points + knowledge_points - (roast_count * 10)
	if score >= 200:
		return "S - Légendaire!"
	elif score >= 150:
		return "A - Excellent"
	elif score >= 100:
		return "B - Très bien"
	elif score >= 60:
		return "C - Correct"
	elif score >= 30:
		return "D - Passable"
	else:
		return "F - Catastrophique"

# === RESET ===
func reset_conversation_stats() -> void:
	combo_count = 0
	# On garde le moral et la connaissance entre les conversations

func reset_all() -> void:
	knowledge_points = 0
	mood_points = 50
	combo_count = 0
	max_combo = 0
	total_good_answers = 0
	total_bad_answers = 0
	roast_count = 0
	argument_points = 0
	
	for key in unlocked_topics:
		unlocked_topics[key] = false
	
	emit_signal("stats_updated")
	print("🔄 Partie réinitialisée")
