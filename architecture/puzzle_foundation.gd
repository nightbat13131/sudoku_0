class_name PuzzleFoundation extends Resource

signal puzzle_generated
signal cell_changed(pos: Vector2i, num: int)

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
func _new_puzzle() -> void: pass

func is_solved() -> bool: return false
