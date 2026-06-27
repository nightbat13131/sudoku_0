class_name MineSweeperManager extends Control

enum PressType {NA = -1, SINGLE = 0,  FLAG = 1, WIDE_PRESS = 2}

const NO_POS = Vector2i(-65658438, -758417)

@onready var mine_sweeper_grid: MineSweeperGrid = %MineSweeperGrid
@onready var button_undo: ButtonEnhanced = %ButtonUndo
@onready var button_redo: ButtonEnhanced = %ButtonRedo
@onready var button_new: ButtonEnhanced = %ButtonNew

@export var _minesweeper : MineSweeper

@export_category("G.U.I.D.E.")
@export var _puzzle_context : GUIDEMappingContext
@export var _action_single : GUIDEAction
@export var _action_flag : GUIDEAction
@export var _action_wide : GUIDEAction

static var _instance : MineSweeperManager
static var _mouse_in_pos : Vector2i = NO_POS

var _press_mode := PressType.NA : set = _set_press_mode

func _ready() -> void:
	_instance = self
	button_new.pressed.connect(_on_new)
	button_redo.pressed.connect(_on_redo)
	button_undo.pressed.connect(_on_undo)
	if _puzzle_context:
		GUIDE.enable_mapping_context(_puzzle_context)
		tree_exited.connect(GUIDE.disable_mapping_context.bind(_puzzle_context))
		if _action_single:
			_action_single.triggered.connect(_set_press_mode.bind(PressType.SINGLE))
		if _action_flag:
			_action_flag.triggered.connect(_set_press_mode.bind(PressType.FLAG))
		if _action_wide:
			_action_wide.triggered.connect(_on_wide_press)
			pass
	if _minesweeper:
		mine_sweeper_grid.set_minesweeper(_minesweeper)
		_minesweeper.new_puzzle()

func _set_press_mode(thing: PressType) -> void: _press_mode = thing

static func cell_pressed(pos: Vector2i) -> void: if _instance: _instance._on_cell_pressed(pos)

func _on_cell_pressed(pos: Vector2i) -> void:
	assert(_minesweeper)
	if _press_mode == PressType.SINGLE:
		_minesweeper.send_press(pos, Utilties.MineSweeper_Cells_Alts.EMPTY)
	elif _press_mode == PressType.FLAG: 
		_minesweeper.send_press(pos, Utilties.MineSweeper_Cells_Alts.FLAG)
		
	#prints("Cell_pressed ", pos, _press_mode)

func _on_new() -> void: if _minesweeper: _minesweeper.new_puzzle()

func _on_undo() -> void: if _minesweeper: _minesweeper.request_undo()

func _on_redo() -> void: if _minesweeper: _minesweeper.request_redo()

static func mouse_in_pos(pos: Vector2i, is_entering: bool) -> void:
	if is_entering:
		_mouse_in_pos = pos
	else: 
		if _mouse_in_pos == pos:
			_mouse_in_pos = NO_POS
	#print(_mouse_in_pos)

func _on_wide_press() -> void:
	prints(_mouse_in_pos, _mouse_in_pos == NO_POS, _action_wide.is_triggered(), _action_wide.is_ongoing(), _action_wide.is_completed())
	
	
	
	
	
	
	
