extends SceneTree

const Logic = preload("res://scripts/logic/NinePortalsLogic.gd")

var passed: int = 0
var failed: int = 0

func assert_test(cond: bool, msg: String) -> void:
	if cond:
		passed += 1
		print("  PASS: ", msg)
	else:
		failed += 1
		print("  FAIL: ", msg)

func _init() -> void:
	test_consistency()
	test_solution_uniqueness()
	test_game_flow()
	print("\n==== %d passed, %d failed ====" % [passed, failed])
	quit(1 if failed > 0 else 0)

func test_consistency() -> void:
	print("\n[Test 1: Protocol consistency]")
	var layout: Array[int] = Logic.DEFAULT_LAYOUT
	assert_test(Logic.is_consistent(layout), "Default layout is consistent")
	assert_test(layout[4] == Logic.Content.PRINCESS, "Default layout: princess in Room 5")
	var truths := Logic.truth_values(layout)
	assert_test(truths[4], "Room 5 inscription true (princess)")
	assert_test(not truths[2], "Room 3 inscription false (self-contradicting tiger claim)")

	var no_princess: Array[int] = [1, 1, 0, 1, 1, 1, 1, 1, 1]
	assert_test(not Logic.is_consistent(no_princess), "Rejects layout without princess")
	var two_princess: Array[int] = [1, 1, 0, 1, 2, 1, 1, 1, 2]
	assert_test(not Logic.is_consistent(two_princess), "Rejects layout with two princesses")
	var tiger_in_5: Array[int] = [1, 1, 0, 1, 1, 1, 1, 1, 2]
	assert_test(not Logic.is_consistent(tiger_in_5), "Rejects wrong princess room")
	var tiger_true: Array[int] = [1, 2, 0, 1, 1, 1, 1, 1, 1]
	assert_test(not Logic.is_consistent(tiger_true), "Rejects princess behind false sign")
	var short: Array[int] = [1, 1]
	assert_test(not Logic.is_consistent(short), "Rejects wrong-sized layout")

func test_solution_uniqueness() -> void:
	print("\n[Test 2: Princess is uniquely determined]")
	var all := Logic.enumerate_consistent()
	assert_test(all.size() > 0, "At least one consistent layout (%d found)" % all.size())
	var always_5 := true
	for l in all:
		if l[4] != Logic.Content.PRINCESS:
			always_5 = false
	assert_test(always_5, "Every canonical consistent layout has the princess in Room 5")
	assert_test(Logic.princess_candidates() == [5], "princess_candidates() == [5] for canonical roles")
	var always_tiger := true
	for i in [1]:
		for l in all:
			if l[i] != Logic.Content.TIGER:
				always_tiger = false
	assert_test(always_tiger, "Room 2 is a tiger in every canonical consistent layout")

	var logic = Logic.new()
	assert_test(Logic.is_consistent(logic.contents, logic.roles), "Random initial layout is consistent with its inscriptions")
	assert_test(Logic.princess_candidates(logic.roles) == [logic.princess_room()], "Random layout uniquely determines the Princess's room")
	var prev_roles: Array[int] = logic.roles.duplicate()
	logic.reset()
	assert_test(logic.roles != prev_roles, "Reset randomizes to a new layout")
	assert_test(Logic.is_consistent(logic.contents, logic.roles), "Reset layout is consistent with its updated inscriptions")
	assert_test(Logic.princess_candidates(logic.roles) == [logic.princess_room()], "Reset layout uniquely determines the Princess's room")

func test_game_flow() -> void:
	print("\n[Test 3: Game flow]")
	var logic = Logic.new()
	var data := {"failed": "", "solved": false, "opened": 0}
	logic.puzzle_failed.connect(func(r): data.failed = r)
	logic.puzzle_solved.connect(func(): data.solved = true)
	logic.door_opened.connect(func(_r, _c): data.opened += 1)

	var empty_rm: int = logic.empty_room()
	var tiger_rm: int = logic.tiger_room()
	var princess_rm: int = logic.princess_room()
	assert_test(not logic.open_door(0) and not logic.open_door(10), "Invalid rooms rejected")
	assert_test(logic.open_door(empty_rm), "Open empty room")
	assert_test(not logic.is_failed and not logic.is_solved, "Empty room does not end the game")
	assert_test(not logic.open_door(empty_rm), "Cannot reopen a door")
	assert_test(logic.open_door(tiger_rm), "Open tiger room")
	assert_test(logic.is_failed and data.failed == "You failed!", "Tiger fails the puzzle")
	assert_test(not logic.open_door(princess_rm), "No moves after failure")
	logic.reset()
	assert_test(not logic.is_failed and not logic.opened[tiger_rm - 1], "Reset clears fail state and doors")
	var new_princess_rm: int = logic.princess_room()
	var other_tiger_rm: int = logic.tiger_room()
	assert_test(logic.open_door(new_princess_rm), "Open Princess room")
	assert_test(logic.is_solved and data.solved, "Princess solves the puzzle")
	assert_test(not logic.open_door(other_tiger_rm), "No moves after victory")
	assert_test(data.opened == 3, "door_opened emitted for each opened door")
