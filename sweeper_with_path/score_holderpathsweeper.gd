class_name ScoreHolder_PathSweeper extends HBoxContainer

const ACTIVE := Color.WHITE
const SPENT := Color(.2,.2,.2)

@onready var label_depth: Label = %LabelDepth
@onready var label_loot: Label = %LabelLoot

@onready var _lives : Array[TextureRect] = [%TextureRect_hp1, %TextureRect_hp2, %TextureRect_hp3]
@onready var _repels : Array[TextureRect] = [%TextureRect_repel1, %TextureRect_repel2, %TextureRect_repel3, %TextureRect_repel4, %TextureRect_repel5]

var _puzzle : PathSweeper

func set_puzzle_info(info: PathSweeper) -> void:
	if _puzzle: 
		_puzzle.changed.disconnect(_on_puzzle_change)
	_puzzle = info
	_puzzle.changed.connect(_on_puzzle_change)
	_on_puzzle_change()

func _on_puzzle_change() -> void:
	if _puzzle == null:
		hide()
		return
	label_depth.set_text("Depth: {}".format([_puzzle.get_depth()], "{}"))
	label_loot.set_text("Loot: {}".format([_puzzle.get_loot_count()], "{}"))
	var hp := _puzzle.get_health()
	for index_h in _lives.size():
		if hp-1 >= index_h:
			_lives[index_h].set_modulate(ACTIVE)
		else:
			_lives[index_h].set_modulate(SPENT)
	var rep := _puzzle.get_spray_count()
	for index_r in _repels.size():
		if rep-1 >= index_r :
			_repels[index_r].set_modulate(ACTIVE)
		else:
			_repels[index_r].set_modulate(SPENT)
