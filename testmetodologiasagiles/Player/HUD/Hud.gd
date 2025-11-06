extends CanvasLayer

@export var HP = 5
const origenX = 30
const origenY = 30

func _ready() -> void:
	for i in HP:
		var escenaHP = load("res://Player/HUD/HP/Corazon.tscn")
		var nuevoCorazon = escenaHP.instantiate()
		$HP.add_child(nuevoCorazon)
		nuevoCorazon.position.x = origenX + (i * 40)
		nuevoCorazon.position.y = origenY
