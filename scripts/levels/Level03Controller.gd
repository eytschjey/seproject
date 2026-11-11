extends Node3D

## Level 03 Controller: 3D greybox presentation of the 8-Queens courtyard.
## Decoupled from the rules: all decisions are made by QueensLogic.

const Logic = preload("res://scripts/logic/QueensLogic.gd")

@onready var board_origin: Marker3D = $Board/BoardOrigin
@onready var tiles: Node3D = $Board/Tiles
@onready var queens_root: Node3D = $Board/Queens
@onready var beams_root: Node3D = $Board/Beams
@onready var cell_grid: GridContainer = %CellGrid
@onready var btn_reset: Button = %BtnReset
@onready var btn_solve: Button = %BtnSolve
@onready var status_label: Label = %StatusLabel
@onready var count_label: Label = %QueenCountLabel
@onready var banner: PanelContainer = %Banner
@onready var banner_label: Label = %BannerLabel

const CELL_SIZE: float = 1.0
const NEXT_LEVEL_SCENE: String = "res://scenes/levels/Level04_KnightsChasm.tscn"
const NEXT_LEVEL_DELAY: float = 4.0
@export var auto_solve_delay: float = 0.35

const COLOR_SAFE := Color(1.0, 0.82, 0.25)
const COLOR_CONFLICT := Color(1.0, 0.15, 0.1)

var logic: RefCounted
var cell_buttons: Dictionary = {}   # Vector2i -> Button
var queen_nodes: Dictionary = {}    # Vector2i -> Node3D
var queen_materials: Dictionary = {} # Vector2i -> StandardMaterial3D
var is_auto_solving: bool = false

var style_cell_light: StyleBoxFlat
var style_cell_dark: StyleBoxFlat
var style_cell_hover: StyleBoxFlat
var style_cell_safe: StyleBoxFlat
var style_cell_conflict: StyleBoxFlat

func _ready() -> void:
	logic = Logic.new()
	logic.state_changed.connect(_on_state_changed)
	logic.move_executed.connect(func(d: String): status_label.text = d)
	logic.puzzle_solved.connect(_on_puzzle_solved)
	_init_gui_styles()
	_build_tiles()
	_build_buttons()
	btn_reset.pressed.connect(_on_reset_pressed)
	btn_solve.pressed.connect(_on_solve_pressed)
	BackToMenuButton.attach($UI/RootControl, Color(0.98, 0.72, 0.22))
	_on_state_changed([], [])

func _make_box_style(bg: Color, border: Color, border_w: int = 2, radius: int = 4) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	return sb

func _init_gui_styles() -> void:
	# Level 3 Color Scheme: Romanesque Warm Bronze & Solar Amber
	var panel_sb := _make_box_style(Color(0.15, 0.10, 0.05, 0.94), Color(0.98, 0.72, 0.22, 0.95), 2, 8)
	panel_sb.content_margin_left = 14.0
	panel_sb.content_margin_right = 14.0
	panel_sb.content_margin_top = 8.0
	panel_sb.content_margin_bottom = 8.0
	for p in [$UI/RootControl/HeaderPanel, $UI/RootControl/SidePanel, banner]:
		if p != null:
			p.add_theme_stylebox_override("panel", panel_sb)
	banner_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	banner_label.add_theme_constant_override("outline_size", 3)

	style_cell_light = _make_box_style(Color(0.28, 0.21, 0.13, 0.96), Color(0.62, 0.46, 0.24, 0.9), 1, 4)
	style_cell_dark = _make_box_style(Color(0.18, 0.13, 0.08, 0.96), Color(0.48, 0.36, 0.18, 0.9), 1, 4)
	style_cell_hover = _make_box_style(Color(0.44, 0.32, 0.16, 1.0), Color(1.0, 0.86, 0.42, 1.0), 2, 4)
	style_cell_safe = _make_box_style(Color(0.88, 0.62, 0.08, 1.0), Color(1.0, 0.95, 0.65, 1.0), 2, 4)
	style_cell_conflict = _make_box_style(Color(0.82, 0.14, 0.14, 1.0), Color(1.0, 0.65, 0.65, 1.0), 2, 4)

	var btn_normal := _make_box_style(Color(0.28, 0.18, 0.08, 0.96), Color(0.98, 0.74, 0.24, 0.95), 2, 6)
	var btn_hover := _make_box_style(Color(0.42, 0.28, 0.12, 1.0), Color(1.0, 0.88, 0.45, 1.0), 2, 6)
	var btn_pressed := _make_box_style(Color(0.55, 0.38, 0.14, 1.0), Color(1.0, 0.96, 0.72, 1.0), 2, 6)
	var btn_disabled := _make_box_style(Color(0.14, 0.10, 0.06, 0.85), Color(0.42, 0.32, 0.18, 0.7), 1, 6)
	for btn in [btn_reset, btn_solve]:
		if btn == null:
			continue
		btn.add_theme_stylebox_override("normal", btn_normal)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.add_theme_stylebox_override("pressed", btn_pressed)
		btn.add_theme_stylebox_override("disabled", btn_disabled)
		btn.add_theme_color_override("font_color", Color(1.0, 0.96, 0.86))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.95))
		btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.88, 0.42))
		btn.add_theme_color_override("font_disabled_color", Color(0.58, 0.50, 0.40))
		btn.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		btn.add_theme_constant_override("outline_size", 2)

## World position of the centre of a board cell (relative to the BoardOrigin marker).
func cell_position(cell: Vector2i) -> Vector3:
	return board_origin.global_position + Vector3(cell.x * CELL_SIZE, 0.0, cell.y * CELL_SIZE)

func _build_tiles() -> void:
	var light_mat := StandardMaterial3D.new()
	light_mat.albedo_color = Color(0.93, 0.92, 0.88)
	light_mat.roughness = 0.3
	var dark_mat := StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.25, 0.27, 0.32)
	dark_mat.roughness = 0.3
	for row in Logic.BOARD_SIZE:
		for col in Logic.BOARD_SIZE:
			var tile := CSGBox3D.new()
			tile.size = Vector3(CELL_SIZE, 0.2, CELL_SIZE)
			tile.material = light_mat if (col + row) % 2 == 0 else dark_mat
			tiles.add_child(tile)
			tile.global_position = cell_position(Vector2i(col, row)) + Vector3(0, -0.1, 0)

func _build_buttons() -> void:
	for row in Logic.BOARD_SIZE:
		for col in Logic.BOARD_SIZE:
			var cell := Vector2i(col, row)
			var b := Button.new()
			b.custom_minimum_size = Vector2(40, 40)
			b.tooltip_text = Logic.cell_name(cell)
			b.add_theme_color_override("font_color", Color(1.0, 0.98, 0.9))
			b.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
			b.add_theme_color_override("font_disabled_color", Color(1.0, 0.98, 0.9))
			b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
			b.add_theme_constant_override("outline_size", 2)
			b.add_theme_font_size_override("font_size", 15)
			b.pressed.connect(_on_cell_pressed.bind(cell))
			cell_grid.add_child(b)
			cell_buttons[cell] = b

func _on_cell_pressed(cell: Vector2i) -> void:
	if is_auto_solving:
		stop_auto_solve()
	logic.toggle_queen(cell)

func _on_reset_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
	logic.reset()
	banner.visible = false
	status_label.text = "The courtyard is cleared. Place 8 queens so none attack each other."

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
	status_label.text = "Placing queens automatically..."
	
	# Find a solution extending current non-conflicting queens; if none, reset and solve fresh.
	var solution: Array[Vector2i] = []
	if logic.conflicting_queens().is_empty():
		solution = Logic.find_completion(logic.queens)
	if solution.is_empty():
		logic.reset()
		solution = Logic.find_completion([])
	
	for cell in solution:
		if not is_auto_solving or logic.is_solved:
			break
		if not logic.has_queen(cell):
			logic.place_queen(cell)
			await get_tree().create_timer(auto_solve_delay).timeout
	
	stop_auto_solve()

func stop_auto_solve() -> void:
	is_auto_solving = false
	if is_instance_valid(btn_solve):
		btn_solve.text = "Auto-Solve (Debug)"
		btn_solve.disabled = logic != null and logic.is_solved

func _on_state_changed(queens: Array, conflicts: Array) -> void:
	# Remove statues whose queen is gone.
	for cell in queen_nodes.keys():
		if cell not in queens:
			queen_nodes[cell].queue_free()
			queen_nodes.erase(cell)
			queen_materials.erase(cell)
	# Add statues for new queens.
	for cell in queens:
		if not queen_nodes.has(cell):
			_spawn_queen(cell)
	# Recolour: crimson in conflict, gold when safe.
	for cell in queen_materials:
		var mat: StandardMaterial3D = queen_materials[cell]
		var c: Color = COLOR_CONFLICT if cell in conflicts else COLOR_SAFE
		mat.albedo_color = c
		mat.emission = c
	_rebuild_beams()
	for cell in cell_buttons:
		var b: Button = cell_buttons[cell]
		var has_q: bool = cell in queens
		var in_conf: bool = cell in conflicts
		b.text = "Q" if has_q else ""
		b.modulate = Color(1, 1, 1)
		b.disabled = logic.is_solved
		var base_sb: StyleBoxFlat = style_cell_light if (cell.x + cell.y) % 2 == 0 else style_cell_dark
		if has_q:
			base_sb = style_cell_conflict if in_conf else style_cell_safe
		b.add_theme_stylebox_override("normal", base_sb)
		b.add_theme_stylebox_override("disabled", base_sb)
		b.add_theme_stylebox_override("hover", base_sb if has_q else style_cell_hover)
		b.add_theme_stylebox_override("pressed", base_sb)
	count_label.text = "Queens: %d / %d" % [queens.size(), Logic.BOARD_SIZE]
	if is_instance_valid(btn_solve):
		btn_solve.disabled = logic.is_solved

func _spawn_queen(cell: Vector2i) -> void:
	var root := Node3D.new()
	var mat := StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.metallic = 0.6
	mat.roughness = 0.35
	var base := CSGCylinder3D.new()
	base.radius = 0.32
	base.height = 0.2
	base.position = Vector3(0, 0.1, 0)
	base.material = mat
	root.add_child(base)
	var body := CSGCylinder3D.new()
	body.radius = 0.2
	body.height = 0.7
	body.position = Vector3(0, 0.55, 0)
	body.material = mat
	root.add_child(body)
	var crown := CSGSphere3D.new()
	crown.radius = 0.22
	crown.position = Vector3(0, 1.0, 0)
	crown.material = mat
	root.add_child(crown)
	queens_root.add_child(root)
	var target := cell_position(cell)
	root.global_position = target + Vector3(0, 2.0, 0)
	create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).tween_property(root, "global_position", target, 0.45)
	queen_nodes[cell] = root
	queen_materials[cell] = mat

## Draw a crimson beam of light between every pair of attacking queens.
func _rebuild_beams() -> void:
	for b in beams_root.get_children():
		b.queue_free()
		beams_root.remove_child(b)
	var beam_mat := StandardMaterial3D.new()
	beam_mat.albedo_color = COLOR_CONFLICT
	beam_mat.emission_enabled = true
	beam_mat.emission = COLOR_CONFLICT
	for pair in logic.conflict_pairs():
		var a := cell_position(pair[0]) + Vector3(0, 0.6, 0)
		var b := cell_position(pair[1]) + Vector3(0, 0.6, 0)
		var beam := CSGBox3D.new()
		beam.size = Vector3(0.06, 0.06, a.distance_to(b))
		beam.material = beam_mat
		beams_root.add_child(beam)
		beam.global_position = (a + b) / 2.0
		beam.look_at(b, Vector3.UP)

func _on_puzzle_solved() -> void:
	if is_auto_solving:
		stop_auto_solve()
	if is_instance_valid(btn_solve):
		btn_solve.disabled = true
	banner.visible = true
	banner_label.text = "PUZZLE SOLVED!\nThe beams converge on the sun crystal.\nThe drawbridge to the catacombs lowers!"
	banner_label.modulate = Color(0.35, 1.0, 0.45)
	status_label.text = "Victory! Eight queens, none attacking."
	for cell in queen_materials:
		queen_materials[cell].albedo_color = Color(0.4, 1.0, 0.5)
		queen_materials[cell].emission = Color(0.4, 1.0, 0.5)
	_proceed_to_next_level()

## Auto-advance to Level 4 a few seconds after victory so the player can see the result.
func _proceed_to_next_level() -> void:
	banner_label.text += "\nProceeding to the Knight's Chasm..."
	await get_tree().create_timer(NEXT_LEVEL_DELAY).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file(NEXT_LEVEL_SCENE)
