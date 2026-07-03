class_name SudokuSubgrid extends Control

var _nw_zero: Vector2i
var _grid_size: Vector2i
var _sudoku_cell_theme : SudokuCellTheme
@onready var cell_holder: GridContainer = %CellHolder
@onready var background_texture_rect: TextureRect = %BackgroundTextureRect

@export var _cell_holder : Control
@export var _cell_scene : PackedScene

func _ready() -> void:
	mouse_exited.connect(_on_mouse_change.bind(false))
	mouse_entered.connect(_on_mouse_change.bind(true))
	_on_mouse_change(false)

func configure(nw_corner: Vector2i, grid_size: Vector2i) -> void:
	_nw_zero = nw_corner
	_grid_size = grid_size
	cell_holder.set_columns(_grid_size.x)
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
	for each_child in _get_cells():
		if each_child is SudokuCell:
			each_child.set_sudoku_cell_theme(_sudoku_cell_theme)

func add_cell(cell: SudokuCellInfo) -> void:
	var index : int = _pos_to_index(cell.get_position())
	assert(index < _get_cells().size())
	var child = _get_cell(index) as SudokuCell
	assert(child != null)
	#child.set_value(global_pos, num, do_lock)
	child.set_cell_info(cell)
	pass

func _pos_to_index(global_pos: Vector2i) -> int: 
	var out_v: Vector2i = global_pos - _nw_zero
	var out_i: int = (_grid_size.x * out_v.y) + out_v.x
	return out_i

func _on_mouse_change(is_in: bool) -> void:
	if is_in:
		background_texture_rect.set_modulate(Utilties.COLOR_SUBGRID_HIGHLIGHT)
	else:
		background_texture_rect.set_modulate(Utilties.COLOR_SUBGRID_LOWLIGHT)
