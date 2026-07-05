class_name PathSweeperCellInfo extends PuzzleCellInfo

static var _start : PathSweeperCellInfo
static var _end : PathSweeperCellInfo

var _is_wall := false : set = set_is_wall
var _danger := Utilties.PathSweeper_Alts.NA
#var _block_danger := false 
var _is_pressed := false : set = _set_is_pressed
var _flag := Utilties.PathSweeper_Alts.NA
var _loot := Utilties.PathSweeper_Alts.NA

# 8 grid of neighbors
var _map_neighbors : Array[PathSweeperCellInfo] : get = get_map_neighbors

func press(press_type: Utilties.PathSweeper_Alts, puzzle: PathSweeper) -> bool:
	var result : bool = false
	if has_loot():
		return do_looting(puzzle)
	match press_type:
		Utilties.PathSweeper_Alts.MOVE:
			result = _walk_into(puzzle)
		Utilties.PathSweeper_Alts.FLAG0 , Utilties.PathSweeper_Alts.FLAG1:
			result = _toggle_flag(press_type, puzzle)
		Utilties.PathSweeper_Alts.REPELL:
			result = _try_use_repell(puzzle)
	return result

func _try_use_repell(puzzle: PathSweeper) -> bool:
	var result := false
	if puzzle.get_spray_count() <= 0:
		return result
	if !_can_walk_here():
		return result
	var undo : UndoRedo = puzzle.get_undo_redo()
	if is_danger():
		undo.add_do_method(set_is_danger.bind(Utilties.PathSweeper_Alts.REPELL_SUCCESS))
		undo.add_do_method(_set_loot.bind(Utilties.PathSweeper_Alts.LOOT0))
		undo.add_undo_method(set_is_danger.bind(_danger))
		undo.add_undo_method(_set_loot.bind(_loot))
		result = true
	undo.add_do_method(puzzle.set_spray_count.bind(puzzle.get_spray_count() - 1))
	undo.add_undo_method(puzzle.set_spray_count.bind(puzzle.get_spray_count()))
	undo.add_do_method(_set_is_pressed.bind(true))
	undo.add_undo_method(_set_is_pressed.bind(false))
	return result

func _walk_into(puzzle: PathSweeper) -> bool:
	if _can_walk_here():
		puzzle.get_undo_redo().add_do_method(_set_is_pressed.bind(true))
		puzzle.get_undo_redo().add_undo_method(_set_is_pressed.bind(false))
		## Consider clearing flag
		return true
	return false

func _toggle_flag(press_type: Utilties.PathSweeper_Alts, puzzle: PathSweeper) -> bool:
	if _is_pressed:
		return false
	var next := press_type
	if _flag == next:
		next = Utilties.PathSweeper_Alts.NA
	puzzle.get_undo_redo().add_do_method(_set_flag.bind(next))
	puzzle.get_undo_redo().add_undo_method(_set_flag.bind(_flag))
	return true

func _can_walk_here() -> bool:
	for each_n in get_path_neighors():
		if each_n.is_pressed():
			return true
	return false

func _signal_group_change() -> void:
	changed.emit()
	for each_n in get_map_neighbors():
		each_n.changed.emit()

func get_button_text() -> String:
	#var text := ""
	#var d_count = get_danger_count()
	#if d_count> 0:
	#	text += str(d_count)
	if is_pressed():
		return str(get_danger_count())+str(self)
	if _is_flag():
		if _flag == Utilties.PathSweeper_Alts.FLAG0:
			return "A"
		elif _flag == Utilties.PathSweeper_Alts.FLAG1:
			return "Z"
	return " "

func do_looting(puzzle: PathSweeper) -> bool:
	var undo : UndoRedo = puzzle.get_undo_redo()
	if !has_loot():
		return false
	undo.add_do_method(_set_loot.bind(Utilties.PathSweeper_Alts.NA))
	undo.add_undo_method(_set_loot.bind(_loot))
	undo.add_do_method(puzzle.set_loot_count.bind(puzzle.get_loot_count() + 1) )
	undo.add_undo_method(puzzle.set_loot_count.bind(puzzle.get_loot_count()) )
	
	return true

func is_button_disabled() -> bool:
	if has_loot():
		return false
	if is_pressed():
		return true
	for each_n in get_map_neighbors():
	#for each_n in get_path_neighors():
		if each_n.is_pressed():
			return false
	#if is_visable():
		#return _is_wall
	return true

func _set_loot(loot: Utilties.PathSweeper_Alts) -> void:
	assert([Utilties.PathSweeper_Alts.NA, Utilties.PathSweeper_Alts.LOOT0 ].has(loot))
	_loot = loot
	_signal_group_change()

func has_loot() -> bool: return _loot != Utilties.PathSweeper_Alts.NA

func _set_flag(value: Utilties.PathSweeper_Alts) -> void: 
	_flag = value
	_signal_group_change()

func _is_flag() -> bool: return _flag != Utilties.PathSweeper_Alts.NA

func set_is_wall(is_wall_: bool) -> void: _is_wall = is_wall_

func is_wall() -> bool:
	if is_door():
		return false
	return _is_wall

func is_pressed() -> bool:
	if _is_pressed:
		return true
	if _start == self:
		return true
	if get_map_neighbors().has(_start):
		return true
	return false

func _set_is_pressed(value: bool) -> void: 
	_is_pressed = value
	_signal_group_change()

#func block_danger() -> void: _block_danger = true

func is_danger_blocked() -> bool:
	#if _block_danger:
	#	return true
	if is_door():
		return true
	if is_wall():
		return true
	## is near start:
	if get_map_neighbors().has(_start):
		return true
	for each_n in get_map_neighbors():
		if each_n:
			if each_n.get_map_neighbors().has(_start):
				return true
	return false

func set_is_danger(danger: Utilties.PathSweeper_Alts) -> void: 
	assert( [Utilties.PathSweeper_Alts.BLOCKED, Utilties.PathSweeper_Alts.NA, Utilties.PathSweeper_Alts.REPELL_SUCCESS,
	Utilties.PathSweeper_Alts.DANGER0,].has(danger) )
	_danger = danger
	_signal_group_change()

func is_danger() -> bool: 
	match _danger:
		Utilties.PathSweeper_Alts.NA, Utilties.PathSweeper_Alts.BLOCKED, Utilties.PathSweeper_Alts.REPELL_SUCCESS:
			return false
	return true

func get_danger_count() -> int:
	var out := 0
	for each : PathSweeperCellInfo in get_map_neighbors():
		if each.is_danger():
			out += 1
	return out

func is_path() -> bool:
	if is_door():
		return true
	if is_danger():
		return false
	return !_is_wall

func is_door() -> bool: return _start == self or _end == self

func _to_string() -> String:
	if is_door(): # door first becuse it's external 
		return "^"
	if _is_wall:
		return "#"
	if has_loot():
		return "@"
	#if _is_protected_path:
	#	return "_"
	if is_danger():
		return "x"
	return str(get_danger_count())

func add_map_neighbor(cell: PathSweeperCellInfo) -> void:
	if cell == null or _map_neighbors.has(cell) or cell == self:
		return
	_map_neighbors.append(cell)
	cell.add_map_neighbor(self)

func get_map_neighbors() -> Array[PathSweeperCellInfo]: return _map_neighbors

# Math Neighbors who can be walked on. Only NSEW
func get_path_neighors() -> Array[PathSweeperCellInfo]:
	var _out : Array[PathSweeperCellInfo] = []
	var direction : Vector2i
	for each_ in _map_neighbors:
		if each_.is_path():
			direction = get_position() - each_.get_position()
			if [direction.y, direction.x].has(0):
				_out.append(each_)
	return _out

static func clear_doors() -> void:
	_start = null
	_end = null

static func set_start(cell: PathSweeperCellInfo) -> void: _start = cell

static func set_end(cell: PathSweeperCellInfo) -> void: _end = cell

static func has_valid_path() -> bool:
	if _end == null or _start == null: 
		return false
	var need_check : Array[PathSweeperCellInfo] = [_start]
	var visited : Array[PathSweeperCellInfo] = []
	var current_cell : PathSweeperCellInfo
	while !need_check.is_empty():
		current_cell = need_check.pop_back()
		visited.append(current_cell)
		for each_n in current_cell.get_path_neighors():
			if each_n == _end:
				return true
			if !need_check.has(each_n) and !visited.has(each_n):
				need_check.append(each_n)
	return false
