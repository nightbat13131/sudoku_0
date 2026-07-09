class_name PressTypeButtonPathSwpeeper extends ButtonEnhanced

@export var _press_type := Utilties.PathSweeper_Alts.MOVE

func _ready() -> void:
	set_toggle_mode(true)
	
	set_pressed_no_signal(get_press_type() == Utilties.PathSweeper_Alts.MOVE)

func get_press_type() -> Utilties.PathSweeper_Alts: return _press_type

func _on_pressed() -> void: pass
