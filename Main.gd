extends Control

@onready var grid_container: GridContainer = $VBoxContainer/CenterContainer/GridBg/MarginContainer/GridContainer
@onready var status_label: Label = $VBoxContainer/Status
@onready var new_game_btn: Button = $VBoxContainer/HBoxContainer/NewGameBtn
@onready var check_btn: Button = $VBoxContainer/HBoxContainer/CheckBtn
@onready var num_pad_popup: PopupPanel = $NumberPadPopup
@onready var num_pad_grid: GridContainer = $NumberPadPopup/MarginContainer/VBoxContainer/GridContainer
@onready var num_pad_clear: Button = $NumberPadPopup/MarginContainer/VBoxContainer/ClearBtn

var cells: Array = []
var active_cell: Button = null
var active_row: int = -1
var active_col: int = -1

func _ready() -> void:
	new_game_btn.pressed.connect(_on_new_game_pressed)
	check_btn.pressed.connect(_on_check_pressed)
	_setup_num_pad()
	_create_grid()
	
	# 设置底部按钮的样式
	var action_btn_normal: StyleBoxFlat = StyleBoxFlat.new()
	action_btn_normal.bg_color = Color(0.3, 0.5, 0.7)
	action_btn_normal.corner_radius_top_left = 6
	action_btn_normal.corner_radius_top_right = 6
	action_btn_normal.corner_radius_bottom_left = 6
	action_btn_normal.corner_radius_bottom_right = 6
	action_btn_normal.content_margin_left = 20
	action_btn_normal.content_margin_right = 20
	action_btn_normal.content_margin_top = 10
	action_btn_normal.content_margin_bottom = 10
	
	var action_btn_hover: StyleBoxFlat = action_btn_normal.duplicate() as StyleBoxFlat
	action_btn_hover.bg_color = Color(0.4, 0.6, 0.8)
	
	var action_btn_pressed: StyleBoxFlat = action_btn_normal.duplicate() as StyleBoxFlat
	action_btn_pressed.bg_color = Color(0.2, 0.4, 0.6)
	
	for btn in [new_game_btn, check_btn]:
		var b: Button = btn as Button
		b.add_theme_stylebox_override("normal", action_btn_normal)
		b.add_theme_stylebox_override("hover", action_btn_hover)
		b.add_theme_stylebox_override("pressed", action_btn_pressed)
		b.add_theme_stylebox_override("focus", action_btn_normal)
	
	_start_new_game()

func _setup_num_pad() -> void:
	# 设置数字键盘弹出框的背景样式
	var popup_style: StyleBoxFlat = StyleBoxFlat.new()
	popup_style.bg_color = Color(0.9, 0.95, 1.0) # 浅蓝色背景
	popup_style.border_width_left = 2
	popup_style.border_width_right = 2
	popup_style.border_width_top = 2
	popup_style.border_width_bottom = 2
	popup_style.border_color = Color(0.3, 0.5, 0.7)
	popup_style.corner_radius_top_left = 8
	popup_style.corner_radius_top_right = 8
	popup_style.corner_radius_bottom_left = 8
	popup_style.corner_radius_bottom_right = 8
	num_pad_popup.add_theme_stylebox_override("panel", popup_style)
	
	# 创建统一的按钮样式
	var btn_normal: StyleBoxFlat = StyleBoxFlat.new()
	btn_normal.bg_color = Color(1.0, 1.0, 1.0)
	btn_normal.border_width_left = 1
	btn_normal.border_width_right = 1
	btn_normal.border_width_top = 1
	btn_normal.border_width_bottom = 1
	btn_normal.border_color = Color(0.7, 0.8, 0.9)
	btn_normal.corner_radius_top_left = 4
	btn_normal.corner_radius_top_right = 4
	btn_normal.corner_radius_bottom_left = 4
	btn_normal.corner_radius_bottom_right = 4
	
	var btn_hover: StyleBoxFlat = btn_normal.duplicate() as StyleBoxFlat
	btn_hover.bg_color = Color(0.85, 0.93, 1.0)
	
	var btn_pressed: StyleBoxFlat = btn_normal.duplicate() as StyleBoxFlat
	btn_pressed.bg_color = Color(0.7, 0.85, 1.0)
	
	for i in range(1, 10):
		var btn: Button = Button.new()
		btn.text = str(i)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 24)
		btn.add_theme_color_override("font_color", Color(0.2, 0.4, 0.6))
		btn.add_theme_color_override("font_hover_color", Color(0.1, 0.3, 0.5))
		
		btn.add_theme_stylebox_override("normal", btn_normal)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.add_theme_stylebox_override("pressed", btn_pressed)
		btn.add_theme_stylebox_override("focus", btn_normal)
		
		btn.pressed.connect(_on_num_pad_selected.bind(str(i)))
		num_pad_grid.add_child(btn)
		
	# 清除按钮特殊样式
	var clear_normal: StyleBoxFlat = btn_normal.duplicate() as StyleBoxFlat
	clear_normal.bg_color = Color(1.0, 0.9, 0.9)
	clear_normal.border_color = Color(0.9, 0.7, 0.7)
	var clear_hover: StyleBoxFlat = clear_normal.duplicate() as StyleBoxFlat
	clear_hover.bg_color = Color(1.0, 0.8, 0.8)
	var clear_pressed: StyleBoxFlat = clear_normal.duplicate() as StyleBoxFlat
	clear_pressed.bg_color = Color(1.0, 0.7, 0.7)
	
	num_pad_clear.add_theme_color_override("font_color", Color(0.8, 0.3, 0.3))
	num_pad_clear.add_theme_stylebox_override("normal", clear_normal)
	num_pad_clear.add_theme_stylebox_override("hover", clear_hover)
	num_pad_clear.add_theme_stylebox_override("pressed", clear_pressed)
	num_pad_clear.add_theme_stylebox_override("focus", clear_normal)
	
	num_pad_clear.pressed.connect(_on_num_pad_selected.bind(""))

func _create_grid() -> void:
	# 生成 9x9 网格
	for row in range(9):
		var row_array: Array = []
		for col in range(9):
			var cell: Button = Button.new()
			cell.custom_minimum_size = Vector2(0, 0)
			cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cell.size_flags_vertical = Control.SIZE_EXPAND_FILL
			cell.add_theme_font_size_override("font_size", 28)
			
			# 设置 3x3 宫格的底色区分和边框区分
			var bg_style: StyleBoxFlat = StyleBoxFlat.new()
			# 统一所有需要填写数字的格子背景色为纯白/极浅蓝
			bg_style.bg_color = Color(0.96, 0.98, 1.0)
			
			# 为 3x3 宫格添加粗边框
			bg_style.border_color = Color(0.25, 0.35, 0.45)
			bg_style.border_width_top = 2 if row % 3 == 0 else 0
			bg_style.border_width_bottom = 2 if row % 3 == 2 else 0
			bg_style.border_width_left = 2 if col % 3 == 0 else 0
			bg_style.border_width_right = 2 if col % 3 == 2 else 0
			
			cell.add_theme_stylebox_override("normal", bg_style)
			cell.add_theme_stylebox_override("hover", bg_style)
			cell.add_theme_stylebox_override("pressed", bg_style)
			cell.add_theme_stylebox_override("focus", bg_style)
			
			var disabled_style: StyleBoxFlat = bg_style.duplicate() as StyleBoxFlat
			# 统一所有预设数字的暗背景颜色为柔和的浅蓝灰色
			disabled_style.bg_color = Color(0.85, 0.9, 0.95)
			cell.add_theme_stylebox_override("disabled", disabled_style)
			
			cell.pressed.connect(_on_cell_pressed.bind(cell, row, col))
			
			grid_container.add_child(cell)
			row_array.append(cell)
		cells.append(row_array)

func _start_new_game() -> void:
	status_label.text = "祝你好运！"
	status_label.add_theme_color_override("font_color", Color(0.2, 0.4, 0.6))
	
	# 生成谜题 (挖空 40 个，属于中等难度)
	var puzzle: Array = SudokuLogic.generate_puzzle(40)
	
	for row in range(9):
		for col in range(9):
			var cell: Button = cells[row][col] as Button
			var val: int = puzzle[row][col]
			
			if val != SudokuLogic.EMPTY:
				cell.text = str(val)
				cell.disabled = true
				cell.add_theme_color_override("font_disabled_color", Color(0.15, 0.25, 0.35)) # 题目数字为深蓝灰色
			else:
				cell.text = ""
				cell.disabled = false
				cell.add_theme_color_override("font_color", Color(0.2, 0.6, 0.86)) # 玩家填写的数字为亮蓝色

func _on_cell_pressed(cell: Button, row: int, col: int) -> void:
	active_cell = cell
	active_row = row
	active_col = col
	
	# 在点击的格子附近显示数字键盘
	var cell_pos: Vector2 = cell.get_global_rect().position
	var cell_size: Vector2 = cell.get_global_rect().size
	
	num_pad_popup.position = Vector2i(int(cell_pos.x + cell_size.x / 2 - 100), int(cell_pos.y + cell_size.y))
	num_pad_popup.popup()

func _on_num_pad_selected(val: String) -> void:
	num_pad_popup.hide()
	
	if active_cell == null:
		return
		
	active_cell.text = val
	
	if val != "":
		# 获取当前玩家盘面
		var player_board: Array = _get_current_board()
		var num: int = val.to_int()
		
		# 临时将当前格子清空以便使用 _is_valid 检查（避免与自己比较）
		player_board[active_row][active_col] = SudokuLogic.EMPTY
		
		if SudokuLogic._is_valid(player_board, active_row, active_col, num):
			active_cell.add_theme_color_override("font_color", Color(0.2, 0.6, 0.86)) # 合法，显示为亮蓝色
		else:
			active_cell.add_theme_color_override("font_color", Color(0.85, 0.25, 0.35)) # 不合法，显示为柔和红色
	else:
		# 清空内容时重置颜色为默认亮蓝色
		active_cell.add_theme_color_override("font_color", Color(0.2, 0.6, 0.86))
		
	# 清除状态
	active_cell = null
	active_row = -1
	active_col = -1

func _get_current_board() -> Array:
	var player_board: Array = []
	for r in range(9):
		var row_vals: Array = []
		for c in range(9):
			var text: String = (cells[r][c] as Button).text
			if text == "":
				row_vals.append(SudokuLogic.EMPTY)
			else:
				row_vals.append(text.to_int())
		player_board.append(row_vals)
	return player_board

func _on_new_game_pressed() -> void:
	_start_new_game()

func _on_check_pressed() -> void:
	var player_board: Array = _get_current_board()
		
	if SudokuLogic.is_solved(player_board):
		status_label.text = "恭喜！解答完全正确！"
		status_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	else:
		status_label.text = "存在错误或未填完，请继续努力！"
		status_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))