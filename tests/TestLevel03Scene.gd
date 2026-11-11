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

	check(s.btn_solve != null and not s.btn_solve.disabled, "Auto-solve button exists and enabled")
	s.auto_solve_delay = 0.005
	s.btn_solve.pressed.emit()
	await create_timer(0.02).timeout
	check(s.is_auto_solving and s.logic.queens.size() > 0, "Auto-solver places queens automatically")
	s.btn_solve.pressed.emit() # Stop it
	await process_frame
	check(not s.is_auto_solving, "Auto-solver stops when toggled")
	var paused_count: int = s.logic.queens.size()
	await create_timer(0.02).timeout
	check(s.logic.queens.size() == paused_count, "Placements pause when solver is stopped")

	# Resume solver to complete 8 queens
	s.btn_solve.pressed.emit()
	while not s.logic.is_solved and s.is_auto_solving:
		await process_frame
	check(s.logic.is_solved, "Auto-solver completed 8-queens solution")
	check(s.banner.visible and s.banner_label.text.contains("SOLVED"), "Victory banner shown")
	check(s.btn_solve.disabled, "Solve button disabled after puzzle is solved")
	print("checks failed: ", checks_failed)
	quit(1 if checks_failed > 0 else 0)
