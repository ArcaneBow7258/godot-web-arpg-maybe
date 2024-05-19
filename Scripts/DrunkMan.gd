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
	return
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
	#Start tile
	tilemap.set_cell(0, starting,0, Vector2i(1,3) )
	smooth(smoothing)
	make_pretty()
	#BetterTerrain.update_terrain_area(tilemap, 0, Rect2i(-3, -3, bounds[0] + 6, bounds[1] + 6), true)
	print(drunkards)
func get_surrounding_data(cords):
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
	return {'floors': floor_count, 'walls': wall_count, 'trims':trim_count}
func smooth(smooth_count):
	var x = bounds[0]
	var y = bounds[1]		
	for i in range(smooth_count):
		var marked = {}
		for idx in range(x*y): # iterate through all cells
			var cords = Vector2i(idx % x, floori(idx / x))
			var c_data = tilemap.get_cell_tile_data(0, cords)
			if c_data: # don't update anything that already has data
				continue
			# counting
			var counts = get_surrounding_data(cords)
			var floor_count = counts['floors']		
			var wall_count = counts['walls']
			var trim_count = counts['trims']
			
			
			if(floor_count >= 2):
				marked[cords] = 0 # make floor
				#tilemap.set_cell(0,cords, 0, floor_cord)
				
		var change = BetterTerrain.create_terrain_changeset(tilemap, 0, marked)
		BetterTerrain.wait_for_terrain_changeset(change)
		BetterTerrain.apply_terrain_changeset(change)

		
	
	

func make_pretty():
	var x = bounds[0]
	var y = bounds[1]		
	var floors = tilemap.get_used_cells_by_id(0, 0, Vector2i(1,4))	
	
	# iterative pass, needs constant passes to make evryhting look good
	# make walls
	var marked = {}
	for idx in range((x+1)*(y+1)): # iterate through all cells
		var cords = Vector2i(idx % x, floori(idx / x))
		var c_data = tilemap.get_cell_tile_data(0, cords)
		if c_data:
			continue
		# counting
		var counts = get_surrounding_data(cords)
		var floor_count = counts['floors']		
		var wall_count = counts['walls']
		var trim_count = counts['trims']
		
		if floor_count >= 1:
			marked[cords] = 1
	apply_and_wait(tilemap, 0, marked)
	marked = {}
	# make trim
	for idx in range((x+2)*(y+2)): # iterate through all cells
		var cords = Vector2i(idx % x, floori(idx / x))
		var c_data = tilemap.get_cell_tile_data(0, cords)
		if c_data:
			continue
		var wall_count = 0
		for t in tilemap.get_surrounding_cells(cords): # consider the sujrrounding cells of cell
			
			var data = BetterTerrain.get_tile_terrain_type(tilemap.get_cell_tile_data(0, t))
			if data == 1:
				wall_count += 1
			if data == 1:
				marked[cords] = 2
		if wall_count >= 3:
			marked[cords] = 1
	#apply_and_wait(tilemap, 0, marked)
	marked = {}
	# corne trimps
	for idx in range((x+2)*(y+2)): # iterate through all cells
		var cords = Vector2i(idx % x, floori(idx / x))
		var c_data = tilemap.get_cell_tile_data(0, cords)
		if c_data:
			continue
		var counts = get_surrounding_data(cords)
		var trim_count = counts['trims']
		if trim_count == 2:
			marked[cords] = 3
	#apply_and_wait(tilemap, 0, marked)
	
func apply_and_wait(tilemap, layer, marked):
	var change = BetterTerrain.create_terrain_changeset(tilemap, layer, marked)
	BetterTerrain.wait_for_terrain_changeset(change)
	BetterTerrain.apply_terrain_changeset(change)
