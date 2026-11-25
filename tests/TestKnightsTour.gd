extends SceneTree

const Logic = preload("res://scripts/logic/KnightsTourLogic.gd")
const Runner = preload("res://tests/TestRunner.gd")

var t: RefCounted

func assert_test(cond: bool, msg: String) -> void:
	t.check(cond, msg)

func _init() -> void:
	t = Runner.new("TestKnightsTour (Level 4 Logic)")
	test_moves()
	test_flow()
	test_tour()
	test_dead_end_and_undo()
	t.finish(self)

func test_moves() -> void:
	t.section("Test 1: Knight moves")
	assert_test(Logic.is_knight_move(Vector2i(0, 0), Vector2i(1, 2)), "(0,0)->(1,2) legal")
	assert_test(Logic.is_knight_move(Vector2i(3, 3), Vector2i(1, 4)), "(3,3)->(1,4) legal")
	assert_test(not Logic.is_knight_move(Vector2i(0, 0), Vector2i(2, 2)), "Diagonal illegal")
	assert_test(not Logic.is_knight_move(Vector2i(0, 0), Vector2i(0, 1)), "Orthogonal step illegal")
	assert_test(not Logic.is_knight_move(Vector2i(0, 0), Vector2i(0, 0)), "Staying illegal")
	var l = Logic.new()
	assert_test(l.valid_moves().size() == 2, "Corner start has exactly 2 moves")
	assert_test(l.visited_count() == 1 and l.is_visited(Vector2i(0, 0)), "Start tile counts as visited")

func test_flow() -> void:
	t.section("Test 2: Move handling")
	var l = Logic.new()
	var data := {"rejected": 0}
	l.move_rejected.connect(func(_r): data.rejected += 1)
	assert_test(not l.move_to(Vector2i(1, 1)), "Illegal move rejected")
	assert_test(not l.move_to(Vector2i(9, 9)), "Out-of-bounds rejected")
	assert_test(l.move_to(Vector2i(1, 2)), "Legal move accepted")
	assert_test(l.current == Vector2i(1, 2) and l.visited_count() == 2, "State updated")
	assert_test(l.move_to(Vector2i(0, 0)) == false, "Cannot revisit a tile")
	assert_test(data.rejected == 3, "move_rejected emitted for each rejection")
	assert_test(l.undo() and l.current == Vector2i(0, 0), "Undo steps back")
	assert_test(not l.undo(), "Cannot undo the start")
	l.move_to(Vector2i(2, 1))
	l.reset()
	assert_test(l.path.size() == 1 and l.current == Logic.START, "Reset restores the start")

func test_tour() -> void:
	t.section("Test 3: Full tour")
	var tour := Logic.find_tour()
	assert_test(tour.size() == 64, "Solver found a 64-tile tour")
	assert_test(Logic.is_valid_tour(tour), "Tour is valid")
	assert_test(tour[0] == Logic.START, "Tour starts at (0,0)")
	var l = Logic.new()
	var data := {"solved": false}
	l.puzzle_solved.connect(func(): data.solved = true)
	for i in range(1, 63):
		l.move_to(tour[i])
	assert_test(not l.is_solved, "Not solved after 63 tiles")
	l.move_to(tour[63])
	assert_test(l.is_solved and data.solved, "Solved on the 64th tile")
	assert_test(not l.move_to(Vector2i(0, 0)) and not l.undo(), "Board locked after solving")
	var bad := tour.duplicate()
	bad[10] = bad[11]
	assert_test(not Logic.is_valid_tour(bad), "Duplicate tile makes a tour invalid")

func test_dead_end_and_undo() -> void:
	t.section("Test 4: Dead end")
	# Corner (0,0): jump to (1,2),(2,1) etc. Build a dead end: go (0,0)->(1,2)->(0,4)->(1,6)->(0,... ) is
	# hard to force, so search for any dead-end path from the start by depth-first walking.
	var l = Logic.new()
	var data := {"failed": ""}
	l.puzzle_failed.connect(func(r): data.failed = r)
	while not l.is_failed:
		var moves := l.valid_moves()
		# Walk greedily toward the MOST connected tiles (worst heuristic) until stuck.
		moves.sort_custom(func(a, b): return Logic.moves_from(a, l.path).size() > Logic.moves_from(b, l.path).size())
		l.move_to(moves[0])
	assert_test(l.is_failed and data.failed == "Dead end!", "Dead end fails the puzzle")
	assert_test(not l.move_to(Vector2i(7, 7)), "No moves after failure")
	var before := l.visited_count()
	assert_test(l.undo() and not l.is_failed and l.visited_count() == before - 1, "Undo recovers from a dead end")
