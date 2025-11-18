extends CharacterBody2D

# Parametros Movimiento
@export var SPEED = 150.0
@export var min_jump_time := 0.35
@export var max_jump_time := 1.1
var invulnerable = false
var health = 100
var dead = false

var target_position: Vector2
var is_charging = false
var is_jumping = false

var player_in_range := false
var jump_cooldown := 0.0

var player_in_explosion_range := false

# Parametros de gravedad predeterminados de godot
var gravity := 1200.0

func _on_area_2d_body_entered(body) -> void:
	if body == Gamestate.player:
		player_in_range = true

func _on_area_2d_body_exited(body) -> void:
	if body == Gamestate.player:
		player_in_range = false

func start_jump_charge():
	target_position = Gamestate.player.global_position
	is_charging = true
	if !dead:
		$AnimatedSprite2D.flip_h = target_position.x < global_position.x
	await get_tree().create_timer(2.0).timeout
	perform_jump()


func perform_jump():
	if is_jumping:
		return
	is_charging = false
	is_jumping = true

	var origin = global_position
	var dx = target_position.x - origin.x
	var dy = target_position.y - origin.y
	
	var distance = abs(dx)
	var jump_time = get_dynamic_jump_time(distance)

	velocity.x = dx / jump_time
	velocity.y = (dy - 0.5 * gravity * jump_time * jump_time) / jump_time

func get_dynamic_jump_time(distance: float) -> float:
	# Normaliza un valor 0–1 basado en 0–300px de distancia
	var normalized = clamp(distance / 300.0, 0.0, 1.0)

	# Interpola entre el tiempo mínimo y máximo
	return lerp(min_jump_time, max_jump_time, normalized)

func _process(delta: float) -> void:
	if !dead and $AnimatedSprite2D:
		if is_charging and $AnimatedSprite2D.animation != "charging":
			$AnimatedSprite2D.animation = "charging"
			$AnimatedSprite2D.play()
		elif is_jumping and $AnimatedSprite2D.animation != "jumping":
			$AnimatedSprite2D.animation = "jumping"
			$AnimatedSprite2D.play()
		elif is_on_floor() and !is_charging and !is_jumping:
			$AnimatedSprite2D.animation = "idle"
			$AnimatedSprite2D.play()
	
	if jump_cooldown > 0:
		jump_cooldown -= delta
		return
	
	if is_jumping or is_charging:
		return
	
	if player_in_range:
		start_jump_charge()

func _physics_process(delta):
	if is_jumping:
		velocity.y += gravity * delta
		$AnimatedSprite2D.rotation = velocity.angle() + rad_to_deg(-90)
	else:
		velocity.y += gravity * delta
	
	var max_vertical_force := -450

	if velocity.y < max_vertical_force:
		velocity.y = max_vertical_force

	move_and_slide()
	
	if !dead:
		# Si toca el suelo termina salto
		if is_jumping and is_on_floor():
			is_jumping = false
			velocity = Vector2.ZERO
			$AnimatedSprite2D.rotation = 0.0
			$Explosion.animation = "explosion"
			$Explosion.play()
			jump_cooldown = 1.0
			if player_in_explosion_range:
				Gamestate.player._taken_hit()
			await get_tree().create_timer(0.3).timeout
			$Explosion.animation = "default"
			$Explosion.play()
		
		for i in range(get_slide_collision_count()):
			checkCollisions(i)

func apply_damage(amount: float) -> void:
	health -= amount
	print("Enemy took damage! HP:", health)

	if health <= 0 and !dead:
		die()

func die():
	dead = true
	remove_child($AnimatedSprite2D)
	$Explosion.animation = "explosion"
	$Explosion.play()
	await get_tree().create_timer(0.7).timeout
	queue_free()


func _on_explosion_area_2d_body_entered(body) -> void:
	if body == Gamestate.player:
		player_in_explosion_range = true


func _on_explosion_area_2d_body_exited(body) -> void:
	if body == Gamestate.player:
		player_in_explosion_range = false

func checkCollisions(i):
	var collision = get_slide_collision(i)
	var tilemap = collision.get_collider()
	if tilemap is TileMapLayer:
		var coords = tilemap.local_to_map(collision.get_position())
		var tile_data = tilemap.get_cell_tile_data(coords)
		if tile_data and tile_data.get_custom_data("hazard"):
			if !dead:
				die()
