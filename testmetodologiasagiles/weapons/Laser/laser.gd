extends Node2D

#Parametros Laser
var laserVisible = false
@export var LaserColor := Color.RED
@export var LaserAnchura := 3.0
@export var collisionMask: int = 1

#Posicion Impacto
var hitPosition: Vector2
var hitCollider: Node = null

func _process(_delta):
	#Detecta en tiempo real si se esta manteniendo pulsado el clic izq del mouse
	laserVisible = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if laserVisible:
		var Laser = global_position
		var Mouse = get_global_mouse_position()
		
		var spaceState = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(Laser, Mouse)
		query.exclude = [get_parent().get_parent()]
		query.collide_with_areas = true
		query.collide_with_bodies = true
		
		var result = spaceState.intersect_ray(query)
		if result:
			# Si hay colisión, usamos esa posición
			hitPosition = result.position
			hitCollider = result.collider
		else:
			# Si no hay colisión, llega hasta el mouse
			hitPosition = Mouse
			hitCollider = null
		queue_redraw()
	else:
		queue_redraw()
	
#Si el laser esta activado se dibuja desde su posicion hasta la posicion del mouse
func _draw():
	if not laserVisible:
		return
	
	var startLocal = Vector2.ZERO
	var endLocal = to_local(hitPosition)
	draw_line(startLocal, endLocal, LaserColor, LaserAnchura)
