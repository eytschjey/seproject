extends Node3D

## Level 05 Controller: 3D greybox presentation of The Night at Dreadbury Manor.
## Decoupled from the rules: all decisions are made by DreadburyLogic.

const Logic = preload("res://scripts/logic/DreadburyLogic.gd")

@onready var storm_light: DirectionalLight3D = $DirectionalLight3D
@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var clues_origin: Marker3D = $Clues/CluesOrigin
@onready var clues_root: Node3D = $Clues/CluesRoot
@onready var altar_origin: Marker3D = $Altar/AltarOrigin
@onready var busts_root: Node3D = $Altar/BustsRoot
@onready var dagger: Node3D = $Altar/Dagger
@onready var dagger_home: Marker3D = $Altar/DaggerHome
@onready var suicide_note: Node3D = $Altar/SuicideNote

@onready var clue_count_label: Label = %ClueCountLabel
@onready var clue_grid: GridContainer = %ClueGrid
@onready var suspect_box: VBoxContainer = %SuspectBox
@onready var btn_accuse: Button = %BtnAccuse
@onready var btn_reset: Button = %BtnReset
@onready var btn_solve: Button = %BtnSolve
@onready var status_label: Label = %StatusLabel
@onready var clue_label: Label = %ClueLabel
@onready var banner: PanelContainer = %Banner
@onready var banner_label: Label = %BannerLabel

@export var auto_solve_delay: float = 0.22

const COLOR_CLUE_UNREAD := Color(0.35, 0.55, 0.95)
const COLOR_CLUE_READ := Color(0.95, 0.78, 0.25)
const COLOR_CLUE_ACTIVE := Color(1.0, 0.95, 0.55)
const COLOR_BUST_IDLE := Color(0.68, 0.65, 0.6)
const COLOR_BUST_SELECTED := Color(1.0, 0.82, 0.28)
const COLOR_BUST_SOLVED := Color(0.35, 1.0, 0.45)
const COLOR_BUST_FAILED := Color(1.0, 0.2, 0.15)

const CLUE_OFFSETS: Array[Vector3] = [
	Vector3(-5.2, 0.85, -1.6),
	Vector3(-3.6, 0.85, -2.4),
	Vector3(-1.8, 0.85, -1.5),
	Vector3(0.0, 0.85, -2.4),
	Vector3(1.8, 0.85, -1.5),
	Vector3(3.6, 0.85, -2.4),
	Vector3(-2.8, 0.85, 0.2),
	Vector3(2.8, 0.85, 0.2),
]

var logic: RefCounted
var clue_buttons: Array[Button] = []
var suspect_buttons: Array[Button] = []
var clue_nodes: Array[Node3D] = []
var clue_materials: Array[StandardMaterial3D] = []
var bust_nodes: Array[Node3D] = []
var bust_materials: Array[StandardMaterial3D] = []
var dagger_tween: Tween
var is_auto_solving: bool = false

func _ready() -> void:
	logic = Logic.new()
	logic.state_changed.connect(_on_state_changed)
	logic.clue_inspected.connect(_on_clue_inspected)
	logic.move_executed.connect(func(d: String): status_label.text = d)
	logic.puzzle_failed.connect(_on_puzzle_failed)
	logic.puzzle_solved.connect(_on_puzzle_solved)
	_build_clues()
	_build_altar()
	_build_dagger()
	_build_buttons()
	btn_accuse.pressed.connect(_on_accuse_pressed)
	btn_reset.pressed.connect(_on_reset_pressed)
	btn_solve.pressed.connect(_on_solve_pressed)
	BackToMenuButton.attach($UI/RootControl)
	_apply_storm_lighting()
	_on_state_changed(logic.discovered_clues.duplicate(), logic.selected_clue, logic.selected_suspect)

func clue_position(index: int) -> Vector3:
	return clues_origin.global_position + CLUE_OFFSETS[index]

func bust_position(suspect: int) -> Vector3:
	var x_offset: float = (suspect - 1) * 2.4
	return altar_origin.global_position + Vector3(x_offset, 0.0, 0.0)

func _build_clues() -> void:
	for i in Logic.CLUE_COUNT:
		var holder := Node3D.new()
		var pedestal := CSGCylinder3D.new()
		pedestal.radius = 0.28
		pedestal.height = 0.75
		pedestal.position = Vector3(0, -0.4, 0)
		var ped_mat := StandardMaterial3D.new()
		ped_mat.albedo_color = Color(0.28, 0.22, 0.18)
		ped_mat.roughness = 0.85
		pedestal.material = ped_mat
		holder.add_child(pedestal)

		var scroll := CSGBox3D.new()
		scroll.size = Vector3(0.46, 0.12, 0.34)
		var mat := StandardMaterial3D.new()
		mat.emission_enabled = true
		mat.roughness = 0.4
		scroll.material = mat
		holder.add_child(scroll)

		var lbl := Label3D.new()
		lbl.text = str(i + 1)
		lbl.font_size = 42
		lbl.pixel_size = 0.008
		lbl.position = Vector3(0, 0.32, 0)
		holder.add_child(lbl)

		clues_root.add_child(holder)
		holder.global_position = clue_position(i)
		clue_nodes.append(holder)
		clue_materials.append(mat)

func _build_altar() -> void:
	for s in Logic.SUSPECT_COUNT:
		var root := Node3D.new()
		var mat := StandardMaterial3D.new()
		mat.emission_enabled = true
		mat.roughness = 0.45
		mat.metallic = 0.25

		var plinth := CSGBox3D.new()
		plinth.size = Vector3(0.9, 0.35, 0.9)
		plinth.position = Vector3(0, 0.175, 0)
		plinth.material = mat
		root.add_child(plinth)

		var torso := CSGCylinder3D.new()
		torso.radius = 0.28
		torso.height = 0.55
		torso.position = Vector3(0, 0.62, 0)
		torso.material = mat
		root.add_child(torso)

		var head := CSGSphere3D.new()
		head.radius = 0.24
		head.position = Vector3(0, 1.1, 0)
		head.material = mat
		root.add_child(head)

		var name_lbl := Label3D.new()
		name_lbl.text = Logic.suspect_name(s)
		name_lbl.font_size = 36
		name_lbl.pixel_size = 0.008
		name_lbl.position = Vector3(0, 1.55, 0)
		root.add_child(name_lbl)

		busts_root.add_child(root)
		root.global_position = bust_position(s)
		bust_nodes.append(root)
		bust_materials.append(mat)

func _build_dagger() -> void:
	var blade_mat := StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.95, 0.88, 0.45)
	blade_mat.metallic = 0.85
	blade_mat.roughness = 0.2
	blade_mat.emission_enabled = true
	blade_mat.emission = Color(0.95, 0.82, 0.3)

	var hilt := CSGBox3D.new()
	hilt.size = Vector3(0.45, 0.08, 0.12)
	hilt.position = Vector3(0, 0.35, 0)
	hilt.material = blade_mat
	dagger.add_child(hilt)

	var blade := CSGCylinder3D.new()
	blade.radius = 0.06
	blade.height = 0.55
	blade.cone = true
	blade.rotation_degrees.x = 180.0
	blade.position = Vector3(0, 0.05, 0)
	blade.material = blade_mat
	dagger.add_child(blade)
	dagger.global_position = dagger_home.global_position

func _build_buttons() -> void:
	for i in Logic.CLUE_COUNT:
		var info: Dictionary = Logic.clue_info(i)
		var b := Button.new()
		b.custom_minimum_size = Vector2(175, 38)
		b.text = "%d. %s" % [i + 1, info["title"]]
		b.tooltip_text = info["location"]
		b.pressed.connect(_on_clue_pressed.bind(i))
		clue_grid.add_child(b)
		clue_buttons.append(b)

	for s in Logic.SUSPECT_COUNT:
		var b := Button.new()
		b.custom_minimum_size = Vector2(350, 38)
		b.text = "Select Bust: %s" % Logic.suspect_name(s)
		b.pressed.connect(_on_suspect_pressed.bind(s))
		suspect_box.add_child(b)
		suspect_buttons.append(b)

func _on_clue_pressed(index: int) -> void:
	if is_auto_solving:
		stop_auto_solve()
	logic.inspect_clue(index)

func _on_suspect_pressed(suspect: int) -> void:
	if is_auto_solving:
		stop_auto_solve()
	logic.select_suspect(suspect)

func _on_accuse_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
	logic.accuse_selected()

func _on_reset_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
	logic.reset()
	banner.visible = false
	suicide_note.visible = false
	_apply_storm_lighting()
	clue_label.text = "Select a clue to inspect the evidence."
	status_label.text = "The storm rumbles over Dreadbury Manor. Examine the clues and identify the killer."

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
	if logic.is_failed:
		logic.reset()
		suicide_note.visible = false
		_apply_storm_lighting()
	status_label.text = "Gathering clues and deducing the killer..."

	for i in Logic.CLUE_COUNT:
		if not is_auto_solving or logic.is_solved:
			break
		if not logic.is_clue_discovered(i):
			logic.inspect_clue(i)
			await get_tree().create_timer(auto_solve_delay).timeout

	if is_auto_solving and not logic.is_solved:
		var candidates: Array[int] = Logic.killer_candidates()
		if not candidates.is_empty():
			var killer: int = candidates[0]
			logic.select_suspect(killer)
			await get_tree().create_timer(auto_solve_delay).timeout
			if is_auto_solving and not logic.is_solved:
				logic.accuse_selected()

	stop_auto_solve()

func stop_auto_solve() -> void:
	is_auto_solving = false
	if is_instance_valid(btn_solve):
		btn_solve.text = "Auto-Solve (Debug)"
		btn_solve.disabled = logic != null and logic.is_solved

func _on_clue_inspected(index: int, clue: Dictionary) -> void:
	clue_label.text = "Clue %d — %s (%s):\n\"%s\"\nLogic: %s" % [
		index + 1,
		clue["title"],
		clue["location"],
		clue["text"],
		clue["formula"],
	]

func _on_state_changed(discovered: Array, selected_clue: int, selected_suspect: int) -> void:
	var game_over: bool = logic.is_solved or logic.is_failed
	for i in clue_materials.size():
		var mat: StandardMaterial3D = clue_materials[i]
		var c: Color = COLOR_CLUE_UNREAD
		if i == selected_clue:
			c = COLOR_CLUE_ACTIVE
		elif discovered[i]:
			c = COLOR_CLUE_READ
		mat.albedo_color = c
		mat.emission = c * 0.55

	for i in clue_buttons.size():
		var b: Button = clue_buttons[i]
		var info: Dictionary = Logic.clue_info(i)
		var mark: String = "✓ " if discovered[i] else ""
		b.text = "%s%d. %s" % [mark, i + 1, info["title"]]
		b.modulate = Color(1.0, 0.92, 0.55) if discovered[i] else Color(1, 1, 1)
		b.disabled = game_over

	for s in bust_materials.size():
		var mat: StandardMaterial3D = bust_materials[s]
		var c: Color = COLOR_BUST_IDLE
		if logic.is_solved and s == logic.accused_suspect:
			c = COLOR_BUST_SOLVED
		elif logic.is_failed and s == logic.accused_suspect:
			c = COLOR_BUST_FAILED
		elif s == selected_suspect:
			c = COLOR_BUST_SELECTED
		mat.albedo_color = c
		mat.emission = c * 0.4 if (s == selected_suspect or s == logic.accused_suspect) else Color.BLACK

	for s in suspect_buttons.size():
		var b: Button = suspect_buttons[s]
		var prefix: String = "► " if s == selected_suspect else ""
		b.text = "%sBust: %s" % [prefix, Logic.suspect_name(s)]
		b.modulate = Color(1.0, 0.88, 0.45) if s == selected_suspect else Color(1, 1, 1)
		b.disabled = game_over

	_move_dagger(selected_suspect, logic.accused_suspect >= 0)
	clue_count_label.text = "Clues Examined: %d / %d" % [logic.discovered_count(), Logic.CLUE_COUNT]
	btn_accuse.disabled = game_over or selected_suspect < 0
	if selected_suspect >= 0:
		btn_accuse.text = "Accuse %s (Place Dagger)" % Logic.suspect_name(selected_suspect)
	else:
		btn_accuse.text = "Place Dagger of Truth"
	if is_instance_valid(btn_solve):
		btn_solve.disabled = logic.is_solved

func _move_dagger(selected_suspect: int, plunged: bool) -> void:
	var target: Vector3 = dagger_home.global_position
	if selected_suspect >= 0:
		var y_off: float = 1.45 if plunged else 1.85
		target = bust_position(selected_suspect) + Vector3(0, y_off, 0)
	if dagger_tween != null and dagger_tween.is_valid():
		dagger_tween.kill()
	dagger_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	dagger_tween.tween_property(dagger, "global_position", target, 0.25)

func _apply_storm_lighting() -> void:
	if is_instance_valid(storm_light):
		storm_light.light_color = Color(0.6, 0.7, 0.95)
		storm_light.light_energy = 0.65

func _apply_morning_lighting() -> void:
	if is_instance_valid(storm_light):
		storm_light.light_color = Color(1.0, 0.9, 0.65)
		storm_light.light_energy = 1.35

func _on_puzzle_failed(reason: String) -> void:
	if is_auto_solving:
		stop_auto_solve()
	banner.visible = true
	banner_label.text = "FALSE ACCUSATION!\n%s\nPress Reset to try again." % reason
	banner_label.modulate = Color(1.0, 0.35, 0.35)

func _on_puzzle_solved() -> void:
	if is_auto_solving:
		stop_auto_solve()
	if is_instance_valid(btn_solve):
		btn_solve.disabled = true
	suicide_note.visible = true
	_apply_morning_lighting()
	banner.visible = true
	banner_label.text = (
		"MYSTERY SOLVED!\n"
		+ "Aunt Agatha killed herself! Placing the Dagger of Truth on Agatha's bust\n"
		+ "reveals her hidden suicide note. The storm clears and the manor doors swing open!"
	)
	banner_label.modulate = Color(0.35, 1.0, 0.45)
	status_label.text = "Victory! The curse of Dreadbury Manor is broken."
