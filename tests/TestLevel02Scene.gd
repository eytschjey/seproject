extends SceneTree

# Plays through the real UI buttons: wrong door (tiger), reset, empty door, then the princess.
var checks_failed: int = 0

func check(cond: bool, msg: String) -> void:
	print(("  PASS: " if cond else "  FAIL: ") + msg)
	if not cond:
		checks_failed += 1

func _init() -> void:
	var s = load("res://scenes/levels/Level02_NinePortals.tscn").instantiate()
	root.add_child(s)
	await process_frame
	check(s.door_buttons.size() == 9, "Nine door buttons created")
	check(s.btn_open.disabled, "Open disabled before selecting a door")

	var tiger_rm: int = s.logic.tiger_room()
	s.door_buttons[tiger_rm - 1].pressed.emit()
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
	s.door_buttons[empty_rm - 1].pressed.emit()
	s.btn_open.pressed.emit()
	await create_timer(1.1).timeout
	check(not s.logic.is_failed and not s.logic.is_solved, "Empty room keeps the game going")

	var princess_rm: int = s.logic.princess_room()
	s.door_buttons[princess_rm - 1].pressed.emit()
	s.btn_open.pressed.emit()
	await create_timer(1.1).timeout
	check(s.logic.is_solved, "Princess door solves the puzzle")
	check(s.banner_label.text.contains("SOLVED") and s.banner_label.text.contains("Door %d" % princess_rm), "Victory banner shown")
	print("checks failed: ", checks_failed)
	quit(1 if checks_failed > 0 else 0)
