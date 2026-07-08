class_name PathSweeper extends PathSweeper_Inner

var _spray_count := 0
var _loot_count := 0
var _lives := 0

func send_press(pos: Vector2i, press_type: Utilties.PathSweeper_Alts) -> void:
	var cell : PathSweeperCellInfo = get_cell_from_pos(pos)
	if cell == null:
		return
	#_undo_redo.create_action("PathSweeperPress " + str(press_type)) # move to functions that start changes
	if _get_results() == Utilties.Results.INPROGRESS:
		cell.press(press_type, self)
		# changed.emit.call_deferred() # needs calling by undo, so tucking in setters
		commit_undo_redo_action()

func _new_puzzle() -> void:
	_loot_count = 0
	_spray_count = 5
	_lives = 3
	super._new_puzzle()
	changed.emit()

func get_status_text() -> String: 
	var text := ""
	match _get_results():
		Utilties.Results.WIN:
			text += "Win\n"
		Utilties.Results.LOSS:
			text += "Died\n"
	text += "Lives: {} Loot: {} , Repells: {}.".format(
		[_lives, _loot_count, _spray_count ],
		 "{}")
	return text

func get_spray_count() -> int: return _spray_count

func change_spray(delta: int) -> void: 
	_spray_count += delta
	changed.emit()

func get_loot_count() -> int: return _loot_count

func set_loot_count(value: int) -> void: 
	_loot_count = value
	changed.emit()

func get_health() -> int: return _lives

func change_health(delta: int) -> void:
	_lives += delta
	changed.emit()

func _get_results() -> Utilties.Results:
	if _lives < 0: # 0 can take one more hit
		return Utilties.Results.LOSS
	if PathSweeperCellInfo._end:
		if PathSweeperCellInfo._end.is_pressed():
			return Utilties.Results.WIN
	return Utilties.Results.INPROGRESS
