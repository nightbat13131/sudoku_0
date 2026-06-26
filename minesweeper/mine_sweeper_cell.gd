class_name MineSweeperCell extends PanelContainer

@onready var back_texture: TextureRect = %BackTexture
@onready var button_enhanced: ButtonEnhanced = %ButtonEnhanced

var _pos : Vector2i
var _value : int : set = _set_value

func _ready() -> void:
	button_enhanced.pressed.connect(_on_button_press)

func _on_button_press() -> void: MineSweeperManager.cell_pressed(_pos)

func apply_cell(pos: Vector2i, value: int) -> void:
	_pos = pos
	_set_value(value)

func _set_value(thing: int) -> void:
	_value = thing
	var text : String = str(thing)
	match thing:
		Utilties.MineSweeper_Cells_Alts.NO_GUESS: 
			text = "_"
		Utilties.MineSweeper_Cells_Alts.BOMB:
			text = "X"
		Utilties.MineSweeper_Cells_Alts.FLAG:
			text = "M"
		Utilties.MineSweeper_Cells_Alts.EMPTY:
			text = " "
	button_enhanced.set_text(text)
