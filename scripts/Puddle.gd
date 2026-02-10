extends Sprite3D

@export var road_manager: Node
var speed: float = 0.0 # Puddles are static on the road, so they move at -player_speed relative to camera
var lane_offset: float = 0.0

func init(manager, start_z, offset):
	road_manager = manager
	position.z = start_z
	lane_offset = offset
	
func _process(delta: float) -> void:
	if not road_manager:
		return
		
	# Move relative to player speed (puddle is stationary on road)
	var player_speed = road_manager.get_speed()
	var relative_speed = player_speed # Puddle moves towards camera at player speed
	
	position.z += relative_speed * delta * 0.1 # visual scale factor
	# Actually wait, EnemyCar uses: position.z += (player_speed - enemy_speed) * delta * 1.5
	# If puddle speed is 0, it should be player_speed * 1.5?
	# Let's match the "ground" speed feel.
	# The shader scrolls at `speed * 0.1`.
	# We want objects to match that scroll.
	# Adjusting to match EnemyCar's base movement feel.
	position.z += player_speed * delta * 1.5 
	
	# Despawn if behind camera
	if position.z > 10.0:
		queue_free()
		
	# Apply Curve Visuals
	var curve = road_manager.current_curve
	var z_depth = position.z
	var curve_offset = curve * (z_depth * z_depth) * 0.001
	
	position.x = lane_offset + curve_offset
	
	# Scale effect
	var proximity = map_range(position.z, -100.0, 3.0, 0.1, 0.3)
	scale = Vector3.ONE * proximity

	# Collision
	if abs(position.z - 3.0) < 1.0:
		var player = road_manager.get_node("Player") 
		if player:
			if abs(position.x - player.position.x) < 0.8:
				print("Hit Puddle!")
				if player.has_method("spin_out"):
					player.spin_out()

func map_range(value, min_input, max_input, min_output, max_output):
	return (value - min_input) / (max_input - min_input) * (max_output - min_output) + min_output
