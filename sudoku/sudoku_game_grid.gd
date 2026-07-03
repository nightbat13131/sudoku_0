class_name SudokuGrid extends GridContainer

@export var _subgrid_theme_scene: PackedScene

var _sudoku: Sudoku
var _sudoku_cell_theme : SudokuCellTheme : set = set_sudoku_cell_theme

func set_sudoku(sudoku: Sudoku) -> void: 
	_sudoku = sudoku
	_sudoku.puzzle_generated.connect(_on_puzzle_generated)

func set_sudoku_cell_theme(cell_theme: SudokuCellTheme) -> void:
	_sudoku_cell_theme = cell_theme
	for each_child in get_children():
		if each_child is SudokuSubgrid:
			each_child.set_sudoku_cell_theme(_sudoku_cell_theme)

func apply_grid(grid: Array[Array]) -> void:
	@warning_ignore("narrowing_conversion")
	set_columns(_get_grid_size().x / _get_subgrid_size().x)
	var sub_index := 0
	var subgrid : SudokuSubgrid
	for row : Array in grid: 
		for cell : SudokuCellInfo in row: 
			sub_index = _pos_to_sub_index(cell.get_position())  #Vector2i(col, row))
			if sub_index == get_child_count():
				subgrid = _subgrid_theme_scene.instantiate()
				add_child(subgrid)
				subgrid.configure(cell.get_position(), _get_subgrid_size())
				subgrid.set_sudoku_cell_theme(_sudoku_cell_theme)
			else: 
				subgrid = get_child(sub_index)
			subgrid.add_cell(cell)
	## TODO: delete subgrids if I have too many.


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
	apply_grid(_sudoku.get_cells_grid())
	_sudoku.print_cells()
