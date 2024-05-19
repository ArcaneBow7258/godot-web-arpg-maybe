extends CharacterBody2D
signal on_hit

@export var navAgent : NavigationAgent2D 
@export var speed : float

func _ready():
	navAgent = $NavigationAgent2D
	
	
func _on_life_on_empty():
	queue_free()
	pass # Replace with function body.
func find_nearest_target(group: String):
	return get_tree().get_nodes_in_group(group)
func find_next_move():
	var targets = find_nearest_target('Player') 
	if len(targets) > 0:
		var closet = targets[0]
		for target in targets:
			#print(target)
			closet = target if (target.get_global_position() - position).length() < (closet.get_global_position() - position).length() else closet
		navAgent.target_position = closet.get_global_position()
	navAgent.get_next_path_position()
func _physics_process(delta):
	find_next_move()
	var next = navAgent.get_next_path_position()
	#print(position)
	#print(next, position)
	velocity = (next - position).normalized() * delta * speed
	move_and_slide()
	
	if navAgent.is_navigation_finished():
		queue_free()
