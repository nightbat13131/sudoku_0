class_name PathSweeperCellInfo extends PuzzleCellInfo

signal updated(cell_info: PathSweeperCellInfo)

## dark, deep dark, no dark
## Cave floor, cave wall (on a floor), 
## danger number
## loot, danger, 

## Tile alternat ideas: Lava makes more visable around it like a big glow

static var _start : PathSweeperCellInfo
static var _end : PathSweeperCellInfo

var _wall := Utilties.PathSweeper_Alts.NA : set = set_wall
var _danger := Utilties.PathSweeper_Alts.NA : set = set_is_danger
#var _block_danger := false 
var _is_pressed := false : set = _set_is_pressed
var _flag := Utilties.PathSweeper_Alts.NA
var _loot := Utilties.PathSweeper_Alts.NA

# 8 grid of neighbors, self not included
var _map_neighbors : Array[PathSweeperCellInfo] : get = get_map_neighbors

#region Interactions from Controler

func press(press_type: Utilties.PathSweeper_Alts, puzzle: PathSweeper) -> void:
	if has_loot():
		return _do_looting(puzzle)
	match press_type:
		Utilties.PathSweeper_Alts.MOVE:
			_walk_into(puzzle)
		Utilties.PathSweeper_Alts.FLAG_DANGER , Utilties.PathSweeper_Alts.FLAG_SAFE:
			_toggle_flag(press_type, puzzle)
		Utilties.PathSweeper_Alts.REPELL:
			_try_use_repell(puzzle)

func _try_use_repell(puzzle: PathSweeper) -> void:
	if _flag == Utilties.PathSweeper_Alts.FLAG_SAFE:
		return ## marked as not needing repell and safe to walk here. Maybe trigger walk instead? 
	if is_pressed() and !is_danger():
		return
	if puzzle.get_spray_count() <= 0:
		return
	elif !_can_walk_to_here():
		return 
	
	var undo : UndoRedo = puzzle.create_undo_redo_action()
	if is_danger():
		undo.add_do_method(set_is_danger.bind(Utilties.PathSweeper_Alts.REPELL_SUCCESS))
		undo.add_do_method(_set_loot.bind(Utilties.PathSweeper_Alts.LOOT0))
		undo.add_undo_method(set_is_danger.bind(_danger))
		undo.add_undo_method(_set_loot.bind(_loot))
		if _flag == Utilties.PathSweeper_Alts.FLAG_DANGER:
			undo.add_do_method(_set_flag.bind(Utilties.PathSweeper_Alts.NA))
			undo.add_undo_method(_set_flag.bind(_flag))
	else: 
		if !is_pressed():
			undo.add_do_method(set_is_danger.bind(Utilties.PathSweeper_Alts.REPELL_WASTED))
			undo.add_undo_method(set_is_danger.bind(_danger))
	if !is_pressed():
		undo.add_do_method(_set_is_pressed.bind(true))
		undo.add_undo_method(_set_is_pressed.bind(false))
	undo.add_do_method(puzzle.change_spray.bind(-1))
	undo.add_undo_method(puzzle.change_spray.bind(1))


func _walk_into(puzzle: PathSweeper) -> void:
	if is_pressed():
		if _end == self:
			puzzle.request_next_level()
			return

	if _has_flag():
		if _flag == Utilties.PathSweeper_Alts.FLAG_DANGER:
			return # this flag blocks walking here
	if !_can_walk_to_here():
		return 
	var undo : UndoRedo = puzzle.get_undo_redo()
	if is_danger():
		if is_pressed():
			return 
		puzzle.create_undo_redo_action()
		undo.add_do_method(puzzle.change_health.bind(-1))
		undo.add_undo_method(puzzle.change_health.bind(1))
	if _has_flag():
		puzzle.create_undo_redo_action()
		undo.add_do_method(_set_flag.bind(Utilties.PathSweeper_Alts.NA))
		undo.add_undo_method(_set_flag.bind(_flag))
	puzzle.create_undo_redo_action()
	undo.add_do_method(_set_is_pressed.bind(true))
	undo.add_undo_method(_set_is_pressed.bind(false))

func _toggle_flag(press_type: Utilties.PathSweeper_Alts, puzzle: PathSweeper) -> void:
	if is_pressed():
		return 
	var next := press_type
	if _flag == next:
		next = Utilties.PathSweeper_Alts.NA
	var undo : UndoRedo =puzzle.create_undo_redo_action()
	undo.add_do_method(_set_flag.bind(next))
	undo.add_undo_method(_set_flag.bind(_flag))

func _do_looting(puzzle: PathSweeper) -> void:
	assert(has_loot())
	var undo : UndoRedo =puzzle.create_undo_redo_action()
	undo.add_do_method(_set_loot.bind(Utilties.PathSweeper_Alts.NA))
	undo.add_undo_method(_set_loot.bind(_loot))
	undo.add_do_method(puzzle.set_loot_count.bind(puzzle.get_loot_count() + 1) )
	undo.add_undo_method(puzzle.set_loot_count.bind(puzzle.get_loot_count()) )

func _set_loot(loot: Utilties.PathSweeper_Alts) -> void:
	assert([Utilties.PathSweeper_Alts.NA, Utilties.PathSweeper_Alts.LOOT0 ].has(loot))
	_loot = loot
	_signal_group_change()

func has_loot() -> bool: return _loot != Utilties.PathSweeper_Alts.NA

func _signal_group_change() -> void:
	updated.emit(self)
	for each_n in get_map_neighbors():
		each_n.updated.emit(each_n)

func _can_walk_to_here() -> bool:
	for each_n in get_path_neighors():
		if each_n.is_pressed():
			return true
	return false

#endregion

#region Puzzle Generation 

#endregion 

#region TileMapLayer Display

func get_darkness() -> Vector2i: # over layer
	if is_pressed():
		if _end == self:
			return Vector2i(16,0)
		return PathSweeper_TileManager.BLANK
	for each_n in get_map_neighbors():
		if each_n.is_pressed():
			return PathSweeper_TileManager.HALF_DARK
	return PathSweeper_TileManager.FULL_DARK

func get_number() -> Vector2i:
	if is_danger(): # enemies block view of numbers
		return PathSweeper_TileManager.BLANK 
	if is_pressed():
		#if !is_wall():
			var count := get_danger_count()
			if count > 0:
				return Vector2i(0,count)
	return PathSweeper_TileManager.BLANK 

func get_mid_item() -> Vector2i:
	if is_pressed():
		if is_door():
			return _get_door_type()
		if is_wall():
			if _wall == Utilties.PathSweeper_Alts.BOULDER:
				return PathSweeper_TileManager.BOULDER
			return _get_wall_type()
		elif has_loot():
			return PathSweeper_TileManager.LOOT
		elif is_danger():
			return PathSweeper_TileManager.DANGER
		elif _danger == Utilties.PathSweeper_Alts.REPELL_SUCCESS:
			return PathSweeper_TileManager.REPELL_SUCCESS
		elif _danger == Utilties.PathSweeper_Alts.REPELL_WASTED:
			return PathSweeper_TileManager.REPELL_WASTED
	if _has_flag():
		if _flag == Utilties.PathSweeper_Alts.FLAG_SAFE:
			return PathSweeper_TileManager.FLAG_SAFE
		elif _flag == Utilties.PathSweeper_Alts.FLAG_DANGER:
			return PathSweeper_TileManager.FLAG_DANGER
	return PathSweeper_TileManager.BLANK 

func _get_door_direciton() -> Vector2i: 
	var entrance : PuzzleCellInfo = get_path_neighors()[0]
	return entrance.get_position() - self.get_position() # direction 

func _get_door_type() -> Vector2i:
	match _get_door_direciton():
		Vector2i.UP:
			return PathSweeper_TileManager.DOOR_N
		Vector2i.LEFT:
			return PathSweeper_TileManager.DOOR_W
		Vector2i.RIGHT:
			return PathSweeper_TileManager.DOOR_E
	return PathSweeper_TileManager.DOOR_S

func _get_wall_type() -> Vector2i:
	if get_map_neighbors().size() <= 3: # corners
		return PathSweeper_TileManager.WALL_
	elif _pos.x == 0:
		return PathSweeper_TileManager.WALL_E
	elif _pos.y == 0:
		return PathSweeper_TileManager.WALL_S
	elif _start.get_position().y == _pos.y: # while _start is always along the bottom 
		return PathSweeper_TileManager.WALL_N
	return PathSweeper_TileManager.WALL_W

#endregion

#region Button Display 

func get_button_text() -> String:
	if is_pressed():
		var text := ""
		var d_count := get_danger_count()
		if d_count > 0:
			text += str(d_count)
		if is_wall():
			if _wall == Utilties.PathSweeper_Alts.WALL:
				return "#"
			elif _wall == Utilties.PathSweeper_Alts.BOULDER:
				return "%"
		if has_loot():
			text += "@"
		if is_danger():
			text += "X"
		return text
	if _has_flag():
		if _flag == Utilties.PathSweeper_Alts.FLAG_DANGER:
			return "d"
		elif _flag == Utilties.PathSweeper_Alts.FLAG_SAFE:
			return "_"
	return " "

func is_button_disabled() -> bool:
	if has_loot():
		return false
	if is_pressed():
		if is_danger():
			return false
		return true
	for each_n in get_map_neighbors():
		if each_n.is_pressed():
			return false
	return true

#endregion 

func _set_flag(value: Utilties.PathSweeper_Alts) -> void: 
	assert([Utilties.PathSweeper_Alts.NA, Utilties.PathSweeper_Alts.FLAG_DANGER, Utilties.PathSweeper_Alts.FLAG_SAFE].has(value))
	_flag = value
	_signal_group_change()

func _has_flag() -> bool: return _flag != Utilties.PathSweeper_Alts.NA

func set_wall(wall_: Utilties.PathSweeper_Alts) -> void: 
	assert( [Utilties.PathSweeper_Alts.NA, 
	Utilties.PathSweeper_Alts.WALL, Utilties.PathSweeper_Alts.BOULDER].has(wall_) )
	_wall = wall_

func is_wall() -> bool:
	if is_door():
		return false
	return [Utilties.PathSweeper_Alts.WALL, Utilties.PathSweeper_Alts.BOULDER].has(_wall)

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
	assert( [Utilties.PathSweeper_Alts.BLOCKED, Utilties.PathSweeper_Alts.NA, 
	Utilties.PathSweeper_Alts.REPELL_SUCCESS, Utilties.PathSweeper_Alts.REPELL_WASTED,
	Utilties.PathSweeper_Alts.DANGER0,].has(danger) )
	_danger = danger
	_signal_group_change()

func is_danger() -> bool: 
	match _danger:
		Utilties.PathSweeper_Alts.DANGER0:
			return true
		Utilties.PathSweeper_Alts.NA, Utilties.PathSweeper_Alts.BLOCKED, Utilties.PathSweeper_Alts.REPELL_SUCCESS, Utilties.PathSweeper_Alts.REPELL_WASTED :
			return false
	push_warning("No match for danger")
	return true

func get_danger_count() -> int:
	var out := 0
	if is_danger():
		out += 1
	for each : PathSweeperCellInfo in get_map_neighbors():
		if each.is_danger():
			out += 1
	return out

func is_path() -> bool:
	if is_door():
		return true
	if is_danger():
		return false
	return !is_wall()

func is_door() -> bool: return _start == self or _end == self

func _to_string() -> String:
	if is_door(): # door first becuse it's external 
		return "^"
	if is_wall():
		if _wall == Utilties.PathSweeper_Alts.WALL:
			return "#"
		elif _wall == Utilties.PathSweeper_Alts.BOULDER:
			return "%"
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
