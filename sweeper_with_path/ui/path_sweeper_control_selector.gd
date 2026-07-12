class_name PathSweeperPressTypeControlSelector extends Control

signal selected(self_: PathSweeperPressTypeControlSelector, mouse_bits: int)

@export_category("Internal Button")
@export var _press_type := Utilties.PathSweeper_Alts.MOVE
@export var _icon : Texture2D

@onready var button: PressTypeButtonPathSwpeeper = %Button
@onready var texture_rect_right: TextureRect = %TextureRect_Right
@onready var texture_rect_left: TextureRect = %TextureRect_Left
@onready var texture_rect_mid: TextureRect = %TextureRect_Mid

func _ready() -> void:
	button.set_button_icon(_icon)
	button.set_press_type(_press_type)
	button.selected.connect(_on_button_selected)

func get_press_type() -> Utilties.PathSweeper_Alts: return _press_type

func apply_mouse_mask(mask_bits: int) -> void:
	if mask_bits & 1<<MOUSE_BUTTON_LEFT:
		texture_rect_left.set_modulate(Color.WHITE)
	if mask_bits & 1<<MOUSE_BUTTON_RIGHT:
		texture_rect_right.set_modulate(Color.WHITE)
	if mask_bits & 1<<MOUSE_BUTTON_MIDDLE:
		texture_rect_mid.set_modulate(Color.WHITE)

func remove_mouse_mask(mask_bits: int) -> void:
	if mask_bits & 1<<MOUSE_BUTTON_LEFT:
		texture_rect_left.set_modulate(Color.TRANSPARENT)
	if mask_bits & 1<<MOUSE_BUTTON_RIGHT:
		texture_rect_right.set_modulate(Color.TRANSPARENT)
	if mask_bits & 1<<MOUSE_BUTTON_MIDDLE:
		texture_rect_mid.set_modulate(Color.TRANSPARENT)

func _on_button_selected(_self: PressTypeButtonPathSwpeeper, mouse_bits: int) -> void: 
	selected.emit(self, mouse_bits)
