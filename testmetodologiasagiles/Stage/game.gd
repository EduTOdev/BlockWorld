extends Node2D

var hud: CanvasLayer = null

func _ready() -> void:
	var escenaHUD = load("res://Player/HUD/HUD.tscn")
	var nuevoHud = escenaHUD.instantiate()
	add_child(nuevoHud)
