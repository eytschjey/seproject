extends Node3D

## Level 04 Controller: 3D greybox presentation of the Knight's Chasm.
## Decoupled from the rules: all decisions are made by KnightsTourLogic.

const Logic = preload("res://scripts/logic/KnightsTourLogic.gd")

@onready var board_origin: Marker3D = $Board/BoardOrigin
@onready var tiles_root: Node3D = $Board/Tiles
@onready var knight: Node3D = $Board/Knight
@onready var cell_grid: GridContainer = %CellGrid
@onready var btn_undo: Button = %BtnUndo
@onready var btn_reset: Button = %BtnReset
@onready var btn_solve: Button = %BtnSolve
@onready var status_label: Label = %StatusLabel
@onready var count_label: Label = %VisitCountLabel
@onready var banner: PanelContainer = %Banner
@onready var banner_label: Label = %BannerLabel

const CELL_SIZE: float = 1.0
const SINK_DEPTH: float = 3.0
const NEXT_LEVEL_SCENE: String = "res://scenes/levels/Level05_DreadburyManor.tscn"
const NEXT_LEVEL_DELAY: float = 4.0
@export var auto_solve_delay: float = 0.22

const COLOR_IDLE := Color(0.45, 0.4, 0.38)
const COLOR_CURRENT := Color(1.0, 0.82, 0.25)
const COLOR_VALID := Color(0.2, 0.55, 1.0)
const COLOR_SOLVED := Color(0.4, 1.0, 0.5)

var logic: RefCounted
var tile_nodes: Dictionary = {}      # Vector2i -> CSGBox3D
var tile_materials: Dictionary = {}  # Vector2i -> StandardMaterial3D
var tile_sunk: Dictionary = {}       # Vector2i -> bool
var cell_buttons: Dictionary = {}    # Vector2i -> Button
var knight_tween: Tween
var is_auto_solving: bool = false

var style_cell_idle: StyleBoxFlat
var style_cell_visited: StyleBoxFlat
var style_cell_current: StyleBoxFlat
var style_cell_valid: StyleBoxFlat
var style_cell_valid_hover: StyleBoxFlat

func _ready() -> void:
	logic = Logic.new()
	logic.state_changed.connect(_on_state_changed)
	logic.move_executed.connect(func(d: String): status_label.text = d)
	logic.move_rejected.connect(func(r: String): status_label.text = r)
	logic.puzzle_failed.connect(_on_puzzle_failed)
	logic.puzzle_solved.connect(_on_puzzle_solved)
	_init_gui_styles()
	_build_tiles()
	_build_buttons()
	_style_action_buttons()
	btn_undo.pressed.connect(_on_undo_pressed)
	btn_reset.pressed.connect(_on_reset_pressed)
	btn_solve.pressed.connect(_on_solve_pressed)
	BackToMenuButton.attach($UI/RootControl)
	_build_knight()
	_on_state_changed(logic.current, logic.path.duplicate())

func _make_box_style(bg: Color, border: Color, border_w: int = 2, radius: int = 4) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	return sb

func _init_gui_styles() -> void:
	style_cell_idle = _make_box_style(Color(0.10, 0.14, 0.22, 0.95), Color(0.28, 0.38, 0.52, 0.9), 1, 4)
	style_cell_visited = _make_box_style(Color(0.10, 0.25, 0.36, 0.96), Color(0.32, 0.68, 0.88, 0.95), 1, 4)
	style_cell_current = _make_box_style(Color(0.88, 0.65, 0.08, 1.0), Color(1.0, 0.96, 0.65, 1.0), 2, 4)
	style_cell_valid = _make_box_style(Color(0.06, 0.48, 0.88, 1.0), Color(0.55, 0.92, 1.0, 1.0), 2, 4)
	style_cell_valid_hover = _make_box_style(Color(0.16, 0.62, 1.0, 1.0), Color(0.85, 0.98, 1.0, 1.0), 2, 4)

func _style_action_buttons() -> void:
	var normal := _make_box_style(Color(0.12, 0.22, 0.36, 0.96), Color(0.4, 0.82, 1.0, 0.95), 2, 6)
	var hover := _make_box_style(Color(0.18, 0.34, 0.54, 1.0), Color(0.65, 0.94, 1.0, 1.0), 2, 6)
	var pressed := _make_box_style(Color(0.08, 0.45, 0.78, 1.0), Color(0.85, 0.98, 1.0, 1.0), 2, 6)
	var disabled := _make_box_style(Color(0.09, 0.12, 0.18, 0.88), Color(0.24, 0.3, 0.4, 0.7), 1, 6)
	for btn in [btn_undo, btn_reset, btn_solve]:
		if btn == null:
			continue
		btn.add_theme_stylebox_override("normal", normal)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", pressed)
		btn.add_theme_stylebox_override("disabled", disabled)
		btn.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
		btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.95, 0.7))
		btn.add_theme_color_override("font_disabled_color", Color(0.55, 0.64, 0.75))
		btn.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
		btn.add_theme_constant_override("outline_size", 2)

## World position of the centre of a board cell (relative to the BoardOrigin marker).
func cell_position(cell: Vector2i) -> Vector3:
	return board_origin.global_position + Vector3(cell.x * CELL_SIZE, 0.0, cell.y * CELL_SIZE)

func _build_tiles() -> void:
	for row in Logic.BOARD_SIZE:
		for col in Logic.BOARD_SIZE:
			var cell := Vector2i(col, row)
			var tile := CSGBox3D.new()
			tile.size = Vector3(CELL_SIZE * 0.92, 0.3, CELL_SIZE * 0.92)
			var mat := StandardMaterial3D.new()
			mat.emission_enabled = true
			mat.roughness = 0.8
			tile.material = mat
			tiles_root.add_child(tile)
			tile.global_position = cell_position(cell) + Vector3(0, -0.15, 0)
			tile_nodes[cell] = tile
			tile_materials[cell] = mat
			tile_sunk[cell] = false

func _build_buttons() -> void:
	for row in Logic.BOARD_SIZE:
		for col in Logic.BOARD_SIZE:
			var cell := Vector2i(col, row)
			var b := Button.new()
			b.custom_minimum_size = Vector2(40, 40)
			b.tooltip_text = Logic.cell_name(cell)
			b.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
			b.add_theme_constant_override("outline_size", 2)
			b.add_theme_font_size_override("font_size", 14)
			b.pressed.connect(_on_cell_pressed.bind(cell))
			cell_grid.add_child(b)
			cell_buttons[cell] = b

func _build_knight() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.85, 0.95)
	mat.metallic = 0.7
	mat.roughness = 0.3
	var body := CSGCylinder3D.new()
	body.radius = 0.25
	body.height = 0.6
	body.position = Vector3(0, 0.3, 0)
	body.material = mat
	knight.add_child(body)
	var head := CSGBox3D.new()
	head.size = Vector3(0.2, 0.35, 0.45)
	head.position = Vector3(0, 0.75, 0.1)
	head.material = mat
	knight.add_child(head)

func _on_cell_pressed(cell: Vector2i) -> void:
	if is_auto_solving:
		stop_auto_solve()
	logic.move_to(cell)

func _on_undo_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
	logic.undo()
	banner.visible = false

func _on_reset_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
	logic.reset()
	banner.visible = false
	status_label.text = "The tiles rise from the lava. Start again from A1."

func _on_solve_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
		return
	if logic.is_solved:
		return
	start_auto_solve()

func start_auto_solve() -> void:
	is_auto_solving = true
	btn_solve.text = "Stop Solver"
	banner.visible = false
	status_label.text = "Solving Knight's Tour automatically..."
	
	# If failed or current path cannot be completed, restart from A1.
	var full_tour: Array[Vector2i] = []
	if not logic.is_failed:
		full_tour = Logic.find_tour_from_path(logic.path)
	if full_tour.is_empty():
		logic.reset()
		full_tour = Logic.find_tour(Logic.START)
	
	var start_idx: int = logic.path.size()
	for i in range(start_idx, full_tour.size()):
		if not is_auto_solving or logic.is_solved:
			break
		logic.move_to(full_tour[i])
		await get_tree().create_timer(auto_solve_delay).timeout
	
	stop_auto_solve()

func stop_auto_solve() -> void:
	is_auto_solving = false
	if is_instance_valid(btn_solve):
		btn_solve.text = "Auto-Solve (Debug)"
		btn_solve.disabled = logic != null and logic.is_solved

func _on_state_changed(current: Vector2i, path: Array) -> void:
	# Visited tiles (except the one under the knight) sink; others re-emerge.
	for cell in tile_nodes:
		var should_sink: bool = cell in path and cell != current
		_set_tile_sunk(cell, should_sink)
	var valid: Array = logic.valid_moves() if logic != null else []
	for cell in tile_materials:
		var mat: StandardMaterial3D = tile_materials[cell]
		var c: Color = COLOR_IDLE
		if cell == current:
			c = COLOR_CURRENT
		elif cell in valid:
			c = COLOR_VALID
		elif cell in path:
			c = Color(0.25, 0.1, 0.08)
		mat.albedo_color = c
		mat.emission = c if (cell == current or cell in valid) else Color.BLACK
	_move_knight(current)
	for cell in cell_buttons:
		var b: Button = cell_buttons[cell]
		var step: int = path.find(cell)
		b.text = str(step + 1) if step >= 0 else ""
		b.disabled = logic != null and (logic.is_solved or logic.is_failed or cell not in valid)
		b.modulate = Color(1, 1, 1)
		if cell == current:
			b.add_theme_stylebox_override("disabled", style_cell_current)
			b.add_theme_stylebox_override("normal", style_cell_current)
			b.add_theme_color_override("font_disabled_color", Color(1.0, 0.98, 0.9))
			b.add_theme_color_override("font_color", Color(1.0, 0.98, 0.9))
		elif cell in valid:
			b.add_theme_stylebox_override("normal", style_cell_valid)
			b.add_theme_stylebox_override("hover", style_cell_valid_hover)
			b.add_theme_stylebox_override("pressed", style_cell_valid_hover)
			b.add_theme_stylebox_override("disabled", style_cell_valid)
			b.add_theme_color_override("font_color", Color(0.95, 0.99, 1.0))
			b.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
			b.add_theme_color_override("font_disabled_color", Color(0.95, 0.99, 1.0))
		elif step >= 0:
			b.add_theme_stylebox_override("disabled", style_cell_visited)
			b.add_theme_stylebox_override("normal", style_cell_visited)
			b.add_theme_color_override("font_disabled_color", Color(0.68, 0.92, 1.0))
			b.add_theme_color_override("font_color", Color(0.68, 0.92, 1.0))
		else:
			b.add_theme_stylebox_override("disabled", style_cell_idle)
			b.add_theme_stylebox_override("normal", style_cell_idle)
			b.add_theme_color_override("font_disabled_color", Color(0.55, 0.65, 0.78))
			b.add_theme_color_override("font_color", Color(0.55, 0.65, 0.78))
	count_label.text = "Visits: %d / %d" % [path.size(), Logic.BOARD_SIZE * Logic.BOARD_SIZE]
	btn_undo.disabled = path.size() <= 1 or (logic != null and logic.is_solved)
	if is_instance_valid(btn_solve):
		btn_solve.disabled = logic != null and logic.is_solved

func _set_tile_sunk(cell: Vector2i, sunk: bool) -> void:
	if tile_sunk[cell] == sunk:
		return
	tile_sunk[cell] = sunk
	var tile: CSGBox3D = tile_nodes[cell]
	var target_y: float = (-0.15 - SINK_DEPTH) if sunk else -0.15
	create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).tween_property(
		tile, "global_position:y", board_origin.global_position.y + target_y, 0.5)

func _move_knight(cell: Vector2i) -> void:
	var target := cell_position(cell)
	if knight.global_position == Vector3.ZERO:
		knight.global_position = target
		return
	if knight_tween != null and knight_tween.is_valid():
		knight_tween.kill()
	var mid := (knight.global_position + target) / 2.0 + Vector3(0, 1.0, 0)
	knight_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	knight_tween.tween_property(knight, "global_position", mid, 0.10)
	knight_tween.tween_property(knight, "global_position", target, 0.10)

func _on_puzzle_failed(reason: String) -> void:
	banner.visible = true
	banner_label.text = "%s You failed!\nUndo a jump or press Reset." % reason
	banner_label.modulate = Color(1.0, 0.35, 0.35)

func _on_puzzle_solved() -> void:
	if is_auto_solving:
		stop_auto_solve()
	if is_instance_valid(btn_solve):
		btn_solve.disabled = true
	banner.visible = true
	banner_label.text = "PUZZLE SOLVED!\nAll 64 runes lock into a radiant bridge\nto the gates of Dreadbury Manor!"
	banner_label.modulate = Color(0.35, 1.0, 0.45)
	status_label.text = "Victory! Every tile visited exactly once."
	for cell in tile_nodes:
		_set_tile_sunk(cell, false)
		tile_materials[cell].albedo_color = COLOR_SOLVED
		tile_materials[cell].emission = COLOR_SOLVED
	_proceed_to_next_level()

## Auto-advance to Level 5 a few seconds after victory so the player can see the result.
func _proceed_to_next_level() -> void:
	banner_label.text += "\nProceeding to Dreadbury Manor..."
	await get_tree().create_timer(NEXT_LEVEL_DELAY).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file(NEXT_LEVEL_SCENE)
