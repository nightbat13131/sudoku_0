class_name PathSweeperManager extends Control

@onready var button_undo: Button = %ButtonUndo
@onready var button_redo: Button = %ButtonRedo
@onready var button_new: Button = %ButtonNew
@onready var path_sweeper_grid: PathSweeperGrid = %PathSweeperGrid
@onready var label_status: Label = %LabelStatus
@onready var tile_manager: PathSweeper_TileManager = %TileManager

@export var _puzzle: PathSweeper
@export var press_type_button_group : ButtonGroup


@warning_ignore("unused_private_class_variable")
@export var _theme : Variant

static var _instance : PathSweeperManager

func _ready() -> void:
	_instance = self
	assert(_puzzle)
	_puzzle.puzzle_generated.connect(_on_puzzle_generated)
	_puzzle.changed.connect(_on_puzzle_change)
	button_undo.pressed.connect(_on_undo)
	button_redo.pressed.connect(_on_redo)
	button_new.pressed.connect(_on_new)
	_on_new()

func _on_new() -> void: if _puzzle: _puzzle.new_puzzle()

func _on_undo() -> void: if _puzzle: _puzzle.request_undo()

func _on_redo() -> void: if _puzzle: _puzzle.request_redo()

func _on_puzzle_generated() -> void: 
	path_sweeper_grid.populate_grid(_puzzle.get_cells_grid())
	%ButtonWalk.set_pressed(true)
	tile_manager.set_grid(_puzzle.get_cells_grid())
	_on_puzzle_change()

static func on_press(pos: Vector2i) -> void:
	if _instance:
		_instance._puzzle.send_press(pos, _instance._get_press_type())

func _get_press_type() -> Utilties.PathSweeper_Alts:
	if press_type_button_group:
		var holder := press_type_button_group.get_pressed_button()
		if holder is PressTypeButtonPathSwpeeper:
			return holder.get_press_type()
	return Utilties.PathSweeper_Alts.NA

func _on_puzzle_change() -> void:
	label_status.set_text(_puzzle.get_status_text())
