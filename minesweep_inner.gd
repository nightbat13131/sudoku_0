class_name MineSweeper_Inner extends PuzzleFoundation

@export var _grid_size : Vector2i : get = get_grid_size
@export var _bomb_count: int = 10
@export var _max_bomb_neighbors := 2
var _bomb_spots : Array[Vector2i]

#var _starting_pos : Vector2i

func _new_puzzle() -> void:
	_clear_grids()
	_populate_grids()

func get_grid_size() -> Vector2i: return _grid_size

func _clear_grids() -> void:
	_solution_grid.clear()
	_player_grid.clear()

func _populate_grids() -> void:
	var _pool : Array[Vector2i] = []
	_bomb_spots.clear()
	for r in _grid_size.y: 
		_solution_grid.append([])
		_player_grid.append([])
		for c in _grid_size.x: 
			_solution_grid[r].append(Utilties.MineSweeper_Cells_Alts.EMPTY)
			_player_grid[r].append(Utilties.MineSweeper_Cells_Alts.NO_GUESS)
			_pool.append(Vector2i(c,r))
	_pool.shuffle()
	var bomb_pos : Vector2i 
	while _bomb_spots.size() < _bomb_count and !_pool.is_empty():
		bomb_pos = _pool.pop_back()
		if _try_place_bomb(bomb_pos):
			_bomb_spots.append(bomb_pos)
	Utilties.display_grid(_solution_grid)

func _try_place_bomb(pos: Vector2i) -> bool:
	var _neighbors := get_nine_grid(pos) #  Array[Vector2i] = []
	_neighbors.erase(pos)
	for each_0 in _neighbors:
		if _solution_grid[each_0.y][each_0.x] >= _max_bomb_neighbors:
			return false
	_solution_grid[pos.y][pos.x] = Utilties.MineSweeper_Cells_Alts.BOMB
	for n_pos in _neighbors:
		if _solution_grid[n_pos.y][n_pos.x] != Utilties.MineSweeper_Cells_Alts.BOMB:
			_solution_grid[n_pos.y][n_pos.x] += 1
	return true

func get_nine_grid(center: Vector2i) -> Array[Vector2i]:
	var _neighbors : Array[Vector2i] = []
	var _point : Vector2i
	for dy in [-1,0,1]:
		for dx in [-1,0,1]:
			_point = center + Vector2i(dx, dy)
			if _point.x < 0 or _point.y < 0:
				continue
			elif _point.x >= _grid_size.x or _point.y >= _grid_size.y:
				continue
			_neighbors.append(_point)
	return _neighbors

func _get_results() -> Utilties.Results:
	var _player : int
	var _solution : int
	for bomb_pos in _bomb_spots:
		if _player_grid[bomb_pos.y][bomb_pos.x] == Utilties.MineSweeper_Cells_Alts.BOMB:
			puzzle_complete.emit(Utilties.Results.LOSS)
			return Utilties.Results.LOSS
	for y in _grid_size.y:
		for x in _grid_size.x:
			_player = _player_grid[y][x]
			if _player == Utilties.MineSweeper_Cells_Alts.NO_GUESS:
				return Utilties.Results.INPROGRESS
			#_solution = _solution_grid[y][x]
			#if _solution == Utilties.MineSweeper_Cells_Alts.BOMB:
				#if _player != Utilties.MineSweeper_Cells_Alts.FLAG:
					#puzzle_complete.emit(Utilties.Results.LOSS)
					#return Utilties.Results.LOSS
	puzzle_complete.emit(Utilties.Results.WIN)
	return Utilties.Results.WIN
