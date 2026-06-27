class_name MineSweeper extends MineSweeper_Inner

func get_solution_grid() -> Array[Array] : return _solution_grid

func get_player_grid() -> Array[Array]: return _player_grid

func send_press(pos: Vector2i, press: Utilties.MineSweeper_Cells_Alts) -> void:
	var current_mark : Utilties.MineSweeper_Cells_Alts
	current_mark = _player_grid[pos.y][pos.x]
	assert(current_mark != Utilties.MineSweeper_Cells_Alts.BOMB)
	var next_mark : Utilties.MineSweeper_Cells_Alts
	if current_mark == Utilties.MineSweeper_Cells_Alts.FLAG:
		if press == Utilties.MineSweeper_Cells_Alts.FLAG:
			next_mark = Utilties.MineSweeper_Cells_Alts.NO_GUESS
		else: 
			return
	elif press == Utilties.MineSweeper_Cells_Alts.FLAG:
		next_mark = press 
	else:
		next_mark = _solution_grid[pos.y][pos.x]
	
	_undo_redo.create_action(Utilties.MINESWEEPER_POKE)
	_undo_redo.add_do_method(__set_cell_value_ur.bind(pos, next_mark) )
	_undo_redo.add_undo_method(__set_cell_value_ur.bind(pos, current_mark) )
	_undo_redo.commit_action()


func __set_cell_value_ur(pos: Vector2i, num: int) -> void:
	assert(num != Utilties.Sudoku_Cell_Alts.GUESS_BLOCKED)
	_player_grid[pos.y][pos.x] = num
	cell_changed.emit(pos, num)
	#if is_guess_complete():
		#print("guess complete")
		#if is_guess_correct():
			#print("puzzle solved")
