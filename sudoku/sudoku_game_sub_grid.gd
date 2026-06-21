class_name SudokuSubgrid extends GridContainer

var _nw_zero: Vector2i
var _grid_size: Vector2i

func configure(nw_corner: Vector2i, grid_size: Vector2i) -> void:
	_nw_zero = nw_corner
	_grid_size = grid_size
	set_columns(_grid_size.x)
	var child_dif := get_child_count() - _grid_size.x * _grid_size.y
	var holder: Node
	if child_dif < 0:
		for i in abs(child_dif):
			add_child(SudokuButton.new())
		## add children
		pass
	elif 0 < child_dif:
		for i in child_dif:
			holder = get_child(0)
			remove_child(holder)
			holder.queue_free()
		## remove_children
		pass

func apply_cell(global_pos: Vector2i, num: int, do_lock := false) -> void: 
	var index : int = _pos_to_index(global_pos)
	assert(index < get_child_count())
	var child = get_child(index) as SudokuButton
	assert(child != null)
	child.set_value(global_pos, num, do_lock)

func _pos_to_index(global_pos: Vector2i) -> int: 
	var out_v: Vector2i = global_pos - _nw_zero
	var out_i: int = (get_columns() * out_v.y) + out_v.x
	return out_i
