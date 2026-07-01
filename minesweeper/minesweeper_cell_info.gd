class_name MinesweeperCellInfo extends Resource


const GUESS_NONE = " "


var _is_bomb := false
var _is_flag := false
var _is_pressed := false
var _neighbor_bomb_count := 0
var _pos : Vector2i
var _game_over := false

func _init(vector: Vector2i) -> void: _pos = vector

func get_show_text() -> String:
	# No guess
	if _is_flag and !_game_over:
		return "F"
	elif !_is_pressed and _game_over and _is_bomb:
		return "*"
	elif !_is_pressed and _game_over:
		return "_"
	elif _is_pressed:
		if _is_bomb:
			return "#"
		elif _neighbor_bomb_count == 0:
			return " "
		else:
			return str(_neighbor_bomb_count)
	return " " 

func get_disable_button() -> bool: 
	if _is_pressed or _game_over:
		return true
	return false

func set_pressed(is_pressed_: bool) -> void:
	_is_pressed = is_pressed_
	changed.emit()

func is_pressed() -> bool: return _is_pressed

func set_flag(is_flag) -> void: 
	_is_flag = is_flag
	changed.emit()

func is_flagged() -> bool: return _is_flag

func get_pos() -> Vector2i: return _pos

func is_pos(pos: Vector2i) -> bool: return pos == _pos

func set_is_bomb(is_bomb_: bool) -> void: _is_bomb = is_bomb_

func is_bomb() -> bool: return _is_bomb

func game_over() -> void: 
	_game_over = true
	changed.emit()

func is_game_over() -> bool: return _game_over

func incrament_bomb_count() -> void: _neighbor_bomb_count += 1

func get_bomb_count() -> int: return _neighbor_bomb_count
