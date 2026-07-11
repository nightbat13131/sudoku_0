@abstract class_name ButtonEnhanced extends Button

@export var _right := true
@export var _left := false

func _ready() -> void:
	if _right and _left:
		set_button_mask(MOUSE_BUTTON_MASK_LEFT  | MOUSE_BUTTON_MASK_RIGHT )
	elif _right: 
		set_button_mask( MOUSE_BUTTON_MASK_RIGHT )
		pressed.connect(_on_pressed)
	elif _left: 
		set_button_mask(MOUSE_BUTTON_MASK_LEFT )


@abstract func _on_pressed() -> void
