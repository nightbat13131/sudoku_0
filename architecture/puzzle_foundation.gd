@abstract
class_name PuzzleFoundation extends Resource

signal puzzle_generated
@warning_ignore("unused_signal")
signal cell_changed(pos: Vector2i, num: int)
@warning_ignore("unused_signal")
signal puzzle_complete(result: Utilties.Results)

var _cells_grid : Array[Array]


var _undo_redo : UndoRedo

func request_undo() -> void: _undo_redo.undo()

func request_redo() -> void: _undo_redo.redo()

func new_puzzle() -> void:
	if _undo_redo:
		_undo_redo.clear_history()
	else: 
		_undo_redo = UndoRedo.new()
	_new_puzzle()
	puzzle_generated.emit()

## Puzzle specific Generation
@abstract func _new_puzzle() -> void

#func is_solved() -> bool: return false
@abstract func _get_results() -> Utilties.Results

func get_cells_grid() -> Array[Array] : return _cells_grid

func get_cell_from_pos(pos: Vector2i) -> PuzzleCellInfo:
	if pos.x < 0 or pos.y < 0:
		return null
	if pos.y >= _cells_grid.size():
		return null
	if pos.x >= _cells_grid[pos.y].size():
		return null
	return get_cells_grid()[pos.y][pos.x]
