@tool
class_name SudokuCell extends Control


@export var _sudoku_cell_theme : SudokuCellTheme : set = set_sudoku_cell_theme
@onready var texture_back: TextureRect = %TextureBack
@onready var sudoku_button: SudokuButton = %SudokuButton

func _ready() -> void:
	_try_set_icon.call_deferred()

func set_sudoku_cell_theme(cell_theme: SudokuCellTheme) -> void:
	_sudoku_cell_theme = cell_theme
	_try_set_icon.call_deferred()

func _try_set_icon() -> void:
	if is_inside_tree():
		if _sudoku_cell_theme:
			sudoku_button.set_sudoku_cell_theme(_sudoku_cell_theme)
			texture_back.set_texture(_sudoku_cell_theme.cell_background)

func set_value(pos: Vector2, value: Variant, do_lock:= false) -> void: 
	sudoku_button.set_value(pos, value, do_lock)	
