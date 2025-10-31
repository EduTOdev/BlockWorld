extends CharacterBody2D

# Parametros Movimiento
const SPEED = 150.0
const JUMP_VELOCITY = -350.0

# Aqui se guarda el arma actual del personaje
var armaSeleccionada: Node2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var tiempoAire: float
var raycastIzq: RayCast2D
var raycastDer: RayCast2D
var proyectile1: Node2D

func _ready():
	equiparArma("res://weapons/Laser/laser.tscn")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		tiempoAire += delta
	else:
		tiempoAire = 0;
	
	raycastIzq = $RayCastIzquierda
	raycastDer = $RayCastDerecha
	
	if raycastIzq.is_colliding() and !raycastDer.is_colliding(): # Correcion de esquinas Izq -> Der
		position.x += 5
	else: if !raycastIzq.is_colliding() and raycastDer.is_colliding(): # Correcion de esquinas Der -> Izq
		position.x -= 5
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and tiempoAire < 0.1: # Coyote time
		velocity.y = JUMP_VELOCITY
		tiempoAire = 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.flip_h = direction < 0
		$WeaponHolder.position.x = 5 * direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Arma1"):
		equiparArma("res://weapons/Laser/laser.tscn")
	elif event.is_action_pressed("Arma2"):
		equiparArma("res://weapons/Shield/shield.tscn")
		
func equiparArma(rutaArma: String):
	if armaSeleccionada and armaSeleccionada.is_inside_tree():
		armaSeleccionada.queue_free()
	
	var escenaArma = load(rutaArma)
	var nuevaArma = escenaArma.instantiate()
	$WeaponHolder.add_child(nuevaArma)
	armaSeleccionada = nuevaArma
