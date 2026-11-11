extends SceneTree

# Plays Level 4 through the real HUD buttons: illegal-looking cells are disabled, a full tour solves it.
var checks_failed: int = 0

func check(cond: bool, msg: String) -> void:
	print(("  PASS: " if cond else "  FAIL: ") + msg)
	if not cond:
		checks_failed += 1

func _init() -> void:
	var s = load("res://scenes/levels/Level04_KnightsChasm.tscn").instantiate()
	root.add_child(s)
	await process_frame
	check(s.cell_buttons.size() == 64 and s.tile_nodes.size() == 64, "64 buttons and 64 tiles created")
	check(s.cell_buttons[Vector2i(1, 1)].disabled, "Non-knight cell is disabled")
	check(not s.cell_buttons[Vector2i(1, 2)].disabled, "Knight-move cell is enabled")
	check(s.cell_buttons[Vector2i(0, 0)].get_theme_stylebox("disabled") == s.style_cell_current, "Start cell uses high-contrast gold current style")
	check(s.cell_buttons[Vector2i(1, 2)].get_theme_stylebox("normal") == s.style_cell_valid, "Valid knight-move cell uses high-contrast cyan style")

	s.cell_buttons[Vector2i(1, 2)].pressed.emit()
	await create_timer(0.4).timeout
	check(s.logic.visited_count() == 2, "Jump executed")
	check(s.tile_sunk[Vector2i(0, 0)], "Start tile sinks after leaving it")
	check(s.cell_buttons[Vector2i(0, 0)].get_theme_stylebox("disabled") == s.style_cell_visited, "Visited cell uses high-contrast teal style")
	check(s.count_label.text.contains("2 / 64"), "Counter updated")
	s.btn_undo.pressed.emit()
	await create_timer(0.4).timeout
	check(s.logic.visited_count() == 1 and not s.tile_sunk[Vector2i(0, 0)], "Undo restores the tile")
	s.btn_reset.pressed.emit()
	await process_frame

	check(s.btn_solve != null and not s.btn_solve.disabled, "Auto-solve button exists and enabled")
	s.auto_solve_delay = 0.005
	s.btn_solve.pressed.emit()
	await create_timer(0.05).timeout
	check(s.is_auto_solving and s.logic.visited_count() > 1, "Auto-solver makes moves automatically")
	s.btn_solve.pressed.emit() # Stop it
	await process_frame
	check(not s.is_auto_solving, "Auto-solver stops when toggled")
	var paused_count: int = s.logic.visited_count()
	await create_timer(0.05).timeout
	check(s.logic.visited_count() == paused_count, "Knight pauses when solver is stopped")

	# Resume solver to complete the tour
	s.btn_solve.pressed.emit()
	while not s.logic.is_solved and s.is_auto_solving:
		await process_frame
	check(s.logic.is_solved, "Auto-solver completed full tour")
	check(s.banner.visible and s.banner_label.text.contains("SOLVED"), "Victory banner shown")
	check(s.btn_solve.disabled, "Solve button disabled after puzzle is solved")
	print("checks failed: ", checks_failed)
	quit(1 if checks_failed > 0 else 0)
