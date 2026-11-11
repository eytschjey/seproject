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
@onready var status_label: Label = %StatusLabel
@onready var count_label: Label = %QueenCountLabel
@onready var banner: PanelContainer = %Banner
@onready var banner_label: Label = %BannerLabel

const CELL_SIZE: float = 1.0
const NEXT_LEVEL_SCENE: String = "res://scenes/levels/Level04_KnightsChasm.tscn"
const NEXT_LEVEL_DELAY: float = 4.0

const COLOR_SAFE := Color(1.0, 0.82, 0.25)
const COLOR_CONFLICT := Color(1.0, 0.15, 0.1)

var logic: RefCounted
var cell_buttons: Dictionary = {}   # Vector2i -> Button
var queen_nodes: Dictionary = {}    # Vector2i -> Node3D
var queen_materials: Dictionary = {} # Vector2i -> StandardMaterial3D

func _ready() -> void:
	logic = Logic.new()
	logic.state_changed.connect(_on_state_changed)
	logic.move_executed.connect(func(d: String): status_label.text = d)
	logic.puzzle_solved.connect(_on_puzzle_solved)
	_build_tiles()
	_build_buttons()
	btn_reset.pressed.connect(_on_reset_pressed)
	BackToMenuButton.attach($UI/RootControl)
	_on_state_changed([], [])

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
			b.pressed.connect(_on_cell_pressed.bind(cell))
			cell_grid.add_child(b)
			cell_buttons[cell] = b

func _on_cell_pressed(cell: Vector2i) -> void:
	logic.toggle_queen(cell)

func _on_reset_pressed() -> void:
	logic.reset()
	banner.visible = false
	status_label.text = "The courtyard is cleared. Place 8 queens so none attack each other."

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
		b.text = "Q" if cell in queens else ""
		b.modulate = Color(1, 0.4, 0.4) if cell in conflicts else Color(1, 1, 1)
		b.disabled = logic.is_solved
	count_label.text = "Queens: %d / %d" % [queens.size(), Logic.BOARD_SIZE]

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
