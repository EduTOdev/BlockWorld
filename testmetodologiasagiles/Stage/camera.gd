extends Camera2D

func _ready() -> void:
	Gamestate.camera = self

func _process(_delta):
	if Gamestate.player:
		global_position = global_position.lerp(Gamestate.player.global_position, 0.1)
