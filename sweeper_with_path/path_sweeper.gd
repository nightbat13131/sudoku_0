class_name PathSweeper extends PathSweeper_Inner

var _spray_count := 0
var _loot_count := 0
var _lives := 0

func send_press(pos: Vector2i, press_type: Utilties.PathSweeper_Alts) -> void:
	var cell : PathSweeperCellInfo = get_cell_from_pos(pos)
	_undo_redo.create_action("PathSweeperPress " + str(press_type))
	cell.press(press_type, self)
	_undo_redo.commit_action()

func _new_puzzle() -> void:
	_loot_count = 0
	_spray_count = 5
	_lives = 3
	super._new_puzzle()

func get_status_text() -> String: 
	return "Lives: {} Loot: {} , Repells: {}.".format(
		[_lives, _loot_count, _spray_count ],
		 "{}")

func get_spray_count() -> int: return _spray_count

func set_spray_count(value: int) -> void: 
	_spray_count = value
	changed.emit()

func get_loot_count() -> int: return _loot_count

func set_loot_count(value: int) -> void: 
	_loot_count = value
	changed.emit()
