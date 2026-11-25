extends SceneTree

# Headless unit & UI integration test for PBI-13: ProgressStore & Main Menu progress display.

const ProgressStoreScript = preload("res://scripts/logic/ProgressStore.gd")
const TEST_SAVE_PATH: String = "user://test_progress_store.cfg"

var checks_failed: int = 0

func check(cond: bool, msg: String) -> void:
	print(("  PASS: " if cond else "  FAIL: ") + msg)
	if not cond:
		checks_failed += 1

func _cleanup_save() -> void:
	var abs_path: String = ProjectSettings.globalize_path(TEST_SAVE_PATH)
	if FileAccess.file_exists(abs_path):
		DirAccess.remove_absolute(abs_path)

func _init() -> void:
	_cleanup_save()
	print("=== TestProgressStore: Headless Persistence ===")
	_test_store_persistence()

	print("=== TestProgressStore: Main Menu Integration ===")
	await _test_main_menu_progress()

	_cleanup_save()
	print("checks failed: ", checks_failed)
	quit(1 if checks_failed > 0 else 0)

func _test_store_persistence() -> void:
	var store = ProgressStoreScript.new(TEST_SAVE_PATH)
	var events := {"completed": 0, "changed": 0}
	store.level_completed.connect(func(_id: String): events["completed"] += 1)
	store.progress_changed.connect(func(_ids: Array): events["changed"] += 1)

	check(store.completed_count() == 0 and store.total_levels() == 7, "Starts with 0 / 7 completed")
	check(not store.mark_completed("invalid_level"), "Rejects unknown level ID")

	check(store.mark_completed("level01"), "Marks level01 completed")
	check(store.mark_completed("level01"), "Marking level01 again succeeds idempotently")
	check(events["completed"] == 1 and events["changed"] == 1, "Signals fire once per newly completed level")
	check(store.is_completed("level01") and not store.is_completed("level02"), "Tracks completion per level ID")

	# Verify persistence across a fresh ProgressStore instance
	var reloaded = ProgressStoreScript.new(TEST_SAVE_PATH)
	check(reloaded.is_completed("level01") and reloaded.completed_count() == 1, "Completion persists to ConfigFile across instances")

	check(ProgressStoreScript.record_completion("level07", TEST_SAVE_PATH), "Static record_completion helper persists completion")
	reloaded.load_progress()
	check(reloaded.is_completed("level07") and reloaded.completed_count() == 2, "Reloaded store reflects static record_completion")

	reloaded.reset_progress()
	var after_reset = ProgressStoreScript.new(TEST_SAVE_PATH)
	check(after_reset.completed_count() == 0, "reset_progress clears saved file")

func _test_main_menu_progress() -> void:
	_cleanup_save()
	var menu = load("res://scenes/ui/MainMenu.tscn").instantiate()
	root.add_child(menu)
	await process_frame

	var store = ProgressStoreScript.new(TEST_SAVE_PATH)
	menu.set_progress_store(store)
	check(menu.progress_label.text == "Progress: 0 / 7 Completed", "Main menu displays 0 / 7 initially")
	check(menu.btn_reset_progress.disabled, "Reset Progress button disabled when 0 completed")
	check(not menu.level_buttons[0].text.begins_with("✓"), "Incomplete level has no checkmark")

	store.mark_completed("level01")
	store.mark_completed("level07")
	menu.refresh_progress()
	check(menu.progress_label.text == "Progress: 2 / 7 Completed", "Main menu updates to 2 / 7 Completed")
	check(menu.level_buttons[0].text.begins_with("✓ "), "Completed Level 1 displays checkmark")
	check(menu.level_buttons[6].text.begins_with("✓ "), "Completed Bonus Chamber displays checkmark")
	check(not menu.btn_reset_progress.disabled, "Reset Progress button enabled when levels completed")

	menu.btn_reset_progress.pressed.emit()
	await process_frame
	check(store.completed_count() == 0 and menu.progress_label.text == "Progress: 0 / 7 Completed", "Clicking Reset Progress clears store and updates UI")
	check(menu.btn_reset_progress.disabled, "Reset Progress button disabled again after reset")

	menu.queue_free()
	await process_frame
