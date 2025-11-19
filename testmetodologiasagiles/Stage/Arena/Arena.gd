extends Node2D

var arena_active := false
var arena_cleared := false

func _on_area_2d_body_entered(body) -> void:
	if arena_active or arena_cleared:
		return
	
	if body == Gamestate.player:
		arena_active = true
		for enemy in $Enemys.get_children():
			enemy.call_deferred("spawnEnemy")
		for doors in $Doors.get_children():
			doors.call_deferred("closeDoor")
		set_process(true)

func _process(_delta):
	if arena_active and $Enemys.get_child_count() == 0:
		arena_active = false
		arena_cleared = true
		set_process(false)
		for doors in $Doors.get_children():
			doors.call_deferred("openDoor")
