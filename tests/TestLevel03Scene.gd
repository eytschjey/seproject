extends SceneTree

# Plays Level 3 through the real HUD buttons: a conflict, removal, then a full solution.
var checks_failed: int = 0

func check(cond: bool, msg: String) -> void:
	print(("  PASS: " if cond else "  FAIL: ") + msg)
	if not cond:
		checks_failed += 1

func _init() -> void:
	var s = load("res://scenes/levels/Level03_SunCourtyard.tscn").instantiate()
	root.add_child(s)
	await process_frame
	check(s.cell_buttons.size() == 64, "64 cell buttons created")
	check(s.tiles.get_child_count() == 64, "64 board tiles created")

	s.cell_buttons[Vector2i(0, 0)].pressed.emit()
	s.cell_buttons[Vector2i(1, 1)].pressed.emit()
	await process_frame
	check(s.queen_nodes.size() == 2, "Two queen statues spawned")
	check(s.beams_root.get_child_count() == 1, "One conflict beam drawn")
	check(s.queen_materials[Vector2i(0, 0)].albedo_color == s.COLOR_CONFLICT, "Conflicting queens turn red")
	s.cell_buttons[Vector2i(1, 1)].pressed.emit()
	await process_frame
	check(s.beams_root.get_child_count() == 0, "Beam removed with the conflicting queen")
	check(s.queen_materials[Vector2i(0, 0)].albedo_color == s.COLOR_SAFE, "Safe queen turns gold")

	s.btn_reset.pressed.emit()
	await process_frame
	check(s.queen_nodes.is_empty(), "Reset removes all statues")

	var sol: Array = s.Logic.solve_all()[0]
	for cell in sol:
		s.cell_buttons[cell].pressed.emit()
	await process_frame
	check(s.logic.is_solved, "Full solution solves the puzzle")
	check(s.banner.visible and s.banner_label.text.contains("SOLVED"), "Victory banner shown")
	print("checks failed: ", checks_failed)
	quit(1 if checks_failed > 0 else 0)
