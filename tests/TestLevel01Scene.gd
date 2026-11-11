extends SceneTree

var checks_failed: int = 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error("  FAIL: " + message)
		checks_failed += 1
	else:
		print("  PASS: " + message)

# Plays the full solution through direct 3D object clicks, checks visuals, and verifies auto-solver.
func _init() -> void:
	var s = load("res://scenes/levels/Level01_Tutorial.tscn").instantiate()
	root.add_child(s)
	await process_frame
	
	# Verify auto-solve button exists and can be toggled
	check(s.btn_solve != null and not s.btn_solve.disabled, "Auto-solve button exists and enabled")
	
	s.auto_solve_delay = 0.005
	s.raft_tween_duration = 0.01
	s.btn_solve.pressed.emit()
	check(s.is_auto_solving, "Auto-solver activates")
	check(s.btn_solve.text == "Stop Solver", "Button says Stop Solver")
	
	await create_timer(0.02).timeout
	s.btn_solve.pressed.emit()
	check(not s.is_auto_solving, "Auto-solver stops when toggled")
	check(s.btn_solve.text == "Auto-Solve (Debug)", "Button restores label")
	
	s._on_reset_pressed()
	await process_frame
	
	# Test auto-solve from clean state to completion
	s.btn_solve.pressed.emit()
	while not s.logic.is_solved and s.is_auto_solving:
		await process_frame
	check(s.logic.is_solved, "Auto-solver completed full river crossing")
	check(s.banner.visible and s.banner_label.text.contains("SOLVED"), "Victory banner shown")
	check(s.btn_solve.disabled, "Solve button disabled after puzzle is solved")
	
	# Reset and test manual 3D clicks sequence
	s._on_reset_pressed()
	await process_frame
	check(not s.logic.is_solved, "Reset restores unsolved state")
	
	var Item = s.Logic.Item
	var map = {
		"G": Item.GOAT,
		"W": Item.WOLF,
		"C": Item.CABBAGE,
		"X": "CROSS"
	}
	# Correct sequence: G load, X, G unload, X(back), W load, X, W unload, G load(east), X, G unload, C load, X, C unload, X(back), G load, X, G unload
	var script = ["G","X","G","X","W","X","W","G","X","G","C","X","C","X","G","X","G"]
	for k in script:
		if k == "X":
			if s.btn_cross.disabled:
				check(false, "Cross button not disabled at step X")
				quit(1)
				return
			s.click_raft()
		else:
			var item: int = map[k]
			s.click_item(item)
		
		# Short waits since raft_tween_duration is 0.01 in this test
		await create_timer(0.04).timeout
	
	check(s.logic.is_solved, "Manual sequence completed puzzle successfully")
	check(s.east_wolf_pos != null and s.wolf_node.global_position.x > 0, "Passengers landed on East shore")
	
	print("checks failed: ", checks_failed)
	quit(1 if checks_failed > 0 else 0)
