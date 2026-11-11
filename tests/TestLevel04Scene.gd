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

	s.cell_buttons[Vector2i(1, 2)].pressed.emit()
	await create_timer(0.4).timeout
	check(s.logic.visited_count() == 2, "Jump executed")
	check(s.tile_sunk[Vector2i(0, 0)], "Start tile sinks after leaving it")
	check(s.count_label.text.contains("2 / 64"), "Counter updated")
	s.btn_undo.pressed.emit()
	await create_timer(0.4).timeout
	check(s.logic.visited_count() == 1 and not s.tile_sunk[Vector2i(0, 0)], "Undo restores the tile")
	s.btn_reset.pressed.emit()
	await process_frame

	var tour: Array = s.Logic.find_tour()
	for i in range(1, 64):
		s.cell_buttons[tour[i]].pressed.emit()
		await process_frame
	check(s.logic.is_solved, "Full tour solves the puzzle")
	check(s.banner.visible and s.banner_label.text.contains("SOLVED"), "Victory banner shown")
	print("checks failed: ", checks_failed)
	quit(1 if checks_failed > 0 else 0)
