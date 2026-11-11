extends SceneTree

# Menu lists all levels, playable ones are enabled, and pressing one loads its scene.
func _init() -> void:
	var m = load("res://scenes/ui/MainMenu.tscn").instantiate()
	root.add_child(m)
	current_scene = m
	await process_frame
	var ok := true
	ok = ok and m.level_buttons.size() == m.LEVELS.size()
	ok = ok and not m.level_buttons[0].disabled and not m.level_buttons[1].disabled
	ok = ok and not m.level_buttons[2].disabled and not m.level_buttons[3].disabled and not m.level_buttons[4].disabled and not m.level_buttons[5].disabled
	print("buttons ok: ", ok)
	m.level_buttons[1].pressed.emit()
	await create_timer(0.5).timeout
	var name_now: String = current_scene.name if current_scene else ""
	print("current scene: ", name_now)
	ok = ok and name_now == "Level02_NinePortals"
	# Back button returns to the menu
	var back: Button = null
	for c in current_scene.get_node("UI/RootControl").get_children():
		if c is BackToMenuButton:
			back = c
	ok = ok and back != null
	if back:
		back.pressed.emit()
		await create_timer(0.5).timeout
		ok = ok and current_scene.name == "MainMenu"
	print("PASS" if ok else "FAIL")
	quit(0 if ok else 1)
