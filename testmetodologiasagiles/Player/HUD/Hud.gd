extends CanvasLayer

const origenX = 30
const origenY = 30

func _ready() -> void:
	Gamestate.hud = self
	for i in Gamestate.totalHP:
		var escenaHP = load("res://Player/HUD/HP/Corazon.tscn")
		var nuevoCorazon = escenaHP.instantiate()
		$HP.add_child(nuevoCorazon)
		nuevoCorazon.position.x = origenX + (i * 40)
		nuevoCorazon.position.y = origenY

func agregarHPTotal():
	Gamestate.totalHP += 1
	actualizarHPTotal()

func disminuirHPTotal():
	if Gamestate.totalHP == 1:
		return
	Gamestate.totalHP -= 1
	actualizarHPTotal()

func actualizarHPTotal():
	for child in $HP.get_children():
		child.queue_free()
		
	for i in Gamestate.totalHP:
		var escenaHP = load("res://Player/HUD/HP/Corazon.tscn")
		var nuevoCorazon = escenaHP.instantiate()
		$HP.add_child(nuevoCorazon)
		nuevoCorazon.position.x = origenX + (i * 40)
		nuevoCorazon.position.y = origenY

func actualizarActualHP():
	var indice = 0
	for child in $HP.get_children():
		if indice < Gamestate.actualHP:
			child.texture = load("res://Player/HUD/HP/CorazonFull.png")
		else:
			child.texture = load("res://Player/HUD/HP/CorazonFullNo.png")
		indice += 1
