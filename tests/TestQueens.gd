extends SceneTree

const Logic = preload("res://scripts/logic/QueensLogic.gd")
const Runner = preload("res://tests/TestRunner.gd")

var t: RefCounted

func assert_test(cond: bool, msg: String) -> void:
	t.check(cond, msg)

func _init() -> void:
	t = Runner.new("TestQueens (Level 3 Logic)")
	test_attacks()
	test_placement()
	test_solutions()
	test_game_flow()
	t.finish(self)

func test_attacks() -> void:
	t.section("Test 1: Attack rules")
	assert_test(Logic.attacks(Vector2i(0, 0), Vector2i(0, 5)), "Same column attacks")
	assert_test(Logic.attacks(Vector2i(1, 3), Vector2i(6, 3)), "Same row attacks")
	assert_test(Logic.attacks(Vector2i(2, 2), Vector2i(5, 5)), "Diagonal attacks")
	assert_test(Logic.attacks(Vector2i(2, 5), Vector2i(4, 3)), "Anti-diagonal attacks")
	assert_test(not Logic.attacks(Vector2i(0, 0), Vector2i(1, 2)), "Knight-move apart is safe")
	assert_test(not Logic.attacks(Vector2i(3, 3), Vector2i(3, 3)), "A queen does not attack itself")

func test_placement() -> void:
	t.section("Test 2: Placement rules")
	var l = Logic.new()
	assert_test(l.place_queen(Vector2i(0, 0)), "Place a queen")
	assert_test(not l.place_queen(Vector2i(0, 0)), "Cannot place on occupied cell")
	assert_test(not l.place_queen(Vector2i(8, 0)) and not l.place_queen(Vector2i(0, -1)), "Out of bounds rejected")
	assert_test(l.place_queen(Vector2i(1, 1)), "Place conflicting queen (allowed)")
	assert_test(l.conflicting_queens().size() == 2, "Both queens reported in conflict")
	assert_test(l.remove_queen(Vector2i(1, 1)), "Remove queen")
	assert_test(l.conflicting_queens().is_empty(), "Conflict cleared after removal")
	assert_test(not l.remove_queen(Vector2i(5, 5)), "Cannot remove from empty cell")
	assert_test(l.toggle_queen(Vector2i(2, 1)) and l.has_queen(Vector2i(2, 1)), "Toggle places")
	assert_test(l.toggle_queen(Vector2i(2, 1)) and not l.has_queen(Vector2i(2, 1)), "Toggle removes")
	l.reset()
	assert_test(l.queens.is_empty(), "Reset clears the board")
	# Max 8 queens: fill with 8 on one row-free layout of conflicts, 9th rejected
	for i in 8:
		l.place_queen(Vector2i(i, 0))
	assert_test(not l.place_queen(Vector2i(0, 1)), "Cannot place a 9th queen")
	assert_test(not l.is_solved, "Eight attacking queens is not a solution")

func test_solutions() -> void:
	t.section("Test 3: Solver")
	var all := Logic.solve_all()
	assert_test(all.size() == 92, "Exactly 92 solutions (found %d)" % all.size())
	var all_valid := true
	for s in all:
		if not Logic.is_valid_solution(s):
			all_valid = false
	assert_test(all_valid, "Every solution is valid")
	assert_test(not Logic.is_valid_solution(all[0].slice(0, 7)), "7 queens is not a full solution")
	var comp := Logic.find_completion([Vector2i(0, 0)])
	assert_test(comp.size() == 8 and Logic.is_valid_solution(comp), "find_completion finds full valid solution extending (0,0)")
	var comp_bad := Logic.find_completion([Vector2i(0, 0), Vector2i(0, 5)])
	assert_test(comp_bad.is_empty(), "find_completion returns empty on conflicting input")

func test_game_flow() -> void:
	t.section("Test 4: Game flow")
	var l = Logic.new()
	var data := {"solved": false, "changes": 0}
	l.puzzle_solved.connect(func(): data.solved = true)
	l.state_changed.connect(func(_q, _c): data.changes += 1)
	var sol: Array = Logic.solve_all()[0]
	for i in 7:
		l.place_queen(sol[i])
	assert_test(not l.is_solved and not data.solved, "Not solved with 7 queens")
	l.place_queen(sol[7])
	assert_test(l.is_solved and data.solved, "Solved with 8 non-attacking queens")
	assert_test(not l.place_queen(Vector2i(0, 0)) and not l.remove_queen(sol[0]), "Board locked after solving")
	assert_test(data.changes == 8, "state_changed emitted per change")
	l.reset()
	assert_test(not l.is_solved and l.queens.is_empty(), "Reset after solving")
