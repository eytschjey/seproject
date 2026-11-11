extends Node3D

## Level 01 Controller: Manages 3D greybox visual representations of the Wolf, Goat & Cabbage puzzle.
## Decoupled from the rules: connects directly to RiverCrossingLogic.
## Direct 3D interaction: Click items to load/unload; click raft or button to row across.

const Logic = preload("res://scripts/logic/RiverCrossingLogic.gd")

@onready var camera: Camera3D = $Camera3D
@onready var raft: Node3D = $Environment/Raft
@onready var raft_slot: Marker3D = $Environment/Raft/ItemSlot

@onready var wolf_node: Node3D = $Items/Wolf
@onready var goat_node: Node3D = $Items/Goat
@onready var cabbage_node: Node3D = $Items/Cabbage

@onready var west_wolf_pos: Marker3D = $Environment/WestShore/WolfPos
@onready var west_goat_pos: Marker3D = $Environment/WestShore/GoatPos
@onready var west_cabbage_pos: Marker3D = $Environment/WestShore/CabbagePos

@onready var east_wolf_pos: Marker3D = $Environment/EastShore/WolfPos
@onready var east_goat_pos: Marker3D = $Environment/EastShore/GoatPos
@onready var east_cabbage_pos: Marker3D = $Environment/EastShore/CabbagePos

@onready var wolf_area: Area3D = $Items/Wolf/ClickArea
@onready var goat_area: Area3D = $Items/Goat/ClickArea
@onready var cabbage_area: Area3D = $Items/Cabbage/ClickArea
@onready var raft_area: Area3D = $Environment/Raft/ClickArea

# UI references
@onready var btn_cross: Button = %BtnCross
@onready var btn_reset: Button = %BtnReset
@onready var btn_solve: Button = %BtnSolve
@onready var status_label: Label = %StatusLabel
@onready var banner: PanelContainer = %Banner
@onready var banner_label: Label = %BannerLabel

@export var auto_solve_delay: float = 0.25
@export var raft_tween_duration: float = 1.2

const RAFT_WEST_X: float = -4.0
const RAFT_EAST_X: float = 4.0
const NEXT_LEVEL_SCENE: String = "res://scenes/levels/Level02_NinePortals.tscn"
const NEXT_LEVEL_DELAY: float = 3.0

var logic: RefCounted
var is_animating: bool = false
var is_auto_solving: bool = false
var _auto_solve_id: int = 0
var raft_tween: Tween = null
var item_tweens: Dictionary = {}  # item -> Tween
var hopping: Dictionary = {}      # item -> bool

var _last_click_frame: int = -1
var hovered_target: Variant = null

func _ready() -> void:
	logic = Logic.new()
	logic.state_changed.connect(_on_state_changed)
	logic.puzzle_failed.connect(_on_puzzle_failed)
	logic.puzzle_solved.connect(_on_puzzle_solved)
	logic.move_executed.connect(_on_move_executed)
	
	btn_cross.pressed.connect(_on_cross_pressed)
	btn_reset.pressed.connect(_on_reset_pressed)
	btn_solve.pressed.connect(_on_solve_pressed)
	
	_connect_area(wolf_area, Logic.Item.WOLF)
	_connect_area(goat_area, Logic.Item.GOAT)
	_connect_area(cabbage_area, Logic.Item.CABBAGE)
	_connect_area(raft_area, "RAFT")
	
	BackToMenuButton.attach($UI/RootControl)
	_update_ui()
	_update_item_positions_instant()

func _connect_area(area: Area3D, target: Variant) -> void:
	area.mouse_entered.connect(func(): _on_area_mouse_entered(target))
	area.mouse_exited.connect(func(): _on_area_mouse_exited(target))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_screen_click(event.position)

func _handle_screen_click(screen_pos: Vector2) -> void:
	if is_animating or logic.is_failed or logic.is_solved or camera == null:
		return
	var from := camera.project_ray_origin(screen_pos)
	var to := from + camera.project_ray_normal(screen_pos) * 100.0
	var space := get_world_3d().direct_space_state

	# Prioritize item hitboxes over the raft hitbox so clicking a passenger on the raft always unloads it.
	var item_query := PhysicsRayQueryParameters3D.create(from, to)
	item_query.collide_with_areas = true
	item_query.collide_with_bodies = false
	item_query.exclude = [raft_area.get_rid()]
	var item_result := space.intersect_ray(item_query)
	if not item_result.is_empty():
		var item_col = item_result.collider
		if item_col == wolf_area:
			click_item(Logic.Item.WOLF)
			return
		elif item_col == goat_area:
			click_item(Logic.Item.GOAT)
			return
		elif item_col == cabbage_area:
			click_item(Logic.Item.CABBAGE)
			return

	var raft_query := PhysicsRayQueryParameters3D.create(from, to)
	raft_query.collide_with_areas = true
	raft_query.collide_with_bodies = false
	var raft_result := space.intersect_ray(raft_query)
	if not raft_result.is_empty() and raft_result.collider == raft_area:
		click_raft()

## Public entry point for clicking an item in 3D or tests.
func click_item(item: int) -> void:
	if is_auto_solving:
		stop_auto_solve()
	_toggle_item(item)

## Public entry point for clicking the raft in 3D or tests.
func click_raft() -> void:
	if is_auto_solving:
		stop_auto_solve()
	_on_cross_pressed()

func _toggle_item(item: int) -> void:
	if is_animating or logic.is_failed or logic.is_solved:
		return
	
	if logic.item_on_boat == item:
		logic.unload_item()
	else:
		var item_on_same_shore = (item in logic.west_items if logic.boat_side == Logic.Side.WEST else item in logic.east_items)
		if not item_on_same_shore:
			var shore_name = "West" if logic.boat_side == Logic.Side.EAST else "East"
			status_label.text = "That passenger is on the " + shore_name + " shore. Row the raft across first!"
			return
		if logic.item_on_boat != null:
			logic.unload_item()
		logic.load_item(item)

func _on_cross_pressed() -> void:
	if is_animating or logic.is_failed or logic.is_solved:
		return
	
	var old_side = logic.boat_side
	var success = logic.cross_river()
	if success:
		_animate_raft(old_side, logic.boat_side)

func _animate_raft(_from_side: int, to_side: int) -> void:
	is_animating = true
	_set_buttons_enabled(false)
	
	if raft_tween != null and raft_tween.is_valid():
		raft_tween.kill()
	
	var target_x = RAFT_EAST_X if to_side == Logic.Side.EAST else RAFT_WEST_X
	raft_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	raft_tween.tween_property(raft, "position:x", target_x, raft_tween_duration)
	# The carried item follows the raft every frame (see _process).
	
	await raft_tween.finished
	is_animating = false
	_set_buttons_enabled(true)

func _process(_delta: float) -> void:
	# Keep the carried item glued to the raft once its hop onto the raft has finished.
	if logic == null or logic.item_on_boat == null:
		return
	if hopping.get(logic.item_on_boat, false):
		return
	_get_item_node(logic.item_on_boat).global_position = raft_slot.global_position

func _on_area_mouse_entered(target: Variant) -> void:
	if is_animating or logic.is_failed or logic.is_solved:
		return
	hovered_target = target
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_POINTING_HAND)
	_tween_target_scale(target, Vector3(1.12, 1.12, 1.12) if target is int else Vector3(1.05, 1.05, 1.05))

func _on_area_mouse_exited(target: Variant) -> void:
	if hovered_target == target:
		hovered_target = null
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	_tween_target_scale(target, Vector3.ONE)

func _tween_target_scale(target: Variant, target_scale: Vector3) -> void:
	var node: Node3D = null
	if target is int:
		node = _get_item_node(target)
	elif target == "RAFT":
		node = raft
	if node != null:
		var tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_property(node, "scale", target_scale, 0.15)

func _on_reset_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
	if raft_tween != null and raft_tween.is_valid():
		raft_tween.kill()
		raft_tween = null
	is_animating = false
	for item in item_tweens:
		if item_tweens[item] != null and item_tweens[item].is_valid():
			item_tweens[item].kill()
	item_tweens.clear()
	hopping.clear()
	logic.reset()
	banner.visible = false
	status_label.text = "Puzzle reset. Transport everything to the East Shore."
	_set_buttons_enabled(true)
	raft.position.x = RAFT_WEST_X
	_update_item_positions_instant()

func _on_solve_pressed() -> void:
	if is_auto_solving:
		stop_auto_solve()
		return
	if logic == null or logic.is_solved or is_animating:
		return
	if logic.is_failed:
		_on_reset_pressed()
	start_auto_solve()

func start_auto_solve() -> void:
	_auto_solve_id += 1
	var my_id: int = _auto_solve_id
	is_auto_solving = true
	btn_solve.text = "Stop Solver"
	status_label.text = "Auto-solver active..."
	
	var steps: Array[Dictionary] = logic.find_solution()
	for step in steps:
		if my_id != _auto_solve_id or not is_auto_solving or logic.is_solved or logic.is_failed:
			break
		
		match step.type:
			"load":
				_toggle_item(step.item)
				await get_tree().create_timer(auto_solve_delay).timeout
			"unload":
				_toggle_item(logic.item_on_boat)
				await get_tree().create_timer(auto_solve_delay).timeout
			"cross":
				var old_side = logic.boat_side
				if logic.cross_river():
					_animate_raft(old_side, logic.boat_side)
					while is_animating and is_auto_solving and my_id == _auto_solve_id:
						await get_tree().process_frame
				await get_tree().create_timer(auto_solve_delay).timeout
	
	if my_id == _auto_solve_id:
		stop_auto_solve()

func stop_auto_solve() -> void:
	_auto_solve_id += 1
	is_auto_solving = false
	if is_instance_valid(btn_solve):
		btn_solve.text = "Auto-Solve (Debug)"
		btn_solve.disabled = logic != null and logic.is_solved

func _on_state_changed(_boat_side: int, _west: Array, _east: Array, _carried) -> void:
	_update_ui()
	_animate_items_to_state()

func _on_move_executed(description: String) -> void:
	status_label.text = description

func _on_puzzle_failed(reason: String) -> void:
	if is_auto_solving:
		stop_auto_solve()
	banner.visible = true
	banner_label.text = "⚠️ " + reason + "\nPress Reset to try again!"
	banner_label.modulate = Color(1.0, 0.35, 0.35)
	_set_buttons_enabled(false)
	btn_reset.disabled = false
	if is_instance_valid(btn_solve):
		btn_solve.disabled = true
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)

func _on_puzzle_solved() -> void:
	if is_auto_solving:
		stop_auto_solve()
	banner.visible = true
	banner_label.text = "🎉 PUZZLE SOLVED!\nAll passengers safely crossed the river!"
	banner_label.modulate = Color(0.35, 1.0, 0.45)
	status_label.text = "Victory! The gate ahead unlocks."
	if is_instance_valid(btn_solve):
		btn_solve.disabled = true
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	_proceed_to_next_level()

## Auto-advance to Level 2 a few seconds after victory so the player can see the result.
func _proceed_to_next_level() -> void:
	banner_label.text += "\nProceeding to the Hall of Nine Portals..."
	await get_tree().create_timer(NEXT_LEVEL_DELAY).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file(NEXT_LEVEL_SCENE)

func _update_ui() -> void:
	btn_cross.text = "Row Raft to East" if logic.boat_side == Logic.Side.WEST else "Row Raft to West"

func _set_buttons_enabled(enabled: bool) -> void:
	btn_cross.disabled = not enabled
	btn_reset.disabled = not enabled
	if is_instance_valid(btn_solve):
		btn_solve.disabled = not enabled or (logic != null and logic.is_solved)
	if enabled:
		_update_ui()

func _get_item_node(item: int) -> Node3D:
	match item:
		Logic.Item.WOLF: return wolf_node
		Logic.Item.GOAT: return goat_node
		Logic.Item.CABBAGE: return cabbage_node
		_: return null

func _get_target_position(item: int) -> Vector3:
	if logic.item_on_boat == item:
		return raft_slot.global_position
	elif item in logic.west_items:
		match item:
			Logic.Item.WOLF: return west_wolf_pos.global_position
			Logic.Item.GOAT: return west_goat_pos.global_position
			Logic.Item.CABBAGE: return west_cabbage_pos.global_position
	elif item in logic.east_items:
		match item:
			Logic.Item.WOLF: return east_wolf_pos.global_position
			Logic.Item.GOAT: return east_goat_pos.global_position
			Logic.Item.CABBAGE: return east_cabbage_pos.global_position
	return Vector3.ZERO

func _update_item_positions_instant() -> void:
	raft.position.x = RAFT_WEST_X if logic.boat_side == Logic.Side.WEST else RAFT_EAST_X
	wolf_node.global_position = _get_target_position(Logic.Item.WOLF)
	goat_node.global_position = _get_target_position(Logic.Item.GOAT)
	cabbage_node.global_position = _get_target_position(Logic.Item.CABBAGE)

func _animate_items_to_state() -> void:
	for item in [Logic.Item.WOLF, Logic.Item.GOAT, Logic.Item.CABBAGE]:
		var node = _get_item_node(item)
		var target = _get_target_position(item)
		if node.global_position.distance_to(target) > 0.05:
			# Cancel any hop still running for this item so tweens never fight.
			if item_tweens.has(item) and item_tweens[item].is_valid():
				item_tweens[item].kill()
			var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			item_tweens[item] = tween
			hopping[item] = true
			# Small hop up and down
			var mid = (node.global_position + target) / 2.0 + Vector3(0, 0.8, 0)
			tween.tween_property(node, "global_position", mid, 0.2)
			tween.tween_property(node, "global_position", target, 0.2)
			tween.finished.connect(func(): hopping[item] = false)

func _animate_raft_back_to_start() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(raft, "position:x", RAFT_WEST_X, 0.5)
