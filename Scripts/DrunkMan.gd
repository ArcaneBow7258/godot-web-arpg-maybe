extends Node2D
# mathermatically, 0 north going clockwise.
@export var bounds : Vector2i
@export var chances : Array[int] # ratio in compariosn to each other
@export var max_iter : int
@export var smoothing : int
@export var n_drunkards : int
@export var tilemap : TileMap
@export var starting : Vector2i
@export var seed : int
func _ready():
	var area = []
	for i in bounds[0]:
		for j in bounds[1]:
			area.append(0)
	var x = bounds[0]
	var y = bounds[1]		
	var max_chances = chances.reduce(func(accum, number): return accum + number, 0)
	var iterations = 0
	var drunkards = []
	var dirs = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	var gen = RandomNumberGenerator.new()
	var floor_cord = Vector2i(1,4)
	var wall_cord = Vector2i(1,1)
	gen.set_seed(seed)
	for i in n_drunkards:
		drunkards.append(starting)
	while iterations < max_iter:
		for drunkard in n_drunkards:
			#print(drunkards[drunkard])
			while true:
				#print(drunkards[drunkard][0]*x  + drunkards[drunkard][1])
				var rand = gen.randf_range(0, max_chances)
				var dir = 0
				for i in range(4):
					if rand <= chances[i]:
						dir = i
						break
					rand -= chances[i]
				if (drunkards[drunkard][0] + dirs[dir][0]) < x and drunkards[drunkard][1] + dirs[dir][1] < y:
					drunkards[drunkard] += dirs[dir]
					break
			area[drunkards[drunkard][0]  + drunkards[drunkard][1] * x ] = floor_cord
			#tilemap.set_cell(0, drunkards[drunkard],0, Vector2i(1,4) )
			if (iterations == max_iter - 1):
				area[drunkards[drunkard][0]  + drunkards[drunkard][1]*x ] = Vector2i(2,3)
		
				#tilemap.set_cell(0, drunkards[drunkard],0, Vector2i(2,3) )
		iterations += 1
	#print('painting')
	for idx in len(area):
		if typeof(area[idx]) != 2:
			#print(idx, Vector2i(idx % x, floori(idx / x)))
			tilemap.set_cell(0, Vector2i(idx % x, floori(idx / x)), 0,  area[idx])
		
	tilemap.set_cell(0, starting,0, Vector2i(1,3) )
	var floors = tilemap.get_used_cells_by_id(0, 0, Vector2i(1,4))	
	for i in range(smoothing):
		var marked_w = {}
		var marked_f = {}
		for idx in range(x*y): # iterate through all cells
			var cords = Vector2i(idx % x, floori(idx / x))
			var c_data = tilemap.get_cell_tile_data(0, cords)
			if c_data:
				continue
			var floor_count = 0
			var wall_count = 0
			var trim_count = 0
			for t in tilemap.get_surrounding_cells(cords): # consider the sujrrounding cells of cell
				var data = BetterTerrain.get_tile_terrain_type(tilemap.get_cell_tile_data(0, t))
				if  data == 0:
					floor_count += 1
				elif data == 1 and (cords - t == Vector2i.UP):
					wall_count += 1
				elif data == 2:
					trim_count += 1
				if(floor_count >= 2):
					pass
					marked_f[cords] = 0
					#tilemap.set_cell(0,cords, 0, floor_cord)
				elif(floor_count == 1):
					marked_f[cords] = 1
				elif(wall_count >= 1 and trim_count <= 2):
					marked_f[cords] = 2
				elif(floor_count == 0):
					tilemap.erase_cell(0,cords)
		var change_f = BetterTerrain.create_terrain_changeset(tilemap, 0, marked_f)
		BetterTerrain.wait_for_terrain_changeset(change_f)
		BetterTerrain.apply_terrain_changeset(change_f)
		var change_w = BetterTerrain.create_terrain_changeset(tilemap, 0, marked_w)
		BetterTerrain.wait_for_terrain_changeset(change_w)
		BetterTerrain.apply_terrain_changeset(change_w)
		
	
	BetterTerrain.update_terrain_area(tilemap, 0, Rect2i(0,0, x, y), true)
	print(drunkards)
			
