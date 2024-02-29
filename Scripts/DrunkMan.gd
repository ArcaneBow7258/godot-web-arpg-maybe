extends Node2D
# mathermatically, 0 north going clockwise.
@export var bounds : Array[int]
@export var chances : Array[int] # ratio in compariosn to each other
@export var max_iter : int
@export var n_drunkards : int
@export var tilemap : TileMap
@export var starting : Vector2i
@export var seed : int
func _ready():
	var max_chances = chances.reduce(func(accum, number): return accum + number, 0)
	var iterations = 0
	var drunkards = []
	var dirs = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	var gen = RandomNumberGenerator.new()
	gen.set_seed(seed)
	for i in n_drunkards:
		drunkards.append(starting)
	while iterations < max_iter:
		for drunkard in n_drunkards:
			var rand = gen.randf_range(0, max_chances)
			var dir = 0
			print("test ", rand)
			for i in range(4):
				if rand <= chances[i]:
					dir = i
					break
				rand -= chances[i]
			print( " dir: ", dir)
			drunkards[drunkard] += dirs[dir]
			tilemap.set_cell(0, drunkards[drunkard],0, Vector2i(1,4) )
			if (iterations == max_iter - 1):
				tilemap.set_cell(0, drunkards[drunkard],0, Vector2i(2,3) )
		iterations += 1
	tilemap.set_cell(0, starting,0, Vector2i(1,3) )
	#print(drunkards)
			
