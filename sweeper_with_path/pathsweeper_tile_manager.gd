class_name PathSweeper_TileManager extends Node2D
## orignal gameboy resolution: resolution of 160 pixels wide by 144 pixels high in a 10:9 aspect ratio.

const BLANK := Vector2i(-1,-1)

const FLOOR_TILE := Vector2i(4,0)

const FULL_DARK  := Vector2i(2,0)
const HALF_DARK := Vector2(3,0)

const BOULDER := Vector2i(7,0)

const WALL_ := Vector2i(5,0)
const WALL_N := Vector2i(5,1)
const WALL_S := Vector2i(5,2)
const WALL_E := Vector2i(5,3)
const WALL_W := Vector2i(5,4)

const DOOR_N := Vector2i(6,0)
const DOOR_S := Vector2i(6,1)
const DOOR_E := Vector2i(6,2)
const DOOR_W := Vector2i(6,3)

const ARROW_N := Vector2i(16,0)
const ARROW_E := Vector2i(16,2)
const ARROW_W := Vector2i(16,1)

const LOOT := Vector2i(9,0)
const DANGER := Vector2i(8,0)
const REPELL_SUCCESS := Vector2i(14,1)
const REPELL_WASTED := Vector2i(14,1)
const FLAG_DANGER := Vector2i(11,0)
const FLAG_SAFE := Vector2i(10,0)

@export var _tileset : TileSet
@export var _dark_layers : TileMapLayer
@export var _mid_layers : TileMapLayer
@export var _floor_layers : TileMapLayer
@export var _number_layers : TileMapLayer

#var _width :int
var _cells : Array[Array]
var _req_size := Vector2i.ONE

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

#func _get_ne() -> Vector2:
	##print(_floor_layers.local_to_map(get_local_mouse_position()))
	#return get_mouse_cell() * Vector2i(_req_size) # get_global_mouse_position() - get_global_mouse_position().posmodv(_req_size)

func _draw() -> void:
	var cell := get_mouse_cell()
	if !_cell_in_use( cell ):
		return

	#draw_circle(cell * _req_size, 8, Color.BLACK, false, 2 ) #debug
	__draw_req( cell )# + (_req_size *.5 ))
	for direction in [Vector2i(-1,-1) , Vector2i(1,-1), Vector2i(1,1), Vector2i(-1,1), ]:
		_draw_corner(cell + direction, direction)


func __draw_req(cell: Vector2i) -> void:
	if !_cell_in_use( cell ):
		return
	cell *= Vector2i(_req_size)
	for pair in [
			[Vector2i.ZERO, Vector2i.RIGHT],
			[Vector2i.ZERO, Vector2i.DOWN],
			[Vector2i.RIGHT, Vector2i.DOWN + Vector2i.RIGHT],
			[Vector2i.DOWN, Vector2i.DOWN + Vector2i.RIGHT]
			]:
		draw_dashed_line(pair[0] * _req_size + cell, pair[1] *  _req_size + cell, Utilties.COLOR_PATH_CENTER_CELL, 5)


func _draw_corner(cell: Vector2i, direction: Vector2i) -> void: 
	if !_cell_in_use(cell):
		return
	#draw_circle(cell * _req_size, 8, Color.ORANGE, false, 2 ) #debug
	
	@warning_ignore("integer_division")
	var center := ( cell * _req_size ) + (_req_size/2)
	
	#draw_circle(center, 8, Color.BLUE, false, 2 ) #debug
	
	@warning_ignore("integer_division")
	var point_out := center + (direction * _req_size/2 )
	draw_polyline(
		[Vector2i(point_out.x, center.y), point_out, Vector2i(center.x, point_out.y)], 
		Utilties.COLOR_PATH_OUTER_CELL, 
		2
	)
	
	#draw_line( point_out, Vector2i(point_out.x, center.y) , Color.WHITE, 2 )
	#draw_line( point_out, Vector2i(center.x, point_out.y),  Color.WHITE, 2 )
	
	#draw_line( point_a, point_b,   Color.WHITE, 2 )
	#__draw_req(cell)
	


func _cell_in_use(cell: Vector2i) -> bool:
	var point := _floor_layers.get_used_rect()
	if cell.x < point.position.x:
		return false
	elif cell.x > point.end.x-1:
		return false
	elif cell.y < point.position.y:
		return false
	elif cell.y > point.end.y-1:
		return false
	return true
	
