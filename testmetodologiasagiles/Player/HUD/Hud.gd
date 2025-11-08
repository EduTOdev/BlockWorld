extends CanvasLayer

@export var HP = 5
const origenX = 30
const origenY = 30

func _ready() -> void:
	Gamestate.hud = self
	for i in HP:
		var escenaHP = load("res://Player/HUD/HP/Corazon.tscn")
		var nuevoCorazon = escenaHP.instantiate()
		$HP.add_child(nuevoCorazon)
		nuevoCorazon.position.x = origenX + (i * 40)
		nuevoCorazon.position.y = origenY

func obtenerHPTotal():
	return HP

func agregarHPTotal():
	HP += 1
	actualizarHPTotal()

func disminuirHPTotal():
	if HP == 1:
		return
	HP -= 1
	actualizarHPTotal()

func actualizarHPTotal():
	for child in $HP.get_children():
		child.queue_free()
		
	for i in HP:
		var escenaHP = load("res://Player/HUD/HP/Corazon.tscn")
		var nuevoCorazon = escenaHP.instantiate()
		$HP.add_child(nuevoCorazon)
		nuevoCorazon.position.x = origenX + (i * 40)
		nuevoCorazon.position.y = origenY

func actualizarActualHP(actualHP: int):
	var indice = 0
	for child in $HP.get_children():
		var sprite = child.get_node("Sprite2D")
		if indice < actualHP:
			sprite.texture = load("res://Player/HUD/HP/CorazonFull.png")
		else:
			sprite.texture = load("res://Player/HUD/HP/CorazonFull.png")
		indice += 1
