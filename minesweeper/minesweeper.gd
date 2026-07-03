class_name MineSweeper extends MineSweeper_Inner

func send_press(pos: Vector2i, press: Utilties.MineSweeper_Cells_Alts) -> void:
	if _first_cell == null:
		_set_first_cell(pos)
		_populate_solution()
	var cell := get_cell_from_pos(pos)
	if cell.is_flagged(): ## flag protects against non-flag presses
		if press != Utilties.MineSweeper_Cells_Alts.FLAG: 
			return
	_process_presses({ get_cell_from_pos(pos): press}, press != Utilties.MineSweeper_Cells_Alts.FLAG)
	_win_check()

func send_wide_press(center: Vector2i) -> void:
	var center_cell = get_cell_from_pos(center) as MinesweeperCellInfo
	
	## Verify the center has a value to check
	if !center_cell.is_pressed():
		return
	var bomb_count := center_cell.get_bomb_count()
	var _neighbors := get_nine_grid_cells(center_cell)
	var _needs_poke : Dictionary[MinesweeperCellInfo, int] # Dictionary[Vector2i, int]
	_neighbors.erase(center_cell)
	## verify count matches number of flags
	for each_0: MinesweeperCellInfo in _neighbors:
		if each_0.is_flagged():
			bomb_count -= 1
		elif !each_0.is_pressed():
			_needs_poke[each_0] = Utilties.MineSweeper_Cells_Alts.PRESS # .append(each_0)
	if bomb_count != 0 or _needs_poke.is_empty():
		return
	_process_presses(_needs_poke)
	_win_check()

func _process_presses(presses: Dictionary[MinesweeperCellInfo, int], with_flood := true) -> void:
	_undo_redo.create_action(Utilties.MINESWEEPER_POKE)
	if with_flood:
		_get_cells_w_flood(presses)
	var press_type : int
	for cell: MinesweeperCellInfo in presses.keys():
		press_type = presses[cell]
		if cell.is_pressed(): ## Can happen with floods
			#prints("What happened?")
			pass
		elif press_type == Utilties.MineSweeper_Cells_Alts.FLAG:
			if cell.is_flagged():
				_undo_redo.add_do_method(cell.set_flag.bind(false))
				_undo_redo.add_undo_method(cell.set_flag.bind(true))
			else: 
				_undo_redo.add_do_method(cell.set_flag.bind(true))
				_undo_redo.add_undo_method(cell.set_flag.bind(false))
		else: 
			#assert(!cell.is_pressed())
			assert(press_type == Utilties.MineSweeper_Cells_Alts.PRESS)
			if !cell.is_flagged(): ## Protected against miss clicks
				_undo_redo.add_do_method(cell.set_pressed.bind(true))
				_undo_redo.add_undo_method(cell.set_pressed.bind(false))
	_undo_redo.commit_action()

# Should not be breaking on flag, not checking _player_grid
func _get_cells_w_flood(cells: Dictionary[MinesweeperCellInfo, int]) -> void:
	## updates the dictionary that is passed into it for usage by the calling function
	var _needs_checking :Array[MinesweeperCellInfo] = cells.keys().duplicate()
	var _has_checked : Array[MinesweeperCellInfo] = []
	var current_cell : MinesweeperCellInfo
	while !_needs_checking.is_empty():
		current_cell = _needs_checking.pop_back()
		_has_checked.append(current_cell)
		if !cells.has(current_cell): # if not included, add to master list
			cells[current_cell] = Utilties.MineSweeper_Cells_Alts.PRESS
		## if blank, get the surounding cells. 
		if current_cell.get_bomb_count() == 0:
			for each_ in get_nine_grid_cells(current_cell):
				if !_has_checked.has(each_):
					if !_needs_checking.has(each_):
						_needs_checking.append(each_)

func _win_check() -> void:
	var result := _get_results()
	## writen knowing more result types may be added to the emum in the future
	if [Utilties.Results.WIN, Utilties.Results.LOSS].has(result):
		_undo_redo.clear_history()
		_first_cell = null
		puzzle_complete.emit(result)
		for row in _cells_grid:
			for cell : MinesweeperCellInfo in row:
				cell.game_over()
