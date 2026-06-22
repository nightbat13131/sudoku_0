class_name SudokuSubgrid extends Control

var _nw_zero: Vector2i
var _grid_size: Vector2i
var _sudoku_cell_theme : SudokuCellTheme
@onready var grid_container: GridContainer = %GridContainer

@export var _cell_holder : Control
@export var _cell_scene : PackedScene

func configure(nw_corner: Vector2i, grid_size: Vector2i) -> void:
	_nw_zero = nw_corner
	_grid_size = grid_size
	grid_container.set_columns(_grid_size.x)
	var child_dif := _get_cells().size() - (_grid_size.x * _grid_size.y)
	var holder: SudokuCell # SudokuButton
	if child_dif < 0: ## add children
		for i in abs(child_dif):
			holder = _cell_scene.instantiate()
			_cell_holder.add_child(holder)
			holder.set_sudoku_cell_theme(_sudoku_cell_theme)
	elif 0 < child_dif: ## remove_children
		for i in child_dif:
			holder = _get_cells()[0]
			_cell_holder.remove_child(holder)
			holder.queue_free()

func _get_cells() -> Array :
	if _cell_holder:
		return _cell_holder.get_children()
		#for each_child in _cell_holder.get_children():
			#if each_child is SudokuCell:
				#out.append(each_child)
	return []

func _get_cell(index: int) -> SudokuCell:
	if _cell_holder:
		return _cell_holder.get_child(index)
		#for each_child in _cell_holder.get_children():
			#if each_child is SudokuCell:
		#		out.append(each_child)
	return null

func set_sudoku_cell_theme(cell_theme: SudokuCellTheme) -> void:
	_sudoku_cell_theme = cell_theme
	for each_child in get_children():
		if each_child is SudokuButton:
			each_child.set_sudoku_cell_theme(_sudoku_cell_theme)

func apply_cell(global_pos: Vector2i, num: int, do_lock := false) -> void: 
	var index : int = _pos_to_index(global_pos)
	assert(index < _get_cells().size())
	var child = _get_cell(index) as SudokuCell
	assert(child != null)
	child.set_value(global_pos, num, do_lock)

func _pos_to_index(global_pos: Vector2i) -> int: 
	var out_v: Vector2i = global_pos - _nw_zero
	var out_i: int = (_grid_size.x * out_v.y) + out_v.x
	return out_i
