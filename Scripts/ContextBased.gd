extends Area2D

@export var interest_groups : PackedStringArray
@export var danger_groups : PackedStringArray
@export_category("Context Variables")
@export var resolution : int = 12
@export var neighbor_propogation : float = 0.5
@export var neighbor_danger : int = 0 
@export var neighbor_interest : int = 0 
@export var bias : float = 0.45

@export var distance_factor : float = 1.0
@export var max_speed : float = 10

@export_category("Spacing")
@export var space_interest : bool = false
@export var spacing_factor : float = 1
@export var spacing_body : Area2D
@export var spacing_size : float = 50
var interest_map : Array[float] = []
var danger_map : Array[float] = []
var angles : Array[float] = []

var in_bodies = []
var in_areas = []

var vel : Vector2
func _ready():
	assert(resolution % 4 == 0 and resolution >= 4)
	interest_map.resize(resolution)
	interest_map.fill(0.0)
	danger_map.resize(resolution)
	danger_map.fill(0.0)
	var t :CollisionShape2D = spacing_body.find_child("CollisionShape2D")
	t.shape.radius = spacing_size
	for i in range(resolution):
		angles.append(2 * PI / resolution * i)
	print(angles)
	
	vel = Vector2(0,0)
	
func _process(delta):
	interest_map.fill(0.0)
	danger_map.fill(0.0)
	for area : Area2D in get_overlapping_areas():
		
		pass
	# Create interest and danger
	for body : Node2D in in_bodies:
		var angle_to = global_position.angle_to_point(body.global_position)
		print(angle_to)
		#adjustments for my mental
		if angle_to < 0:
			angle_to = angle_to + (2* PI)
		var idx = _closest_marker(0, resolution-1, angle_to)	
		if Global.intersect(interest_groups, body.get_groups()):
			
			
			interest_map[idx] += 1# need some interest scaler
			for i in range(neighbor_interest):
				var real_i = i + 1# cause i starts at 0,, and power&0 is 1 which is bad
				interest_map[(idx - (real_i) ) % resolution] += neighbor_propogation**real_i * 1.0 
				interest_map[(idx + (real_i) ) % resolution] += neighbor_propogation**real_i * 1.0 * bias
			#if space_interest and Global.intersect([body], spacing_body.get_overlapping_bodies()):
				#interest_map[idx] += spacing_factor# need some interest scaler
				#for i in range(neighbor_num+1):
					#var real_i = i + 1# cause i starts at 0,, and power&0 is 1 which is bad
					#interest_map[(idx - (real_i) + resolution/2) % resolution] += neighbor_propogation**real_i * 1.0 * spacing_factor
					#interest_map[(idx + (real_i) + resolution/2) % resolution] += neighbor_propogation**real_i * 1.0 * spacing_factor
		if Global.intersect(danger_groups, body.get_groups()) and  Global.intersect([body], spacing_body.get_overlapping_bodies()):
			
			danger_map[idx] += 1
			for i in range(neighbor_danger):
				var real_i = i + 1
				danger_map[(idx - (real_i)) % resolution] += neighbor_propogation**real_i * 1.0
				danger_map[(idx + (real_i)) % resolution] += neighbor_propogation**real_i * 1.0 * bias
			if Global.intersect([body], spacing_body.get_overlapping_bodies()):
				print('yes')
				interest_map[idx] += spacing_factor# need some interest scaler
				for i in range(neighbor_interest):
					var real_i = i + 1# cause i starts at 0,, and power&0 is 1 which is bad
					interest_map[(idx - (real_i) + resolution/2) % resolution] += neighbor_propogation**real_i * 1.0 * spacing_factor
					interest_map[(idx + (real_i) + resolution/2) % resolution] += neighbor_propogation**real_i * 1.0 * spacing_factor  * bias
	# logic for interest and dangesr
	vel = Vector2(0,0)
	for i in range(resolution):
		if danger_map[i] > 0:
			interest_map[i] = 0
		#interest_map[i] -=  danger_map[i] 
		vel += Vector2(interest_map[i],0).rotated(angles[i]) 
		#vel.dot()
	var max_interest = interest_map.max()
	var max_index = interest_map.find(max_interest)
	#vel = Vector2(interest_map[max_index],0).rotated(angles[max_index]) 
	#for i in range(2):
		#vel += Vector2(interest_map[(max_index+i)%resolution],0).rotated(angles[(max_index+i)%resolution])  * bias
		#vel += Vector2(interest_map[(max_index-i)%resolution],0).rotated(angles[(max_index-i)%resolution]) 
	#vel = interest_map[max_index]
	vel = vel.normalized()
	print(interest_map)
	print(danger_map)
	get_parent().velocity = vel * delta * max_speed

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body != get_parent():
		in_bodies.append(body)
func _on_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	in_bodies.erase(body)
	
func _closest_marker(start, end, angle_rad):
	var mid :int = round((start + end) / 2)
	if start == end:
		return start
	elif end - start == 1:
		return start if angle_rad - angles[start] < angles[end] - angle_rad else end
	elif angle_rad <= angles[mid]:
		return _closest_marker(start, mid, angle_rad)
	else:
		return _closest_marker(mid, end, angle_rad)
