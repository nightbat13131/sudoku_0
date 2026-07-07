class_name PathSweeper_Inner extends PuzzleFoundation

@export var _inner_grid_size : Vector2i : get = get_grid_size 

@export var _danger_count: int = 10
@export var _extra_wall_count : int = 10
@export var _danger_neighbors : int = 2

func _get_results() -> Utilties.Results:
	return Utilties.Results.INPROGRESS

func request_restart() -> void: pass

func _restart() -> void: pass

func _new_puzzle() -> void:
	PathSweeperCellInfo.clear_doors()
	_clear_grids()
	_populate_extra_walls()
	_populate_danger()
	Utilties.display_grid(get_cells_grid())

func get_grid_size() -> Vector2i: return _inner_grid_size + (Vector2i.ONE*2)

func _clear_grids() -> void:
	_cells_grid.clear()
	var cell : PathSweeperCellInfo
	var position : Vector2i
	var size = get_grid_size()
	for r in size.y: 
		_cells_grid.append([])
		for c in size.x: 
			position = Vector2i(c, r)
			cell = PathSweeperCellInfo.new()
			cell.set_position(position)
			_cells_grid[r].append(cell)
			for direction in [Vector2i.UP + Vector2i.LEFT, Vector2i.UP, Vector2i.LEFT, Vector2i.UP + Vector2i.RIGHT]:
				cell.add_map_neighbor(
					get_cell_from_pos(position + direction)
				)
			if r == 0 or r == size.y-1 or c == 0 or c == size.x-1:
				cell.set_wall(Utilties.PathSweeper_Alts.WALL)
	_place_doors()

func _place_doors() -> void: 
	## enter always from the bottom
	var xs := range(1,get_grid_size().x - 2)
	xs.shuffle()
	var start_x : int = xs.pop_back()
	PathSweeperCellInfo.set_start(get_cells_grid()[get_grid_size().y-1][start_x])
	var end := Vector2i.ONE
	match [0,0,1,2].pick_random():
		0: # back wall
			PathSweeperCellInfo.set_end(get_cells_grid()[0][xs.pop_back()])
			return
		1: 
			#if start_x > get_grid_size().x * .5:
			end.x = 0
		2: 
			#else:
			end.x = get_grid_size().x-1
	end.y = range(1, get_grid_size().y/2).pick_random()
	print(end)
	
	PathSweeperCellInfo.set_end(get_cells_grid()[end.y][end.x])


func _populate_extra_walls() -> void:
	var canidates : Array[PathSweeperCellInfo]
	for row : Array in get_cells_grid():
		for cell : PathSweeperCellInfo in row:
			if !cell.is_danger_blocked(): # cell.is_path() and !cell.is_door():
				canidates.append(cell)
				#cell._is_danger = true
	canidates.shuffle()
	var _count := 0
	while !canidates.is_empty() and _count < _extra_wall_count:
		if __try_place_boulder(canidates.pop_back()):
			_count += 1

func __try_place_boulder(cell: PathSweeperCellInfo) -> bool:
	cell.set_wall(Utilties.PathSweeper_Alts.BOULDER)
	for each_n in cell.get_map_neighbors():
		if each_n.get_danger_count() > _danger_neighbors:
			cell.set_wall(Utilties.PathSweeper_Alts.NA)
			return false
	if !PathSweeperCellInfo.has_valid_path():
		cell.set_wall(Utilties.PathSweeper_Alts.NA)
		return false
	return true

func _populate_danger() -> void:
	var canidates : Array[PathSweeperCellInfo]
	for row : Array in get_cells_grid():
		for cell : PathSweeperCellInfo in row:
			if !cell.is_danger_blocked():# if cell.is_path() and !cell.is_door():
				canidates.append(cell)
				#cell._is_danger = true
	canidates.shuffle()
	var _count := 0
	while !canidates.is_empty() and _count < _danger_count:
		if __try_place_danger(canidates.pop_back()):
			_count += 1

func __try_place_danger(cell: PathSweeperCellInfo) -> bool:
	cell.set_is_danger(Utilties.PathSweeper_Alts.DANGER0)
	for each_n in cell.get_map_neighbors():
		if each_n.get_danger_count() > _danger_neighbors:
			cell.set_is_danger(Utilties.PathSweeper_Alts.NA)
			return false
	if !PathSweeperCellInfo.has_valid_path():
		cell.set_is_danger(Utilties.PathSweeper_Alts.NA)
		return false
	return true
