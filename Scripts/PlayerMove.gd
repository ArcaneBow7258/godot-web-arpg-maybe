extends CharacterBody2D
var move_dir : Vector2
@export var move_rate: float = 1
var node_sprite : AnimatedSprite2D
var point_sprite : Sprite2D
var cam : Camera2D
var attack_pivot : Node2D
signal on_hit
func _ready():
	node_sprite = get_node("Sprite")
	node_sprite.play()
	point_sprite = get_node("Pointer")
	attack_pivot = $Attack/AttackAnimPivot
	return
	
func _process(delta):
	
	if move_dir != Vector2(0,0) and node_sprite.animation != "Run":
		node_sprite.animation = "Run"
	elif  move_dir == Vector2(0,0) and node_sprite.animation != "Idle":
		node_sprite.animation = "Idle"
	pointer_camera()
		
	return
func _physics_process(delta):
	player_move(delta)
	velocity = move_dir
	move_and_slide()
	
func player_move(delta):
	move_dir = Vector2(0,0)
	if Input.is_action_pressed("Up"):
		move_dir.y -= 1
	if Input.is_action_pressed("Down"):
		move_dir.y += 1
	if Input.is_action_pressed("Right"):
		move_dir.x += 1
	if Input.is_action_pressed("Left"):
		move_dir.x -= 1
	move_dir = move_dir.normalized()  * delta * move_rate
	#translate(move_dir * delta * move_rate)
	
func pointer_camera():
	point_sprite.look_at(get_global_mouse_position()) 
	attack_pivot.look_at(get_global_mouse_position()) 
	point_sprite.rotate(PI / 2)

	if node_sprite.flip_h != true and (get_global_mouse_position().x - position.x < 0):
		node_sprite.flip_h = true 
	elif node_sprite.flip_h != false and (get_global_mouse_position().x - position.x > 0):
		node_sprite.flip_h = false
		
		


func _on_life_value_changed(value):
	pass # Replace with function body.
