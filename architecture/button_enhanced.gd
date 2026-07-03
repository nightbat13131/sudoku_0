@abstract class_name ButtonEnhanced extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

@abstract func _on_pressed() -> void
