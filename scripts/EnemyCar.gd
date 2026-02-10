extends Sprite3D

@export var road_manager: Node
var speed: float = 20.0 # Will be randomized
var lane_offset: float = 0.0 # Offset from center

func init(manager, start_z, offset):
	road_manager = manager
	position.z = start_z
	lane_offset = offset
	# Randomize enemy speed for variety. Slower = faster approach relative to player!
	speed = randf_range(10.0, 40.0)
	
func _process(delta: float) -> void:
	if not road_manager:
		return
		
	# Move relative to player speed
	# If player is faster, enemy comes towards camera (+Z)
	var player_speed = road_manager.get_speed()
	var relative_speed = player_speed - speed
	
	position.z += relative_speed * delta * 1.5 # Increased scale factor for faster gameplay feel
	
	# Despawn if behind camera or too far
	if position.z > 10.0:
		if road_manager.has_method("car_avoided"):
			road_manager.car_avoided()
		queue_free()
	elif position.z < -200.0:
		queue_free()
		
	# Apply Curve Visuals
	var curve = road_manager.current_curve
	# Shader logic: x += curve * z^2 * 0.001
	# But in shader, z is 0 at camera? No, VERTEX.z is local to mesh. 
	# Our camera is at z=5, road starts at 0? 
	# Let's approximate. The road mesh is centered at 0.
	
	var z_depth = position.z
	var curve_offset = curve * (z_depth * z_depth) * 0.001
	
	position.x = lane_offset + curve_offset

	# Exaggerated Scaling (Pseudo-3D feel)
	# As it gets closer (Z increases), scale up. 
	# Reduced scale and added Y offset to prevent ground clipping
	var proximity = map_range(position.z, -100.0, 3.0, 0.1, 0.3)
	scale = Vector3.ONE * proximity
	
	# Raise car so wheels touch ground (assuming sprite is centered)
	# Adjust 1.2 modifier based on actual sprite height 
	position.y = proximity * 1.5 

	# Simple collision check with player
	# Player is at z=3 approx.
	if abs(position.z - 3.0) < 1.0:
		var player = road_manager.get_node("Player") 
		if player:
			# Check X overlap
			if abs(position.x - player.position.x) < 0.8:
				road_manager.game_over()

func map_range(value, min_input, max_input, min_output, max_output):
	return (value - min_input) / (max_input - min_input) * (max_output - min_output) + min_output
