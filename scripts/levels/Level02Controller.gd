extends Node3D

## Level 02 Controller: 3D greybox presentation of the Hall of Nine Portals.
## Decoupled from the rules: all decisions are made by NinePortalsLogic.
## Direct 3D interaction: Click any door or plaque in the 3D hall to select and inspect it.

const Logic = preload("res://scripts/logic/NinePortalsLogic.gd")

@onready var camera: Camera3D = $Camera3D
@onready var btn_open: Button = %BtnOpen
@onready var btn_reset: Button = %BtnReset
@onready var btn_solve: Button = %BtnSolve
@onready var status_label: Label = %StatusLabel
@onready var plaque_label: Label = %PlaqueLabel
@onready var banner: PanelContainer = %Banner
@onready var banner_label: Label = %BannerLabel

const DOOR_OPEN_ANGLE: float = -105.0 # degrees; swings toward the viewer
const DOOR_TWEEN_DURATION: float = 0.8
const NEXT_LEVEL_SCENE: String = "res://scenes/levels/Level03_SunCourtyard.tscn"
const NEXT_LEVEL_DELAY: float = 4.0
@export var auto_solve_delay: float = 0.22

const COLOR_PLAQUE_IDLE := Color(0.78, 0.65, 0.3)
const COLOR_PLAQUE_INSPECTED := Color(0.9, 0.78, 0.4)
const COLOR_PLAQUE_SELECTED := Color(1.0, 0.92, 0.45)
const COLOR_FRAME_IDLE := Color(0.2, 0.18, 0.17)
const COLOR_FRAME_SELECTED := Color(0.55, 0.45, 0.22)

var logic: RefCounted
var door_areas: Dictionary = {}        # Area3D -> room number (1..9)
var plaque_materials: Dictionary = {}  # room -> StandardMaterial3D
var frame_materials: Dictionary = {}   # room -> StandardMaterial3D
var selected: int = 0                  # 0 = nothing selected, else room number 1..9
var hovered_door: int = 0
var is_animating: bool = false
var is_auto_solving: bool = false
var content_nodes: Dictionary = {}     # room -> Node3D spawned behind the door
var inspected: Dictionary = {}         # room -> true once its plaque was read

func _ready() -> void:
	logic = Logic.new()
	logic.door_opened.connect(_on_door_opened)
	logic.puzzle_failed.connect(_on_puzzle_failed)
	logic.puzzle_solved.connect(_on_puzzle_solved)
	logic.move_executed.connect(_on_move_executed)

	_setup_door_interactions()
	btn_open.pressed.connect(_on_open_pressed)
	btn_reset.pressed.connect(_on_reset_pressed)
	btn_solve.pressed.connect(_on_solve_pressed)
	BackToMenuButton.attach($UI/RootControl, Color(0.95, 0.76, 0.28))
	_apply_gui_theme()
	_update_ui()

func _make_box_style(bg: Color, border: Color, border_w: int = 2, radius: int = 8) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 8.0
	sb.content_margin_bottom = 8.0
	return sb

func _apply_gui_theme() -> void:
	# Level 2 Color Scheme: Royal Imperial Burgundy & Burnished Gold
	var panel_sb := _make_box_style(Color(0.16, 0.06, 0.10, 0.94), Color(0.95, 0.76, 0.28, 0.95), 2, 8)
	var plaque_sb := _make_box_style(Color(0.20, 0.08, 0.12, 0.95), Color(1.0, 0.84, 0.36, 0.98), 2, 10)
	for p in [$UI/RootControl/HeaderPanel, $UI/RootControl/ActionBar, banner]:
		if p != null:
			p.add_theme_stylebox_override("panel", panel_sb)
	if has_node("UI/RootControl/PlaquePanel"):
		$UI/RootControl/PlaquePanel.add_theme_stylebox_override("panel", plaque_sb)
	banner_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	banner_label.add_theme_constant_override("outline_size", 3)
	var btn_normal := _make_box_style(Color(0.28, 0.09, 0.14, 0.96), Color(0.95, 0.78, 0.32, 0.95), 2, 6)
	var btn_hover := _make_box_style(Color(0.40, 0.14, 0.20, 1.0), Color(1.0, 0.90, 0.55, 1.0), 2, 6)
	var btn_pressed := _make_box_style(Color(0.52, 0.18, 0.24, 1.0), Color(1.0, 0.96, 0.75, 1.0), 2, 6)
	var btn_disabled := _make_box_style(Color(0.14, 0.07, 0.09, 0.85), Color(0.45, 0.36, 0.22, 0.7), 1, 6)
	for btn in [btn_open, btn_reset, btn_solve]:
		if btn == null:
			continue
		btn.add_theme_stylebox_override("normal", btn_normal)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.add_theme_stylebox_override("pressed", btn_pressed)
		btn.add_theme_stylebox_override("disabled", btn_disabled)
		btn.add_theme_color_override("font_color", Color(1.0, 0.95, 0.84))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.94))
		btn.add_theme_color_override("font_pressed_color", Color(1.0, 0.88, 0.45))
		btn.add_theme_color_override("font_disabled_color", Color(0.58, 0.50, 0.44))
		btn.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		btn.add_theme_constant_override("outline_size", 2)

func _door(n: int) -> Node3D:
	return get_node("Doors/Door%d" % n)

func _setup_door_interactions() -> void:
	var hitbox_shape := BoxShape3D.new()
	hitbox_shape.size = Vector3(2.0, 3.9, 0.8)

	for n in range(1, Logic.DOOR_COUNT + 1):
		var door_node := _door(n)

		var plaque_mat := StandardMaterial3D.new()
		plaque_mat.albedo_color = COLOR_PLAQUE_IDLE
		plaque_mat.metallic = 0.7
		plaque_mat.roughness = 0.4
		plaque_mat.emission_enabled = true
		var plaque_box: CSGBox3D = door_node.get_node("Plaque")
		plaque_box.material = plaque_mat
		plaque_materials[n] = plaque_mat

		var frame_mat := StandardMaterial3D.new()
		frame_mat.albedo_color = COLOR_FRAME_IDLE
		frame_mat.roughness = 0.85
		frame_mat.emission_enabled = true
		var frame_box: CSGBox3D = door_node.get_node("Frame")
		frame_box.material = frame_mat
		frame_materials[n] = frame_mat

		var area := Area3D.new()
		area.name = "ClickArea"
		var col := CollisionShape3D.new()
		col.shape = hitbox_shape
		col.position = Vector3(0, 1.9, 0.0)
		area.add_child(col)
		door_node.add_child(area)
		door_areas[area] = n

		area.mouse_entered.connect(_on_door_mouse_entered.bind(n))
		area.mouse_exited.connect(_on_door_mouse_exited.bind(n))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_screen_click(event.position)

func _handle_screen_click(screen_pos: Vector2) -> void:
	if is_animating or camera == null:
		return
	var from := camera.project_ray_origin(screen_pos)
	var to := from + camera.project_ray_normal(screen_pos) * 100.0
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result := space.intersect_ray(query)
	if result.is_empty():
		return
	var col = result.collider
	if door_areas.has(col):
		click_door(door_areas[col])

func _on_door_mouse_entered(n: int) -> void:
	if is_animating or logic.is_failed or logic.is_solved:
		return
	hovered_door = n
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_POINTING_HAND)
	create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).tween_property(
		_door(n), "scale", Vector3(1.04, 1.04, 1.04), 0.14
	)

func _on_door_mouse_exited(n: int) -> void:
	if hovered_door == n:
		hovered_door = 0
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).tween_property(
		_door(n), "scale", Vector3.ONE, 0.14
	)

## Public entry point for clicking a door in 3D or tests.
func click_door(n: int) -> void:
	if is_auto_solving:
		stop_auto_solve()
	if is_animating:
		return
	_select_door(n)

func _select_door(n: int) -> void:
	selected = n
	inspected[n] = true
	plaque_label.text = "Door %d:\n\"%s\"" % [n, logic.get_inscription(n)]
	_update_ui()

func _on_open_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
	if is_animating or selected == 0:
		return
	logic.open_door(selected)

func _on_reset_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
	if is_animating:
		return
	_reset_hall()

func _reset_hall() -> void:
	logic.reset()
	inspected.clear()
	if selected != 0:
		plaque_label.text = "Door %d:\n\"%s\"" % [selected, logic.get_inscription(selected)]
	for n in content_nodes:
		content_nodes[n].queue_free()
	content_nodes.clear()
	for n in range(1, Logic.DOOR_COUNT + 1):
		var hinge: Node3D = _door(n).get_node("Hinge")
		hinge.rotation_degrees.y = 0.0
		_door(n).get_node("RoomLight").visible = false
	banner.visible = false
	status_label.text = "The hall resets. Choose wisely."
	_update_ui()

func _on_solve_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
		return
	if is_animating or logic.is_solved:
		return
	start_auto_solve()

func start_auto_solve() -> void:
	is_auto_solving = true
	btn_solve.text = "Stop Solver"
	banner.visible = false
	if logic.is_failed:
		_reset_hall()
	status_label.text = "Inspecting plaques and deducing the Princess's portal..."

	for n in range(1, Logic.DOOR_COUNT + 1):
		if not is_auto_solving or logic.is_solved:
			break
		if not inspected.has(n):
			_select_door(n)
			await get_tree().create_timer(auto_solve_delay).timeout

	if is_auto_solving and not logic.is_solved:
		var target_room: int = logic.solve_princess_room()
		if target_room >= 1 and target_room <= Logic.DOOR_COUNT:
			_select_door(target_room)
			await get_tree().create_timer(auto_solve_delay).timeout
			if is_auto_solving and not logic.is_solved and not is_animating:
				logic.open_door(target_room)
				while is_animating and is_inside_tree():
					await get_tree().process_frame

	stop_auto_solve()

func stop_auto_solve() -> void:
	is_auto_solving = false
	if is_instance_valid(btn_solve):
		btn_solve.text = "Auto-Solve (Debug)"
		btn_solve.disabled = is_animating or (logic != null and logic.is_solved)

func _on_move_executed(description: String) -> void:
	status_label.text = description

func _on_door_opened(room: int, content: int) -> void:
	_spawn_content(room, content)
	var door := _door(room)
	var light: OmniLight3D = door.get_node("RoomLight")
	light.visible = true
	match content:
		Logic.Content.TIGER: light.light_color = Color(1.0, 0.15, 0.1)
		Logic.Content.PRINCESS: light.light_color = Color(1.0, 0.85, 0.4)
		_: light.light_color = Color(0.7, 0.65, 0.55)
	is_animating = true
	_update_ui()
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(door.get_node("Hinge"), "rotation_degrees:y", DOOR_OPEN_ANGLE, DOOR_TWEEN_DURATION)
	await tween.finished
	is_animating = false
	_update_ui()

func _spawn_content(room: int, content: int) -> void:
	var slot: Marker3D = _door(room).get_node("RoomSlot")
	var root := Node3D.new()
	slot.add_child(root)
	content_nodes[room] = root
	var mat := StandardMaterial3D.new()
	match content:
		Logic.Content.TIGER:
			mat.albedo_color = Color(0.9, 0.5, 0.1)
			var body := CSGBox3D.new()
			body.size = Vector3(1.0, 0.6, 0.5)
			body.position = Vector3(0, 0.3, 0)
			body.material = mat
			root.add_child(body)
			var eye_mat := StandardMaterial3D.new()
			eye_mat.albedo_color = Color(1, 0.1, 0.1)
			eye_mat.emission_enabled = true
			eye_mat.emission = Color(1, 0.1, 0.1)
			for dx in [-0.15, 0.15]:
				var eye := CSGSphere3D.new()
				eye.radius = 0.07
				eye.position = Vector3(dx + 0.3, 0.55, 0.26)
				eye.material = eye_mat
				root.add_child(eye)
		Logic.Content.PRINCESS:
			mat.albedo_color = Color(1.0, 0.85, 0.3)
			mat.emission_enabled = true
			mat.emission = Color(1.0, 0.8, 0.2)
			var dress := CSGCylinder3D.new()
			dress.radius = 0.35
			dress.height = 1.0
			dress.position = Vector3(0, 0.5, 0)
			dress.material = mat
			root.add_child(dress)
			var head := CSGSphere3D.new()
			head.radius = 0.2
			head.position = Vector3(0, 1.2, 0)
			head.material = mat
			root.add_child(head)
		_:
			mat.albedo_color = Color(0.55, 0.5, 0.42)
			for i in 4:
				var dust := CSGSphere3D.new()
				dust.radius = 0.15 + 0.05 * i
				dust.position = Vector3(-0.4 + 0.25 * i, 0.15, 0.1 * (i % 2))
				dust.material = mat
				root.add_child(dust)

func _on_puzzle_failed(_reason: String) -> void:
	if is_auto_solving:
		stop_auto_solve()
	banner.visible = true
	banner_label.text = "You failed!\nPress Reset to try again."
	banner_label.modulate = Color(1.0, 0.35, 0.35)
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)

func _on_puzzle_solved() -> void:
	if is_auto_solving:
		stop_auto_solve()
	if is_instance_valid(btn_solve):
		btn_solve.disabled = true
	banner.visible = true
	banner_label.text = "PUZZLE SOLVED!\nThe Princess is behind Door %d. The Royal Sigil is yours!" % logic.princess_room()
	banner_label.modulate = Color(0.35, 1.0, 0.45)
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	_proceed_to_next_level()

## Auto-advance to Level 3 a few seconds after victory so the player can see the result.
func _proceed_to_next_level() -> void:
	banner_label.text += "\nProceeding to the Sun Courtyard..."
	await get_tree().create_timer(NEXT_LEVEL_DELAY).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file(NEXT_LEVEL_SCENE)

func _update_ui() -> void:
	var game_over: bool = logic.is_failed or logic.is_solved
	for n in range(1, Logic.DOOR_COUNT + 1):
		if plaque_materials.has(n):
			var p_mat: StandardMaterial3D = plaque_materials[n]
			if n == selected:
				p_mat.albedo_color = COLOR_PLAQUE_SELECTED
				p_mat.emission = COLOR_PLAQUE_SELECTED * 0.45
			elif inspected.has(n):
				p_mat.albedo_color = COLOR_PLAQUE_INSPECTED
				p_mat.emission = COLOR_PLAQUE_INSPECTED * 0.15
			else:
				p_mat.albedo_color = COLOR_PLAQUE_IDLE
				p_mat.emission = Color.BLACK
		if frame_materials.has(n):
			var f_mat: StandardMaterial3D = frame_materials[n]
			f_mat.albedo_color = COLOR_FRAME_SELECTED if n == selected else COLOR_FRAME_IDLE
			f_mat.emission = COLOR_FRAME_SELECTED * 0.35 if n == selected else Color.BLACK

	btn_open.disabled = (
		is_animating or game_over or selected == 0 or logic.opened[selected - 1]
	)
	btn_open.text = "Open Door %d" % selected if selected != 0 else "Open Selected Door"
	btn_reset.disabled = is_animating
	if is_instance_valid(btn_solve):
		btn_solve.disabled = is_animating or logic.is_solved
