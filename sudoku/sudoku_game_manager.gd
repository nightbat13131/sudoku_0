class_name SudokuGame extends Control

@export var _sudoku : Sudoku
@export var _sudoku_cell_theme : SudokuCellTheme

@onready var sudoku_game_grid: SudokuGrid = %SudokuGameGrid
@onready var mouse_helper: MouseHelper = %MouseHelper
@onready var selected_number: SpinBox = %SelectedNumber
@onready var button_undo: ButtonEnhanced = %ButtonUndo
@onready var button_redo: ButtonEnhanced = %ButtonRedo
@onready var button_new: ButtonEnhanced = %ButtonNew

static var _instance : SudokuGame

func _ready() -> void:
	_instance = self
	_sudoku.puzzle_generated.connect(_on_puzzle_generated)
	sudoku_game_grid.set_sudoku(_sudoku)
	button_new.pressed.connect(_on_request_new)
	button_undo.pressed.connect(_on_undo)
	button_redo.pressed.connect(_on_redo)
	sudoku_game_grid.set_sudoku_cell_theme(_sudoku_cell_theme)
	#sudoku_game_grid.child_entered_tree.connect(_on_sudoku_game_grid_child_entered_tree)
	#sudoku.new_game(Vector2i(4,4), Vector2i(2,2), Utilties.Difficulty.HARD)
	#await get_tree().process_frame
	#_a.display_grid(_a._solution_grid, "Solution")
	#_a.display_grid(_a.get_player_grid(), "player")
	#sudoku_game_grid.apply_grid( sudoku.get_player_grid())
#	_a.gen(Utilties.Difficulty.EASY)
	#_a.print_1()
	#print(_a.domains)
	_start_game()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Utilties.INPUT_UNDO):
		_on_undo()
	elif event.is_action_pressed(Utilties.INPUT_REDO):
		_on_redo()

func _start_game() -> void:
	_sudoku.generate_next_puzzle()

static func sudoku_cell_pressed(pos: Vector2i) -> void:
	if _instance:
		_instance._sudoku_cell_pressed(pos)

func _sudoku_cell_pressed(pos: Vector2i) -> void:
	_sudoku.request_player_guess(pos, selected_number.get_value() as int )

static func sudoku_cell_clear(pos: Vector2i) -> void:
	if _instance:
		_instance._sudoku_cell_clear(pos)

func _sudoku_cell_clear(pos: Vector2i) -> void:
	_sudoku.request_player_guess(pos, Utilties.Sudoku_Cell_Alts.EMPTY as int )

static func sudoku_cell_hint(pos: Vector2) -> void:
	if _instance:
		_instance._sudoku_cell_hint(pos)

func _sudoku_cell_hint(pos: Vector2) -> void:
	_sudoku.request_player_hint(pos, selected_number.get_value() as int )

func _on_puzzle_generated() -> void: 
	selected_number.set_max(_sudoku.get_domain_max())

func _on_undo() -> void: 
	if _sudoku:
		_sudoku.request_undo()

func _on_redo() -> void:
	if _sudoku:
		_sudoku.request_redo()

func _on_request_new() -> void: _sudoku.generate_next_puzzle()
