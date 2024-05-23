extends CanvasLayer

@export var life_bar : TextureProgressBar
@export var res_bar : TextureProgressBar
var player :CharacterBody2D
signal start(node)
func _ready():
	Global.set_hud(self)
	
	life_bar = $Bars/LifeBar
	res_bar = $Bars/ResourceBar
	set_process(false)
	


func _on_start(node):
	set_process(true)
	player = node
	print('Hud Started')
func _process(delta):
	life_bar.max_value = player.life_bar.maxLife
	life_bar.value = player.life_bar.value
	

