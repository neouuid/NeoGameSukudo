class_name SudokuLogic

const SIZE: int = 9
const EMPTY: int = 0

# 生成一个完整的合法数独终盘
static func generate_board() -> Array:
	var board: Array = []
	for i in range(SIZE):
		board.append([0, 0, 0, 0, 0, 0, 0, 0, 0])
	
	_fill_board(board)
	return board

# 挖空以生成谜题 (难度取决于 holes 的数量，通常 30-50 比较合适)
static func generate_puzzle(holes: int = 40) -> Array:
	var board: Array = generate_board()
	var puzzle: Array = board.duplicate(true)
	
	var count: int = holes
	while count > 0:
		var row: int = randi() % SIZE
		var col: int = randi() % SIZE
		if puzzle[row][col] != EMPTY:
			puzzle[row][col] = EMPTY
			count -= 1
			
	return puzzle

# 回溯法填充棋盘
static func _fill_board(board: Array) -> bool:
	for row in range(SIZE):
		for col in range(SIZE):
			if board[row][col] == EMPTY:
				# 尝试填入 1-9
				var numbers: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
				numbers.shuffle() # 随机打乱以生成不同的棋盘
				
				for num in numbers:
					if _is_valid(board, row, col, num as int):
						board[row][col] = num
						if _fill_board(board):
							return true
						board[row][col] = EMPTY
				return false
	return true

# 检查在 (row, col) 填入 num 是否合法
static func _is_valid(board: Array, row: int, col: int, num: int) -> bool:
	# 检查行和列
	for i in range(SIZE):
		if board[row][i] == num or board[i][col] == num:
			return false
			
	# 检查 3x3 宫格
	var start_row: int = row - (row % 3)
	var start_col: int = col - (col % 3)
	for i in range(3):
		for j in range(3):
			if board[start_row + i][start_col + j] == num:
				return false
				
	return true

# 检查玩家的当前解答是否正确（无冲突且已填满）
static func is_solved(board: Array) -> bool:
	for row in range(SIZE):
		for col in range(SIZE):
			if board[row][col] == EMPTY:
				return false
			var temp: int = board[row][col]
			board[row][col] = EMPTY
			var valid: bool = _is_valid(board, row, col, temp)
			board[row][col] = temp
			if not valid:
				return false
	return true
