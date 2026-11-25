extends SceneTree

# Plays through Level 2 via direct 3D door clicks: wrong door (tiger), reset, empty door, auto-solver, and first-person mode.
const Runner = preload("res://tests/TestRunner.gd")

var t: RefCounted

func check(cond: bool, msg: String) -> void:
	t.check(cond, msg)

func _init() -> void:
	t = Runner.new("TestLevel02Scene (Level 2 3D, Auto-Solve & First-Person)")
	var s = load("res://scenes/levels/Level02_NinePortals.tscn").instantiate()
	root.add_child(s)
	await physics_frame
	await physics_frame
	check(s.door_areas.size() == 9, "Nine 3D door click areas created")
	check(s.btn_open.disabled, "Open disabled before selecting a door")

	var tiger_rm: int = s.logic.tiger_room()
	var tiger_door_pos: Vector3 = s._door(tiger_rm).global_position + Vector3(0, 1.5, 0)
	var tiger_screen_pos: Vector2 = s.camera.unproject_position(tiger_door_pos)
	s._handle_screen_click(tiger_screen_pos)
	check(s.selected == tiger_rm, "Single 3D screen click selects the door")
	check(s.plaque_label.text.contains(s.logic.get_inscription(tiger_rm)), "Plaque for selected door displayed")
	s.btn_open.pressed.emit()
	await create_timer(1.1).timeout
	check(s.logic.is_failed, "Tiger door fails")
	check(s.banner.visible and s.banner_label.text.contains("You failed"), "Fail banner shown")
	check(s.banner_label.text.contains("Reset"), "Banner asks the player to press Reset")
	check(s.btn_open.disabled, "Open disabled after failure")
	check(s.get_node("Doors/Door%d/Hinge" % tiger_rm).rotation_degrees.y < -90.0, "Door swung open")

	var old_roles: Array[int] = s.logic.roles.duplicate()
	s.btn_reset.pressed.emit()
	check(not s.logic.is_failed and not s.banner.visible, "Reset clears failure")
	check(s.content_nodes.is_empty(), "Reset removes room contents")
	check(s.logic.roles != old_roles, "Reset randomizes layout")
	check(s.plaque_label.text.contains(s.logic.get_inscription(tiger_rm)), "Reset updates displayed plaque inscription")

	var empty_rm: int = s.logic.empty_room()
	var empty_door_pos: Vector3 = s._door(empty_rm).global_position + Vector3(0, 1.5, 0)
	s._handle_screen_click(s.camera.unproject_position(empty_door_pos))
	check(s.selected == empty_rm, "3D click selects empty door")
	s.btn_open.pressed.emit()
	await create_timer(1.1).timeout
	check(not s.logic.is_failed and not s.logic.is_solved, "Empty room keeps the game going")

	check(s.btn_solve != null and not s.btn_solve.disabled, "Auto-solve button exists and enabled")
	s.auto_solve_delay = 0.01
	s.btn_solve.pressed.emit()
	await create_timer(0.03).timeout
	check(s.is_auto_solving and s.inspected.size() > 1, "Auto-solver inspects plaques automatically")
	s.btn_solve.pressed.emit() # Pause solver
	await process_frame
	check(not s.is_auto_solving, "Auto-solver stops when toggled")

	var princess_rm: int = s.logic.princess_room()
	s.btn_solve.pressed.emit() # Resume solver to completion
	while not s.logic.is_solved and (s.is_auto_solving or s.is_animating):
		await process_frame
	check(s.logic.is_solved, "Auto-solver deduces and opens Princess door")
	check(s.banner_label.text.contains("SOLVED") and s.banner_label.text.contains("Door %d" % princess_rm), "Victory banner shown")
	check(s.btn_solve.disabled, "Solve button disabled after puzzle is solved")

	# PBI-04: First-Person & Journal integration in Level 2
	while s.is_animating:
		await process_frame
	s.btn_reset.pressed.emit()
	await physics_frame
	check(s.player != null and s.door_interactables.size() == 9, "First-person Player and 9 Interactable3D doors initialized")
	check(not s.is_first_person, "Starts in overview camera mode")

	s.btn_view_mode.pressed.emit()
	await physics_frame
	check(s.is_first_person and s.player.camera.current, "View mode toggle activates first-person camera")

	# Position player facing Door 5 within interaction range
	s.player.position = Vector3(0.0, 0.05, 2.2)
	s.player.rotation = Vector3.ZERO
	s.player.camera_pivot.rotation = Vector3.ZERO
	await physics_frame
	await physics_frame
	s.player.update_interaction_focus()
	check(s.player.focused_interactable == s.door_interactables[5], "First-person raycast focuses Door 5 Interactable3D")
	check(s.player.prompt_label.text == "[E] Inspect Door 5", "Contextual prompt shows '[E] Inspect Door 5'")

	check(s.player.try_interact(), "Pressing interact inspects Door 5 in first-person")
	check(s.selected == 5 and s.journal_state.has_entry("level02", "door_5"), "First-person door inspection selects door and logs plaque to Journal")

	# Opening journal in first-person releases mouse capture; closing restores it
	s.journal_ui.open()
	check(not s.player.is_mouse_captured, "Opening journal releases first-person mouse capture")
	s.journal_ui.close()
	check(s.player.is_mouse_captured, "Closing journal restores first-person mouse capture")

	s.btn_view_mode.pressed.emit()
	check(not s.is_first_person and s.camera.current, "Toggling view mode returns to overview camera")

	t.finish(self)
