extends SceneTree

# Headless unit test suite for MidnightBridgeLogic (PBI-10: The Midnight Bridge / Bridge & Torch).

const Logic = preload("res://scripts/logic/MidnightBridgeLogic.gd")
const Runner = preload("res://tests/TestRunner.gd")

var t: RefCounted

func check(cond: bool, msg: String) -> void:
	t.check(cond, msg)

func _init() -> void:
	t = Runner.new("TestMidnightBridge (Bonus Logic)")
	_test_initial_state()
	_test_validation_and_rejections()
	_test_optimal_15_minute_solution()
	_test_torch_burnout_and_undo()
	_test_dijkstra_solver_from_start_and_midgame()
	t.finish(self)

func _test_initial_state() -> void:
	var m = Logic.new()
	check(m.torch_side == Logic.Side.WEST, "Torch starts on West side")
	check(m.west_travelers.size() == 4 and m.east_travelers.is_empty(), "All 4 travelers start on West side")
	check(m.elapsed_minutes == 0 and m.remaining_minutes() == 15, "Starts at 0 elapsed / 15 remaining minutes")
	check(not m.is_solved and not m.is_failed, "Not solved or failed initially")
	check(Logic.group_cost([Logic.Traveler.ARIELA, Logic.Traveler.DUMPY]) == 8, "Pair crossing cost equals slower traveler")

func _test_validation_and_rejections() -> void:
	var m = Logic.new()
	var rejected := {"count": 0, "reason": ""}
	m.move_rejected.connect(func(r: String):
		rejected["count"] += 1
		rejected["reason"] = r
	)

	check(not m.cross([]), "Rejects empty crossing group")
	check(not m.cross([Logic.Traveler.ARIELA, Logic.Traveler.BRIAN, Logic.Traveler.CHARLY]), "Rejects more than 2 travelers")
	check(not m.cross([Logic.Traveler.ARIELA, Logic.Traveler.ARIELA]), "Rejects duplicate traveler")
	check(not m.cross([99]), "Rejects invalid traveler ID")
	check(rejected["count"] == 4, "move_rejected emitted for every invalid attempt")

	# Move Ariela to East, then try to cross Brian (who is still on West) while torch is on East
	check(m.cross([Logic.Traveler.ARIELA]), "Single traveler can cross with torch")
	check(m.torch_side == Logic.Side.EAST and m.elapsed_minutes == 1, "Torch moves to East and adds 1 minute")
	check(not m.can_cross([Logic.Traveler.BRIAN]), "Cannot cross traveler on opposite side from torch")
	check(not m.cross([Logic.Traveler.BRIAN]), "Crossing traveler without torch fails")

func _test_optimal_15_minute_solution() -> void:
	var m = Logic.new()
	var solved := {"flag": false}
	m.puzzle_solved.connect(func(): solved["flag"] = true)

	check(m.cross([Logic.Traveler.ARIELA, Logic.Traveler.BRIAN]), "Step 1: Ariela & Brian West -> East (+2m)")
	check(m.elapsed_minutes == 2, "Elapsed is 2 min")
	check(m.cross([Logic.Traveler.ARIELA]), "Step 2: Ariela East -> West (+1m)")
	check(m.elapsed_minutes == 3, "Elapsed is 3 min")
	check(m.cross([Logic.Traveler.CHARLY, Logic.Traveler.DUMPY]), "Step 3: Charly & Dumpy West -> East (+8m)")
	check(m.elapsed_minutes == 11, "Elapsed is 11 min")
	check(m.cross([Logic.Traveler.BRIAN]), "Step 4: Brian East -> West (+2m)")
	check(m.elapsed_minutes == 13, "Elapsed is 13 min")
	check(m.cross([Logic.Traveler.ARIELA, Logic.Traveler.BRIAN]), "Step 5: Ariela & Brian West -> East (+2m)")
	check(m.elapsed_minutes == 15 and m.remaining_minutes() == 0, "Total elapsed is strictly 15 min")
	check(m.is_solved and solved["flag"], "Puzzle solved at 15 min and puzzle_solved emitted")
	check(not m.undo(), "Cannot undo after puzzle is solved")
	check(not m.cross([Logic.Traveler.ARIELA]), "Cannot cross after puzzle is solved")

func _test_torch_burnout_and_undo() -> void:
	var m = Logic.new()
	var failed := {"flag": false, "reason": ""}
	m.puzzle_failed.connect(func(r: String):
		failed["flag"] = true
		failed["reason"] = r
	)

	# Naive strategy (always ferry with Ariela): 8+1+5+1+2 = 17 min -> exceeds 15 min!
	m.cross([Logic.Traveler.ARIELA, Logic.Traveler.DUMPY])  # 8
	m.cross([Logic.Traveler.ARIELA])                        # 9
	m.cross([Logic.Traveler.ARIELA, Logic.Traveler.CHARLY]) # 14
	m.cross([Logic.Traveler.ARIELA])                        # 15
	check(not m.is_failed and m.elapsed_minutes == 15, "At 15 min without all on East, not yet failed")
	m.cross([Logic.Traveler.ARIELA, Logic.Traveler.BRIAN])  # 17 -> FAIL
	check(m.is_failed and failed["flag"], "Exceeding 15 min triggers puzzle_failed")
	check(failed["reason"].contains("17 / 15"), "Failure reason reports elapsed vs limit")
	check(not m.cross([Logic.Traveler.ARIELA]), "Further crossings blocked after failure")

	# Undo recovers cleanly from failure
	check(m.undo(), "Undo allowed from failed state")
	check(not m.is_failed and m.elapsed_minutes == 15 and m.torch_side == Logic.Side.WEST, "Undo restores previous state and clears failure")

	m.reset()
	check(m.elapsed_minutes == 0 and m.west_travelers.size() == 4 and not m.is_failed, "Reset restores clean start state")

func _test_dijkstra_solver_from_start_and_midgame() -> void:
	var m = Logic.new()
	var steps: Array[Dictionary] = m.find_optimal_solution()
	check(steps.size() == 5, "Dijkstra finds 5-step optimal solution from start")
	var total_cost: int = 0
	for step in steps:
		total_cost += int(step["cost"])
		check(m.cross(step["travelers"]), "Solver step executes cleanly")
	check(total_cost == 15 and m.is_solved, "Dijkstra solution solves puzzle in exactly 15 minutes")

	# Mid-game completion from valid prefix
	m.reset()
	m.cross([Logic.Traveler.ARIELA, Logic.Traveler.BRIAN]) # 2m
	m.cross([Logic.Traveler.BRIAN])                        # 4m (symmetric optimal branch!)
	var rem_steps: Array[Dictionary] = m.find_optimal_solution()
	check(rem_steps.size() == 3, "Dijkstra finds 3 remaining steps from symmetric optimal prefix")
	for step in rem_steps:
		m.cross(step["travelers"])
	check(m.is_solved and m.elapsed_minutes == 15, "Mid-game Dijkstra completion solves in 15 minutes")

	# Unwinnable mid-game state returns empty array
	m.reset()
	m.cross([Logic.Traveler.ARIELA, Logic.Traveler.DUMPY])  # 8m
	m.cross([Logic.Traveler.DUMPY])                         # 16m -> already failed
	check(m.find_optimal_solution().is_empty(), "Solver returns empty array on failed state")

	m.reset()
	m.cross([Logic.Traveler.ARIELA, Logic.Traveler.DUMPY])  # 8m
	m.cross([Logic.Traveler.ARIELA])                        # 9m -> min remaining is 5+1+2 = 8 -> 17 > 15!
	check(m.find_optimal_solution().is_empty(), "Solver returns empty array when 15-min budget is mathematically unreachable")
