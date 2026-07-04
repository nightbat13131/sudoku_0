class_name PathSweeper extends PathSweeper_Inner

func send_press(pos: Vector2i, press_type: Utilties.PathSweeper_Alts) -> void:
	var cell : PathSweeperCellInfo = get_cell_from_pos(pos)
	_undo_redo.create_action("PathSweeperPress " + str(press_type))
	cell.press(press_type, _undo_redo)
	_undo_redo.commit_action()
