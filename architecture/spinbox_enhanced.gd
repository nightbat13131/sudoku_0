class_name SpinBox_Enhanced extends SpinBox

@export var looping := false
@export var use_mouse_scroll := false

func _ready() -> void:
	_setup_looping()

func _setup_looping() -> void:
	set_allow_greater(looping)
	set_allow_lesser(looping)
	if looping:
		value_changed.connect(_on_value_changed_loop)

func _on_value_changed_loop(value_: float) -> void:
	if value_ > max_value:
		set_value(min_value)
	elif value_ < min_value:
		set_value(max_value)
