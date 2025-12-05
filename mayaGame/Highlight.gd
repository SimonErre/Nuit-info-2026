extends Sprite

# Script pour l'effet de surbrillance pulsante

var time = 0.0
var pulse_speed = 2.0
var min_alpha = 0.3
var max_alpha = 0.8
var min_scale = 0.4
var max_scale = 0.6

func _ready():
	# Créer un cercle/étoile de lumière via un simple ColorRect ou texture
	# On utilise un simple cercle blanc qu'on teinte
	_create_glow_texture()

func _create_glow_texture():
	# Créer une texture de cercle lumineux programmatiquement
	var img = Image.new()
	var size = 64
	img.create(size, size, false, Image.FORMAT_RGBA8)
	img.lock()
	
	var center = Vector2(size / 2, size / 2)
	var radius = size / 2
	
	for x in range(size):
		for y in range(size):
			var dist = Vector2(x, y).distance_to(center)
			if dist < radius:
				# Gradient du centre vers l'extérieur
				var alpha = 1.0 - (dist / radius)
				alpha = alpha * alpha  # Effet plus doux
				img.set_pixel(x, y, Color(1, 1, 0.8, alpha))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	
	img.unlock()
	
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	texture = tex

func _process(delta):
	time += delta * pulse_speed
	
	# Pulsation de l'opacité
	var alpha = lerp(min_alpha, max_alpha, (sin(time) + 1.0) / 2.0)
	modulate.a = alpha
	
	# Légère pulsation de la taille
	var scale_factor = lerp(min_scale, max_scale, (sin(time * 0.8) + 1.0) / 2.0)
	scale = Vector2(scale_factor, scale_factor)
