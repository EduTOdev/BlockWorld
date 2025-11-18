extends Button

func _on_pressed() -> void:
	var escenaNivel = load("res://Stage/Nivel1/Nivel1.tscn")
	var nuevoNivel = escenaNivel.instantiate()
	Gamestate.game.add_child(nuevoNivel)
	Gamestate.hud.visible = true
	get_parent().queue_free()
