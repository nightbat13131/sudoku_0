extends Node2D

@export var _tile_reference : TileMapLayer

var _req_size := Vector2.ONE

func _ready() -> void:
	assert(_tile_reference)
	_req_size = _tile_reference.get_tile_set().get_tile_size() * _tile_reference.get_scale().x

func _process(_delta: float) -> void: queue_redraw()

func _get_ne() -> Vector2:
	return get_global_mouse_position() - get_global_mouse_position().posmodv(_req_size)# .snapped(_req_size)

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
