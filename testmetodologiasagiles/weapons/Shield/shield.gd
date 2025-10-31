extends Node2D

#Parametros Escudo
var escudoActivado = false
var distanciaMaxima = 40

func _process(delta):
	escudoActivado = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var Player = get_parent().global_position
	var Mouse = get_global_mouse_position()
	var direccion = Mouse - Player
	var distancia = direccion.length()
	
	if escudoActivado:
		visible = true
		var direccionNormalizada = Vector2.ZERO
		if distancia != 0:
			direccionNormalizada = direccion.normalized()
		var distanciaFinal = min(distancia, 40)
		global_position = Player + direccionNormalizada * distanciaFinal
		if direccion != Vector2.ZERO:
			rotation = direccion.angle()
	else:
		visible = false
