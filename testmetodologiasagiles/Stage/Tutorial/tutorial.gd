extends Node2D

func _ready() -> void:
	Gamestate.currentLevel = self
	Gamestate.currentLevelNumber = 0
	var escenaPlayer = load("res://Player/player.tscn")
	var nuevoPlayer = escenaPlayer.instantiate()
	add_child(nuevoPlayer)
	nuevoPlayer.global_position = $Start.global_position
	Gamestate.camera.global_position = nuevoPlayer.global_position
	await get_tree().create_timer(0.1).timeout
	Gamestate.levelTimer.start()
