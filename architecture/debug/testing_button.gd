extends ButtonEnhanced

func _on_pressed() -> void:
	prints("press", _left, _right, _pressed_button_mask, 1<<_pressed_button_mask)
	pass
