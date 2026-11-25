class_name JournalState
extends RefCounted

## Pure headless data model for the In-Game Logic Journal (PBI-01).
## Stores discovered inscriptions, clues, and formal logic formulas per level
## with zero dependencies on 3D nodes, UI Controls, or the SceneTree.

enum Mark { UNKNOWN, YES, NO }

signal entry_added(level_id: String, entry: Dictionary)
signal entry_updated(level_id: String, entry: Dictionary)
signal journal_cleared(level_id: String)
signal state_changed(level_id: String, entries: Array)
signal scratchpad_changed(level_id: String, row: String, col: String, mark: int)

var _entries_by_level: Dictionary = {}  # level_id (String) -> Array[Dictionary]
var _scratchpad_config: Dictionary = {} # level_id (String) -> {"rows": Array[String], "cols": Array[String]}
var _scratchpad_marks: Dictionary = {}  # level_id (String) -> Dictionary ("row|col" -> int)

## Add or update an entry for `level_id`.
## Returns true if a new entry was added or an existing entry's content changed,
## and false if the input is invalid or an identical entry already exists.
func add_entry(
	level_id: String,
	entry_id: String,
	title: String,
	body: String,
	subtitle: String = "",
	formula: String = "",
	order: int = -1
) -> bool:
	if level_id.is_empty() or entry_id.is_empty():
		return false

	if not _entries_by_level.has(level_id):
		_entries_by_level[level_id] = []

	var list: Array = _entries_by_level[level_id]
	var entry: Dictionary = {
		"id": entry_id,
		"title": title,
		"subtitle": subtitle,
		"body": body,
		"formula": formula,
		"order": order,
	}

	for i in list.size():
		if list[i]["id"] == entry_id:
			if list[i] == entry:
				return false
			list[i] = entry
			_sort_entries(list)
			entry_updated.emit(level_id, entry.duplicate())
			state_changed.emit(level_id, get_entries(level_id))
			return true

	list.append(entry)
	_sort_entries(list)
	entry_added.emit(level_id, entry.duplicate())
	state_changed.emit(level_id, get_entries(level_id))
	return true

func has_entry(level_id: String, entry_id: String) -> bool:
	if not _entries_by_level.has(level_id):
		return false
	for entry in _entries_by_level[level_id]:
		if entry["id"] == entry_id:
			return true
	return false

func get_entry(level_id: String, entry_id: String) -> Dictionary:
	if not _entries_by_level.has(level_id):
		return {}
	for entry in _entries_by_level[level_id]:
		if entry["id"] == entry_id:
			return entry.duplicate()
	return {}

func get_entries(level_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not _entries_by_level.has(level_id):
		return result
	for entry in _entries_by_level[level_id]:
		result.append(entry.duplicate())
	return result

func entry_count(level_id: String) -> int:
	if not _entries_by_level.has(level_id):
		return 0
	return _entries_by_level[level_id].size()

func total_count() -> int:
	var count: int = 0
	for level_id in _entries_by_level:
		count += _entries_by_level[level_id].size()
	return count

func level_ids() -> Array[String]:
	var ids: Array[String] = []
	for k in _entries_by_level.keys():
		ids.append(str(k))
	ids.sort()
	return ids

func clear_level(level_id: String) -> void:
	if _entries_by_level.has(level_id):
		_entries_by_level[level_id] = []
	clear_scratchpad(level_id)
	journal_cleared.emit(level_id)
	state_changed.emit(level_id, [])

func clear_all() -> void:
	var ids := level_ids()
	_entries_by_level.clear()
	for lvl in _scratchpad_marks.keys():
		_scratchpad_marks[lvl] = {}
		scratchpad_changed.emit(str(lvl), "", "", Mark.UNKNOWN)
	for level_id in ids:
		journal_cleared.emit(level_id)
		state_changed.emit(level_id, [])

# ---------------------------------------------------------------------------
# Deduction Scratchpad Matrix (PBI-09)
# ---------------------------------------------------------------------------

## Configure row and column labels for a level's deduction scratchpad matrix.
func configure_scratchpad(level_id: String, rows: Array[String], cols: Array[String]) -> void:
	if level_id.is_empty():
		return
	_scratchpad_config[level_id] = {
		"rows": rows.duplicate(),
		"cols": cols.duplicate(),
	}
	_scratchpad_marks[level_id] = {}
	scratchpad_changed.emit(level_id, "", "", Mark.UNKNOWN)

func has_scratchpad(level_id: String) -> bool:
	if not _scratchpad_config.has(level_id):
		return false
	var cfg: Dictionary = _scratchpad_config[level_id]
	return not cfg["rows"].is_empty() and not cfg["cols"].is_empty()

func get_scratchpad_rows(level_id: String) -> Array[String]:
	if not _scratchpad_config.has(level_id):
		return []
	var result: Array[String] = []
	for r in _scratchpad_config[level_id]["rows"]:
		result.append(str(r))
	return result

func get_scratchpad_cols(level_id: String) -> Array[String]:
	if not _scratchpad_config.has(level_id):
		return []
	var result: Array[String] = []
	for c in _scratchpad_config[level_id]["cols"]:
		result.append(str(c))
	return result

func get_mark(level_id: String, row: String, col: String) -> int:
	if not _scratchpad_marks.has(level_id):
		return Mark.UNKNOWN
	return int(_scratchpad_marks[level_id].get(_cell_key(row, col), Mark.UNKNOWN))

func set_mark(level_id: String, row: String, col: String, mark: int) -> bool:
	if not has_scratchpad(level_id):
		return false
	if mark < Mark.UNKNOWN or mark > Mark.NO:
		return false
	var cfg: Dictionary = _scratchpad_config[level_id]
	if row not in cfg["rows"] or col not in cfg["cols"]:
		return false
	if not _scratchpad_marks.has(level_id):
		_scratchpad_marks[level_id] = {}
	var key: String = _cell_key(row, col)
	if mark == Mark.UNKNOWN:
		_scratchpad_marks[level_id].erase(key)
	else:
		_scratchpad_marks[level_id][key] = mark
	scratchpad_changed.emit(level_id, row, col, mark)
	return true

## Cycle a scratchpad cell: UNKNOWN -> YES -> NO -> UNKNOWN. Returns the new mark.
func cycle_mark(level_id: String, row: String, col: String) -> int:
	var current: int = get_mark(level_id, row, col)
	var next_mark: int = (current + 1) % 3
	if not set_mark(level_id, row, col, next_mark):
		return Mark.UNKNOWN
	return next_mark

## Clear all marks in `level_id`'s scratchpad while preserving its row/column schema.
func clear_scratchpad(level_id: String) -> void:
	if _scratchpad_marks.has(level_id):
		_scratchpad_marks[level_id] = {}
	scratchpad_changed.emit(level_id, "", "", Mark.UNKNOWN)

static func mark_symbol(mark: int) -> String:
	match mark:
		Mark.YES: return "✓"
		Mark.NO: return "✗"
		_: return ""

static func _cell_key(row: String, col: String) -> String:
	return "%s|%s" % [row, col]

func _sort_entries(list: Array) -> void:
	var has_explicit_order := false
	for entry in list:
		if int(entry["order"]) >= 0:
			has_explicit_order = true
			break
	if not has_explicit_order:
		return
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var oa: int = int(a["order"])
		var ob: int = int(b["order"])
		if oa < 0 and ob < 0:
			return false
		if oa < 0:
			return false
		if ob < 0:
			return true
		return oa < ob
	)
