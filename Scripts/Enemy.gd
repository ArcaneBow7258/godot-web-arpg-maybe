extends CharacterBody2D
signal on_hit

@export var navAgent : NavigationAgent2D 
@export var speed : float
@export var aggro_range : float
var current_target 
var delay = false
var delay_time = 2

var attacklogic : Node2D
var range :float = 0
signal player_collide
signal debug_enable

var hitbox  : CollisionShape2D


func _ready():
	navAgent = $NavigationAgent2D
	current_target = null
	attacklogic = $attacklogic
	hitbox = $HitBox
	range = attacklogic.range
	
func _on_life_on_empty():
	queue_free()
	pass # Replace with function body.
func find_nearest_target(group: String):
	return get_tree().get_nodes_in_group(group)
func find_next_move():
	var targets = find_nearest_target('Player') 
	if len(targets) > 0:
		var closet = null
		var space_state = get_world_2d().direct_space_state # https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
		for target in targets:
			var query = PhysicsRayQueryParameters2D.create(global_position, target.get_global_position(), 4)
			#query.collide_with_areas = true
			query.collide_with_bodies = true
			var result = space_state.intersect_ray(query)
			
			#print(global_position, target.get_global_position())
			if result != {}:
				continue
			#print(target)
			#print(result)
			if closet == null:
				closet = targets[0]
				continue
			closet = target if (target.get_global_position() - position).length() < (closet.get_global_position() - position).length() and (target.get_global_position() - position).length() < aggro_range else closet
		current_target = closet if closet else current_target
		if current_target != null:
			navAgent.target_position = current_target.get_global_position()
			return navAgent.get_next_path_position()

func _physics_process(delta):
	# Debounce?
	if not(delay):
		await get_tree().physics_frame
		delay = true
	find_next_move()
	var next = navAgent.get_next_path_position()
	#print(position)
	#print(next, position)
	if (next - position).length() >= range:
		velocity = (next - position).normalized() * delta * speed
		#var collision = move_and_collide(velocity)
		#if collision or navAgent.is_target_reached():
			#var collider : Node2D= collision.get_collider() 
			#collider
			#player_collide.emit()
		move_and_slide()
	var seen_ids = [] #https://github.com/godotengine/godot/issues/74804
	for index in get_slide_collision_count(): #https://stackoverflow.com/questions/73225523/how-to-detect-which-collision-layer-a-kinematicbody-is-colliding-with-in-godot
		var collision := get_slide_collision(index)
		var collider := collision.get_collider()
		if not is_instance_valid(collider) or collider.name == 'TileMap':
			continue
		var collider_id = collision.get_collider_id()
		if collider.get_collision_layer() == 1 and collider_id not in seen_ids:
			seen_ids.append(collider_id)
			#print('valdiation')
			#if self_destruct
			player_collide.emit(collider)

func _on_player_collide(node):
	node.on_hit.emit(10)
	queue_free()
