extends Node3D

## Level 01 Controller: Manages 3D greybox visual representations of the Wolf, Goat & Cabbage puzzle.
## Decoupled from the rules: connects directly to RiverCrossingLogic.

const Logic = preload("res://scripts/logic/RiverCrossingLogic.gd")

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

# UI references
@onready var btn_wolf: Button = %BtnWolf
@onready var btn_goat: Button = %BtnGoat
@onready var btn_cabbage: Button = %BtnCabbage
@onready var btn_cross: Button = %BtnCross
@onready var btn_reset: Button = %BtnReset
@onready var status_label: Label = %StatusLabel
@onready var banner: PanelContainer = %Banner
@onready var banner_label: Label = %BannerLabel

const RAFT_WEST_X: float = -4.0
const RAFT_EAST_X: float = 4.0
const TWEEN_DURATION: float = 1.2

var logic: RefCounted
var is_animating: bool = false
var item_tweens: Dictionary = {}  # item -> Tween
var hopping: Dictionary = {}      # item -> bool

func _ready() -> void:
	logic = Logic.new()
	logic.state_changed.connect(_on_state_changed)
	logic.puzzle_failed.connect(_on_puzzle_failed)
	logic.puzzle_solved.connect(_on_puzzle_solved)
	logic.move_executed.connect(_on_move_executed)
	
	btn_wolf.pressed.connect(func(): _toggle_item(Logic.Item.WOLF))
	btn_goat.pressed.connect(func(): _toggle_item(Logic.Item.GOAT))
	btn_cabbage.pressed.connect(func(): _toggle_item(Logic.Item.CABBAGE))
	btn_cross.pressed.connect(_on_cross_pressed)
	btn_reset.pressed.connect(_on_reset_pressed)
	
	_update_ui()
	_update_item_positions_instant()

func _toggle_item(item: int) -> void:
	if is_animating or logic.is_failed or logic.is_solved:
		return
	
	if logic.item_on_boat == item:
		logic.unload_item()
	else:
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
	
	var target_x = RAFT_EAST_X if to_side == Logic.Side.EAST else RAFT_WEST_X
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(raft, "position:x", target_x, TWEEN_DURATION)
	# The carried item follows the raft every frame (see _process).
	
	await tween.finished
	is_animating = false
	_set_buttons_enabled(true)

func _process(_delta: float) -> void:
	# Keep the carried item glued to the raft once its hop onto the raft has finished.
	if logic == null or logic.item_on_boat == null:
		return
	if hopping.get(logic.item_on_boat, false):
		return
	_get_item_node(logic.item_on_boat).global_position = raft_slot.global_position

func _on_reset_pressed() -> void:
	if is_animating:
		return
	logic.reset()
	banner.visible = false
	status_label.text = "Puzzle reset. Transport everything to the East Shore."
	# Re-enable ALL controls (they were disabled by the fail state).
	_set_buttons_enabled(true)
	_animate_raft_back_to_start()

func _on_state_changed(_boat_side: int, _west: Array, _east: Array, _carried) -> void:
	_update_ui()
	_animate_items_to_state()

func _on_move_executed(description: String) -> void:
	status_label.text = description

func _on_puzzle_failed(reason: String) -> void:
	banner.visible = true
	banner_label.text = "⚠️ " + reason + "\nPress Reset to try again!"
	banner_label.modulate = Color(1.0, 0.35, 0.35)
	_set_buttons_enabled(false)
	btn_reset.disabled = false

func _on_puzzle_solved() -> void:
	banner.visible = true
	banner_label.text = "🎉 PUZZLE SOLVED!\nAll passengers safely crossed the river!"
	banner_label.modulate = Color(0.35, 1.0, 0.45)
	status_label.text = "Victory! The gate ahead unlocks."

func _update_ui() -> void:
	btn_cross.text = "Row Raft to East" if logic.boat_side == Logic.Side.WEST else "Row Raft to West"
	
	_update_button_label(btn_wolf, Logic.Item.WOLF, "Wolf")
	_update_button_label(btn_goat, Logic.Item.GOAT, "Goat")
	_update_button_label(btn_cabbage, Logic.Item.CABBAGE, "Cabbage")

func _update_button_label(button: Button, item: int, name_str: String) -> void:
	if logic.item_on_boat == item:
		button.text = "Unload " + name_str
		button.disabled = false
	else:
		var is_on_same_shore = item in logic.west_items if logic.boat_side == Logic.Side.WEST else item in logic.east_items
		button.text = "Load " + name_str
		button.disabled = not is_on_same_shore or logic.item_on_boat != null

func _set_buttons_enabled(enabled: bool) -> void:
	btn_wolf.disabled = not enabled
	btn_goat.disabled = not enabled
	btn_cabbage.disabled = not enabled
	btn_cross.disabled = not enabled
	btn_reset.disabled = not enabled
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
