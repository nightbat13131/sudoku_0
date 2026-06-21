class_name SudokuGame extends Control


@export var _sudoku : Sudoku
@onready var sudoku_game_grid: SudokuGrid = %SudokuGameGrid
@onready var mouse_helper: MouseHelper = %MouseHelper
@onready var selected_number: SpinBox = %SelectedNumber

static var _instance : SudokuGame

func _ready() -> void:
	_instance = self
	_sudoku.puzzle_generated.connect(_on_puzzle_generated)
	sudoku_game_grid.set_sudoku(_sudoku)
	
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

func _start_game() -> void:
	_sudoku.generate_next_puzzle()

static func sudoku_pressed(pos: Vector2i) -> void:
	if _instance:
		_instance._sudoku_pressed(pos)

func _sudoku_pressed(pos: Vector2i) -> void:
	sudoku_game_grid.apply_cell(pos, selected_number.get_value() as int)

func _on_puzzle_generated() -> void: 
	selected_number.set_max(_sudoku.get_domain_max())
