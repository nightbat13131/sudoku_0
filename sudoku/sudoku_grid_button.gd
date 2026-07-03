
class_name SudokuButton extends Button

#var _pos: Vector2
#var _value : Variant
var _info: SudokuCellInfo
var _sudoku_cell_theme : SudokuCellTheme : set = set_sudoku_cell_theme

func _ready() -> void:
	set_text_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	set_icon_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	set_button_mask(MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_MIDDLE | MOUSE_BUTTON_MASK_RIGHT )
	_try_set_icon()

func set_cell_info(cell: SudokuCellInfo) -> void:
	_info = cell
	if _info:
		_info.guess_changed.connect(_on_guess_change)
		set_disabled(!_info.is_player_cell())
	_on_guess_change.bind(_info.get_button_text()).call_deferred()

func set_sudoku_cell_theme(cell_theme: SudokuCellTheme) -> void:
	_sudoku_cell_theme = cell_theme
	_try_set_icon.call_deferred()

func _try_set_icon() -> void:
	if is_inside_tree():
		if _sudoku_cell_theme:
			set_button_icon(_sudoku_cell_theme.cell_background)

#func set_value(pos: Vector2, value: Variant, do_lock:= false) -> void: 
	#_pos = pos
	#_value = value
	#if _value == Utilties.Sudoku_Cell_Alts.EMPTY:
		#set_text(" ")
	#else: 
		#set_text(str(value))
	#set_disabled(do_lock)
	#_update_icon.call_deferred()

func _update_icon() -> void: 
	if is_inside_tree():
		if _sudoku_cell_theme:
			set_button_icon(_sudoku_cell_theme.get_index_texture( _info.get_button_value()))

func _on_guess_change(button_text: String) -> void:
	#var _text := "|"
	#if _info:
	#	_text = _info.get_button_text()
	set_text(button_text)
	_update_icon.call_deferred()
	
