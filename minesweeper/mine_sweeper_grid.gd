class_name MineSweeperGrid extends GridContainer

@export var _cell_scene : PackedScene

var _minesweeper : MineSweeper

func set_minesweeper(minesweeper: MineSweeper) -> void: 
	_minesweeper = minesweeper
	_minesweeper.puzzle_generated.connect(_on_new_puzzle)

func _on_new_puzzle() -> void: _populate_grid(_minesweeper.get_cells_grid())

func _populate_grid(grid: Array) -> void:
	set_columns(grid[0].size())
	var cell: MinesweeperCellInfo
	for y : int in grid.size():
		for x: int in grid[y].size():
			cell = grid[y][x]
			assert(cell.is_pos(Vector2i(x,y)))
			_apply_cell(Vector2i(x, y), grid[y][x])

func _apply_cell(pos, cell) -> void:
	var index := _pos_to_index(pos)
	## Assumes that only children are the MineSweeper cells.
	var holder : MineSweeperCell
	if index >= get_child_count():
		holder = _cell_scene.instantiate()
		add_child(holder)
	else:
		holder = get_child(index)
	holder.apply_cell(pos, cell)

func _pos_to_index(pos: Vector2i) -> int: return get_columns() * (pos.y) + pos.x

func remote_hold(center_pos: Vector2i, is_pressed : bool) -> void:
	var _index : int
	var _cell_show : MineSweeperCell
	for cell_pos in _minesweeper.get_nine_grid_vectors(center_pos):
		_index = _pos_to_index(cell_pos)
		_cell_show = get_child(_index)
		_cell_show.remote_hold(is_pressed)
