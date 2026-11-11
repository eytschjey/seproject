extends SceneTree

# Plays the full solution through the real UI buttons and checks visuals.
func _init() -> void:
	var s = load("res://scenes/levels/Level01_Tutorial.tscn").instantiate()
	root.add_child(s)
	await process_frame
	var steps = [["G", 1], ["X", 0], ["G", 1], ["X", 0], ["W", 1], ["X", 0], ["W", 1], ["G", 1], ["X", 0], ["G", 1], ["C", 1], ["X", 0], ["C", 1], ["X", 0], ["G", 1], ["X", 0], ["G", 1]]
	# Simplified: load/unload toggles + crosses, per the known solution
	var seq = ["G", "X", "G", "X", "W", "X", "W", "G", "X", "G", "C", "X", "C", "X", "G", "X", "G"]
	var map = {"G": s.btn_goat, "W": s.btn_wolf, "C": s.btn_cabbage, "X": s.btn_cross}
	# Correct sequence: G load, X, G unload, X(back), W load, X, W unload, G load(east), X, G unload, C load, X, C unload, X(back), G load, X, G unload
	var script = ["G","X","G","X","W","X","W","G","X","G","C","X","C","X","G","X","G"]
	for k in script:
		var b: Button = map[k]
		if b.disabled:
			print("BLOCKED at ", k, " (button disabled) state: ", s.logic.item_on_boat, s.logic.west_items, s.logic.east_items)
			quit(1); return
		b.pressed.emit()
		await create_timer(1.6 if k == "X" else 0.5).timeout
		if k == "X" and s.logic.item_on_boat != null:
			var n = s._get_item_node(s.logic.item_on_boat)
			print("riding check: item x=%.2f raft x=%.2f" % [n.global_position.x, s.raft.position.x])
	print("solved=", s.logic.is_solved, " banner=", s.banner_label.text.replace("\n", " "))
	print("final positions: wolf=", s.wolf_node.global_position.x, " goat=", s.goat_node.global_position.x, " cab=", s.cabbage_node.global_position.x)
	quit()
