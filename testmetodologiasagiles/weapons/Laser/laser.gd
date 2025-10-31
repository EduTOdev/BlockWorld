extends Node2D

#Parametros Laser
var laserVisible = false

func _process(_delta):
	#Detecta en tiempo real si se esta manteniendo pulsado el clic izq del mouse
	laserVisible = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	#Activa redraw el cual manda a llamar draw constantemente para que se actualice la posicion del laser
	#en tiempo real
	if laserVisible:
		queue_redraw()
	else:
		queue_redraw()

func _draw():
	if laserVisible:
		var a = Vector2.ZERO
		var b = to_local(get_global_mouse_position())
		draw_line(a, b, Color.RED, 3)
