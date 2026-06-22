class_name SudokuGrid extends GridContainer

@export var _subgrid_theme_scene: PackedScene

var _sudoku: Sudoku
var _sudoku_cell_theme : SudokuCellTheme : set = set_sudoku_cell_theme


func set_sudoku(sudoku: Sudoku) -> void: 
	_sudoku = sudoku
	_sudoku.puzzle_generated.connect(_on_puzzle_generated)
	_sudoku.cell_changed.connect(_on_cell_changed)

func set_sudoku_cell_theme(cell_theme: SudokuCellTheme) -> void:
	_sudoku_cell_theme = cell_theme
	for each_child in get_children():
		if each_child is SudokuSubgrid:
			each_child.set_sudoku_cell_theme(_sudoku_cell_theme)

func apply_grid(grid: Array[Array]) -> void:
	@warning_ignore("narrowing_conversion")
	set_columns(_get_grid_size().x / _get_subgrid_size().x)
	var sub_index := 0
	var new_subgrid : SudokuSubgrid
	for row: int in grid.size():
		for col: int in grid[row].size():
			sub_index = _pos_to_sub_index(Vector2i(col, row))
			if sub_index == get_child_count():
				new_subgrid = _subgrid_theme_scene.instantiate()
				add_child(new_subgrid)
				new_subgrid.configure(Vector2i(col, row), _get_subgrid_size())
				new_subgrid.set_sudoku_cell_theme(_sudoku_cell_theme)
			_apply_cell.call_deferred(Vector2i(col, row), grid[row][col], grid[row][col] != 0)
	var child_dif = sub_index - get_child_count()
	## TODO: delete subgrids if I have too many.

func _apply_cell(pos: Vector2i, num: int, do_lock := false) -> void: 
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
	var out : Vector2i = pos / _get_subgrid_size()
	return (get_columns() * out.y) + out.x

func _vector_to_index(pos: Vector2i) -> int: return get_columns() * (pos.y) + pos.x

func _on_puzzle_generated() -> void:
	apply_grid(_sudoku.get_player_grid())

func _on_cell_changed(pos: Vector2i, num: int,) -> void:
	_apply_cell(pos, num)
