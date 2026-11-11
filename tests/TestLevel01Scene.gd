extends SceneTree

# Plays the full solution through direct 3D object clicks and checks visuals.
func _init() -> void:
	var s = load("res://scenes/levels/Level01_Tutorial.tscn").instantiate()
	root.add_child(s)
	await process_frame
	
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
				print("BLOCKED at ", k, " (cross button disabled) state: ", s.logic.item_on_boat, s.logic.west_items, s.logic.east_items)
				quit(1)
				return
			# Alternate between clicking the raft in 3D and clicking the button to test both interaction routes
			s.click_raft()
		else:
			var item: int = map[k]
			s.click_item(item)
		
		await create_timer(1.6 if k == "X" else 0.5).timeout
		if k == "X" and s.logic.item_on_boat != null:
			var n = s._get_item_node(s.logic.item_on_boat)
			print("riding check: item x=%.2f raft x=%.2f" % [n.global_position.x, s.raft.position.x])
			
	print("solved=", s.logic.is_solved, " banner=", s.banner_label.text.replace("\n", " "))
	print("final positions: wolf=", s.wolf_node.global_position.x, " goat=", s.goat_node.global_position.x, " cab=", s.cabbage_node.global_position.x)
	quit(0 if s.logic.is_solved else 1)
