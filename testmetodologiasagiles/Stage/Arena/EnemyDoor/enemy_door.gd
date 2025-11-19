extends StaticBody2D

var offsetPuerta = -42

func closeDoor():
	$CollisionShape2D.set_deferred("disabled", false)
	offsetPuerta = 0

func openDoor():
	$CollisionShape2D.set_deferred("disabled", true)
	offsetPuerta = -42

func _process(delta) -> void:
	$Sprite2D.offset.y = move_toward($Sprite2D.offset.y, offsetPuerta, delta * 300)
