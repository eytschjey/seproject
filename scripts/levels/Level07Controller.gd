extends Node3D

## Level 07 Controller: 3D presentation of Bonus Chamber — The Midnight Bridge (Bridge & Torch).
## Decoupled from the rules: all state transitions and optimal solving live in MidnightBridgeLogic.

const Logic = preload("res://scripts/logic/MidnightBridgeLogic.gd")
const ProgressStore = preload("res://scripts/logic/ProgressStore.gd")

@onready var camera: Camera3D = $Camera3D
@onready var torch_node: Node3D = $Torch
@onready var torch_flame: CSGSphere3D = $Torch/Flame
@onready var torch_light: OmniLight3D = $Torch/TorchLight
@onready var bridge_center: Marker3D = $Environment/RopeBridge/BridgeCenter

@onready var west_positions: Array[Marker3D] = [
	$Environment/WestCliff/ArielaPos,
	$Environment/WestCliff/BrianPos,
	$Environment/WestCliff/CharlyPos,
	$Environment/WestCliff/DumpyPos,
]
@onready var east_positions: Array[Marker3D] = [
	$Environment/EastCliff/ArielaPos,
	$Environment/EastCliff/BrianPos,
	$Environment/EastCliff/CharlyPos,
	$Environment/EastCliff/DumpyPos,
]
@onready var torch_west_pos: Marker3D = $Environment/WestCliff/TorchPos
@onready var torch_east_pos: Marker3D = $Environment/EastCliff/TorchPos

@onready var traveler_nodes: Array[Node3D] = [
	$Travelers/Ariela,
	$Travelers/Brian,
	$Travelers/Charly,
	$Travelers/Dumpy,
]
@onready var traveler_areas: Array[Area3D] = [
	$Travelers/Ariela/ClickArea,
	$Travelers/Brian/ClickArea,
	$Travelers/Charly/ClickArea,
	$Travelers/Dumpy/ClickArea,
]

@onready var traveler_box: HBoxContainer = %TravelerButtons
@onready var torch_timer_label: Label = %TorchTimerLabel
@onready var status_label: Label = %StatusLabel
@onready var banner: PanelContainer = %Banner
@onready var banner_label: Label = %BannerLabel
@onready var btn_cross: Button = %BtnCross
@onready var btn_undo: Button = %BtnUndo
@onready var btn_reset: Button = %BtnReset
@onready var btn_solve: Button = %BtnSolve

@export var auto_solve_delay: float = 0.25
@export var crossing_tween_duration: float = 0.75

var logic: RefCounted
var selected_travelers: Array[int] = []
var traveler_buttons: Array[Button] = []
var is_animating: bool = false
var is_auto_solving: bool = false
var _auto_solve_id: int = 0
var _flicker_time: float = 0.0

var _style_btn_normal: StyleBoxFlat
var _style_btn_hover: StyleBoxFlat
var _style_btn_selected: StyleBoxFlat
var _style_btn_disabled: StyleBoxFlat

func _ready() -> void:
	logic = Logic.new()
	logic.state_changed.connect(_on_state_changed)
	logic.move_executed.connect(func(d: String): status_label.text = d)
	logic.move_rejected.connect(func(r: String): status_label.text = r)
	logic.puzzle_failed.connect(_on_puzzle_failed)
	logic.puzzle_solved.connect(_on_puzzle_solved)

	_init_gui_theme()
	_build_traveler_buttons()
	btn_cross.pressed.connect(_on_cross_pressed)
	btn_undo.pressed.connect(_on_undo_pressed)
	btn_reset.pressed.connect(_on_reset_pressed)
	btn_solve.pressed.connect(_on_solve_pressed)
	BackToMenuButton.attach($UI/RootControl, Color(0.68, 0.48, 0.26, 0.70))

	_snap_all_to_state()
	_update_ui()
	_update_torch_visuals()

func _make_box_style(bg: Color, border: Color, border_w: int = 1, radius: int = 6) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	return sb

func _init_gui_theme() -> void:
	# Bonus Chamber Color Scheme: Midnight Navy & Warm Ember-Amber
	var panel_sb := _make_box_style(Color(0.06, 0.08, 0.13, 0.88), Color(0.62, 0.44, 0.24, 0.60), 1, 8)
	for p in [$UI/RootControl/HeaderPanel, $UI/RootControl/ActionBar, banner]:
		if p != null:
			p.add_theme_stylebox_override("panel", panel_sb)
	banner_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
	banner_label.add_theme_constant_override("outline_size", 2)

	_style_btn_normal = _make_box_style(Color(0.11, 0.14, 0.22, 0.90), Color(0.54, 0.40, 0.24, 0.65), 1, 6)
	_style_btn_hover = _make_box_style(Color(0.16, 0.20, 0.30, 0.94), Color(0.72, 0.54, 0.30, 0.80), 1, 6)
	_style_btn_selected = _make_box_style(Color(0.38, 0.24, 0.10, 0.95), Color(0.95, 0.72, 0.32, 0.95), 2, 6)
	_style_btn_disabled = _make_box_style(Color(0.07, 0.09, 0.13, 0.72), Color(0.24, 0.26, 0.34, 0.45), 1, 6)

	for btn in [btn_cross, btn_undo, btn_reset, btn_solve]:
		_apply_button_colors(btn)

func _apply_button_colors(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal", _style_btn_normal)
	btn.add_theme_stylebox_override("hover", _style_btn_hover)
	btn.add_theme_stylebox_override("pressed", _style_btn_selected)
	btn.add_theme_stylebox_override("disabled", _style_btn_disabled)
	btn.add_theme_color_override("font_color", Color(0.90, 0.89, 0.86))
	btn.add_theme_color_override("font_hover_color", Color(0.98, 0.96, 0.92))
	btn.add_theme_color_override("font_disabled_color", Color(0.46, 0.48, 0.54))
	btn.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.65))
	btn.add_theme_constant_override("outline_size", 1)

func _build_traveler_buttons() -> void:
	for t in Logic.TRAVELER_COUNT:
		var b := Button.new()
		b.custom_minimum_size = Vector2(150, 36)
		_apply_button_colors(b)
		b.pressed.connect(_on_traveler_clicked.bind(t))
		traveler_box.add_child(b)
		traveler_buttons.append(b)

func _process(delta: float) -> void:
	_flicker_time += delta
	if logic == null:
		return
	if logic.is_failed:
		torch_light.light_energy = 0.0
		torch_flame.visible = false
		return
	torch_flame.visible = true
	var ratio: float = clampf(float(logic.remaining_minutes()) / float(Logic.MAX_MINUTES), 0.12, 1.0)
	var flicker: float = sin(_flicker_time * 11.0) * 0.14 + cos(_flicker_time * 17.3) * 0.08
	torch_light.light_energy = maxf(0.4, 3.2 * ratio + flicker)
	torch_light.omni_range = lerpf(4.5, 14.0, ratio)
	var flame_scale: float = lerpf(0.45, 1.0, ratio)
	torch_flame.scale = Vector3.ONE * flame_scale

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_screen_click(event.position)

func _handle_screen_click(screen_pos: Vector2) -> void:
	if is_animating or logic.is_failed or logic.is_solved or camera == null:
		return
	var from: Vector3 = camera.project_ray_origin(screen_pos)
	var to: Vector3 = from + camera.project_ray_normal(screen_pos) * 100.0
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result: Dictionary = space.intersect_ray(query)
	if result.is_empty():
		return
	var idx: int = traveler_areas.find(result.collider)
	if idx >= 0:
		_on_traveler_clicked(idx)

func _on_traveler_clicked(traveler: int) -> void:
	if is_auto_solving:
		stop_auto_solve()
	if is_animating or logic.is_failed or logic.is_solved:
		return
	var side_list: Array[int] = logic.travelers_on_side(logic.torch_side)
	if traveler not in side_list:
		status_label.text = "%s is on the opposite cliff — bring the torch back first." % Logic.traveler_name(traveler)
		return
	if traveler in selected_travelers:
		selected_travelers.erase(traveler)
	else:
		if selected_travelers.size() >= 2:
			selected_travelers.pop_front()
		selected_travelers.append(traveler)
	_update_ui()

func _on_cross_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
	if is_animating or selected_travelers.is_empty():
		return
	_execute_crossing(selected_travelers.duplicate())

func _execute_crossing(group: Array[int]) -> void:
	if is_animating:
		return
	if not logic.cross(group):
		return
	selected_travelers.clear()
	await _animate_crossing(group)
	_update_ui()
	_update_torch_visuals()

func _animate_crossing(group: Array[int]) -> void:
	is_animating = true
	_update_ui()
	var dur: float = maxf(0.01, crossing_tween_duration)
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for t in group:
		var node: Node3D = traveler_nodes[t]
		var dst: Vector3 = _target_traveler_pos(t)
		tween.tween_property(node, "global_position", dst, dur)
	tween.tween_property(torch_node, "global_position", _target_torch_pos(), dur)
	await tween.finished
	is_animating = false

func _on_undo_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
	if is_animating:
		return
	if logic.undo():
		selected_travelers.clear()
		banner.visible = false
		_snap_all_to_state()
		_update_ui()
		_update_torch_visuals()

func _on_reset_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
	if is_animating:
		return
	selected_travelers.clear()
	logic.reset()
	banner.visible = false
	status_label.text = "The torch is relit (15:00). Guide all four travelers across the Midnight Bridge."
	_snap_all_to_state()
	_update_ui()
	_update_torch_visuals()

func _on_solve_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
		return
	if is_animating or logic.is_solved:
		return
	start_auto_solve()

func start_auto_solve() -> void:
	_auto_solve_id += 1
	var my_id: int = _auto_solve_id
	is_auto_solving = true
	btn_solve.text = "Stop Solver"
	banner.visible = false
	status_label.text = "Auto-solver guiding travelers across the Midnight Bridge..."

	var steps: Array[Dictionary] = logic.find_optimal_solution()
	if steps.is_empty():
		selected_travelers.clear()
		logic.reset()
		_snap_all_to_state()
		_update_ui()
		_update_torch_visuals()
		steps = logic.find_optimal_solution()

	for step in steps:
		if my_id != _auto_solve_id or not is_auto_solving or logic.is_solved or logic.is_failed:
			break
		var group: Array[int] = []
		for t in step["travelers"]:
			group.append(int(t))
		selected_travelers = group.duplicate()
		_update_ui()
		await get_tree().create_timer(auto_solve_delay).timeout
		if my_id != _auto_solve_id or not is_auto_solving:
			break
		await _execute_crossing(group)
		await get_tree().create_timer(auto_solve_delay).timeout

	if my_id == _auto_solve_id:
		stop_auto_solve()

func stop_auto_solve() -> void:
	_auto_solve_id += 1
	is_auto_solving = false
	if is_instance_valid(btn_solve):
		btn_solve.text = "Auto-Solve (Debug)"
		btn_solve.disabled = is_animating or (logic != null and logic.is_solved)

func _on_state_changed(_side: int, _west: Array, _east: Array, _elapsed: int) -> void:
	_update_torch_visuals()
	_update_ui()

func _on_puzzle_failed(reason: String) -> void:
	if is_auto_solving:
		stop_auto_solve()
	banner.visible = true
	banner_label.text = "TORCH BURNED OUT!\n%s\nPress Undo or Reset to try again." % reason
	banner_label.modulate = Color(1.0, 0.35, 0.35)
	_update_torch_visuals()

func _on_puzzle_solved() -> void:
	if is_auto_solving:
		stop_auto_solve()
	ProgressStore.record_completion("level07")
	banner.visible = true
	banner_label.text = "BONUS CHAMBER CLEARED!\nAll four travelers crossed the Midnight Bridge in %d / %d minutes!" % [logic.elapsed_minutes, Logic.MAX_MINUTES]
	banner_label.modulate = Color(0.35, 1.0, 0.45)
	status_label.text = "Victory! You mastered the Bridge & Torch puzzle."
	_update_ui()

func _target_traveler_pos(t: int) -> Vector3:
	if t in logic.east_travelers:
		return east_positions[t].global_position
	return west_positions[t].global_position

func _target_torch_pos() -> Vector3:
	return torch_east_pos.global_position if logic.torch_side == Logic.Side.EAST else torch_west_pos.global_position

func _snap_all_to_state() -> void:
	for t in Logic.TRAVELER_COUNT:
		traveler_nodes[t].global_position = _target_traveler_pos(t)
	torch_node.global_position = _target_torch_pos()

func _update_torch_visuals() -> void:
	if logic == null:
		return
	var rem: int = logic.remaining_minutes()
	torch_timer_label.text = "Torch Remaining: %02d:00  |  Elapsed: %d / %d min  |  Torch Side: %s" % [
		rem,
		logic.elapsed_minutes,
		Logic.MAX_MINUTES,
		Logic.side_name(logic.torch_side),
	]
	if logic.is_failed:
		torch_timer_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	elif rem <= 3:
		torch_timer_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.25))
	else:
		torch_timer_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.36))

func _update_ui() -> void:
	if logic == null:
		return
	var game_over: bool = logic.is_solved or logic.is_failed
	var current_side_travelers: Array[int] = logic.travelers_on_side(logic.torch_side)

	for t in traveler_buttons.size():
		var b: Button = traveler_buttons[t]
		var on_torch_side: bool = t in current_side_travelers
		var is_sel: bool = t in selected_travelers
		var side_tag: String = "W" if t in logic.west_travelers else "E"
		b.text = "%s%s (%dm) [%s]" % ["► " if is_sel else "", Logic.traveler_name(t), Logic.crossing_time(t), side_tag]
		b.disabled = is_animating or game_over or not on_torch_side
		b.add_theme_stylebox_override("normal", _style_btn_selected if is_sel else _style_btn_normal)
		traveler_nodes[t].scale = Vector3(1.12, 1.12, 1.12) if is_sel else Vector3.ONE

	var can_go: bool = not is_animating and not game_over and not selected_travelers.is_empty() and logic.can_cross(selected_travelers)
	btn_cross.disabled = not can_go
	if can_go:
		var cost: int = Logic.group_cost(selected_travelers)
		var dir_str: String = "East" if logic.torch_side == Logic.Side.WEST else "West"
		btn_cross.text = "Cross to %s (+%d min)" % [dir_str, cost]
	else:
		btn_cross.text = "Cross Bridge"

	btn_undo.disabled = is_animating or logic.history.is_empty() or logic.is_solved
	btn_reset.disabled = is_animating
	if is_instance_valid(btn_solve):
		btn_solve.disabled = is_animating or logic.is_solved
