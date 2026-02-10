extends Node3D

@export var speed: float = 0.0
@export var max_speed: float = 50.0
@export var acceleration: float = 20.0
@export var deceleration: float = 10.0
@export var road_mesh: MeshInstance3D

@export var background_rect: TextureRect
@export var mountain_rect: TextureRect

var spawn_timer: float = 0.0
var current_curve: float = 0.0
var target_curve: float = 0.0
var curve_timer: float = 0.0
var bg_scroll: float = 0.0
var mnt_scroll: float = 0.0

@export var enemy_scene: PackedScene
@export var puddle_scene: PackedScene
var puddle_timer: float = 0.0

var score: int = 0
var distance: float = 0.0
var cars_passed: int = 0

# Turbo Logic
var is_turbo_active: bool = false
var turbo_charge: float = 5.0 # Seconds remaining until ready (starts empty or full? Let's say full: 5.0)
var turbo_cooldown_max: float = 5.0
var turbo_duration: float = 3.0
var turbo_timer: float = 0.0
@export var camera: Camera3D

signal score_updated(new_score, new_distance, cars_passed)
signal turbo_updated(is_ready, charge_percent, is_active)

# Stage Logic
var current_stage_index: int = 0
var stage_distance_threshold: float = 2000.0
var sky_textures: Array = [
	preload("res://assets/sprites/sky_bg.png"),
	preload("res://assets/sprites/sky_sunset.png"),
	preload("res://assets/sprites/sky_day.png")
]

func _ready() -> void:
	# Ensure correct initial state
	if background_rect:
		background_rect.texture = sky_textures[0]
	current_stage_index = 0
	
	if puddle_scene:
		puddle_timer = randf_range(2.0, 5.0)

func _process(delta: float) -> void:
	# Turbo Input
	if Input.is_action_just_pressed("ui_accept") and not is_turbo_active and turbo_charge >= turbo_cooldown_max:
		activate_turbo()

	# Turbo State Management
	if is_turbo_active:
		turbo_timer -= delta
		if turbo_timer <= 0:
			deactivate_turbo()
	else:
		# Recharge
		if turbo_charge < turbo_cooldown_max:
			turbo_charge += delta
			if turbo_charge > turbo_cooldown_max:
				turbo_charge = turbo_cooldown_max
	
	# Update UI
	emit_signal("turbo_updated", turbo_charge >= turbo_cooldown_max, turbo_charge / turbo_cooldown_max, is_turbo_active)

	# Update Camera FOV for warp effect
	if camera:
		var target_fov = 90.0 if is_turbo_active else 75.0
		camera.fov = move_toward(camera.fov, target_fov, delta * 50.0)

	if speed > 0.0:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_enemy()
			spawn_timer = randf_range(1.0, 3.0)
			
		puddle_timer -= delta
		if puddle_timer <= 0:
			spawn_puddle()
			puddle_timer = randf_range(3.0, 8.0) # Puddles are rarer

		# Advance along curve
		distance += speed * delta
		
		# Check for Stage Transition
		var new_stage_index = int(distance / stage_distance_threshold) % sky_textures.size()
		if new_stage_index != current_stage_index:
			current_stage_index = new_stage_index
			if background_rect:
				background_rect.texture = sky_textures[current_stage_index]
		
		# Check for Stage Transition
		var new_stage_index = int(distance / stage_distance_threshold) % sky_textures.size()
		if new_stage_index != current_stage_index:
			current_stage_index = new_stage_index
			if background_rect:
				background_rect.texture = sky_textures[current_stage_index]
		
		# Passing logic is handled in EnemyCar.gd
				
		score = int(distance) + (cars_passed * 100)
		emit_signal("score_updated", score, distance, cars_passed)

	# Handle speed inputs (communicated via player or direct input for now)
	# ... (existing speed logic)
	
	if Input.is_action_pressed("ui_up"):
		speed = move_toward(speed, max_speed, acceleration * delta)
	elif Input.is_action_pressed("ui_down"):
		speed = move_toward(speed, 0.0, acceleration * 2.0 * delta)
	else:
		speed = move_toward(speed, 0.0, deceleration * delta)
		
	# Update Shader
	if road_mesh:
		var mat = road_mesh.get_active_material(0)
		if mat:
			mat.set_shader_parameter("speed", speed * 0.1) # Scale for UV scrolling
			mat.set_shader_parameter("curve_strength", current_curve)

	# Turn Logic
	curve_timer -= delta
	if curve_timer <= 0:
		# State Machine for Curves
		# 0 = Straight, 1 = Enter Turn, 2 = Hold Turn, 3 = Exit Turn
		# Let's simplify: Pick a new target curve state
		if abs(target_curve) < 0.01:
			# Currently straight, pick a turn
			var turn_direction = 1 if randf() > 0.5 else -1
			target_curve = randf_range(0.1, 0.3) * turn_direction # Stronger curves (was 0.05)
			curve_timer = randf_range(2.0, 4.0) # Time to hold the turn
		else:
			# Currently turning, go straight
			target_curve = 0.0
			curve_timer = randf_range(1.0, 3.0) # Time to stay straight
	
	# Smoothly interpolate current curve to target
	current_curve = move_toward(current_curve, target_curve, delta * 0.2) # Faster transition (was 0.01)

	# Parallax Background Scrolling
	if background_rect:
		var mat = background_rect.material
		if mat:
			# User requested vertical scrolling matching speed (like the road)
			bg_scroll -= speed * delta * 0.05 # Negative to scroll down (top to bottom)
			mat.set_shader_parameter("scroll_speed", bg_scroll)

	# Mountain Parallax
	# if mountain_rect:
	# 	var mat = mountain_rect.material
	# 	if mat:
	# 		mnt_scroll -= speed * delta * 0.15 # Faster than sky (0.05), slower than road
	# 		mat.set_shader_parameter("scroll_speed", mnt_scroll)

func activate_turbo():
	SoundManager.play_turbo()
	is_turbo_active = true
	turbo_timer = turbo_duration
	turbo_charge = 0.0
	max_speed = 80.0 # Boost speed (normally 50)
	acceleration = 40.0 # Faster accel

func deactivate_turbo():
	is_turbo_active = false
	max_speed = 50.0 # Reset to normal
	acceleration = 20.0 # Reset accel

func spawn_enemy():
	if not enemy_scene:
		return
		
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	# Spawn far away (-Z)
	var lane = randf_range(-2.0, 2.0)
	if enemy.has_method("init"):
		enemy.init(self, -100.0, lane)

func spawn_puddle():
	if not puddle_scene:
		return
		
	var puddle = puddle_scene.instantiate()
	add_child(puddle)
	var lane = randf_range(-2.0, 2.0)
	if puddle.has_method("init"):
		puddle.init(self, -100.0, lane)

func car_avoided():
	cars_passed += 1
	# Bonus score immediate effect if wanted, but we calc in process
	
func game_over():
	print("GAME OVER")
	speed = 0.0
	set_process(false)
	# Show UI
	var ui = get_node_or_null("UI")
	if ui:
		ui.show_game_over()




func get_speed() -> float:
	return speed
