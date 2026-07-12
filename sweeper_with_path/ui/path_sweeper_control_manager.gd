class_name PathSweeperControlManager extends Control

@export var _active_primary : PathSweeperPressTypeControlSelector
@export var _active_secondary : PathSweeperPressTypeControlSelector
@export var _active_tertiary : PathSweeperPressTypeControlSelector

func _ready() -> void:
	for each_child in get_children():
		if each_child is PathSweeperPressTypeControlSelector:
			each_child.selected.connect(_on_selected)
	prints(1, 1<<1, 2, 1<<2, 3, 1<<3)
	_refresh_icons()

func _on_selected(control: PathSweeperPressTypeControlSelector, mouse_bits: int) -> void:
	if mouse_bits & 1<<MOUSE_BUTTON_LEFT:
		_active_primary = control
	if mouse_bits & 1<<MOUSE_BUTTON_RIGHT: 
		_active_secondary = control
	if mouse_bits & 1<<MOUSE_BUTTON_MIDDLE:
		_active_tertiary = control
	_refresh_icons()
	return

func get_press_type(mouse_mask: int) -> Utilties.PathSweeper_Alts:
	match mouse_mask:
		MOUSE_BUTTON_MASK_LEFT:
			if _active_primary:
				return _active_primary.get_press_type()
		MOUSE_BUTTON_RIGHT:
			if _active_secondary:
				return _active_secondary.get_press_type()
		MOUSE_BUTTON_MIDDLE:
			if _active_tertiary:
				return _active_tertiary.get_press_type()
	return Utilties.PathSweeper_Alts.NA

func _refresh_icons() -> void:
	for each_child in get_children():
		if each_child is PathSweeperPressTypeControlSelector:
			if each_child == _active_primary:
				each_child.apply_mouse_mask(1<<MOUSE_BUTTON_LEFT)
			else: 
				each_child.remove_mouse_mask(1<<MOUSE_BUTTON_LEFT)
				
			if each_child == _active_secondary:
				each_child.apply_mouse_mask(1<<MOUSE_BUTTON_RIGHT)
			else: 
				each_child.remove_mouse_mask(1<<MOUSE_BUTTON_RIGHT)
				
			if each_child == _active_tertiary:
				each_child.apply_mouse_mask(1<<MOUSE_BUTTON_MIDDLE)
			else: 
				each_child.remove_mouse_mask(1<<MOUSE_BUTTON_MIDDLE)
