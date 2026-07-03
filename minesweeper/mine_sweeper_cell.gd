class_name MineSweeperCell extends PanelContainer

@onready var back_texture: TextureRect = %BackTexture
@onready var button: Button = %Button
var _resource : MinesweeperCellInfo

# var _pos : Vector2i
#var _text : String : set = _set_text

func _ready() -> void:
	button.pressed.connect(_on_button_press)
	button.mouse_entered.connect(_on_mouse_in.bind(true))
	button.mouse_exited.connect(_on_mouse_in.bind(false))
	#_set_info(_resource)

func _on_button_press() -> void: MineSweeperManager.cell_pressed(_resource.get_position())

#func apply_cell(pos: Vector2i, value: int) -> void:
func apply_cell(info: MinesweeperCellInfo) -> void:
	_set_info(info)

func _on_mouse_in(is_entering: bool) -> void: MineSweeperManager.mouse_in_pos(_resource.get_position(), is_entering)

func remote_hold(_is_pressed: bool) -> void:
	## When to igore the remote press
	if _resource:
		if _resource.is_pressed():
	#if _value != Utilties.MineSweeper_Cells_Alts.NO_GUESS:
			return
	button.set_toggle_mode(_is_pressed)
	button.set_pressed(_is_pressed)

func _set_info(info: MinesweeperCellInfo) -> void:
	if _resource:
		_resource.changed.disconnect(_on_info_change)
	_resource = info
	if _resource:
		_resource.changed.connect(_on_info_change)
	_on_info_change()

func _on_info_change() -> void:
	var _text := "^"
	if _resource:
		_text = _resource.get_show_text()
		button.set_disabled(_resource.get_disable_button())
		#button_enhanced.set_disabled( false) #_resource.is_game_over())
	else:
		_text = "?"
		button.set_disabled(false)
	button.set_text(_text)
	#button_enhanced.set_disabled(_resource.is_pressed()) # ![Utilties.MineSweeper_Cells_Alts.NO_GUESS, Utilties.MineSweeper_Cells_Alts.FLAG].has(thing))
