extends CharacterBody2D

# Parametros Movimiento
const SPEED = 150.0
const JUMP_VELOCITY = -350.0

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
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		#Aplica la velocidad.x en base a la direccion
		velocity.x = direction * SPEED
		#Se giran los sprites en base a la direccion
		$AnimatedSprite2D.flip_h = direction < 0
		$WeaponHolder.position.x = 5 * direction
	else:
		#Si se suelta la tecla de movimiento se va reduciendo su velocidad gradualmente hasta llegar a 0
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

#Se detectan las teclas numericas para activar el cambio de armas
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Arma0"):
		equiparArma(armas[0])
	elif event.is_action_pressed("Arma1"):
		equiparArma(armas[1])
	
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
