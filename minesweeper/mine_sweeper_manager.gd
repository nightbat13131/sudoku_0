class_name MineSweeperManager extends Control

#enum PressType {NA = -1, SINGLE = 0,  FLAG = 1, WIDE_PRESS = 2}

const NO_POS = Vector2i(-9, -7)
#const EVENT_TO_WAIT = "wait"
#const EVENT_WIDE_START = "wide_start"
#const EVENT_WIDE_STOP = "wide_stop"

@onready var mine_sweeper_grid: MineSweeperGrid = %MineSweeperGrid
@onready var button_undo: ButtonEnhanced = %ButtonUndo
@onready var button_redo: ButtonEnhanced = %ButtonRedo
@onready var button_new: ButtonEnhanced = %ButtonNew

@export var _minesweeper : MineSweeper

@export_category("G.U.I.D.E.")
@export var _puzzle_context : GUIDEMappingContext
@export var _action_single : GUIDEAction
@export var _action_flag : GUIDEAction
@export var _action_wide_start : GUIDEAction
@export var _action_wide_end : GUIDEAction

static var _instance : MineSweeperManager
var _mouse_pos : Vector2i = NO_POS
var _wide_pressed := false : set = _set_wide_pressed
var _press_mode := Utilties.MineSweeper_Cells_Alts.PRESS : set = _set_press_mode
var _puzzle_active := false

func _ready() -> void:
	_instance = self
	button_new.pressed.connect(_on_new)
	button_redo.pressed.connect(_on_redo)
	button_undo.pressed.connect(_on_undo)
	if _puzzle_context:
		GUIDE.enable_mapping_context(_puzzle_context)
		tree_exited.connect(GUIDE.disable_mapping_context.bind(_puzzle_context))
		if _action_single:
			_action_single.triggered.connect(_set_press_mode.bind(Utilties.MineSweeper_Cells_Alts.PRESS))
		if _action_flag:
			_action_flag.triggered.connect(_set_press_mode.bind(Utilties.MineSweeper_Cells_Alts.FLAG))
		if _action_wide_start:
			_action_wide_start.triggered.connect(_set_wide_pressed.bind(true))
		if _action_wide_end: 
			_action_wide_end.triggered.connect(_set_wide_pressed.bind(false))
	if _minesweeper:
		mine_sweeper_grid.set_minesweeper(_minesweeper)
		_minesweeper.puzzle_complete.connect(_on_puzzle_complete)
		_on_new()

func _set_press_mode(thing: Utilties.MineSweeper_Cells_Alts) -> void: _press_mode = thing

static func cell_pressed(pos: Vector2i) -> void: if _instance: _instance._on_cell_pressed(pos)

func _on_cell_pressed(pos: Vector2i) -> void:
	if !_puzzle_active: 
		return
	assert(_minesweeper)
	_minesweeper.send_press(pos, _press_mode)

func _on_new() -> void: 
	if _minesweeper: 
		_minesweeper.new_puzzle()
		_puzzle_active = true

func _on_undo() -> void: if _minesweeper: _minesweeper.request_undo()

func _on_redo() -> void: if _minesweeper: _minesweeper.request_redo()

static func mouse_in_pos(pos: Vector2i, is_entering: bool) -> void: if _instance: _instance._mouse_in_pos(pos, is_entering)

func _mouse_in_pos(pos: Vector2i, is_entering: bool) -> void:
	var old_pos := _mouse_pos
	if is_entering:
		_mouse_pos = pos
	else: 
		if _mouse_pos == pos:
			_mouse_pos = NO_POS
	if _wide_pressed:
		if _has_cell():
			_on_wide_hold(_mouse_pos, true)
		else: 
			_on_wide_hold(old_pos, false)

func _set_wide_pressed(is_pressed: bool) -> void:
	#var old_pressed := _wide_pressed
	_wide_pressed = is_pressed
	if _has_cell():
		_on_wide_hold(_mouse_pos, _wide_pressed)
		if !_wide_pressed:
			_on_wide_press()

func _on_wide_hold(pos: Vector2i, is_pressed: bool) -> void: 
	if !_puzzle_active: 
		return
	mine_sweeper_grid.remote_hold(pos, is_pressed)

func _on_wide_press() -> void: 
	if !_puzzle_active: 
		return
	_minesweeper.send_wide_press(_mouse_pos)

func _has_cell() -> bool: return _mouse_pos != MineSweeperManager.NO_POS

func _on_puzzle_complete(result: Utilties.Results) -> void:
	if result == Utilties.Results.WIN:
		_puzzle_active = false
		print("win")
	elif result == Utilties.Results.LOSS:
		_puzzle_active = false
		print("loss")
		
