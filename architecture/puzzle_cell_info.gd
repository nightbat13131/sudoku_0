class_name PuzzleCellInfo extends Resource

var _pos : Vector2i
var _game_over := false

func set_position(vector: Vector2i) -> void: _pos = vector

func get_position() -> Vector2i: return _pos

func is_position(pos: Vector2i) -> bool: return pos == _pos

func game_over() -> void: 
	_game_over = true
	changed.emit()

func is_game_over() -> bool: return _game_over
