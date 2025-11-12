extends CharacterBody2D

# Parametros Movimiento
@export var SPEED = 150.0
@export var JUMP_VELOCITY = -350.0
@export var WALL_JUMP_VELOCITY = Vector2(150, -350)
@export var DASHSPEED = 350.0
@export var DashDuracion = 0.15
@export var jump_buffer_time := 0.15
var jump_buffer_timer := 0.0
var Direction
var lastDirection = 0
var Dasheando = false
var Dashes = 1
var invulnerable = false
var wall_stick_time := 0.0
var wall_sliding := false

# Wall jump variables
var can_wall_jump := false
var wall_jump_cooldown := 0.0
var last_wall_dir := 0
var wall_jump_lock_time := 0.15
var wall_jump_timer := 0.0

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
var raycastTopIzq: RayCast2D
var raycastTopDer: RayCast2D

# Funcion para automaticamente equipar el arma0
func _ready():
	Gamestate.player = self
	equiparArma(armas[0])

# Se inicia el proceso de fisicas de godot
func _physics_process(delta: float) -> void:
	#Si no esta tocando el suelo le aplica la gravedad en su velocidad.y y aumenta tiempoAire en base
	#al tiempo que estuvo cayendo para aplicar coyote time
	if not is_on_floor() and !Dasheando:
		velocity.y += gravity * delta
		tiempoAire += delta
	elif is_on_floor():
		#Si toca el suelo reinicia su tiempoAire a 0
		tiempoAire = 0
		Dashes = 1
		wall_jump_cooldown = 0
		jump_buffer_timer = 0
		if jump_buffer_timer > 0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0
			tiempoAire = 1
	
	if Dasheando:
		velocity.y = 0
	
	var wall_dir := 0
	if is_on_wall():
		wall_dir = sign(get_wall_normal().x)
		last_wall_dir = wall_dir
		wall_stick_time = 0.2
	else:
		if wall_stick_time > 0:
			if wall_dir != Direction:
				wall_stick_time = 0
			wall_stick_time -= delta
			wall_dir = last_wall_dir
		else:
			wall_dir = 0
	
	# Wall slide
	wall_sliding = false
	if wall_dir != 0 and not is_on_floor() and velocity.y > 0 and wall_jump_cooldown <= 0:
		wall_sliding = true
		velocity.y = min(velocity.y, 100) # Control de velocidad de caída
		can_wall_jump = true
	else:
		can_wall_jump = false
	
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
	
	#Le indicamos su respectivo raycast a las variables
	raycastTopIzq = $RayCastTopIzquierda
	raycastTopDer = $RayCastTopDerecha
	
	if raycastTopIzq.is_colliding() and !raycastTopDer.is_colliding(): # Correcion de esquinas Izq -> Der
		position.x += 5
	else: if !raycastTopIzq.is_colliding() and raycastTopDer.is_colliding(): # Correcion de esquinas Der -> Izq
		position.x -= 5
	
	if $RayCastBottomFront1.is_colliding() and !$RayCastBottomFront2.is_colliding() and Dasheando:
		position.y -= 8
	
	# Manipular el salto del player
	if Input.is_action_just_pressed("ui_accept") and tiempoAire < 0.1: # Coyote time
		velocity.y = JUMP_VELOCITY
		# Se aumenta tiempoAire a un valor superior para indicar que ya se salto
		tiempoAire = 1
	
	if Input.is_action_just_pressed("ui_accept") and can_wall_jump:
		velocity.x -= -last_wall_dir * WALL_JUMP_VELOCITY.x
		velocity.y = WALL_JUMP_VELOCITY.y
		
		can_wall_jump = false
		wall_jump_cooldown = 0.25
		jump_buffer_timer = 0
		tiempoAire = 1
		wall_jump_timer = wall_jump_lock_time
	
	#Se recibe la input de movimiento del personaje y guarda 1 o -1 para indicar la direccion
	Direction = Input.get_axis("ui_left", "ui_right")
	
	# Cooldown para evitar reengancharse
	if wall_jump_cooldown > 0:
		wall_jump_cooldown -= delta
		if Direction != 0 and sign(Direction) == last_wall_dir:
			Direction = 0
	
	if !Dasheando:
		if wall_jump_timer <= 0:
			if Direction:
				$AnimatedSprite2D.flip_h = Direction < 0
				velocity.x = Direction * SPEED
				if $AnimatedSprite2D.animation != "moving":
					$AnimatedSprite2D.animation = "moving"
					$AnimatedSprite2D.play()
				if Direction != lastDirection:
					lastDirection = Direction
					ajustar_offsets(Direction)
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				if velocity.x == 0 and $AnimatedSprite2D.animation != "idle":
					$AnimatedSprite2D.animation = "idle"

	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var tilemap = collision.get_collider()
		if tilemap is TileMapLayer:
			var coords = tilemap.local_to_map(collision.get_position())
			var tile_data = tilemap.get_cell_tile_data(coords)
			if tile_data and tile_data.get_custom_data("hazard"):
				_on_hazard_hit()

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
	Gamestate.actualHP -= 1
	Gamestate.hud.actualizarActualHP()

	if Gamestate.actualHP <= 0:
		# Puedes reiniciar nivel completo aquí si quieres
		print("Game Over")
	else:
		# Respawnea al último punto
		await get_tree().create_timer(0.1).timeout
		Gamestate.respawnPlayer()
	
	await get_tree().create_timer(0.2).timeout
	invulnerable = false
