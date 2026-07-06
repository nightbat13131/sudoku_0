class_name PathSweeperCell extends PanelContainer

@onready var back_texture: TextureRect = %BackTexture
@onready var button: Button = %Button

var _info: PathSweeperCellInfo

func _ready() -> void:
	button.pressed.connect(_on_pressed)

func apply_cell(cell: PathSweeperCellInfo) -> void:
	_info = cell
	#_info.changed.connect(_on_cell_change)
	_info.updated.connect(_on_cell_change)
	_on_cell_change(_info)

func _on_cell_change(cell: PathSweeperCellInfo) -> void:
	button.set_text(cell.get_button_text())
	button.set_disabled(cell.is_button_disabled())

func get_cell_position() -> Vector2i:
	if _info:
		return _info.get_position()
	return Vector2i(-1,-1)

func _on_pressed() -> void: PathSweeperManager.on_press(get_cell_position())
