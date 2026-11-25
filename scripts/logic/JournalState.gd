class_name JournalState
extends RefCounted

## Pure headless data model for the In-Game Logic Journal (PBI-01).
## Stores discovered inscriptions, clues, and formal logic formulas per level
## with zero dependencies on 3D nodes, UI Controls, or the SceneTree.

signal entry_added(level_id: String, entry: Dictionary)
signal entry_updated(level_id: String, entry: Dictionary)
signal journal_cleared(level_id: String)
signal state_changed(level_id: String, entries: Array)

var _entries_by_level: Dictionary = {}  # level_id (String) -> Array[Dictionary]

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
	journal_cleared.emit(level_id)
	state_changed.emit(level_id, [])

func clear_all() -> void:
	var ids := level_ids()
	_entries_by_level.clear()
	for level_id in ids:
		journal_cleared.emit(level_id)
		state_changed.emit(level_id, [])

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
