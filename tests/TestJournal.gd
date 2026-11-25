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

	# Scratchpad matrix headless model checks (PBI-09)
	var pad_events := {"changes": 0}
	js.scratchpad_changed.connect(func(_lvl: String, _r: String, _c: String, _m: int): pad_events["changes"] += 1)
	var rows: Array[String] = ["Door 1", "Door 2"]
	var cols: Array[String] = ["Princess", "Tiger"]
	js.configure_scratchpad("level02", rows, cols)
	check(js.has_scratchpad("level02") and not js.has_scratchpad("unknown"), "Scratchpad schema configured per level")
	check(js.get_mark("level02", "Door 1", "Princess") == JournalModel.Mark.UNKNOWN, "Scratchpad cells default to UNKNOWN")
	check(not js.set_mark("level02", "Door 99", "Princess", JournalModel.Mark.YES), "Rejects out-of-schema row")
	check(js.cycle_mark("level02", "Door 1", "Princess") == JournalModel.Mark.YES, "First cycle sets YES")
	check(js.cycle_mark("level02", "Door 1", "Princess") == JournalModel.Mark.NO, "Second cycle sets NO")
	check(js.cycle_mark("level02", "Door 1", "Princess") == JournalModel.Mark.UNKNOWN, "Third cycle resets to UNKNOWN")
	check(js.set_mark("level02", "Door 2", "Tiger", JournalModel.Mark.NO), "set_mark updates cell")
	js.clear_level("level02")
	check(js.has_scratchpad("level02") and js.get_mark("level02", "Door 2", "Tiger") == JournalModel.Mark.UNKNOWN, "clear_level wipes marks while preserving schema")
	check(pad_events["changes"] >= 5, "scratchpad_changed signal fires on updates and clears")

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

	# Scratchpad tab & cell clicking UI checks (PBI-09)
	check(not ui.tab_row.visible, "Tab row hidden when no scratchpad configured")
	var ui_rows: Array[String] = ["Suspect A", "Suspect B"]
	var ui_cols: Array[String] = ["Killer", "Innocent"]
	js.configure_scratchpad("test_lvl", ui_rows, ui_cols)
	ui.open()
	await process_frame
	check(ui.tab_row.visible and ui.scratchpad_buttons.size() == 4, "Tab row visible and 2x2 scratchpad grid built")
	ui.btn_tab_scratchpad.pressed.emit()
	await process_frame
	check(ui.scratchpad_view.visible and not ui.notes_view.visible, "Deduction Matrix tab switches to scratchpad view")
	var cell_btn: Button = ui.scratchpad_buttons["Suspect A|Killer"]
	cell_btn.pressed.emit()
	await process_frame
	check(js.get_mark("test_lvl", "Suspect A", "Killer") == JournalModel.Mark.YES and ui.scratchpad_buttons["Suspect A|Killer"].text == "✓", "Clicking matrix cell marks ✓")
	ui.scratchpad_buttons["Suspect A|Killer"].pressed.emit()
	await process_frame
	check(js.get_mark("test_lvl", "Suspect A", "Killer") == JournalModel.Mark.NO and ui.scratchpad_buttons["Suspect A|Killer"].text == "✗", "Second click marks ✗")
	ui.btn_clear_scratchpad.pressed.emit()
	await process_frame
	check(js.get_mark("test_lvl", "Suspect A", "Killer") == JournalModel.Mark.UNKNOWN, "Clear Matrix button resets all marks")

	host.queue_free()
	await process_frame

func _test_level02_integration() -> void:
	var s = load("res://scenes/levels/Level02_NinePortals.tscn").instantiate()
	root.add_child(s)
	await physics_frame
	await physics_frame

	check(s.journal_state != null and s.journal_ui != null, "Level 2 initializes JournalState and Journal UI")
	check(s.journal_state.entry_count("level02") == 0, "Level 2 journal starts empty")
	check(s.journal_state.has_scratchpad("level02") and s.journal_ui.scratchpad_buttons.size() == 36, "Level 2 configures 9x4 deduction matrix")
	s.journal_state.set_mark("level02", "Door 1", "Tiger", JournalModel.Mark.YES)

	s.click_door(4)
	s.click_door(2)
	await process_frame
	check(s.journal_state.entry_count("level02") == 2, "Inspecting doors automatically logs inscriptions in Level 2 journal")
	var entries: Array = s.journal_state.get_entries("level02")
	check(entries[0]["id"] == "door_2" and entries[1]["id"] == "door_4", "Level 2 journal orders doors numerically")
	check(entries[0]["body"] == s.logic.get_inscription(2), "Logged Level 2 inscription matches dynamic door text")

	s.btn_reset.pressed.emit()
	await process_frame
	check(s.journal_state.entry_count("level02") == 0 and s.journal_state.get_mark("level02", "Door 1", "Tiger") == JournalModel.Mark.UNKNOWN, "Resetting Level 2 clears stale randomized door entries and scratchpad marks")

	s.queue_free()
	await process_frame

func _test_level05_integration() -> void:
	var s = load("res://scenes/levels/Level05_DreadburyManor.tscn").instantiate()
	root.add_child(s)
	await process_frame

	check(s.journal_state != null and s.journal_ui != null, "Level 5 initializes JournalState and Journal UI")
	check(s.journal_state.entry_count("level05") == 0, "Level 5 journal starts empty")
	check(s.journal_state.has_scratchpad("level05") and s.journal_ui.scratchpad_buttons.size() == 12, "Level 5 configures 3x4 deduction matrix")
	s.journal_state.set_mark("level05", "Charles", "Killer", JournalModel.Mark.NO)

	s.clue_buttons[2].pressed.emit()
	s.clue_buttons[0].pressed.emit()
	await process_frame
	check(s.journal_state.entry_count("level05") == 2, "Inspecting clues automatically logs them in Level 5 journal")
	var entries: Array = s.journal_state.get_entries("level05")
	check(entries[0]["id"] == "clue_0" and entries[1]["id"] == "clue_2", "Level 5 journal orders clues by index")
	check(entries[0]["formula"] == s.logic.get_clue(0)["formula"], "Level 5 journal preserves formal FOL formula")

	s.btn_reset.pressed.emit()
	await process_frame
	check(s.journal_state.entry_count("level05") == 0 and s.journal_state.get_mark("level05", "Charles", "Killer") == JournalModel.Mark.UNKNOWN, "Resetting Level 5 clears clues and scratchpad marks from previous case")

	s.queue_free()
	await process_frame
