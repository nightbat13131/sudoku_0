class_name SudokuCellTheme extends Resource

@export var cell_background : Texture2D

@export var cell_blank : Texture2D

@export var num_textures : Array[Texture2D] = [null, null, null, null]

func get_index_texture(index: int ) -> Texture: 
	if index == Utilties.Sudoku_Cell_Alts.EMPTY:
		return cell_blank
	elif index < 1:
		return cell_blank
	index -= 1
	assert(index < num_textures.size() )
	return num_textures.get(index)
