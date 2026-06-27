class_name SudokuGame extends Control

@export var _sudoku : Sudoku
@export var _sudoku_cell_theme : SudokuCellTheme

@export_category("G.U.I.D.E.")
@export var puzzle_context: GUIDEMappingContext
@export var action_undo: GUIDEAction
@export var action_redo : GUIDEAction

@onready var sudoku_game_grid: SudokuGrid = %SudokuGameGrid
@onready var mouse_helper: SudokuMouseHelper = %MouseHelper
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
	if puzzle_context:
		GUIDE.enable_mapping_context(puzzle_context)
		tree_exiting.connect(GUIDE.disable_mapping_context.bind(puzzle_context))
		if action_redo:
			action_redo.triggered.connect(_on_redo)
		if action_undo:
			action_undo.triggered.connect(_on_undo)
	_on_request_new()

static func sudoku_cell_pressed(pos: Vector2i) -> void: if _instance: _instance._sudoku_cell_pressed(pos)

func _sudoku_cell_pressed(pos: Vector2i) -> void: _sudoku.request_player_guess(pos, selected_number.get_value() as int )

static func sudoku_cell_clear(pos: Vector2i) -> void: if _instance:	_instance._sudoku_cell_clear(pos)

func _sudoku_cell_clear(pos: Vector2i) -> void: _sudoku.request_player_guess(pos, Utilties.Sudoku_Cell_Alts.EMPTY as int )

static func sudoku_cell_hint(pos: Vector2) -> void: if _instance: _instance._sudoku_cell_hint(pos)

func _sudoku_cell_hint(pos: Vector2) -> void: _sudoku.request_player_hint(pos, selected_number.get_value() as int )

func _on_puzzle_generated() -> void: selected_number.set_max(_sudoku.get_domain_max())

func _on_undo() -> void: if _sudoku: _sudoku.request_undo()

func _on_redo() -> void: if _sudoku: _sudoku.request_redo()

func _on_request_new() -> void: _sudoku.new_puzzle()
