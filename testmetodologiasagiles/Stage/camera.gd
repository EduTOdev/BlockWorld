extends Camera2D

var shakeStrength := 0.0
@export var shakeDecay := 5.0  # Qué tan rápido se reduce la fuerza
@export var shakeIntensity := 5.0  # Escala general de la sacudida

@export var follow_target: CharacterBody2D
@export var base_smooth_speed := 6.0     # Velocidad base del seguimiento
@export var max_smooth_speed := 30.0     # Máxima velocidad cuando el jugador va rápido
@export var speed_distance_threshold := 40.0  # Distancia a la que empieza a acelerar
@export var smoothing_enabled := true

func _ready() -> void:
	Gamestate.camera = self

func _process(delta):
	if not follow_target:
		return

	# Posición objetivo (jugador)
	var target_pos = follow_target.global_position
	var cam_pos = global_position
	var distance = cam_pos.distance_to(target_pos)

	# Calcula la “fuerza” del seguimiento dinámico
	var smooth_speed = base_smooth_speed
	if distance > speed_distance_threshold:
		var excess = distance - speed_distance_threshold
		smooth_speed = lerp(base_smooth_speed, max_smooth_speed, clamp(excess / 200.0, 0.0, 1.0))

	# Aplica el smoothing dinámico
	global_position = global_position.lerp(target_pos, delta * smooth_speed)
	
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
