class_name MineSweeper_Inner extends PuzzleFoundation
## if I ever desicde to make a no guess board https://minesweeperblast.com/minesweeper-board-generation/

@export var _grid_size : Vector2i : get = get_grid_size
@export var _bomb_count: int = 10
@export var _max_bomb_neighbors := 2

var _bomb_cells : Array[MinesweeperCellInfo]

var _first_cell : MinesweeperCellInfo 

func _set_first_cell(pos: Vector2i) -> void: _first_cell = get_cell_from_pos(pos)

func _new_puzzle() -> void:
	_clear_grids()
	_first_cell = null 

func get_grid_size() -> Vector2i: return _grid_size

func _clear_grids() -> void:
	_cells_grid.clear()
	var cell : MinesweeperCellInfo
	for r in _grid_size.y: 
		_cells_grid.append([])
		for c in _grid_size.x: 
			cell = MinesweeperCellInfo.new()
			cell.set_position(Vector2i(c,r))
			_cells_grid[r].append(cell)

func _populate_solution() -> void:
	var _pool : Array[MinesweeperCellInfo] = []
	_bomb_cells.clear()
	for r in _grid_size.y: 
		for c in _grid_size.x: 
			_pool.append(get_cell_from_pos(Vector2i(c,r)))
	for each_cell in get_nine_grid_cells(_first_cell):
		_pool.erase(each_cell)
	_pool.shuffle()
	var _bomb_option : MinesweeperCellInfo
	while _bomb_cells.size() < _bomb_count and !_pool.is_empty():
		_bomb_option = _pool.pop_back()
		if _try_place_bomb(_bomb_option): 
			_bomb_cells.append(_bomb_option)

func _try_place_bomb(cell: MinesweeperCellInfo) -> bool:
	var _neighbors := get_nine_grid_cells(cell)
	_neighbors.erase(cell) #pos)
	for each_0 in _neighbors:
		if each_0.get_bomb_count() >= _max_bomb_neighbors:
			return false
	cell.set_is_bomb(true)
	for each_1 in _neighbors:
		each_1.incrament_bomb_count()
	return true

func get_nine_grid_cells(center: MinesweeperCellInfo) -> Array[MinesweeperCellInfo]: 
	var  _neighbors : Array[MinesweeperCellInfo] = []
	for _point: Vector2i in get_nine_grid_vectors(center.get_position()):
			_neighbors.append(get_cell_from_pos(_point))
	return _neighbors

func get_nine_grid_vectors(center_pos: Vector2i) -> Array[Vector2i]:
	var out : Array[Vector2i] = []
	var _point : Vector2i
	for dy in [-1,0,1]:
		for dx in [-1,0,1]:
			_point = center_pos + Vector2i(dx, dy)
			if _point.x < 0 or _point.y < 0:
				continue
			elif _point.x >= _grid_size.x or _point.y >= _grid_size.y:
				continue
			out.append(_point)
	return out

func _get_results() -> Utilties.Results:
	for bomb_cell in _bomb_cells:
		assert(bomb_cell._is_bomb)
		if bomb_cell.is_pressed():
			return Utilties.Results.LOSS
	for row in _cells_grid:
		for cell : MinesweeperCellInfo in row:
			if _bomb_cells.has(cell):
				continue ## already checked
			elif cell.is_flagged(): # non-bomb flagged
			#if !cell.is_flagged_correct(): 
				return Utilties.Results.INPROGRESS
			elif !cell.is_pressed():
				return Utilties.Results.INPROGRESS
	return Utilties.Results.WIN

#func get_cell_from_pos(pos: Vector2i) -> MinesweeperCellInfo:
	#if pos.x < 0 or pos.y < 0:
		#return null
	#if pos.y >= _cells_grid.size():
		#return null
	#if pos.x >= _cells_grid[pos.y].size():
		#return null
	#return get_cells_grid()[pos.y][pos.x]

func request_restart() -> void: pass

func _restart() -> void: pass
