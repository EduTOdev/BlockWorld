extends CharacterBody2D

# Parametros Movimiento
@export var SPEED = 150.0
@export var JUMP_VELOCITY = -350.0
@export var WALL_JUMP_VELOCITY = Vector2(150, -350)
@export var DASHSPEED = 350.0
@export var DashDuracion = 0.15
@export var jump_buffer_time := 0.15
@export var healingMaxManaCost = 4
var jump_buffer_timer := 0.0
var Direction
var lastDirection = 0
var Dasheando = false
var Dashes = 1
var invulnerable = false
var wall_stick_time := 0.0
var wall_sliding := false
var healManaConsumed = 0
var healStatus = false
var justHealed = false

# Wall jump variables
var can_wall_jump := false
var wall_jump_cooldown := 0.0
var last_wall_dir := 0
var wall_jump_lock_time := 0.15
var wall_jump_timer := 0.0
var wall_dir = 0

# Aqui se guarda el arma actual y la lista de armas del player
var armaSeleccionada: Node2D
var armas = [
	"res://weapons/Laser/laser.tscn",
	"res://weapons/Shield/shield.tscn"
]

# Parametros de gravedad predeterminados de godot
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
# Variable para el coyote time
var tiempoAire: float
# Raycasts para la correccion de esquinas
@onready var raycastTopIzq: RayCast2D = $RayCastTopIzquierda
@onready var raycastTopDer: RayCast2D = $RayCastTopDerecha

# Funcion para automaticamente equipar el arma0
func _ready():
	Gamestate.player = self
	equiparArma(armas[0])
	await get_tree().create_timer(0.1).timeout
	Gamestate.camera.follow_target = self

# Se inicia el proceso de fisicas de godot
func _physics_process(delta: float) -> void:
	#Si no esta tocando el suelo le aplica la gravedad en su velocidad.y y aumenta tiempoAire en base
	#al tiempo que estuvo cayendo para aplicar coyote time
	if not is_on_floor() and !Dasheando:
		velocity.y += gravity * delta
		tiempoAire += delta
	elif is_on_floor():
		tocarSuelo()
	
	if Dasheando:
		velocity.y = 0
	
	wall_dir = 0
	detectarPared(delta)
	
	# Wall slide
	wall_sliding = false
	if wall_dir != 0 and not is_on_floor() and velocity.y > 0 and wall_jump_cooldown <= 0:
		wall_sliding = true
		velocity.y = min(velocity.y, 100) # Control de velocidad de caída
		can_wall_jump = true
		Dashes = 1
	else:
		can_wall_jump = false
	
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
	
	if raycastTopIzq.is_colliding() and !raycastTopDer.is_colliding(): # Correcion de esquinas Izq -> Der
		position.x += 5
	else: if !raycastTopIzq.is_colliding() and raycastTopDer.is_colliding(): # Correcion de esquinas Der -> Izq
		position.x -= 5
	
	if $RayCastBottomFront1.is_colliding() and !$RayCastBottomFront2.is_colliding() and Dasheando:
		position.y -= 8
	
	# Manipular el salto del player
	if Input.is_action_just_pressed("ui_accept") and tiempoAire < 0.1 and not can_wall_jump: # Coyote time
		jump()
	
	if Input.is_action_just_pressed("ui_accept") and can_wall_jump and tiempoAire < 0.1:
		wallJump()
	
	#Se recibe la input de movimiento del personaje y guarda 1 o -1 para indicar la direccion
	Direction = Input.get_axis("ui_left", "ui_right")
	
	# Cooldown para evitar reengancharse
	if wall_jump_cooldown > 0:
		wall_jump_cooldown -= delta
		if Direction != 0 and sign(Direction) == last_wall_dir:
			Direction = 0
	
	var healing = Input.is_action_pressed("Heal")
	if healing and is_on_floor() and !justHealed:
		startHealing(delta)
	else:
		healManaConsumed = 0
		
	healing = Input.is_action_just_released("Heal")
	if healing:
		justHealed = false
	
	if !Dasheando and !healStatus:
		move()

	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var tilemap = collision.get_collider()
		if tilemap is TileMapLayer:
			var coords = tilemap.local_to_map(collision.get_position())
			var tile_data = tilemap.get_cell_tile_data(coords)
			if tile_data and tile_data.get_custom_data("hazard"):
				_on_hazard_hit()
	
		# --- Efecto de Squash & Stretch ---
	var stretch_strength = clamp(abs(velocity.y) / 400.0, 0.0, 0.1) # 600 es velocidad máxima esperada al caer
	var sprite = $AnimatedSprite2D
	# Si está cayendo -> estirar
	if velocity.y > 0 and not is_on_floor() and not is_on_wall():
		sprite.scale.x = lerp(sprite.scale.x, 1.0 - stretch_strength, 0.2)
		sprite.scale.y = lerp(sprite.scale.y, 1.0 + stretch_strength, 0.2)
		if velocity.y > 300 and $AnimatedSprite2D.animation != "falling":
			$AnimatedSprite2D.animation = "falling"
			$AnimatedSprite2D.play()

	# Si toca el suelo -> squash (aplanarse brevemente)
	elif is_on_floor():
		var impact_strength = clamp(abs(velocity.y) / 400.0, 0.0, 0.1)
		sprite.scale.x = lerp(sprite.scale.x, 1.0 + impact_strength, 0.3)
		sprite.scale.y = lerp(sprite.scale.y, 1.0 - impact_strength, 0.3)
		
		# Regresar al tamaño normal poco después
		await get_tree().create_timer(0.08).timeout
		sprite.scale = sprite.scale.lerp(Vector2(1, 1), 0.3)

#Se detectan las teclas para diversas acciones
func _input(event: InputEvent) -> void:
	# Armas
	for i in range(armas.size()):
		if event.is_action_pressed("Arma" + str(i)):
			equiparArma(armas[i])
	# Movimiento
	if event.is_action_pressed("Dash"):
		dash()
	if event.is_action_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time

func dash():
	if Dasheando or Dashes <= 0:
		return
	Dasheando = true
	Dashes -= 1
	#Aplica la velocidad.x en base a la direccion
	if $AnimatedSprite2D.flip_h:
		velocity.x = -1 * DASHSPEED
	else:
		velocity.x = 1 * DASHSPEED
	#Se giran los sprites en base a la direccion
	$AnimatedSprite2D.animation = "Dash"
	$AnimatedSprite2D.play()
	await get_tree().create_timer(DashDuracion).timeout
	Dasheando = false

func equiparArma(rutaArma: String):
	#Se quita el arma actual
	if armaSeleccionada and armaSeleccionada.is_inside_tree():
		armaSeleccionada.queue_free()
	
	#Se carga la escena de la nueva arma
	var escenaArma = load(rutaArma)
	var nuevaArma = escenaArma.instantiate()
	#Se agrega la arma como child de WeaponHolder y actualiza el arma actual
	$WeaponHolder.add_child(nuevaArma)
	armaSeleccionada = nuevaArma

func ajustar_offsets(dir):
	if dir == 1:
		$AnimatedSprite2D.position.x = 0
		$WeaponHolder.position.x = 5
		$WeaponHolder/RayCastFront.position.x = -2
		$WeaponHolder/RayCastFront.target_position.x = 2
		$RayCastBottomFront1.position.x = 3
		$RayCastBottomFront1.target_position.x = 4
		$RayCastBottomFront2.position.x = 3
		$RayCastBottomFront2.target_position.x = 4
	elif dir == -1:
		$AnimatedSprite2D.position.x = 1
		$WeaponHolder.position.x = -4
		$WeaponHolder/RayCastFront.position.x = 2
		$WeaponHolder/RayCastFront.target_position.x = -2
		$RayCastBottomFront1.position.x = -2
		$RayCastBottomFront1.target_position.x = -4
		$RayCastBottomFront2.position.x = -2
		$RayCastBottomFront2.target_position.x = -4

func _on_hazard_hit():
	if invulnerable:
		return
	Gamestate.camera.startShake(0.7)
	invulnerable = true
	$AnimatedSprite2D.modulate = Color.RED
	Gamestate.actualHP -= 1
	Gamestate.hud.actualizarActualHP()

	if Gamestate.actualHP <= 0:
		# Puedes reiniciar nivel completo aquí si quieres
		print("Game Over")
	else:
		# Respawnea al último punto
		await get_tree().create_timer(0.1).timeout
		Gamestate.respawnPlayer()
		$AnimatedSprite2D.modulate = Color.WHITE
	
	await get_tree().create_timer(0.2).timeout
	invulnerable = false
	
func heal():
	if Gamestate.actualHP < Gamestate.totalHP:
		Gamestate.actualHP += 1
		Gamestate.hud.actualizarActualHP()
		Gamestate.camera.startShake(1.0)
		justHealed = true

func tocarSuelo():
	#Si toca el suelo reinicia su tiempoAire a 0
	tiempoAire = 0
	Dashes = 1
	wall_jump_cooldown = 0
	jump_buffer_timer = 0
	if jump_buffer_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		tiempoAire = 1

func detectarPared(delta):
	if is_on_wall():
		wall_dir = sign(get_wall_normal().x)
		last_wall_dir = wall_dir
		wall_stick_time = 0.2
		tiempoAire = 0
	else:
		# Usa el raycast frontal para verificar si sigue cerca de una pared
		var front_ray = $WeaponHolder/RayCastFront
		var still_near_wall = front_ray.is_colliding()
		if wall_stick_time > 0 and still_near_wall:
			wall_stick_time -= delta
			wall_dir = last_wall_dir
		else:
			wall_stick_time = 0
			wall_dir = 0

func jump():
	velocity.y = JUMP_VELOCITY
	# Se aumenta tiempoAire a un valor superior para indicar que ya se salto
	tiempoAire = 1
	$AnimatedSprite2D.animation = "jumping"
	$AnimatedSprite2D.play()

func wallJump():
	velocity.x -= -last_wall_dir * WALL_JUMP_VELOCITY.x
	velocity.y = WALL_JUMP_VELOCITY.y
	
	can_wall_jump = false
	wall_jump_cooldown = 0.15
	jump_buffer_timer = 0
	tiempoAire = 1
	wall_jump_timer = wall_jump_lock_time
	$AnimatedSprite2D.animation = "jumping"
	$AnimatedSprite2D.play()

func startHealing(delta):
	if Gamestate.actualMana > 0:
		var ManaConsumed = delta * 4
		Gamestate.actualMana -= ManaConsumed
		Gamestate.actualMana = clamp(Gamestate.actualMana, 0, Gamestate.totalMana)
		Gamestate.hud.actualizarActualMana()
		Gamestate.camera.startShake(0.2)
		healManaConsumed += ManaConsumed
		
		if Gamestate.actualMana <= 0:
			healManaConsumed = 0
			justHealed = true
		
		if healManaConsumed >= 4:
			heal()
			healManaConsumed = 0
	else:
		healManaConsumed = 0

func move():
	if wall_jump_timer <= 0:
		if Direction:
			$AnimatedSprite2D.flip_h = Direction < 0
			velocity.x = Direction * SPEED
			if velocity.y == 0 and $AnimatedSprite2D.animation != "moving":
				$AnimatedSprite2D.animation = "moving"
				$AnimatedSprite2D.play()
			if Direction != lastDirection:
				lastDirection = Direction
				ajustar_offsets(Direction)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if velocity.x == 0 and velocity.y == 0 and $AnimatedSprite2D.animation != "idle":
				$AnimatedSprite2D.animation = "idle"
