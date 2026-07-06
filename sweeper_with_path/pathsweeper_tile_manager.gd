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

var _width :int
var _cells : Array[Array]

func set_grid(grid: Array) -> void:
	_cells = grid
	_clear_tilemaps()
	for row in _cells:
		for cell : PathSweeperCellInfo in row:
			cell.updated.connect(_on_cell_update)
			_floor_layers.set_cell(cell.get_position(), 0, FLOOR_TILE)
			_on_cell_update(cell)
			#

func _pos_to_index(pos: Vector2i) -> int: return get_width() * (pos.y) + pos.x

func _set_width(value: int) -> void: _width = value

func get_width() -> int: return _width

func _init_tilemaps() -> void:
	assert(_tileset and _dark_layers and _mid_layers and _floor_layers and _number_layers )
	for each : TileMapLayer in [_dark_layers, _mid_layers, _floor_layers, _number_layers]:
		each.set_tile_set(_tileset)

func _clear_tilemaps() -> void:
	for each : TileMapLayer in [_dark_layers, _mid_layers, _floor_layers, _number_layers]:
		each.clear()

func _on_cell_update(cell: PathSweeperCellInfo) -> void:
	var pos := cell.get_position()
	_dark_layers.set_cell(pos, 0, cell.get_darkness())
	_mid_layers.set_cell(pos, 0, cell.get_mid_item())
	_number_layers.set_cell(pos, 0, cell.get_number())
	# set_cell(coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0)
