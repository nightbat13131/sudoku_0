class_name PathSweeperCellInfo extends PuzzleCellInfo

static var _start : PathSweeperCellInfo
static var _end : PathSweeperCellInfo

var _is_wall := false
var _is_danger := false
var _block_danger := false
var _is_pressed := false
var _is_flag := false

# 8 grid of neighbors
var _map_neighbors : Array[PathSweeperCellInfo] : get = get_map_neighbors

func press(press_type: Utilties.PathSweeper_Alts, undo_redo: UndoRedo) -> void:
	match press_type:
		Utilties.PathSweeper_Alts.MOVE:
			_walk_into(undo_redo)

func _walk_into(undo_redo: UndoRedo) -> void:
	if _is_flag:
		return
	# can I be walked to
	for each_n in get_path_neighors():
		if each_n.is_pressed():
			undo_redo.add_do_method(_set_is_pressed.bind(true))
			undo_redo.add_do_method(_signal_group_change)
			undo_redo.add_undo_method(_set_is_pressed.bind(false))
			undo_redo.add_undo_method(_signal_group_change)

func _signal_group_change() -> void:
	changed.emit()
	for each_n in get_map_neighbors():
		each_n.changed.emit()

func get_button_text() -> String:
	if is_pressed():
	#if is_visable():
		return str(self)
	return " "

func is_button_disabled() -> bool:
	if is_pressed():
		return true
	for each_n in get_map_neighbors():
	#for each_n in get_path_neighors():
		if each_n.is_pressed():
			return false
	#if is_visable():
		#return _is_wall
	return true


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

func _set_is_pressed(value: bool) -> void: _is_pressed = value

func block_danger() -> void: _block_danger = true

func is_danger_blocked() -> bool:
	if _block_danger:
		return true
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

func set_is_danger(is_danger_: bool) -> void: _is_danger = is_danger_

func is_danger() -> bool: return _is_danger

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
	#if _is_protected_path:
	#	return "_"
	if _is_danger:
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
