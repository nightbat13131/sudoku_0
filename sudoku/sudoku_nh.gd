# davidlunadeleon https://github.com/davidlunadeleon
# GNU General Public License v3.0
# https://github.com/davidlunadeleon/Sudoku/blob/main/src/scripts/Sudoku.gd 


class_name Sudoku_nha extends Node
## movified version of script taken from above



const INITIAL_DOMAIN: Array[int] = [1,2,3,4,5,6,7,8,9]
const NROWS: int = 9
const NCOLS: int = 9
const SQR_SIZE: int = 3
var domains: Dictionary[Vector2i, Array] # Array[int]
var constraints: Dictionary[Vector2i, Array] ## Array[String]
var sorted_cells: Array
var rng : RandomNumberGenerator

func _init() -> void:
	randomize()
	rng = RandomNumberGenerator.new()
	sorted_cells = []
	domains = {}
	constraints = {}
	__init()
	__init_constraints()

func __init() -> void:
	sorted_cells.clear()
	for x: int in range(NROWS):
		for y: int in range(NCOLS):
			domains[Vector2i(x, y)] = INITIAL_DOMAIN.duplicate()

func __init_constraints():
	for key in domains.keys():
		constraints[key] = []
		var row = key.y
		var col = key.x
		for x: int in range(NCOLS):
			if x != col:
				constraints.get(key).push_back(Vector2i(x, row))
		for y: int in range(NROWS):
			if y != row:
				constraints.get(key).push_back(Vector2i(col, y))
		var sqr_row: int = row / SQR_SIZE
		var sqr_col: int = col / SQR_SIZE
		for x: int in range(sqr_row * SQR_SIZE, ((sqr_row + 1) * SQR_SIZE)):
			if x != col:
				for y: int in range(sqr_col * SQR_SIZE, ((sqr_col + 1) * SQR_SIZE)):
					if y != row:
						constraints.get(key).push_back(Vector2i(x,y))# str(x) + str(y))

func print_1() -> void:
	var holder : Array[int]
	var temp := ""
	var cha := "_"
	for row_i : int in range(NROWS):
		temp = ""
		for col_i : int in range(NCOLS):
			cha = "_"
			holder = domains.get(Vector2i(row_i, col_i))
			if holder:
				if holder.size() == 1:
					cha = str(holder[0])
			temp += cha
		print(temp)

func set_cell(pos: Vector2i, val: int) -> bool: 
	domains[pos] = [val]
	if is_var_consistent(pos):
		return true
	clear_cell(pos)
	return false

func clear_cell(pos: Vector2i): domains[pos] = INITIAL_DOMAIN.duplicate()

func get_grid() -> Array[Array]:
	var grid : Array[Array] = []
	for x: int in range(NCOLS):
		var temp_row = []
		for y: int in range(NROWS):
			var key = Vector2i(x,y)
			if domains.get(key).size() > 1:
				temp_row.push_back(0)
			else:
				temp_row.push_back(domains.get(key).front())
		grid.push_back(temp_row)
	return grid

func remove_inconsistencies(key1: Vector2i, key2: Vector2i) -> bool:
	var domain1 : Array = domains.get(key1)
	var domain2 : Array = domains.get(key2)
	if domain2.size() == 1:
		var i: int = domain2.front()
		if domain1.has(i):
			domain1.erase(i)
			return true
	return false

func ac3_algorithm() -> bool:
	var key_queue : Array[Array] = []
	for key: Vector2i in domains.keys():
		for neighbor: Vector2i in constraints.get(key):
			key_queue.push_back([key, neighbor])
	while !key_queue.is_empty():
		var key_arr = key_queue.pop_back()
		var key1 = key_arr[0]
		var key2 = key_arr[1]
		if remove_inconsistencies(key1, key2):
			for neighbor in constraints.get(key1):
				key_queue.push_back([neighbor, key1])
	for domain: Array in domains.values():
		if domain.is_empty():
			return false
	return true

class Sorter:
	static func sort_mrv(x, y) -> bool:
		var dom_x_size : int = x.values().front().size()
		var dom_y_size : int= y.values().front().size()
		return dom_x_size < dom_y_size

func sort_cells():
	var cells : Array = []
	for key in domains.keys():
		cells.push_back({key: domains.get(key)})
	cells.sort_custom(Sorter.sort_mrv)
	for cell in cells:
		if cell.values().front().size() > 1:
			sorted_cells.push_back(cell.keys().front())

func is_var_consistent(key: Vector2i) -> bool:
	if domains.get(key).size() > 1:
		return false
	var val: int = domains.get(key).front()
	for neighbor: Vector2i in constraints.get(key):
		var domain: Array = domains.get(neighbor)
		if domain.is_empty() || (domain.size() == 1 && domain.has(val)):
			return false
	return true

func backtrack(depth) -> bool:
	if depth >= sorted_cells.size():
		return true;
	var key = sorted_cells[depth]
	var domain = domains.get(key).duplicate()
	for val in domain:
		domains[key] = [val]
		var wasErased = []
		for neighbor in constraints.get(key):
			if domains.get(neighbor).has(val):
				domains.get(neighbor).erase(val)
				wasErased.push_back(true)
			else:
				wasErased.push_back(false)
		if is_var_consistent(key) && backtrack(depth + 1):
			return true
		var i = 0
		for neighbor in constraints.get(key):
			if wasErased[i]:
				domains.get(neighbor).push_back(val)
			i = i + 1
	domains[key] = domain
	return false

func solve() -> bool:
	var temp_domains = domains.duplicate()
	if ac3_algorithm():
		sort_cells()
		if backtrack(0):
			sorted_cells.clear()
			return true
	sorted_cells.clear()
	domains = temp_domains
	return false

func clear_domains():
	for x: int in range(NROWS):
		for y: int in range(NCOLS):
			clear_cell(Vector2(x, y))

func verify_rows(rows: Array) -> bool:
	for i: int in range(NCOLS):
		var row : int = rows[i]
		var key = Vector2i(row, i)# str(row) + str(i)
		if !is_var_consistent(key):
			return false
	return true

func gen(difficulty: Utilties.Difficulty):
	var randNum: int = (randi() % 9) + 1
	var rows : Array = range(9)
	var verified = false
	while !verified:
		clear_domains()
		rows.shuffle()
		for x : int in range(NCOLS):
			var row = rows[x]
			domains[Vector2i(row, x)] = [randNum]
		verified = verify_rows(rows)
	solve()
	var keys_to_del: Array[Vector2i] = domains.keys().duplicate()
	keys_to_del.shuffle()
	var n_to_del : int
	if difficulty == Utilties.Difficulty.EASY:
		n_to_del = rng.randi_range(15, 25)
	elif difficulty == Utilties.Difficulty.MEDIUM:
		n_to_del = rng.randi_range(30, 45)
	else:
		n_to_del = rng.randi_range(50, 60)
	keys_to_del.resize(n_to_del)
	while !keys_to_del.is_empty():
		var key = keys_to_del.pop_back()
		#var x = key[0].to_int()
		#var y = key[1].to_int()
		clear_cell(key)
