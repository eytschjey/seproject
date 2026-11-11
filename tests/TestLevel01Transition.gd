extends SceneTree

# Solves Level 1 through the logic and checks that the game auto-advances to Level 2.
func _init() -> void:
	var s = load("res://scenes/levels/Level01_Tutorial.tscn").instantiate()
	root.add_child(s)
	current_scene = s
	await process_frame
	var Item = s.Logic.Item
	var steps = [
		[Item.GOAT, true], [null, false], [Item.GOAT, true], [null, false],
		[Item.WOLF, true], [null, false], [Item.WOLF, true], [Item.GOAT, true],
		[null, false], [Item.GOAT, true], [Item.CABBAGE, true], [null, false],
		[Item.CABBAGE, true], [null, false], [Item.GOAT, true], [null, false], [Item.GOAT, true]]
	for st in steps:
		if st[0] == null:
			s.logic.cross_river()
		elif s.logic.item_on_boat == st[0]:
			s.logic.unload_item()
		else:
			s.logic.load_item(st[0])
	var solved: bool = s.logic.is_solved
	var delay: float = s.NEXT_LEVEL_DELAY
	print("level 1 solved: ", solved)
	await create_timer(delay + 1.0).timeout
	var name_now: String = current_scene.name if current_scene else ""
	print("current scene: ", name_now)
	var ok: bool = solved and name_now == "Level02_NinePortals"
	print("PASS" if ok else "FAIL")
	quit(0 if ok else 1)
