extends SceneTree

# Plays Level 5 through the real HUD buttons: clue inspection, false accusation, reset, and auto-solver victory.
var checks_failed: int = 0

func check(cond: bool, msg: String) -> void:
	print(("  PASS: " if cond else "  FAIL: ") + msg)
	if not cond:
		checks_failed += 1

func _init() -> void:
	var s = load("res://scenes/levels/Level05_DreadburyManor.tscn").instantiate()
	root.add_child(s)
	await process_frame

	check(s.clue_buttons.size() == 8 and s.clue_nodes.size() == 8, "8 clue buttons and 8 3D clue nodes created")
	check(s.suspect_buttons.size() == 3 and s.bust_nodes.size() == 3, "3 suspect buttons and 3 3D busts created")
	check(s.btn_accuse.disabled, "Accuse button disabled before selecting a suspect")

	# Inspect Clue 1
	s.clue_buttons[0].pressed.emit()
	await process_frame
	check(s.logic.is_clue_discovered(0), "Clue 1 marked as discovered")
	check(s.clue_label.text.contains("Coroner's Journal"), "Clue panel displays inspected clue details")
	check(s.clue_count_label.text.contains("1 / 8"), "Clue counter updated to 1 / 8")

	# Select Charles and make a false accusation
	s.suspect_buttons[2].pressed.emit()
	await process_frame
	check(not s.btn_accuse.disabled, "Accuse button enabled after selecting a suspect")
	s.btn_accuse.pressed.emit()
	await process_frame
	check(s.logic.is_failed, "Accusing Charles fails the puzzle")
	check(s.banner.visible and s.banner_label.text.contains("Contradiction"), "Failure banner displays logical contradiction")
	check(s.btn_accuse.disabled, "Accuse button disabled after failure")

	# Reset
	s.btn_reset.pressed.emit()
	await process_frame
	check(not s.logic.is_failed and not s.banner.visible and s.logic.discovered_count() == 0, "Reset clears failure and clue progress")

	# Test Auto-Solver (pause and resume)
	check(s.btn_solve != null and not s.btn_solve.disabled, "Auto-solve button exists and enabled")
	s.auto_solve_delay = 0.01
	s.btn_solve.pressed.emit()
	await create_timer(0.035).timeout
	check(s.is_auto_solving and s.logic.discovered_count() > 0, "Auto-solver inspects clues automatically")
	s.btn_solve.pressed.emit() # Pause
	await process_frame
	check(not s.is_auto_solving, "Auto-solver stops when toggled")

	# Resume to finish solving
	s.btn_solve.pressed.emit()
	while not s.logic.is_solved and s.is_auto_solving:
		await process_frame
	check(s.logic.is_solved and s.logic.all_clues_discovered(), "Auto-solver examines all clues and solves the mystery")
	check(s.suicide_note.visible, "Hidden suicide note 3D prop is revealed on victory")
	check(s.banner.visible and s.banner_label.text.contains("MYSTERY SOLVED"), "Victory banner shown")
	check(s.btn_solve.disabled, "Solve button disabled after puzzle is solved")

	print("checks failed: ", checks_failed)
	quit(1 if checks_failed > 0 else 0)
