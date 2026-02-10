extends Sprite3D

@export var road_manager: Node
@export var lateral_speed: float = 10.0
@export var max_x: float = 4.0

var is_spinning: bool = false
var spin_timer: float = 0.0

@export var side_texture: Texture2D
var original_texture: Texture2D
var flip_timer: float = 0.0

func _ready():
	original_texture = texture
	if not side_texture:
		# Fallback load if export is empty
		side_texture = load("res://assets/sprites/car_player_side.png")

func _process(delta: float) -> void:
	if is_spinning:
		# Spin effect: Flip horizontally to simulate spinning
		flip_timer += delta
		if flip_timer > 0.1: 
			flip_h = !flip_h
			flip_timer = 0.0
			
		# Also rotate Z for extra chaos
		rotation.z += delta * 15.0
			
		spin_timer -= delta
		
		# Decelerate rapidly
		if road_manager:
			road_manager.speed = move_toward(road_manager.speed, 0.0, delta * 30.0)
			
		if spin_timer <= 0:
			print("Spin complete")
			is_spinning = false
			texture = original_texture
			flip_h = false
			rotation.z = 0.0
		return

	var speed_factor = 0.0
	if road_manager:
		speed_factor = road_manager.get_speed() / road_manager.max_speed
	
	# Can only steer if moving
	if speed_factor > 0.01:
		var input_x = Input.get_axis("ui_left", "ui_right")
		
		# Move car laterally
		position.x += input_x * lateral_speed * delta
		
		# Clamp to road
		position.x = clamp(position.x, -max_x, max_x)
		
		# Tilt effect
		rotation.z = move_toward(rotation.z, input_x * -0.1, delta * 2.0)
	else:
		rotation.z = move_toward(rotation.z, 0.0, delta * 2.0)

func spin_out():
	if not is_spinning:
		print("Spinning out!")
		SoundManager.play_puddle()
		is_spinning = true
		spin_timer = 2.0 # Spin for 2 seconds
		if side_texture:
			texture = side_texture
		else:
			print("Error: side_texture missing")
