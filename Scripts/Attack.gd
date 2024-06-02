extends ShapeCast2D
@export var attack_rate : float
@export var attack_range : float = 50
@export var attack_damage : float = 10
var last_attack : float
var timer : Timer
var anim : AnimatedSprite2D
var parent : Node2D
func _ready():
	timer = $Timer
	anim = $AttackAnimPivot/AnimatedSprite2D
	parent = get_parent()
func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("Basic Attack") and timer.is_stopped():
			#print("Left button was clicked at ", event.position,  get_viewport_rect().size)
			enabled = true
			#anim.enabled = true
			anim.speed_scale = 1 /  attack_rate 
			anim.stop()
			anim.play("attack_1")
			anim.scale.x = (attack_range + 16) / 32
			anim.position.x = 32 * anim.scale.x / 2 
			anim.look_at(get_global_mouse_position())
			#anim.rotate(-3*PI/4)
			
			target_position = (event.position -( get_viewport_rect().size/2)).normalized() * attack_range#.rotated(parent.rotation_degrees * PI / 180)
			#var global_diff =  (get_global_mouse_position() - global_position)
			# Make adjustments due to offset
			#print('pos', parent.global_position - global_position)
			#global_diff += global_position - parent.global_position 
			#global_diff.y = -1 * global_diff.y
			#dtarget_position =global_diff.rotated(parent.rotation_degrees * PI / 180)
			force_shapecast_update()
			if is_colliding():
				for i in range(get_collision_count()):
					var colide := get_collider(i) as Node2D
					var life := colide.find_child("Life") as TextureProgressBar
					if life:
						life.value -= attack_damage
			timer.start()
			#enabled = false
