extends SceneTree

# Automated headless unit & integration test for PBI-01: In-Game Logic Journal.
# Verifies JournalState (pure headless model), Journal.tscn UI toggle/rendering,
# and automatic logging + reset clearing in Level 2 and Level 5.

const JournalModel = preload("res://scripts/logic/JournalState.gd")
const JournalUI = preload("res://scripts/ui/JournalController.gd")

var checks_failed: int = 0

func check(cond: bool, msg: String) -> void:
	print(("  PASS: " if cond else "  FAIL: ") + msg)
	if not cond:
		checks_failed += 1

func _init() -> void:
	print("=== TestJournal: Headless Model ===")
	_test_headless_model()

	print("=== TestJournal: UI Scene & Toggle ===")
	await _test_journal_ui()

	print("=== TestJournal: Level 2 Integration ===")
	await _test_level02_integration()

	print("=== TestJournal: Level 5 Integration ===")
	await _test_level05_integration()

	print("checks failed: ", checks_failed)
	quit(1 if checks_failed > 0 else 0)

func _test_headless_model() -> void:
	var js = JournalModel.new()
	var events := {"added": 0, "updated": 0, "cleared": 0, "changed": 0}
	js.entry_added.connect(func(_lvl: String, _e: Dictionary): events["added"] += 1)
	js.entry_updated.connect(func(_lvl: String, _e: Dictionary): events["updated"] += 1)
	js.journal_cleared.connect(func(_lvl: String): events["cleared"] += 1)
	js.state_changed.connect(func(_lvl: String, _arr: Array): events["changed"] += 1)

	check(js.entry_count("level02") == 0 and js.total_count() == 0, "Starts empty")
	check(not js.add_entry("", "k", "T", "B"), "Rejects empty level_id")
	check(not js.add_entry("level02", "", "T", "B"), "Rejects empty entry_id")

	check(js.add_entry("level02", "door_5", "Door 5", "Text 5", "Hall", "", 5), "Adds Door 5 entry")
	check(js.add_entry("level02", "door_2", "Door 2", "Text 2", "Hall", "", 2), "Adds Door 2 entry")
	check(not js.add_entry("level02", "door_2", "Door 2", "Text 2", "Hall", "", 2), "Ignores identical duplicate")
	check(js.entry_count("level02") == 2 and events["added"] == 2, "Entry count and entry_added signal accurate")

	var ordered: Array = js.get_entries("level02")
	check(ordered[0]["id"] == "door_2" and ordered[1]["id"] == "door_5", "Entries sorted by explicit order")

	check(js.add_entry("level02", "door_2", "Door 2", "Updated text 2", "Hall", "", 2), "Updates existing entry on change")
	check(events["updated"] == 1 and js.get_entry("level02", "door_2")["body"] == "Updated text 2", "entry_updated emitted and content updated")

	check(js.add_entry("level05", "clue_0", "Clue 1", "Killer hates victim", "Library", "∀x,y: killed(x,y) → hates(x,y)", 0), "Supports isolated per-level entries")
	check(js.total_count() == 3 and js.level_ids() == ["level02", "level05"], "Tracks totals and level IDs across levels")

	js.clear_level("level02")
	check(js.entry_count("level02") == 0 and js.entry_count("level05") == 1, "clear_level only clears targeted level")
	check(events["cleared"] == 1, "journal_cleared signal emitted")

	js.clear_all()
	check(js.total_count() == 0, "clear_all removes entries across all levels")

func _test_journal_ui() -> void:
	var host := Control.new()
	root.add_child(host)
	var js = JournalModel.new()
	var ui = JournalUI.attach(host, js, "test_lvl", "Test Chamber")
	await process_frame

	check(not ui.is_open and not ui.overlay.visible, "Journal starts closed")
	check(ui.empty_label.visible and ui.entries_list.get_child_count() == 0, "Empty state shown when no entries logged")
	check(ui.btn_toggle.text == "Journal (0)", "Toggle button displays initial 0 count")

	ui.btn_toggle.pressed.emit()
	await process_frame
	check(ui.is_open and ui.overlay.visible, "Toggle button opens journal overlay")

	js.add_entry("test_lvl", "c1", "Clue 1", "A killer hates their victim.", "Desk", "killed(x,y) -> hates(x,y)", 1)
	await process_frame
	check(not ui.empty_label.visible and ui.entries_list.get_child_count() == 1, "Adding entry renders card and hides empty label")
	check(ui.btn_toggle.text == "Journal (1)" and ui.count_label.text == "1 entry", "Counts update live on state_changed")

	# Test `journal` input action (J key) toggles it closed
	var ev := InputEventAction.new()
	ev.action = "journal"
	ev.pressed = true
	ui._unhandled_input(ev)
	await process_frame
	check(not ui.is_open and not ui.overlay.visible, "Journal action closes open overlay")

	ui._unhandled_input(ev)
	await process_frame
	check(ui.is_open and ui.overlay.visible, "Journal action re-opens overlay")

	ui.btn_close.pressed.emit()
	await process_frame
	check(not ui.is_open and not ui.overlay.visible, "Close button closes overlay")

	host.queue_free()
	await process_frame

func _test_level02_integration() -> void:
	var s = load("res://scenes/levels/Level02_NinePortals.tscn").instantiate()
	root.add_child(s)
	await physics_frame
	await physics_frame

	check(s.journal_state != null and s.journal_ui != null, "Level 2 initializes JournalState and Journal UI")
	check(s.journal_state.entry_count("level02") == 0, "Level 2 journal starts empty")

	s.click_door(4)
	s.click_door(2)
	await process_frame
	check(s.journal_state.entry_count("level02") == 2, "Inspecting doors automatically logs inscriptions in Level 2 journal")
	var entries: Array = s.journal_state.get_entries("level02")
	check(entries[0]["id"] == "door_2" and entries[1]["id"] == "door_4", "Level 2 journal orders doors numerically")
	check(entries[0]["body"] == s.logic.get_inscription(2), "Logged Level 2 inscription matches dynamic door text")

	s.btn_reset.pressed.emit()
	await process_frame
	check(s.journal_state.entry_count("level02") == 0, "Resetting Level 2 clears stale randomized door entries")

	s.queue_free()
	await process_frame

func _test_level05_integration() -> void:
	var s = load("res://scenes/levels/Level05_DreadburyManor.tscn").instantiate()
	root.add_child(s)
	await process_frame

	check(s.journal_state != null and s.journal_ui != null, "Level 5 initializes JournalState and Journal UI")
	check(s.journal_state.entry_count("level05") == 0, "Level 5 journal starts empty")

	s.clue_buttons[2].pressed.emit()
	s.clue_buttons[0].pressed.emit()
	await process_frame
	check(s.journal_state.entry_count("level05") == 2, "Inspecting clues automatically logs them in Level 5 journal")
	var entries: Array = s.journal_state.get_entries("level05")
	check(entries[0]["id"] == "clue_0" and entries[1]["id"] == "clue_2", "Level 5 journal orders clues by index")
	check(entries[0]["formula"] == s.logic.get_clue(0)["formula"], "Level 5 journal preserves formal FOL formula")

	s.btn_reset.pressed.emit()
	await process_frame
	check(s.journal_state.entry_count("level05") == 0, "Resetting Level 5 clears clues from previous case")

	s.queue_free()
	await process_frame
