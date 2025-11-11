extends Node2D

#Parametros Escudo
var escudoActivado = false
var distanciaMaxima = 40

@export var manaRecoveryDelay := 0.5
# Control de delay
var recoveryTimer := 0.0

func _process(delta):
	escudoActivado = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var Player = get_parent().get_parent().global_position
	var Mouse = get_global_mouse_position()
	var direccion = Mouse - Player
	var distancia = direccion.length()
	
	if escudoActivado:
		if Gamestate.actualMana <= 0:
			visible = false
			return
		visible = true
		Gamestate.actualMana -= delta * 2
		Gamestate.actualMana = clamp(Gamestate.actualMana, 0, Gamestate.totalMana)
		Gamestate.hud.actualizarActualMana()
		var direccionNormalizada = Vector2.ZERO
		if distancia != 0:
			direccionNormalizada = direccion.normalized()
		var distanciaFinal = min(distancia, 40)
		global_position = Player + direccionNormalizada * distanciaFinal
		if direccion != Vector2.ZERO:
			rotation = direccion.angle()
	else:
		if recoveryTimer > 0:
			recoveryTimer -= delta
		else:
			if Gamestate.actualMana < Gamestate.totalMana:
				Gamestate.actualMana += delta
				Gamestate.actualMana = clamp(Gamestate.actualMana, 0, Gamestate.totalMana)
				Gamestate.hud.actualizarActualMana()
		visible = false
