extends CanvasLayer

const OrigenBorderX = 70
const OrigenBorderY = 65
const origenHPX = 160
const origenHPY = 40
const origenManaX = 160
const origenManaY = 90
const distanciaHP = 55
const distanciaMana = 40

func _ready() -> void:
	Gamestate.hud = self
	dibujarHP()
	dibujarMana()
	dibujarBorder()

func dibujarBorder():
	var escenaBorder = load("res://Player/HUD/Status/border.tscn")
	var NuevoBorder = escenaBorder.instantiate()
	$Status.add_child(NuevoBorder)
	NuevoBorder.position.x = OrigenBorderX
	NuevoBorder.position.y = OrigenBorderY

func changeStatus(status: String):
	if status == "Default":
		$Status.get_child(0).get_child(0).texture = load("res://Player/HUD/Status/statusDefault.png")
	if status == "Damaged":
		$Status.get_child(0).get_child(0).texture = load("res://Player/HUD/Status/statusDamaged.png")
	if status == "1HP":
		$Status.get_child(0).get_child(0).texture = load("res://Player/HUD/Status/status1HP.png")

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
		if indice < floor(Gamestate.actualMana):
			child.texture = load("res://Player/HUD/Mana/ManaFull.png")
		else:
			child.texture = load("res://Player/HUD/Mana/ManaFullNo.png")
		indice += 1
