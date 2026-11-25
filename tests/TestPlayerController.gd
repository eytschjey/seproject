extends SceneTree

# Automated headless unit & 3D physics integration test for PBI-02:
# First-Person 3D Player Controller (Player.tscn) & Interactable3D component.

const InteractableScript = preload("res://scripts/core/Interactable3D.gd")

var checks_failed: int = 0

func check(cond: bool, msg: String) -> void:
	print(("  PASS: " if cond else "  FAIL: ") + msg)
	if not cond:
		checks_failed += 1

func _init() -> void:
	print("=== TestPlayerController: Interactable3D Unit Checks ===")
	_test_interactable_unit()

	print("=== TestPlayerController: Player.tscn Movement, Look & Raycast ===")
	await _test_player_scene()

	print("checks failed: ", checks_failed)
	quit(1 if checks_failed > 0 else 0)

func _test_interactable_unit() -> void:
	var item = InteractableScript.new()
	item.prompt_text = "Inspect Plaque"
	item.action_hint = "E"

	var state := {"interacted": 0, "focused": 0, "unfocused": 0, "last_player": null}
	item.interacted.connect(func(p: Node):
		state["interacted"] += 1
		state["last_player"] = p
	)
	item.focused.connect(func(_p: Node): state["focused"] += 1)
	item.unfocused.connect(func(_p: Node): state["unfocused"] += 1)

	check(item.get_prompt() == "[E] Inspect Plaque", "Formats contextual prompt correctly")
	var dummy_player := Node.new()
	check(item.interact(dummy_player), "Enabled Interactable3D accepts interaction")
	check(state["interacted"] == 1 and state["last_player"] == dummy_player, "Emits interacted(player) signal with player reference")

	item.set_focused(true, dummy_player)
	item.set_focused(true, dummy_player) # idempotent
	item.set_focused(false, dummy_player)
	check(state["focused"] == 1 and state["unfocused"] == 1, "Focus/unfocus signals fire once per transition")

	item.interaction_enabled = false
	check(item.get_prompt() == "", "Disabled Interactable3D returns empty prompt")
	check(not item.interact(dummy_player), "Disabled Interactable3D rejects interaction")

	dummy_player.free()
	item.free()

func _test_player_scene() -> void:
	var world := Node3D.new()
	root.add_child(world)

	# Floor static body so CharacterBody3D can land on ground
	var floor_body := StaticBody3D.new()
	var floor_col := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(20.0, 0.5, 20.0)
	floor_col.shape = floor_shape
	floor_col.position = Vector3(0.0, -0.25, 0.0)
	floor_body.add_child(floor_col)
	world.add_child(floor_body)

	# Instantiate Player.tscn at origin facing -Z
	var player = load("res://scenes/player/Player.tscn").instantiate()
	world.add_child(player)

	# Place an Interactable3D directly ahead of the player camera (at z = -2.0, y = 1.6)
	var target = InteractableScript.new()
	target.name = "PlaqueInteractable"
	target.prompt_text = "Inspect Plaque"
	var target_col := CollisionShape3D.new()
	var target_shape := BoxShape3D.new()
	target_shape.size = Vector3(1.2, 1.2, 0.4)
	target_col.shape = target_shape
	target.add_child(target_col)
	target.position = Vector3(0.0, 1.6, -2.0)
	world.add_child(target)

	var signals := {"interacted": 0, "focus_changes": 0}
	target.interacted.connect(func(_p: Node): signals["interacted"] += 1)
	player.focus_changed.connect(func(_node: Node): signals["focus_changes"] += 1)

	await physics_frame
	await physics_frame

	# Structure & initial state
	check(player.camera_pivot != null and player.camera != null and player.interaction_ray != null, "Player scene has CameraPivot, Camera3D, and InteractionRay")
	check(player.is_mouse_captured, "Mouse capture active on ready when capture_mouse_on_ready is true")

	# Raycast detection & contextual prompt
	player.update_interaction_focus()
	check(player.focused_interactable == target, "Centered RayCast3D detects Interactable3D in range")
	check(player.prompt_panel.visible and player.prompt_label.text == "[E] Inspect Plaque", "Contextual prompt panel displays '[E] Inspect Plaque'")
	check(target.is_focused and signals["focus_changes"] >= 1, "Interactable3D marked focused and focus_changed emitted")

	# Trigger interaction via `interact` input action
	var interact_ev := InputEventAction.new()
	interact_ev.action = "interact"
	interact_ev.pressed = true
	player._unhandled_input(interact_ev)
	check(signals["interacted"] == 1, "Pressing 'interact' action triggers Interactable3D.interacted(player)")

	# Disable target -> prompt hides and focus clears
	target.interaction_enabled = false
	player.update_interaction_focus()
	check(player.focused_interactable == null and not player.prompt_panel.visible, "Disabling interactable clears focus and hides prompt")
	target.interaction_enabled = true

	# Move target out of range (> 3.5m) -> no detection
	target.position = Vector3(0.0, 1.6, -6.0)
	await physics_frame
	await physics_frame
	player.update_interaction_focus()
	check(player.focused_interactable == null and not player.prompt_panel.visible, "Interactable outside interaction_range is not focused")

	# Mouse look yaw + pitch clamping
	var initial_yaw: float = player.rotation.y
	player.apply_look_delta(Vector2(100.0, 0.0))
	check(player.rotation.y < initial_yaw, "Horizontal mouse motion rotates player yaw")
	player.apply_look_delta(Vector2(0.0, -50000.0))
	check(is_equal_approx(rad_to_deg(player.camera_pivot.rotation.x), player.max_pitch_degrees), "Upward pitch clamped to max_pitch_degrees")
	player.apply_look_delta(Vector2(0.0, 50000.0))
	check(is_equal_approx(rad_to_deg(player.camera_pivot.rotation.x), player.min_pitch_degrees), "Downward pitch clamped to min_pitch_degrees")

	# Esc toggles mouse capture
	var esc_ev := InputEventKey.new()
	esc_ev.keycode = KEY_ESCAPE
	esc_ev.pressed = true
	player._unhandled_input(esc_ev)
	check(not player.is_mouse_captured, "Pressing Escape releases mouse capture")
	player._unhandled_input(esc_ev)
	check(player.is_mouse_captured, "Pressing Escape again re-enables mouse capture")

	# Walk & sprint velocity computation
	var walk_vel: Vector3 = player.compute_horizontal_velocity(Vector2(0.0, -1.0), false)
	var sprint_vel: Vector3 = player.compute_horizontal_velocity(Vector2(0.0, -1.0), true)
	check(is_equal_approx(walk_vel.length(), player.walk_speed), "Forward walk velocity matches walk_speed")
	check(is_equal_approx(sprint_vel.length(), player.sprint_speed), "Forward sprint velocity matches sprint_speed")

	world.queue_free()
	await process_frame
