extends SceneTree

const Logic = preload("res://scripts/logic/RiverCrossingLogic.gd")

var total_assertions: int = 0
var failed_assertions: int = 0

func _init() -> void:
	print("==================================================")
	print("🧪 Running River Crossing Logic Verification Tests")
	print("==================================================")
	
	test_initial_state()
	test_illegal_move_wolf_eats_goat()
	test_illegal_move_goat_eats_cabbage()
	test_valid_solution_path()
	test_reset()
	test_find_solution()
	
	print("==================================================")
	if failed_assertions == 0:
		print("🎉 ALL %d ASSERTIONS PASSED SUCCESSFULLY!" % total_assertions)
		print("==================================================")
		quit(0)
	else:
		push_error("❌ %d ASSERTION(S) FAILED!" % failed_assertions)
		print("==================================================")
		quit(1)

func assert_test(condition: bool, message: String) -> void:
	total_assertions += 1
	if not condition:
		failed_assertions += 1
		push_error("  ❌ FAILED: " + message)
	else:
		print("  ✔ " + message)

func test_initial_state() -> void:
	print("\n[Test 1: Initial State]")
	var logic = Logic.new()
	assert_test(logic.boat_side == Logic.Side.WEST, "Boat starts on West shore")
	assert_test(logic.item_on_boat == null, "Boat starts empty")
	assert_test(logic.west_items.size() == 3, "West shore has all 3 items")
	assert_test(logic.east_items.is_empty(), "East shore is empty")
	assert_test(not logic.is_solved, "Puzzle is not solved yet")
	assert_test(not logic.is_failed, "Puzzle is not in fail state")

func test_illegal_move_wolf_eats_goat() -> void:
	print("\n[Test 2: Leaving Wolf & Goat Alone on Shore]")
	var logic = Logic.new()
	var signal_data = { "emitted": false, "reason": "" }
	logic.puzzle_failed.connect(func(reason: String):
		signal_data.emitted = true
		signal_data.reason = reason
	)
	
	# Taking cabbage to East leaves Wolf + Goat together on West
	assert_test(logic.load_item(Logic.Item.CABBAGE), "Loaded cabbage onto boat")
	var cross_ok = logic.cross_river()
	assert_test(not cross_ok, "Crossing is prevented due to predatory hazard")
	assert_test(logic.is_failed, "Logic state marked as failed")
	assert_test(signal_data.emitted, "puzzle_failed signal was emitted")
	assert_test("wolf ate the goat" in signal_data.reason.to_lower(), "Reason: %s" % signal_data.reason)

func test_illegal_move_goat_eats_cabbage() -> void:
	print("\n[Test 3: Leaving Goat & Cabbage Alone on Shore]")
	var logic = Logic.new()
	var signal_data = { "emitted": false, "reason": "" }
	logic.puzzle_failed.connect(func(reason: String):
		signal_data.emitted = true
		signal_data.reason = reason
	)
	
	# Taking wolf to East leaves Goat + Cabbage together on West
	assert_test(logic.load_item(Logic.Item.WOLF), "Loaded wolf onto boat")
	var cross_ok = logic.cross_river()
	assert_test(not cross_ok, "Crossing is prevented due to herbivore hazard")
	assert_test(logic.is_failed, "Logic state marked as failed")
	assert_test(signal_data.emitted, "puzzle_failed signal was emitted")
	assert_test("goat ate the cabbage" in signal_data.reason.to_lower(), "Reason: %s" % signal_data.reason)

func test_valid_solution_path() -> void:
	print("\n[Test 4: Full Valid Solution Sequence]")
	var logic = Logic.new()
	var solved_data = { "emitted": false }
	logic.puzzle_solved.connect(func(): solved_data.emitted = true)
	
	# 1. Take Goat across to East
	assert_test(logic.load_item(Logic.Item.GOAT), "1. Load Goat")
	assert_test(logic.cross_river(), "1. Cross to East")
	assert_test(logic.unload_item(), "1. Unload Goat on East")
	
	# 2. Return alone to West
	assert_test(logic.cross_river(), "2. Return alone to West")
	
	# 3. Take Wolf to East
	assert_test(logic.load_item(Logic.Item.WOLF), "3. Load Wolf")
	assert_test(logic.cross_river(), "3. Cross to East with Wolf")
	assert_test(logic.unload_item(), "3. Unload Wolf on East")
	
	# 4. Bring Goat back to West (avoids leaving Wolf & Goat together on East)
	assert_test(logic.load_item(Logic.Item.GOAT), "4. Load Goat on East")
	assert_test(logic.cross_river(), "4. Return with Goat to West")
	assert_test(logic.unload_item(), "4. Unload Goat on West")
	
	# 5. Take Cabbage to East (leaves Goat alone on West)
	assert_test(logic.load_item(Logic.Item.CABBAGE), "5. Load Cabbage")
	assert_test(logic.cross_river(), "5. Cross to East with Cabbage")
	assert_test(logic.unload_item(), "5. Unload Cabbage on East")
	
	# 6. Return alone to West
	assert_test(logic.cross_river(), "6. Return alone to West")
	
	# 7. Take Goat across to East
	assert_test(logic.load_item(Logic.Item.GOAT), "7. Load Goat on West")
	assert_test(logic.cross_river(), "7. Cross to East with Goat")
	assert_test(logic.unload_item(), "7. Unload Goat on East")
	
	assert_test(logic.is_solved, "Logic state confirms solved")
	assert_test(solved_data.emitted, "puzzle_solved signal emitted")
	assert_test(logic.east_items.size() == 3, "All 3 items now reside on East shore")
	assert_test(logic.west_items.is_empty(), "West shore is empty")

func test_reset() -> void:
	print("\n[Test 5: Reset Functionality]")
	var logic = Logic.new()
	# Cause fail
	logic.load_item(Logic.Item.CABBAGE)
	logic.cross_river()
	assert_test(logic.is_failed, "Put in fail state")
	
	logic.reset()
	assert_test(not logic.is_failed, "is_failed reset to false")
	assert_test(logic.west_items.size() == 3, "West items restored")
	assert_test(logic.boat_side == Logic.Side.WEST, "Boat restored to West")

func test_find_solution() -> void:
	print("\n[Test 6: BFS Auto-Solver]")
	var logic = Logic.new()
	var path: Array[Dictionary] = logic.find_solution()
	assert_test(path.size() == 17, "find_solution finds optimal 17-step sequence")
	
	for step in path:
		if step.type == "load":
			logic.load_item(step.item)
		elif step.type == "unload":
			logic.unload_item()
		elif step.type == "cross":
			logic.cross_river()
	
	assert_test(logic.is_solved, "Applying BFS steps solves the puzzle")
	assert_test(logic.find_solution().is_empty(), "find_solution on solved state returns empty")
	
	# Test from partial state
	logic.reset()
	logic.load_item(Logic.Item.GOAT)
	logic.cross_river()
	var partial_path = logic.find_solution()
	assert_test(partial_path.size() == 15, "find_solution finds remaining steps from partial state")
	for step in partial_path:
		if step.type == "load":
			logic.load_item(step.item)
		elif step.type == "unload":
			logic.unload_item()
		elif step.type == "cross":
			logic.cross_river()
	assert_test(logic.is_solved, "Applying partial steps solves the puzzle")
