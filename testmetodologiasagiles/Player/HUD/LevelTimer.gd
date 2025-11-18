extends Node2D

var time := 0.0
var running := false

func _ready() -> void:
	Gamestate.levelTimer = self

func start():
	time = 0
	running = true

func stop():
	running = false

func reset():
	time = 0
	running = false

func _process(delta):
	if running:
		time += delta
	$Label.text = get_formatted_time()

func get_formatted_time() -> String:
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
