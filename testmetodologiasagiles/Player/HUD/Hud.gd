extends CanvasLayer

const origenHPX = 30
const origenHPY = 30
const origenManaX = 30
const origenManaY = 80
const distanciaHP = 55
const distanciaMana = 40

func _ready() -> void:
	Gamestate.hud = self
	dibujarHP()
	dibujarMana()

func dibujarHP():
	for i in Gamestate.totalHP:
		var escenaHP = load("res://Player/HUD/HP/Corazon.tscn")
		var nuevoCorazon = escenaHP.instantiate()
		$HP.add_child(nuevoCorazon)
		nuevoCorazon.position.x = origenHPX + (i * distanciaHP)
		nuevoCorazon.position.y = origenHPY

func dibujarMana():
	for i in Gamestate.totalMana:
		var escenaMana = load("res://Player/HUD/Mana/ManaBola.tscn")
		var nuevoBola = escenaMana.instantiate()
		$Mana.add_child(nuevoBola)
		nuevoBola.position.x = origenManaX + (i * distanciaMana)
		nuevoBola.position.y = origenManaY

#-------- HP --------
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
		
	dibujarHP()

func actualizarActualHP():
	var indice = 0
	for child in $HP.get_children():
		if indice < Gamestate.actualHP:
			child.texture = load("res://Player/HUD/HP/CorazonFull.png")
		else:
			child.texture = load("res://Player/HUD/HP/CorazonFullNo.png")
		indice += 1

#-------- Mana --------
func agregarManaTotal():
	Gamestate.totalMana += 1
	actualizarManaTotal()
 
func disminuirManaTotal():
	if Gamestate.totalMana == 1:
		return
	Gamestate.totalMana -= 1
	actualizarManaTotal()

func actualizarManaTotal():
	for child in $Mana.get_children():
		child.queue_free()
		
	dibujarMana()

func actualizarActualMana():
	var indice = 0
	for child in $Mana.get_children():
		if indice < Gamestate.actualMana:
			child.texture = load("res://Player/HUD/Mana/ManaFull.png")
		else:
			child.texture = load("res://Player/HUD/Mana/ManaFullNo.png")
		indice += 1
