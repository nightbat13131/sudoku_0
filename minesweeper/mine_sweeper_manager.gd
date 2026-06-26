class_name MineSweeperManager extends Control

enum PressType {NA = -1, SINGLE = 0,  FLAG = 1, WIDE_PRESS = 2}
@onready var mine_sweeper_grid: MineSweeperGrid = %MineSweeperGrid

@export var _minesweeper : MineSweeper

@export_category("G.U.I.D.E.")
@export var _puzzle_context : GUIDEMappingContext
@export var _action_single : GUIDEAction
@export var _action_flag : GUIDEAction
@export var _action_wide : GUIDEAction

static var _instance : MineSweeperManager

var _press_mode := PressType.NA : set = _set_press_mode

func _ready() -> void:
	_instance = self
	if _puzzle_context:
		GUIDE.enable_mapping_context(_puzzle_context)
		tree_exited.connect(GUIDE.disable_mapping_context.bind(_puzzle_context))
		if _action_single:
			_action_single.triggered.connect(_set_press_mode.bind(PressType.SINGLE))
		if _action_flag:
			_action_flag.triggered.connect(_set_press_mode.bind(PressType.FLAG))
		if _action_single:
			_action_wide.triggered.connect(_set_press_mode.bind(PressType.WIDE_PRESS))
	if _minesweeper:
		mine_sweeper_grid.set_minesweeper(_minesweeper)
		_minesweeper.new_puzzle()

func _set_press_mode(thing: PressType) -> void: _press_mode = thing

static func cell_pressed(pos: Vector2i) -> void: if _instance: _instance._on_cell_pressed(pos)

func _on_cell_pressed(pos: Vector2i) -> void:
	prints("Cell_pressed ", pos, _press_mode)
