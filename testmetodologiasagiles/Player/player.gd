extends CharacterBody2D

# Parametros Movimiento
@export var SPEED = 150.0
@export var JUMP_VELOCITY = -350.0
@export var DASHSPEED = 300.0
@export var DashDuracion = 0.2
var Direction
var Dasheando = false
var HP

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
var raycastIzq: RayCast2D
var raycastDer: RayCast2D

# Funcion para automaticamente equipar el arma0
func _ready():
	equiparArma(armas[0])
	#HP = Gamestate.hud.obtenerHPTotal()

# Se inicia el proceso de fisicas de godot
func _physics_process(delta: float) -> void:
	#Si no esta tocando el suelo le aplica la gravedad en su velocidad.y y aumenta tiempoAire en base
	#al tiempo que estuvo cayendo para aplicar coyote time
	if not is_on_floor():
		velocity.y += gravity * delta
		tiempoAire += delta
	else:
		#Si toca el suelo reinicia su tiempoAire a 0
		tiempoAire = 0;
	
	#Le indicamos su respectivo raycast a las variables
	raycastIzq = $RayCastIzquierda
	raycastDer = $RayCastDerecha
	
	if raycastIzq.is_colliding() and !raycastDer.is_colliding(): # Correcion de esquinas Izq -> Der
		position.x += 5
	else: if !raycastIzq.is_colliding() and raycastDer.is_colliding(): # Correcion de esquinas Der -> Izq
		position.x -= 5
	
	# Manipular el salto del player
	if Input.is_action_just_pressed("ui_accept") and tiempoAire < 0.1: # Coyote time
		velocity.y = JUMP_VELOCITY
		# Se aumenta tiempoAire a un valor superior para indicar que ya se salto
		tiempoAire = 1
	
	#Se recibe la input de movimiento del personaje y guarda 1 o -1 para indicar la direccion
	Direction = Input.get_axis("ui_left", "ui_right")
	if !Dasheando:
		if Direction:
			#Aplica la velocidad.x en base a la direccion
			velocity.x = Direction * SPEED
			#Se giran los sprites en base a la direccion
			$AnimatedSprite2D.flip_h = Direction < 0
			if $AnimatedSprite2D.animation != "moving":
				$AnimatedSprite2D.animation = "moving"
				$AnimatedSprite2D.play()
			if Direction == 1:
				$AnimatedSprite2D.position.x = 0
				$WeaponHolder.position.x = 5
				$WeaponHolder/RayCastFront.position.x = -2
				$WeaponHolder/RayCastFront.target_position.x = 2
			else: if Direction == -1:
				$AnimatedSprite2D.position.x = 1
				$WeaponHolder.position.x = -4
				$WeaponHolder/RayCastFront.position.x = 2
				$WeaponHolder/RayCastFront.target_position.x = -2
		else:
			#Si se suelta la tecla de movimiento se va reduciendo su velocidad gradualmente hasta llegar a 0
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if velocity.x == 0 and $AnimatedSprite2D.animation != "idle":
				$AnimatedSprite2D.animation = "idle"
	
	move_and_slide()

#Se detectan las teclas para diversas acciones
func _input(event: InputEvent) -> void:
	# Armas
	for i in range(armas.size()):
		if event.is_action_pressed("Arma" + str(i)):
			equiparArma(armas[i])
	# Movimiento
	if event.is_action_pressed("Dash"):
		dash()

func dash():
	#Gamestate.hud.actualizarActualHP(HP)
	if Dasheando:
		return
	Dasheando = true
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
