class_name MineSweeper extends MineSweeper_Inner

func send_press(pos: Vector2i, press: Utilties.MineSweeper_Cells_Alts) -> void:
	_undo_redo.create_action(Utilties.MINESWEEPER_POKE)
	_process_presses({pos: press}, press != Utilties.MineSweeper_Cells_Alts.FLAG)
	_undo_redo.commit_action()
	_win_check()

func send_wide_press(center: Vector2i) -> void:
	var count = _player_grid[center.y][center.x]
	## Verify the center has a value to check
	if count < 0:
		return
	var _flag_count := 0
	var _neighbor_value : int
	var _neighbors = get_nine_grid(center)
	var _needs_poke : Dictionary[Vector2i, int]
	_neighbors.erase(center)
	## verify count matches number of flags
	for each_0: Vector2i in _neighbors:
		_neighbor_value = _player_grid[each_0.y][each_0.x]
		if _neighbor_value == Utilties.MineSweeper_Cells_Alts.FLAG:
			_flag_count += 1
		elif _neighbor_value == Utilties.MineSweeper_Cells_Alts.NO_GUESS:
			_needs_poke[each_0] = Utilties.MineSweeper_Cells_Alts.EMPTY # .append(each_0)
	if _flag_count != count or _needs_poke.is_empty():
		return
	## place holder, need mass press
	_undo_redo.create_action(Utilties.MINESWEEPER_POKE)
	_process_presses(_needs_poke)
	_undo_redo.commit_action()
	_win_check()

func _process_presses(presses: Dictionary[Vector2i, int], with_flood := true) -> void:
	if with_flood:
		_get_cells_w_flood(presses)
	
	var current_mark : Utilties.MineSweeper_Cells_Alts
	var press : int
	for pos in presses.keys():
		press = presses[pos]
		current_mark = _player_grid[pos.y][pos.x]
		assert(current_mark != Utilties.MineSweeper_Cells_Alts.BOMB)
		var next_mark : Utilties.MineSweeper_Cells_Alts
		if current_mark == Utilties.MineSweeper_Cells_Alts.FLAG:
			if press == Utilties.MineSweeper_Cells_Alts.FLAG:
				next_mark = Utilties.MineSweeper_Cells_Alts.NO_GUESS
			else: 
				return
		elif press == Utilties.MineSweeper_Cells_Alts.FLAG:
			next_mark = Utilties.MineSweeper_Cells_Alts.FLAG 
		else:
			next_mark = _solution_grid[pos.y][pos.x]
		_undo_redo.add_do_method( __set_cell_value_ur.bind(pos, next_mark) )
		_undo_redo.add_undo_method(__set_cell_value_ur.bind(pos, current_mark) )

func _get_cells_w_flood(cells: Dictionary[Vector2i, int]) -> void:
	## updates the dictionary that is passed into it for usage by the calling function
	var _needs_checking :Array[Vector2i] = cells.keys().duplicate()
	var _has_checked : Array[Vector2i] = []
	var current_pos : Vector2i
	var _canidates : Array[Vector2i]
	while !_needs_checking.is_empty():
		## if blank, get the surounding cells. 
		current_pos = _needs_checking.pop_back()
		_has_checked.append(current_pos)
		if !cells.has(current_pos):
			cells[current_pos] = Utilties.MineSweeper_Cells_Alts.PRESS
		if _solution_grid[current_pos.y][current_pos.x] == Utilties.MineSweeper_Cells_Alts.EMPTY:
			for each_ in get_nine_grid(current_pos):
				if !_has_checked.has(each_):
					if !_needs_checking.has(each_):
						_needs_checking.append(each_)

func __set_cell_value_ur(pos: Vector2i, num: int) -> void:
	assert(num != Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED)
	_player_grid[pos.y][pos.x] = num
	cell_changed.emit(pos, num)

func _win_check() -> void:
	var result := _get_results()
	if result != Utilties.Results.INPROGRESS:
		_undo_redo.clear_history()
