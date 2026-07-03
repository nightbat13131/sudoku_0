class_name SudokuButton extends Button

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
		_info.changed.connect(_on_info_changed)
		set_disabled(!_info.is_player_cell())
	_on_guess_change.bind(_info.get_button_text()).call_deferred()

func set_sudoku_cell_theme(cell_theme: SudokuCellTheme) -> void:
	_sudoku_cell_theme = cell_theme
	_try_set_icon.call_deferred()

func _try_set_icon() -> void:
	if is_inside_tree():
		if _sudoku_cell_theme:
			set_button_icon(_sudoku_cell_theme.cell_background)

func _update_icon() -> void: 
	if is_inside_tree():
		if _sudoku_cell_theme:
			set_button_icon(_sudoku_cell_theme.get_index_texture( _info.get_button_value()))

func _on_guess_change(button_text: String) -> void:
	set_text(button_text)
	_update_icon.call_deferred()

func _on_info_changed() -> void:
	if _info.is_game_over():
		set_disabled(true)
