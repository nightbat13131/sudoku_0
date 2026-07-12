class_name PressTypeButtonPathSwpeeper extends ButtonEnhanced

signal selected(self_ : PressTypeButtonPathSwpeeper, mouse_mask: int )

@export var _press_type := Utilties.PathSweeper_Alts.MOVE

func _ready() -> void:
	super._ready()
	if button_group:
		set_toggle_mode(true)
	set_pressed_no_signal(get_press_type() == Utilties.PathSweeper_Alts.MOVE)

func set_press_type(press_type : Utilties.PathSweeper_Alts) -> void: _press_type = press_type

func get_press_type() -> Utilties.PathSweeper_Alts: return _press_type

func _on_pressed() -> void: 
	#print(_pressed_button_mask)
	selected.emit(self, _pressed_button_bits)
