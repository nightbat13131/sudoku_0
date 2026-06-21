class_name SudokuGrid extends GridContainer

var _sudoku: Sudoku

func set_sudoku(sudoku: Sudoku) -> void: 
	_sudoku = sudoku
	_sudoku.puzzle_generated.connect(_on_puzzle_generated)

func apply_grid(grid: Array[Array]) -> void:
	set_columns(_get_grid_size().x / _get_subgrid_size().x)
	var sub_index := 0
	for row: int in grid.size():
		for col: int in grid[row].size():
			sub_index = _pos_to_sub_index(Vector2i(col, row))
			if sub_index == get_child_count():
				add_child(SudokuSubgrid.new())
				get_child(sub_index).configure(Vector2i(col, row), _get_subgrid_size())
			apply_cell.call_deferred(Vector2i(col, row), grid[row][col], grid[row][col] != 0)
	var child_dif = sub_index - get_child_count()
	print(child_dif)

func apply_cell(pos: Vector2i, num: int, do_lock := false) -> void: 
	var index : int = _pos_to_sub_index(pos)
	assert(index < get_child_count())
	var child = get_child(index) as SudokuSubgrid
	assert(child != null)
	child.apply_cell(pos, num, do_lock)

func _get_grid_size() -> Vector2:
	if _sudoku:
		return _sudoku.get_grid_size()
	return Vector2.ONE*2

func _get_subgrid_size() -> Vector2i:
	if _sudoku:
		return _sudoku.get_subgrid_size()
	return Vector2.ONE

func _pos_to_sub_index(pos: Vector2i) -> int:
	@warning_ignore("integer_division")
	var out : Vector2i = pos / _get_subgrid_size() # Prints (3, -4)
	prints(pos, _get_subgrid_size(), out)
	return (get_columns() * out.y) + out.x

func _vector_to_index(pos: Vector2i) -> int: return get_columns() * (pos.y) + pos.x

func _on_puzzle_generated() -> void:
	apply_grid(_sudoku.get_player_grid())
