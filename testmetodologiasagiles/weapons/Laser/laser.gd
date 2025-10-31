extends Node2D

#Parametros Laser
var laserVisible = false

func _process(delta):
	laserVisible = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if laserVisible:
		queue_redraw()
	else:
		queue_redraw()

func _draw():
	if laserVisible:
		var a = Vector2.ZERO
		var b = to_local(get_global_mouse_position())
		draw_line(a, b, Color.RED, 3)
