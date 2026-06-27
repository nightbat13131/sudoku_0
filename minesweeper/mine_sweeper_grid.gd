class_name MineSweeperGrid extends GridContainer

@export var _cell_scene : PackedScene

var _minesweeper : MineSweeper

func set_minesweeper(minesweeper: MineSweeper) -> void: 
	_minesweeper = minesweeper
	_minesweeper.puzzle_generated.connect(_on_new_puzzle)
	_minesweeper.cell_changed.connect(_apply_cell)

func _on_new_puzzle() -> void:
	_populate_grid(_minesweeper.get_player_grid())
	print("Thing")

func _populate_grid(grid: Array) -> void:
	set_columns(grid[0].size())
	for y : int in grid.size():
		for x: int in grid[y].size():
			_apply_cell(Vector2i(x, y), grid[y][x])

func _apply_cell(pos: Vector2i, value: int) -> void:
	var index := _pos_to_index(pos)
	## Assumes that only children are the MineSweeper cells.
	var holder : MineSweeperCell
	if index >= get_child_count():
		holder = _cell_scene.instantiate()
		add_child(holder)
	else:
		holder = get_child(index)
	holder.apply_cell(pos, value)

func _pos_to_index(pos: Vector2i) -> int: return get_columns() * (pos.y) + pos.x
