extends Area2D

func _on_body_entered(body):
	if body == Gamestate.player:
		Gamestate.levelTimer.stop()
		Gamestate.hud.visible = false
		Gamestate.game.changeLevel(Gamestate.currentLevelNumber)
		Gamestate.currentLevel.queue_free()
