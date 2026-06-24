@tool
class_name SudokuCell extends PanelContainer

var _mode := Utilties.SudokuMode.ICONS

@export var _sudoku_cell_theme : SudokuCellTheme : set = set_sudoku_cell_theme
@onready var texture_back: TextureRect = %TextureBack
@onready var sudoku_button: SudokuButton = %SudokuButton
@onready var pencil: Label = %Pencil

func _ready() -> void:
	_try_set_icon.call_deferred()
	if !Engine.is_editor_hint():
		pencil.set_text("")

func set_sudoku_cell_theme(cell_theme: SudokuCellTheme) -> void:
	_sudoku_cell_theme = cell_theme
	_try_set_icon.call_deferred()

func _try_set_icon() -> void:
	if is_inside_tree():
		if _sudoku_cell_theme:
			sudoku_button.set_sudoku_cell_theme(_sudoku_cell_theme)
			texture_back.set_texture(_sudoku_cell_theme.cell_background)

func set_value(pos: Vector2, value: Variant, do_lock:= false) -> void: 
	if value == Utilties.Sudoku_Cell_Alts.EMPTY:
		pencil.show()
	else:
		pencil.hide()
	sudoku_button.set_value(pos, value, do_lock)	

func set_hint(_pos: Vector2, hints: Array, shape: Vector2) -> void: 
	var hint_text := ""
	var count = 1
	for r in shape.y:
		for c in shape.x: 
			if hints.has(count):
				if _mode == Utilties.SudokuMode.NUMBERS:
					hint_text += str(count)
				else: 
					hint_text += "*"
			else: 
				hint_text += " "
			if c +1 == shape.x:
				if r + 1 != shape.y:
					hint_text += "\n"
			else:
				hint_text += " "
							
			count += 1
	pencil.set_text(hint_text)
