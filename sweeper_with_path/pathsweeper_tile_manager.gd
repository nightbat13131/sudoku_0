class_name PathSweeper_TileManager extends Node2D


const BLANK := Vector2i(-1,-1)

const FLOOR_TILE := Vector2i(4,0)

const FULL_DARK  := Vector2i(2,0)
const HALF_DARK := Vector2(3,0)

const BOULDER := Vector2i(10,0)
const WALL_SEW := Vector2i(7,1)
const DOOR_S := Vector2i(8,1)

const LOOT := Vector2i(12,0)
const DANGER := Vector2i(11,0)
const REPELL_SUCCESS := Vector2i(15,0)
const REPELL_WASTED := Vector2i(16,0)
const FLAG_0 := Vector2i(14,0)
const FLAG_1 := Vector2i(13,0)

@export var _tileset : TileSet
@export var _dark_layers : TileMapLayer
@export var _mid_layers : TileMapLayer
@export var _floor_layers : TileMapLayer
@export var _number_layers : TileMapLayer

#var _width :int
var _cells : Array[Array]
var _req_size := Vector2.ONE

func _ready() -> void:
	set_z_index(100)
	_init_tilemaps()

func set_grid(grid: Array) -> void:
	_cells = grid
	_clear_tilemaps()
	for row in _cells:
		for cell : PathSweeperCellInfo in row:
			cell.updated.connect(_on_cell_update)
			_floor_layers.set_cell(cell.get_position(), 0, FLOOR_TILE)
			_on_cell_update(cell)

func get_width() -> int: return _cells[0].size()

func _init_tilemaps() -> void:
	assert(_tileset and _dark_layers and _mid_layers and _floor_layers and _number_layers )
	for each : TileMapLayer in [_dark_layers, _mid_layers, _floor_layers, _number_layers]:
		each.set_tile_set(_tileset)
		each.set_z_index(-50)
	_req_size = _floor_layers.get_tile_set().get_tile_size() * _floor_layers.get_scale().x

func _clear_tilemaps() -> void:
	for each : TileMapLayer in [_dark_layers, _mid_layers, _floor_layers, _number_layers]:
		each.clear()

func _on_cell_update(cell: PathSweeperCellInfo) -> void:
	var pos := cell.get_position()
	_dark_layers.set_cell(pos, 0, cell.get_darkness())
	_mid_layers.set_cell(pos, 0, cell.get_mid_item())
	_number_layers.set_cell(pos, 0, cell.get_number())

func get_mouse_cell() -> Vector2i: return _floor_layers.local_to_map(get_local_mouse_position())



func _process(_delta: float) -> void: queue_redraw()

func _get_ne() -> Vector2:
	#print(_floor_layers.local_to_map(get_local_mouse_position()))
	return get_mouse_cell() * Vector2i(_req_size) # get_global_mouse_position() - get_global_mouse_position().posmodv(_req_size)

func _draw() -> void:
	draw_circle(_get_ne(), 8, Color.BLACK, false, 2 ) #debug
	__draw_req( _get_ne() )# + (_req_size *.5 ))
	pass

func __draw_req(nw: Vector2) -> void:
	for pair in [
		[Vector2.ZERO, Vector2.RIGHT],
		[Vector2.ZERO, Vector2.DOWN],
		[Vector2.RIGHT, Vector2.DOWN + Vector2.RIGHT],
		[Vector2.DOWN, Vector2.DOWN + Vector2.RIGHT]
			]:
		draw_dashed_line(pair[0] * _req_size + nw, pair[1] *  _req_size + nw, Color.BLACK, 5)
	
	pass
