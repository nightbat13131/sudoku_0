class_name MineSweeper_Inner extends PuzzleFoundation

@export var _grid_size : Vector2i : get = get_grid_size
@export var _bomb_count: int = 10
@export var _max_bomb_neighbors := 2

var _solution_grid : Array[Array]
var _player_grid : Array[Array]
var _starting_pos : Vector2i

func _new_puzzle() -> void:
	_clear_grids()
	_populate_grids()

func get_grid_size() -> Vector2i: return _grid_size

func _clear_grids() -> void:
	_solution_grid.clear()
	_player_grid.clear()

func _populate_grids() -> void:
	var _pool : Array[Vector2i] = []
	for r in _grid_size.y: 
		_solution_grid.append([])
		_player_grid.append([])
		for c in _grid_size.x: 
			_solution_grid[r].append(Utilties.MineSweeper_Cells_Alts.EMPTY)
			_player_grid[r].append(Utilties.MineSweeper_Cells_Alts.NO_GUESS)
			_pool.append(Vector2i(c,r))
	_pool.shuffle()
	var bomb_pos : Vector2i 
	var count := _bomb_count
	while count > 0 and !_pool.is_empty():
		bomb_pos = _pool.pop_back()
		if _try_place_bomb(bomb_pos):
			count -= 1
	Utilties.display_grid(_solution_grid)

func _try_place_bomb(pos: Vector2i) -> bool:
	var _neighbors : Array[Vector2i] = []
	for dy in [-1,0,1]:
		for dx in [-1,0,1]:
			if dx == 0 and dy == 0:
				continue
			elif pos.x + dx < 0 or pos.y + dy < 0:
				continue
			elif pos.x + dx >= _grid_size.x or pos.y + dy >= _grid_size.y:
				continue
			
			if _solution_grid[pos.y + dy][pos.x + dx] >= _max_bomb_neighbors:
				return false
			_neighbors.append(Vector2i(pos.x + dx, pos.y + dy))
	_solution_grid[pos.y][pos.x] = Utilties.MineSweeper_Cells_Alts.BOMB
	for n_pos in _neighbors:
		if _solution_grid[n_pos.y][n_pos.x] != Utilties.MineSweeper_Cells_Alts.BOMB:
			_solution_grid[n_pos.y][n_pos.x] += 1
	return true
