@tool
class_name SudokuCell extends PanelContainer

var _mode := Utilties.SudokuMode.ICONS

enum PressTypes {NA = 0, PEN = 1, ERASE = 2, PENCIL = 3}

static var _press_type := PressTypes.NA ## static because only the first object in the tree catches the action, after that it's counting as handled. 

@export var _sudoku_cell_theme : SudokuCellTheme : set = set_sudoku_cell_theme
@onready var texture_back: TextureRect = %TextureBack
@onready var sudoku_button: SudokuButton = %SudokuButton
@onready var pencil: Label = %Pencil

@export var action_pen: GUIDEAction
@export var action_erase: GUIDEAction
@export var action_pencil: GUIDEAction

var _pos : Vector2i

func _ready() -> void:
	_try_set_icon.call_deferred()
	sudoku_button.pressed.connect(_on_button_press)
	if Engine.is_editor_hint():
		return
	pencil.set_text("")
	if action_pen:
		action_pen.triggered.connect(_set_press_type.bind(PressTypes.PEN))
	if action_erase:
		action_erase.triggered.connect(_set_press_type.bind(PressTypes.ERASE))	
	if action_pencil:
		action_pencil.triggered.connect(_set_press_type.bind(PressTypes.PENCIL))
	mouse_exited.connect(_set_press_type.bind(PressTypes.NA))

func set_sudoku_cell_theme(cell_theme: SudokuCellTheme) -> void:
	_sudoku_cell_theme = cell_theme
	_try_set_icon.call_deferred()

func _try_set_icon() -> void:
	if is_inside_tree():
		if _sudoku_cell_theme:
			sudoku_button.set_sudoku_cell_theme(_sudoku_cell_theme)
			texture_back.set_texture(_sudoku_cell_theme.cell_background)

func set_value(pos: Vector2, value: Variant, do_lock:= false) -> void: 
	_pos = pos
	if value == Utilties.Sudoku_Cell_Alts.EMPTY:
		pencil.show()
	else:
		pencil.hide()
	sudoku_button.set_value(pos, value, do_lock)	

func set_hint(pos: Vector2, hints: Array, shape: Vector2) -> void: 
	_pos = pos
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

func _set_press_type(thing: PressTypes) -> void: _press_type = thing

func _on_button_press() -> void:
	match _press_type:
		PressTypes.PEN: #  PressMode.LEFT:
			SudokuGame.sudoku_cell_pressed(_pos)
		PressTypes.PENCIL: #  PressMode.RIGHT:
			SudokuGame.sudoku_cell_hint(_pos)
		PressTypes.ERASE: 
			SudokuGame.sudoku_cell_clear(_pos)
