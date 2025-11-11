extends Camera2D

var shakeStrength := 0.0
@export var shakeDecay := 5.0  # Qué tan rápido se reduce la fuerza
@export var shakeIntensity := 5.0  # Escala general de la sacudida

func _ready() -> void:
	Gamestate.camera = self

func _process(delta):
	if Gamestate.player:
		global_position = global_position.lerp(Gamestate.player.global_position, 0.1)
	
	if shakeStrength > 0:
		shakeStrength = max(shakeStrength - shakeDecay * delta, 0)
		offset = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shakeStrength * shakeIntensity
	else:
		offset = Vector2.ZERO

func startShake(strength: float):
	shakeStrength = strength
