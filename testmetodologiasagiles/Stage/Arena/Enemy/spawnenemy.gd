extends Node2D

var enemigoSpawneado = false

func spawnEnemy():
	var escenaEnemy = load("res://Enemy/Enemy.tscn")
	var nuevoEnemy = escenaEnemy.instantiate()
	add_child(nuevoEnemy)
	enemigoSpawneado = true

func _process(delta) -> void:
	if get_child_count() == 0 and enemigoSpawneado:
		queue_free()
