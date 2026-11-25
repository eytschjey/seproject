extends SceneTree

# Menu lists all levels, playable ones are enabled, and pressing one loads its scene.
const Runner = preload("res://tests/TestRunner.gd")

func _init() -> void:
	var t = Runner.new("TestMainMenu (Level Select & Navigation)")
	var m = load("res://scenes/ui/MainMenu.tscn").instantiate()
	root.add_child(m)
	current_scene = m
	await process_frame

	t.check(m.level_buttons.size() == m.LEVELS.size(), "Main menu creates one button per configured level")
	var all_enabled := true
	for b in m.level_buttons:
		if b.disabled:
			all_enabled = false
	t.check(all_enabled, "All configured playable level buttons are enabled")

	m.level_buttons[1].pressed.emit()
	await create_timer(0.5).timeout
	var name_now: String = current_scene.name if current_scene else ""
	t.check(name_now == "Level02_NinePortals", "Clicking Level 2 button loads Level02_NinePortals")

	# Back button returns to the menu
	var back: Button = null
	for c in current_scene.get_node("UI/RootControl").get_children():
		if c is BackToMenuButton:
			back = c
	t.check(back != null, "BackToMenuButton is attached to loaded level")
	if back:
		back.pressed.emit()
		await create_timer(0.5).timeout
		t.check(current_scene.name == "MainMenu", "Clicking BackToMenuButton returns to MainMenu")

	t.finish(self)
