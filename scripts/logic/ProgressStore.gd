class_name ProgressStore
extends RefCounted

## Headless persistent progress store for SEProject (PBI-13).
## Saves completed level IDs to a Godot ConfigFile (default: user://save.cfg).

const DEFAULT_SAVE_PATH: String = "user://save.cfg"
const SECTION_PROGRESS: String = "progress"
const LEVEL_IDS: Array[String] = [
	"level01",
	"level02",
	"level03",
	"level04",
	"level05",
	"level06",
	"level07",
]

signal level_completed(level_id: String)
signal progress_changed(completed_ids: Array)

var save_path: String = DEFAULT_SAVE_PATH
var _completed: Dictionary = {} # level_id (String) -> bool

func _init(path: String = DEFAULT_SAVE_PATH) -> void:
	save_path = path
	load_progress()

func load_progress() -> bool:
	_completed.clear()
	var cfg := ConfigFile.new()
	var err: int = cfg.load(save_path)
	if err != OK:
		return false
	for level_id in LEVEL_IDS:
		if bool(cfg.get_value(SECTION_PROGRESS, level_id, false)):
			_completed[level_id] = true
	return true

func save_progress() -> bool:
	var cfg := ConfigFile.new()
	for level_id in LEVEL_IDS:
		cfg.set_value(SECTION_PROGRESS, level_id, _completed.get(level_id, false))
	return cfg.save(save_path) == OK

func mark_completed(level_id: String) -> bool:
	if level_id not in LEVEL_IDS:
		return false
	var already_done: bool = _completed.get(level_id, false)
	_completed[level_id] = true
	save_progress()
	if not already_done:
		level_completed.emit(level_id)
		progress_changed.emit(completed_levels())
	return true

func is_completed(level_id: String) -> bool:
	return _completed.get(level_id, false)

func completed_levels() -> Array[String]:
	var result: Array[String] = []
	for level_id in LEVEL_IDS:
		if _completed.get(level_id, false):
			result.append(level_id)
	return result

func completed_count() -> int:
	return completed_levels().size()

func total_levels() -> int:
	return LEVEL_IDS.size()

func reset_progress() -> void:
	_completed.clear()
	save_progress()
	progress_changed.emit([])

## Convenience one-liner for level controllers to persist completion on victory.
static func record_completion(level_id: String, path: String = DEFAULT_SAVE_PATH) -> bool:
	var store = load("res://scripts/logic/ProgressStore.gd").new(path)
	return store.mark_completed(level_id)
