extends CanvasLayer

func _ready() -> void:
	$Score.text = "Tiempo: " + Gamestate.levelTimer.get_formatted_time()
