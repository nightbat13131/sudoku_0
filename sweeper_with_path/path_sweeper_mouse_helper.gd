class_name PathSweeperHelper extends Control

@export var _button_group: ButtonGroup
@onready var mouse_label: Label = %MouseLabel

@export var _pathsweeper_theme : Variant

func _ready() -> void:
	if _button_group:
		_button_group.pressed.connect(_on_button_pressed)
		_on_button_pressed(_button_group.get_pressed_button())

func _process(_delta: float) -> void: global_position = get_global_mouse_position()

func _on_button_pressed(button) -> void: 
	var text : String = ""
	if button is PressTypeButtonPathSwpeeper:
		text = str(button.get_press_type())
	mouse_label.set_text("\n"+text)
