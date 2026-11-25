extends SceneTree

# Headless integration test for PBI-11: Bonus Chamber — The Midnight Bridge (Level07_MidnightBridge.tscn).

var checks_failed: int = 0

func check(cond: bool, msg: String) -> void:
	print(("  PASS: " if cond else "  FAIL: ") + msg)
	if not cond:
		checks_failed += 1

func _init() -> void:
	var s = load("res://scenes/levels/Level07_MidnightBridge.tscn").instantiate()
	root.add_child(s)
	s.crossing_tween_duration = 0.01
	s.auto_solve_delay = 0.01
	await physics_frame
	await physics_frame

	check(s.traveler_nodes.size() == 4 and s.traveler_buttons.size() == 4, "4 travelers and 4 HUD buttons created")
	check(s.btn_cross.disabled and s.btn_undo.disabled, "Cross and Undo disabled initially")
	check(s.torch_timer_label.text.contains("15:00"), "Torch timer displays initial 15:00 remaining")
	check(s.torch_flame.visible and s.torch_light.light_energy > 0.0, "Torch flame and light active initially")

	# Direct 3D screen click selects Ariela (0), HUD button selects Dumpy (3)
	var ariela_screen: Vector2 = s.camera.unproject_position(s.traveler_nodes[0].global_position + Vector3(0, 0.8, 0))
	s._handle_screen_click(ariela_screen)
	s.traveler_buttons[3].pressed.emit()
	await process_frame
	check(0 in s.selected_travelers and 3 in s.selected_travelers, "3D click and HUD button select crossing pair")
	check(not s.btn_cross.disabled and s.btn_cross.text.contains("+8 min"), "Cross button displays slower traveler cost (+8 min)")

	# Cross Ariela + Dumpy (8m), return Ariela (9m), cross Ariela + Charly (14m), return Ariela (15m), cross Ariela + Brian (17m -> burnout!)
	s.btn_cross.pressed.emit()
	while s.is_animating:
		await process_frame
	check(s.logic.elapsed_minutes == 8 and s.logic.torch_side == s.Logic.Side.EAST, "Crossing advances torch to East and adds 8 minutes")

	s.traveler_buttons[0].pressed.emit()
	s.btn_cross.pressed.emit()
	while s.is_animating:
		await process_frame
	s.traveler_buttons[0].pressed.emit()
	s.traveler_buttons[2].pressed.emit()
	s.btn_cross.pressed.emit()
	while s.is_animating:
		await process_frame
	s.traveler_buttons[0].pressed.emit()
	s.btn_cross.pressed.emit()
	while s.is_animating:
		await process_frame
	s.traveler_buttons[0].pressed.emit()
	s.traveler_buttons[1].pressed.emit()
	s.btn_cross.pressed.emit()
	while s.is_animating:
		await process_frame

	check(s.logic.is_failed, "Naive 17-minute sequence burns out torch")
	check(s.banner.visible and s.banner_label.text.contains("TORCH BURNED OUT"), "Torch burnout banner shown")
	await process_frame
	check(not s.torch_flame.visible and s.torch_light.light_energy == 0.0, "Torch flame extinguishes on burnout")

	# Undo recovers cleanly
	s.btn_undo.pressed.emit()
	await process_frame
	check(not s.logic.is_failed and not s.banner.visible and s.logic.elapsed_minutes == 15, "Undo recovers from torch burnout")

	# Reset & Auto-Solve (pause + resume)
	s.btn_reset.pressed.emit()
	await process_frame
	check(s.logic.elapsed_minutes == 0 and s.logic.west_travelers.size() == 4, "Reset returns all travelers to West cliff")

	s.btn_solve.pressed.emit()
	await create_timer(0.05).timeout
	check(s.is_auto_solving, "Auto-solver starts")
	s.btn_solve.pressed.emit()
	await process_frame
	check(not s.is_auto_solving, "Auto-solver pauses when toggled")

	s.btn_solve.pressed.emit()
	while not s.logic.is_solved and (s.is_auto_solving or s.is_animating):
		await process_frame
	check(s.logic.is_solved and s.logic.elapsed_minutes == 15, "Auto-solver completes Midnight Bridge in exactly 15 minutes")
	check(s.banner.visible and s.banner_label.text.contains("BONUS CHAMBER CLEARED"), "Victory banner displayed")
	check(s.btn_solve.disabled, "Auto-solve disabled after victory")

	print("checks failed: ", checks_failed)
	quit(1 if checks_failed > 0 else 0)
