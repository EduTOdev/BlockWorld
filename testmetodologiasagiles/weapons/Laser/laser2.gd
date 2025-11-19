extends Node2D

# ======================
#  Parámetros del Láser
# ======================
var laserVisible = false
@export var LaserColor := Color.RED : set = set_color
@export var LaserAnchura := 3.0
@export var collisionMask: int = 1
@export var manaRecoveryDelay := 0.5

# Posición de impacto
var hitPosition: Vector2
var hitCollider: Node = null

# Control de delay
var recoveryTimer := 0.0

# ======================
# Nodos de Efectos
# ======================
@onready var line_2d: Line2D = $Line2D
@onready var collision_particles: GPUParticles2D = $CollisionParticles2D
@onready var laser_particles: GPUParticles2D = $LaserParticles2D

# ======================
# Inicialización
# ======================
func _ready() -> void:
	set_color(LaserColor)
	_hide_beam()
	var mat := ShaderMaterial.new()
	mat.shader = load("res://weapons/Laser/laser.gdshader")

# ======================
# Color sincronizado
# ======================
func set_color(new_color: Color) -> void:
	LaserColor = new_color
	if !is_inside_tree():
		return
	if collision_particles:
		collision_particles.modulate = new_color
	if laser_particles:
		laser_particles.modulate = new_color

# ======================
# Lógica Principal
# ======================
func _process(delta):
	laserVisible = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	if laserVisible:
		recoveryTimer = manaRecoveryDelay

		if get_parent().get_child(0).is_colliding() or Gamestate.actualMana <= 0:
			laserVisible = false
			_hide_beam()
			return

		# Gasta maná mientras se dispara
		Gamestate.actualMana -= delta
		Gamestate.actualMana = clamp(Gamestate.actualMana, 0, Gamestate.totalMana)
		Gamestate.hud.actualizarActualMana()

		# Detecta colisión
		var Laser = global_position
		var Mouse = get_global_mouse_position()
		var spaceState = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(Laser, Mouse)
		query.exclude = [get_parent().get_parent()]
		query.collision_mask = (1 << 0) | (1 << 2) | (1 << 3)
		query.collide_with_areas = true
		query.collide_with_bodies = true

		var result = spaceState.intersect_ray(query)
		if result:
			hitPosition = result.position
			hitCollider = result.collider
			if hitCollider and hitCollider.has_method("apply_damage"):
				hitCollider.apply_damage(delta * 50)
		else:
			hitPosition = Mouse
			hitCollider = null

		_update_beam()
	else:
		_hide_beam()
		if recoveryTimer > 0:
			recoveryTimer -= delta
		else:
			if Gamestate.actualMana < Gamestate.totalMana:
				Gamestate.actualMana += delta
				Gamestate.actualMana = clamp(Gamestate.actualMana, 0, Gamestate.totalMana)
				Gamestate.hud.actualizarActualMana()

# ======================
# Control de Partículas
# ======================
func _update_beam():
	line_2d.visible = true
	collision_particles.emitting = true
	laser_particles.emitting = true

	var laser = hitPosition - global_position
	var direction = laser.normalized()
	var angle = direction.angle()
	var length = laser.length()

	# Actualiza línea
	line_2d.clear_points()
	line_2d.add_point(Vector2.ZERO)
	line_2d.add_point(to_local(hitPosition))

	# Posiciones de partículas
	collision_particles.global_position = hitPosition
	collision_particles.look_at(global_position)
	
	laser_particles.global_position = global_position.lerp(hitPosition, 0.5)
	laser_particles.rotation = angle
	
	var mat := laser_particles.process_material
	if mat and mat is ParticleProcessMaterial:
		# Ajustamos la caja de emisión (centrada)
		mat.emission_box_extents.x = length / 2.0

func _hide_beam():
	if !line_2d:
		return
	line_2d.visible = false
	collision_particles.emitting = false
	laser_particles.emitting = false
