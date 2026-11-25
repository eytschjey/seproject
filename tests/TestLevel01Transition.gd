extends SceneTree

# Solves Level 1 through the logic and checks that the game auto-advances to Level 2.
const Runner = preload("res://tests/TestRunner.gd")

func _init() -> void:
	var t = Runner.new("TestLevel01Transition (Level 1 -> Level 2)")
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
	var delay: float = s.NEXT_LEVEL_DELAY
	t.check(s.logic.is_solved, "Level 1 solved via optimal sequence")
	await create_timer(delay + 1.0).timeout
	var name_now: String = current_scene.name if current_scene else ""
	t.check(name_now == "Level02_NinePortals", "Auto-advances to Level02_NinePortals after delay")
	t.finish(self)
