extends Node3D

## Level 02 Controller: 3D greybox presentation of the Hall of Nine Portals.
## Decoupled from the rules: all decisions are made by NinePortalsLogic.

const Logic = preload("res://scripts/logic/NinePortalsLogic.gd")

@onready var door_buttons_box: HBoxContainer = %DoorButtons
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

var logic: RefCounted
var door_buttons: Array[Button] = []
var selected: int = 0 # 0 = nothing selected, else room number 1..9
var is_animating: bool = false
var is_auto_solving: bool = false
var content_nodes: Dictionary = {} # room -> Node3D spawned behind the door
var inspected: Dictionary = {}     # room -> true once its plaque was read

func _ready() -> void:
	logic = Logic.new()
	logic.door_opened.connect(_on_door_opened)
	logic.puzzle_failed.connect(_on_puzzle_failed)
	logic.puzzle_solved.connect(_on_puzzle_solved)
	logic.move_executed.connect(_on_move_executed)

	for n in range(1, Logic.DOOR_COUNT + 1):
		var b := Button.new()
		b.text = "Door %d" % n
		b.pressed.connect(_on_door_button_pressed.bind(n))
		door_buttons_box.add_child(b)
		door_buttons.append(b)
	btn_open.pressed.connect(_on_open_pressed)
	btn_reset.pressed.connect(_on_reset_pressed)
	btn_solve.pressed.connect(_on_solve_pressed)
	BackToMenuButton.attach($UI/RootControl)
	_update_ui()

func _door(n: int) -> Node3D:
	return get_node("Doors/Door%d" % n)

func _on_door_button_pressed(n: int) -> void:
	if is_auto_solving:
		stop_auto_solve()
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

func _on_puzzle_solved() -> void:
	if is_auto_solving:
		stop_auto_solve()
	if is_instance_valid(btn_solve):
		btn_solve.disabled = true
	banner.visible = true
	banner_label.text = "PUZZLE SOLVED!\nThe Princess is behind Door %d. The Royal Sigil is yours!" % logic.princess_room()
	banner_label.modulate = Color(0.35, 1.0, 0.45)
	_proceed_to_next_level()

## Auto-advance to Level 3 a few seconds after victory so the player can see the result.
func _proceed_to_next_level() -> void:
	banner_label.text += "\nProceeding to the Sun Courtyard..."
	await get_tree().create_timer(NEXT_LEVEL_DELAY).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file(NEXT_LEVEL_SCENE)

func _update_ui() -> void:
	var game_over: bool = logic.is_failed or logic.is_solved
	for i in door_buttons.size():
		var n := i + 1
		door_buttons[i].text = ("Door %d%s" % [n, " (open)" if logic.opened[i] else ""])
		door_buttons[i].disabled = is_animating
	btn_open.disabled = (
		is_animating or game_over or selected == 0 or logic.opened[selected - 1]
	)
	btn_open.text = "Open Door %d" % selected if selected != 0 else "Open Selected Door"
	btn_reset.disabled = is_animating
	if is_instance_valid(btn_solve):
		btn_solve.disabled = is_animating or logic.is_solved
