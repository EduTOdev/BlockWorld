extends Node2D

func _ready() -> void:
	Gamestate.game = self

func drawHUD():
	var escenaHUD = load("res://Player/HUD/HUD.tscn")
	var nuevoHud = escenaHUD.instantiate()
	add_child(nuevoHud)

func changeLevel(level):
	if level == 0:
		var escenaScore = load("res://Menu/Score/Tutorial/ScoreTutorial.tscn")
		var nuevoScore = escenaScore.instantiate()
		add_child(nuevoScore)
