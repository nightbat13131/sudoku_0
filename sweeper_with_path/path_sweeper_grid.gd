class_name PathSweeperGrid extends GridContainer

@export var _cell_scene : PackedScene

func populate_grid(grid: Array) -> void:
	set_columns(grid[0].size())
	var cell: PathSweeperCellInfo
	for y : int in grid.size():
		for x: int in grid[y].size():
			cell = grid[y][x]
			assert(cell.is_position(Vector2i(x,y)))
			_apply_cell(Vector2i(x, y), cell)

func _apply_cell(pos, cell) -> void:
	var index := _pos_to_index(pos)
	## Assumes that only children are the MineSweeper cells.
	var holder : PathSweeperCell
	if index >= get_child_count():
		holder = _cell_scene.instantiate()
		add_child(holder)
	else:
		holder = get_child(index)
	holder.apply_cell(cell)

func _pos_to_index(pos: Vector2i) -> int: return get_columns() * (pos.y) + pos.x
