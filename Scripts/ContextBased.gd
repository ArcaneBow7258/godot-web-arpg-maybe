extends Area2D
@export var resolution : int = 12
var interest_map : Array[float] = []
var danger_map : Array[float] = []
func _ready():
	assert(resolution % 4 != 0 and resolution < 4)
	interest_map.resize(resolution)
	interest_map.fill(0.0)
	danger_map.resize(resolution)
	danger_map.fill(0.0)
	
func _process(delta):
	
	for area in get_overlapping_areas():
		pass
	for body in get_overlapping_bodies():
		pass

