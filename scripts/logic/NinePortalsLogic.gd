class_name NinePortalsLogic
extends RefCounted

## Pure logical model of the Trial of the Nine Portals (Smullyan's Lady-or-the-Tiger).
## Source: Theoretical Computer Science: Logic & Puzzles, Chapter 4, Exercise 13.
##
## Royal Logic Protocol:
##  * Tiger room    -> its inscription is false.
##  * Princess room -> its inscription is true.
##  * Empty rooms   -> either ALL empty-room inscriptions are true, or ALL are false.
## Exactly one room holds the Princess.
##
## Rooms are numbered 1..9 in the public API; layouts are arrays indexed 0..8.

enum Content { EMPTY, TIGER, PRINCESS }

const DOOR_COUNT: int = 9

## Canonical hidden layout used in the game (consistent with the protocol).
## Rooms 1,2,4,6,7,8,9 = Tiger, Room 3 = Empty, Room 5 = Princess.
const DEFAULT_LAYOUT: Array[int] = [1, 1, 0, 1, 2, 1, 1, 1, 1]

const INSCRIPTIONS: Array[String] = [
	"The princess is in a room with an odd number and there is no tiger in the rooms with an even number.",
	"This room is empty.",
	"The inscription on Room No. 5 is true, the inscription on Room No. 7 is false, and there is a tiger in Room No. 3.",
	"The inscription on Room No. 1 is false, there is no tiger in Room No. 8, and the inscription on Room No. 9 is true.",
	"If the inscription on Room No. 2 or on Room No. 4 is true, then there is no tiger in Room No. 1.",
	"The inscription on Room No. 3 is false, the princess is in Room No. 2, and there is no tiger in Room No. 2.",
	"The princess is in Room No. 1 and the inscription on Room No. 5 is true.",
	"There is no tiger in this room and Room No. 9 is empty.",
	"Neither in this room nor in Room No. 1 is there a tiger, and moreover, the inscription on Room No. 6 is true.",
]

signal state_changed(opened: Array, selected: int)
signal door_opened(room: int, content: int)
signal move_executed(description: String)
signal puzzle_failed(reason: String)
signal puzzle_solved()

var contents: Array[int] = []
var opened: Array[bool] = []
var is_solved: bool = false
var is_failed: bool = false

func _init(layout: Array[int] = DEFAULT_LAYOUT) -> void:
	contents = layout.duplicate()
	contents.shuffle()
	reset()

## Restore the initial state (the hidden layout is kept).
func reset() -> void:
	opened = []
	for i in DOOR_COUNT:
		opened.append(false)
	is_solved = false
	is_failed = false
	state_changed.emit(opened.duplicate(), -1)
	contents.shuffle()

## Open a door (room 1..9). Returns true if the door was opened.
func open_door(room: int) -> bool:
	if is_failed or is_solved:
		return false
	if room < 1 or room > DOOR_COUNT or opened[room - 1]:
		return false
	opened[room - 1] = true
	var c: int = contents[room - 1]
	door_opened.emit(room, c)
	match c:
		Content.TIGER:
			is_failed = true
			move_executed.emit("Door %d opens... a tiger leaps out!" % room)
			state_changed.emit(opened.duplicate(), room)
			puzzle_failed.emit("You failed!")
		Content.PRINCESS:
			is_solved = true
			move_executed.emit("Door %d opens... the Princess awaits!" % room)
			state_changed.emit(opened.duplicate(), room)
			puzzle_solved.emit()
		_:
			move_executed.emit("Door %d opens... only dust and silence." % room)
			state_changed.emit(opened.duplicate(), room)
	return true

# ---------------------------------------------------------------------------
# Static rule evaluation (usable for solving / verification without an instance)
# ---------------------------------------------------------------------------

## Truth value of the inscription on every door (index 0..8) for the given layout.
static func truth_values(layout: Array) -> Array[bool]:
	var memo: Dictionary = {}
	var result: Array[bool] = []
	for k in range(1, DOOR_COUNT + 1):
		result.append(_truth(k, layout, memo))
	return result

static func _truth(k: int, layout: Array, memo: Dictionary) -> bool:
	if memo.has(k):
		return memo[k] == 1
	memo[k] = 0 # cycle guard: a circular reference counts as false
	var value: bool = _evaluate(k, layout, memo)
	memo[k] = 1 if value else 0
	return value

static func _tiger(layout: Array, room: int) -> bool:
	return layout[room - 1] == Content.TIGER

static func _princess(layout: Array, room: int) -> bool:
	return layout[room - 1] == Content.PRINCESS

static func _empty(layout: Array, room: int) -> bool:
	return layout[room - 1] == Content.EMPTY

static func _evaluate(k: int, layout: Array, memo: Dictionary) -> bool:
	match k:
		1:
			var odd_princess := false
			for r in [1, 3, 5, 7, 9]:
				odd_princess = odd_princess or _princess(layout, r)
			var even_tiger := false
			for r in [2, 4, 6, 8]:
				even_tiger = even_tiger or _tiger(layout, r)
			return odd_princess and not even_tiger
		2:
			return _empty(layout, 2)
		3:
			return _truth(5, layout, memo) and not _truth(7, layout, memo) and _tiger(layout, 3)
		4:
			return not _truth(1, layout, memo) and not _tiger(layout, 8) and _truth(9, layout, memo)
		5:
			var cond: bool = _truth(2, layout, memo) or _truth(4, layout, memo)
			return (not cond) or not _tiger(layout, 1)
		6:
			return not _truth(3, layout, memo) and _princess(layout, 2) and not _tiger(layout, 2)
		7:
			return _princess(layout, 1) and _truth(5, layout, memo)
		8:
			return not _tiger(layout, 8) and _empty(layout, 9)
		9:
			return not _tiger(layout, 9) and not _tiger(layout, 1) and _truth(6, layout, memo)
	return false

## Does the layout satisfy the Royal Logic Protocol?
static func is_consistent(layout: Array) -> bool:
	if layout.size() != DOOR_COUNT:
		return false
	var princesses := 0
	for c in layout:
		if c == Content.PRINCESS:
			princesses += 1
	if princesses != 1:
		return false
	var truths: Array[bool] = truth_values(layout)
	var empty_true := 0
	var empty_false := 0
	for i in DOOR_COUNT:
		match layout[i]:
			Content.TIGER:
				if truths[i]:
					return false
			Content.PRINCESS:
				if not truths[i]:
					return false
			_:
				if truths[i]:
					empty_true += 1
				else:
					empty_false += 1
	return empty_true == 0 or empty_false == 0

## Brute-force all 3^9 layouts and return every one consistent with the protocol.
static func enumerate_consistent() -> Array:
	var found: Array = []
	var total: int = int(pow(3, DOOR_COUNT))
	for n in total:
		var layout: Array[int] = []
		var x := n
		for i in DOOR_COUNT:
			layout.append(x % 3)
			x /= 3
		if is_consistent(layout):
			found.append(layout)
	return found

## Rooms (1..9) that hold the Princess in at least one consistent layout.
static func princess_candidates() -> Array[int]:
	var rooms: Array[int] = []
	for layout in enumerate_consistent():
		var room: int = layout.find(Content.PRINCESS) + 1
		if room not in rooms:
			rooms.append(room)
	rooms.sort()
	return rooms

static func inscription_text(room: int) -> String:
	return INSCRIPTIONS[room - 1]
