class_name ScoreHolder_PathSweeper extends HBoxContainer

@onready var label_depth: Label = %LabelDepth

var _puzzle : PathSweeper

func set_puzzle_info(info: PathSweeper) -> void:
	if _puzzle: 
		_puzzle.changed.disconnect(_on_puzzle_change)
	_puzzle = info
	_puzzle.changed.connect(_on_puzzle_change)
	_on_puzzle_change()

func _on_puzzle_change() -> void:
	if _puzzle == null:
		hide()
		return
	label_depth.set_text("Depth {}".format([_puzzle.get_depth()], "{}"))
	pass
