extends Node

@export var general_mapping : GUIDEMappingContext

func  _ready() -> void:
	if general_mapping:
		GUIDE.enable_mapping_context(general_mapping)
