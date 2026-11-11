extends SceneTree

const Logic = preload("res://scripts/logic/DreadburyLogic.gd")

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
	test_axioms_and_models()
	test_solution_uniqueness()
	test_investigation_and_accusation_flow()
	print("\n==== %d passed, %d failed ====" % [passed, failed])
	quit(1 if failed > 0 else 0)

func test_axioms_and_models() -> void:
	print("\n[Test 1: First-order model checking]")
	# Canonical valid interpretation:
	# Agatha hates Agatha & Charles (not Butler).
	# Butler hates Agatha & Charles (not Butler, since Butler is richer than Agatha).
	# Charles hates nobody that Agatha hates.
	# Richer than Agatha: Butler ([false, true, false]).
	var valid_hates := [
		[true, false, true],   # Agatha hates Agatha, Charles
		[true, false, true],   # Butler hates Agatha, Charles (not himself)
		[false, true, false],  # Charles hates only Butler
	]
	var valid_richer := [false, true, false]

	assert_test(
		Logic.is_consistent_model(Logic.Suspect.AGATHA, valid_hates, valid_richer),
		"Canonical valid model with Agatha as killer is consistent"
	)
	assert_test(
		not Logic.is_consistent_model(Logic.Suspect.CHARLES, valid_hates, [false, true, false]),
		"Rejects Charles as killer when Charles does not hate Agatha"
	)
	var charles_hates_agatha := [
		[true, false, true],
		[true, false, true],
		[true, false, false],
	]
	assert_test(
		not Logic.is_consistent_model(Logic.Suspect.CHARLES, charles_hates_agatha, [false, true, false]),
		"Rejects Charles hating Agatha (violates Charles's Letter)"
	)
	var butler_hates_all := [
		[true, false, true],
		[true, true, true],
		[false, false, false],
	]
	assert_test(
		not Logic.is_consistent_model(Logic.Suspect.BUTLER, butler_hates_all, [false, false, false]),
		"Rejects Butler hating everyone (violates Psychological Profile)"
	)
	assert_test(
		not Logic.is_consistent_model(Logic.Suspect.AGATHA, valid_hates, [true, true, false]),
		"Rejects Agatha being richer than herself"
	)
	assert_test(
		not Logic.is_consistent_model(-1, valid_hates, valid_richer),
		"Rejects invalid killer index"
	)
	assert_test(
		not Logic.is_consistent_model(Logic.Suspect.AGATHA, [], valid_richer),
		"Rejects malformed hates matrix"
	)

func test_solution_uniqueness() -> void:
	print("\n[Test 2: Unique killer deduction]")
	var models := Logic.enumerate_consistent_models()
	assert_test(models.size() > 0, "At least one consistent first-order model exists (%d found)" % models.size())
	var all_agatha := true
	var butler_always_richer := true
	for m in models:
		if m["killer"] != Logic.Suspect.AGATHA:
			all_agatha = false
		if not m["richer_than_agatha"][Logic.Suspect.BUTLER]:
			butler_always_richer = false
	assert_test(all_agatha, "Every consistent model proves Aunt Agatha killed herself")
	assert_test(butler_always_richer, "Every consistent model requires the Butler to be richer than Agatha")
	assert_test(
		Logic.killer_candidates() == [Logic.Suspect.AGATHA],
		"killer_candidates() == [Suspect.AGATHA]"
	)
	assert_test(
		Logic.contradiction_for(Logic.Suspect.CHARLES).contains("Contradiction"),
		"Contradiction explanation provided for Charles"
	)
	assert_test(
		Logic.contradiction_for(Logic.Suspect.BUTLER).contains("Contradiction"),
		"Contradiction explanation provided for the Butler"
	)

func test_investigation_and_accusation_flow() -> void:
	print("\n[Test 3: Investigation & accusation gameplay flow]")
	var logic := Logic.new()
	var state := {"clues": 0, "failed": "", "solved": false, "accusations": 0}
	logic.clue_inspected.connect(func(_idx, _c): state.clues += 1)
	logic.puzzle_failed.connect(func(r): state.failed = r)
	logic.puzzle_solved.connect(func(): state.solved = true)
	logic.accusation_made.connect(func(_s, _ok, _e): state.accusations += 1)

	assert_test(logic.discovered_count() == 0 and not logic.all_clues_discovered(), "Starts with 0 discovered clues")
	assert_test(not logic.inspect_clue(-1) and not logic.inspect_clue(8), "Rejects out-of-bounds clue index")
	for i in Logic.CLUE_COUNT:
		assert_test(logic.inspect_clue(i), "Inspect clue %d (%s)" % [i + 1, Logic.CLUES[i]["title"]])
	assert_test(logic.all_clues_discovered() and logic.discovered_count() == 8, "All 8 clues discovered")
	assert_test(state.clues == 8, "clue_inspected emitted 8 times")

	assert_test(not logic.select_suspect(-1) and not logic.select_suspect(3), "Rejects invalid suspect selection")
	assert_test(logic.select_suspect(Logic.Suspect.CHARLES), "Selects Charles at the altar")
	assert_test(logic.accuse_selected(), "Accuses selected suspect (Charles)")
	assert_test(logic.is_failed and not logic.is_solved, "Accusing Charles fails the puzzle")
	assert_test(state.failed.contains("Contradiction"), "Failure signal carries logical contradiction")
	assert_test(not logic.accuse(Logic.Suspect.AGATHA), "Cannot accuse again after failure without reset")

	logic.reset()
	assert_test(not logic.is_failed and logic.discovered_count() == 0 and logic.selected_suspect == -1, "Reset restores initial state")

	assert_test(logic.accuse(Logic.Suspect.BUTLER), "Accusing the Butler executes")
	assert_test(logic.is_failed and state.failed.contains("Contradiction"), "Accusing the Butler fails with contradiction")

	logic.reset()
	assert_test(logic.select_suspect(Logic.Suspect.AGATHA), "Selects Aunt Agatha at the altar")
	assert_test(logic.accuse_selected(), "Accuses Aunt Agatha")
	assert_test(logic.is_solved and state.solved, "Accusing Aunt Agatha solves the puzzle")
	assert_test(not logic.accuse(Logic.Suspect.CHARLES), "No actions allowed after puzzle is solved")
	assert_test(state.accusations == 3, "accusation_made emitted for each accusation")
