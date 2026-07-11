class_name PathSweeperManager extends Node

@onready var button_undo: Button = %ButtonUndo
@onready var button_redo: Button = %ButtonRedo
@onready var button_new: Button = %ButtonNew
@onready var label_status: Label = %LabelStatus
@onready var tile_manager: PathSweeper_TileManager = %TileManager
@onready var score_holder: ScoreHolder_PathSweeper = %ScoreHolder


@export var _puzzle: PathSweeper
@export var press_type_button_group : ButtonGroup
@export var press_type_button_group_second : ButtonGroup

@export_category("G.U.I.D.E.")
@export var _context : GUIDEMappingContext
@export var _primary_action: GUIDEAction
@export var _secondary_action: GUIDEAction

@warning_ignore("unused_private_class_variable")
@export var _theme : Variant

static var _instance : PathSweeperManager

func _ready() -> void:
	_instance = self
	assert(_puzzle)
	_puzzle.puzzle_generated.connect(_on_puzzle_generated)
	score_holder.set_puzzle_info(_puzzle)
	button_undo.pressed.connect(_on_undo)
	button_redo.pressed.connect(_on_redo)
	button_new.pressed.connect(_on_new)
	if _context:
		GUIDE.enable_mapping_context(_context)
		if _primary_action:
			_primary_action.triggered.connect(_on_primary_action)
		if _secondary_action:
			_secondary_action.triggered.connect(_on_secondary_action)
	_on_new()

func _on_new() -> void: if _puzzle: 
	%ButtonWalk.set_pressed(true)
	%ButtonFlag3.set_pressed(true)
	_puzzle.new_game() #new_puzzle()

func _on_undo() -> void: if _puzzle: _puzzle.request_undo()

func _on_redo() -> void: if _puzzle: _puzzle.request_redo()

func _on_puzzle_generated() -> void: 
	tile_manager.set_grid(_puzzle.get_cells_grid())
	_on_puzzle_change()

func _on_primary_action() -> void:
	var pos = tile_manager.get_mouse_cell()
	_instance._puzzle.send_press(pos, _instance._get_press_type())

func _on_secondary_action() -> void:
	var pos = tile_manager.get_mouse_cell()
	_instance._puzzle.send_press(pos, _instance._get_press_type_secondary())

func _get_press_type() -> Utilties.PathSweeper_Alts:
	if press_type_button_group:
		var holder := press_type_button_group.get_pressed_button()
		if holder is PressTypeButtonPathSwpeeper:
			return holder.get_press_type()
	return Utilties.PathSweeper_Alts.NA

func _get_press_type_secondary() -> Utilties.PathSweeper_Alts:
	if press_type_button_group_second:
		var holder := press_type_button_group_second.get_pressed_button()
		if holder is PressTypeButtonPathSwpeeper:
			return holder.get_press_type()
	return Utilties.PathSweeper_Alts.NA

func _on_puzzle_change() -> void:
	label_status.set_text(_puzzle.get_status_text())
