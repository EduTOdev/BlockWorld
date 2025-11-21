extends Button

func _on_pressed() -> void:
	#var escenaTutorial = load("res://Stage/Tutorial/Tutorial.tscn")
	var escenaTutorial = load("res://Stage/Nivel1/Nivel1.tscn")
	var nuevoTutorial = escenaTutorial.instantiate()
	Gamestate.game.add_child(nuevoTutorial)
	Gamestate.game.drawHUD()
	get_parent().queue_free()
