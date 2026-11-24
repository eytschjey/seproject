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
	test_all_cases_unique_killer()
	test_randomized_reset_outcomes()
	test_investigation_and_accusation_flow()
	print("\n==== %d passed, %d failed ====" % [passed, failed])
	quit(1 if failed > 0 else 0)

func test_axioms_and_models() -> void:
	print("\n[Test 1: First-order model checking]")
	var valid_hates := [
		[true, false, true],   # Agatha hates Agatha, Charles
		[true, false, true],   # Butler hates Agatha, Charles (not himself)
		[false, true, false],  # Charles hates only Butler
	]
	var valid_richer := [false, true, false]

	assert_test(
		Logic.is_consistent_model(Logic.Suspect.AGATHA, valid_hates, valid_richer, Logic.Case.AGATHA),
		"Canonical valid model with Agatha as killer is consistent (Case.AGATHA)"
	)
	assert_test(
		not Logic.is_consistent_model(Logic.Suspect.CHARLES, valid_hates, [false, true, false], Logic.Case.AGATHA),
		"Rejects Charles as killer when Charles does not hate Agatha"
	)
	var charles_hates_agatha := [
		[true, false, true],
		[true, false, true],
		[true, false, false],
	]
	assert_test(
		not Logic.is_consistent_model(Logic.Suspect.CHARLES, charles_hates_agatha, [false, true, false], Logic.Case.AGATHA),
		"Rejects Charles hating Agatha (violates Charles's Letter in Case.AGATHA)"
	)
	var butler_hates_all := [
		[true, false, true],
		[true, true, true],
		[false, false, false],
	]
	assert_test(
		not Logic.is_consistent_model(Logic.Suspect.BUTLER, butler_hates_all, [false, false, false], Logic.Case.AGATHA),
		"Rejects Butler hating everyone (violates Psychological Profile)"
	)
	assert_test(
		not Logic.is_consistent_model(Logic.Suspect.AGATHA, valid_hates, [true, true, false], Logic.Case.AGATHA),
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

func test_all_cases_unique_killer() -> void:
	print("\n[Test 2: Unique killer deduction across all 3 outcomes]")
	var expected_killers: Array[int] = [
		Logic.Suspect.AGATHA,
		Logic.Suspect.BUTLER,
		Logic.Suspect.CHARLES,
	]
	for case_id in Logic.CASE_COUNT:
		var models := Logic.enumerate_consistent_models(case_id)
		var expected: int = expected_killers[case_id]
		var name_str: String = Logic.suspect_name(expected)
		assert_test(
			models.size() > 0,
			"Case %d (%s): at least one consistent model exists (%d found)" % [case_id, name_str, models.size()]
		)
		assert_test(
			Logic.killer_candidates(case_id) == [expected],
			"Case %d (%s): killer_candidates() uniquely deduces [%s]" % [case_id, name_str, name_str]
		)
		for s in Logic.SUSPECT_COUNT:
			var exp_text := Logic.contradiction_for(s, case_id)
			if s == expected:
				assert_test(
					exp_text.contains("Proven"),
					"Case %d: proof explanation provided for true killer (%s)" % [case_id, Logic.suspect_name(s)]
				)
			else:
				assert_test(
					exp_text.contains("Contradiction"),
					"Case %d: contradiction explanation provided for innocent suspect (%s)" % [case_id, Logic.suspect_name(s)]
				)
		assert_test(
			Logic.victory_message_for(case_id).contains(name_str),
			"Case %d: victory message names %s" % [case_id, name_str]
		)

func test_randomized_reset_outcomes() -> void:
	print("\n[Test 3: Randomized case selection on start and reset]")
	var logic := Logic.new()
	var seen := {}
	seen[logic.active_case] = true
	var always_changed := true
	for _i in 30:
		var prev := logic.active_case
		logic.reset()
		if logic.active_case == prev:
			always_changed = false
		seen[logic.active_case] = true
	assert_test(always_changed, "reset() always rotates to a different outcome than the previous one")
	assert_test(seen.size() == Logic.CASE_COUNT, "All 3 outcomes (Agatha, Butler, Charles) occur across resets")

func test_investigation_and_accusation_flow() -> void:
	print("\n[Test 4: Investigation & accusation gameplay flow across all 3 outcomes]")
	for case_id in Logic.CASE_COUNT:
		var logic := Logic.new(case_id)
		var killer: int = logic.solve_killer()
		var innocent_a: int = (killer + 1) % Logic.SUSPECT_COUNT
		var innocent_b: int = (killer + 2) % Logic.SUSPECT_COUNT
		var state := {"clues": 0, "failed": "", "solved": false, "accusations": 0}
		logic.clue_inspected.connect(func(_idx, _c): state.clues += 1)
		logic.puzzle_failed.connect(func(r): state.failed = r)
		logic.puzzle_solved.connect(func(): state.solved = true)
		logic.accusation_made.connect(func(_s, _ok, _e): state.accusations += 1)

		assert_test(logic.discovered_count() == 0 and not logic.all_clues_discovered(), "Case %d: starts with 0 discovered clues" % case_id)
		if case_id == 0:
			assert_test(not logic.inspect_clue(-1) and not logic.inspect_clue(8), "Rejects out-of-bounds clue index")
			assert_test(not logic.select_suspect(-1) and not logic.select_suspect(3), "Rejects invalid suspect selection")
		for i in Logic.CLUE_COUNT:
			logic.inspect_clue(i)
		assert_test(logic.all_clues_discovered() and state.clues == 8, "Case %d: all 8 clues inspected and emitted" % case_id)

		assert_test(logic.select_suspect(innocent_a) and logic.accuse_selected(), "Case %d: accuses first innocent (%s)" % [case_id, Logic.suspect_name(innocent_a)])
		assert_test(logic.is_failed and not logic.is_solved and state.failed.contains("Contradiction"), "Case %d: false accusation 1 fails with contradiction" % case_id)
		assert_test(not logic.accuse(killer), "Case %d: cannot accuse again after failure without reset" % case_id)

		logic.reset(case_id)
		assert_test(not logic.is_failed and logic.discovered_count() == 0 and logic.selected_suspect == -1, "Case %d: reset restores initial state" % case_id)

		assert_test(logic.accuse(innocent_b) and logic.is_failed and state.failed.contains("Contradiction"), "Case %d: false accusation 2 (%s) fails with contradiction" % [case_id, Logic.suspect_name(innocent_b)])

		logic.reset(case_id)
		assert_test(logic.select_suspect(killer) and logic.accuse_selected(), "Case %d: accuses true killer (%s)" % [case_id, Logic.suspect_name(killer)])
		assert_test(logic.is_solved and state.solved, "Case %d: accusing %s solves the puzzle" % [case_id, Logic.suspect_name(killer)])
		assert_test(not logic.accuse(innocent_a), "Case %d: no actions allowed after puzzle is solved" % case_id)
		assert_test(state.accusations == 3, "Case %d: accusation_made emitted 3 times" % case_id)
