class_name PathSweeperManager extends Control

@onready var button_undo: Button = %ButtonUndo
@onready var button_redo: Button = %ButtonRedo
@onready var button_new: Button = %ButtonNew
@onready var path_sweeper_grid: PathSweeperGrid = %PathSweeperGrid

@export var _puzzle: PathSweeper
@export var press_type_button_group : ButtonGroup

@warning_ignore("unused_private_class_variable")
@export var _theme : Variant

static var _instance : PathSweeperManager

func _ready() -> void:
	_instance = self
	assert(_puzzle)
	_puzzle.puzzle_generated.connect(_on_puzzle_generated)
	button_undo.pressed.connect(_on_undo)
	button_redo.pressed.connect(_on_redo)
	button_new.pressed.connect(_on_new)
	_on_new()

func _on_new() -> void: if _puzzle: _puzzle.new_puzzle()

func _on_undo() -> void: if _puzzle: _puzzle.request_undo()

func _on_redo() -> void: if _puzzle: _puzzle.request_redo()

func _on_puzzle_generated() -> void: path_sweeper_grid.populate_grid(_puzzle.get_cells_grid())

static func on_press(pos: Vector2i) -> void:
	if _instance:
		_instance._puzzle.send_press(pos, Utilties.PathSweeper_Alts.MOVE)
