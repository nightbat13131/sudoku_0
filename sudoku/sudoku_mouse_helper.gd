class_name SudokuMouseHelper extends Control

@export var number_selector: SpinBox
@onready var mouse_lable: Label = %MouseLable

func _ready() -> void:
	if number_selector:
		number_selector.value_changed.connect(_on_number_selected)

func _process(_delta: float) -> void: global_position = get_global_mouse_position()

func _on_number_selected(value: int) -> void: mouse_lable.set_text("\n"+str(value))
