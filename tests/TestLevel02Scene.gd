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

	s.door_buttons[0].pressed.emit()
	check(s.plaque_label.text.contains("odd number"), "Plaque for door 1 displayed")
	s.btn_open.pressed.emit()
	await create_timer(1.1).timeout
	check(s.logic.is_failed, "Door 1 (tiger) fails")
	check(s.banner.visible and s.banner_label.text.contains("You failed"), "Fail banner shown")
	check(s.banner_label.text.contains("Reset"), "Banner asks the player to press Reset")
	check(s.btn_open.disabled, "Open disabled after failure")
	check(s.get_node("Doors/Door1/Hinge").rotation_degrees.y < -90.0, "Door swung open")

	s.btn_reset.pressed.emit()
	check(not s.logic.is_failed and not s.banner.visible, "Reset clears failure")
	check(s.content_nodes.is_empty(), "Reset removes room contents")

	s.door_buttons[2].pressed.emit()
	s.btn_open.pressed.emit()
	await create_timer(1.1).timeout
	check(not s.logic.is_failed and not s.logic.is_solved, "Empty Room 3 keeps the game going")

	s.door_buttons[4].pressed.emit()
	s.btn_open.pressed.emit()
	await create_timer(1.1).timeout
	check(s.logic.is_solved, "Door 5 solves the puzzle")
	check(s.banner_label.text.contains("SOLVED"), "Victory banner shown")
	print("checks failed: ", checks_failed)
	quit(1 if checks_failed > 0 else 0)
