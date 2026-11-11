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
## Role 1,2,4,6,7,8,9 = Tiger, Role 3 = Empty, Role 5 = Princess.
const DEFAULT_LAYOUT: Array[int] = [1, 1, 0, 1, 2, 1, 1, 1, 1]
const DEFAULT_ROLES: Array[int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]

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

var base_layout: Array[int] = []
var roles: Array[int] = []
var contents: Array[int] = []
var inscriptions: Array[String] = []
var opened: Array[bool] = []
var is_solved: bool = false
var is_failed: bool = false

func _init(layout: Array[int] = DEFAULT_LAYOUT) -> void:
	base_layout = layout.duplicate()
	reset()

## Restore the initial state with a new randomized room layout and matching door inscriptions.
func reset() -> void:
	var new_roles: Array[int] = DEFAULT_ROLES.duplicate()
	new_roles.shuffle()
	while roles.size() == DOOR_COUNT and new_roles == roles:
		new_roles.shuffle()
	_apply_roles(new_roles)
	opened = []
	for i in DOOR_COUNT:
		opened.append(false)
	is_solved = false
	is_failed = false
	state_changed.emit(opened.duplicate(), -1)

func _apply_roles(new_roles: Array[int]) -> void:
	roles = new_roles.duplicate()
	contents = []
	for r in roles:
		contents.append(base_layout[r - 1])
	inscriptions = []
	for room in range(1, DOOR_COUNT + 1):
		inscriptions.append(inscription_text(room, roles))

## Return the current inscription on door `room` (1..9).
func get_inscription(room: int) -> String:
	return inscriptions[room - 1]

## Return the room number (1..9) that currently holds the Princess.
func princess_room() -> int:
	return contents.find(Content.PRINCESS) + 1

## Deduce the Princess's room (1..9) purely from the current door inscriptions and protocol rules.
func solve_princess_room() -> int:
	var candidates := princess_candidates(roles)
	return candidates[0] if not candidates.is_empty() else -1

## Return a room number (1..9) that is currently Empty (or -1 if none).
func empty_room() -> int:
	var idx := contents.find(Content.EMPTY)
	return idx + 1 if idx != -1 else -1

## Return a room number (1..9) that currently holds a Tiger (or -1 if none).
func tiger_room() -> int:
	var idx := contents.find(Content.TIGER)
	return idx + 1 if idx != -1 else -1

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

## Truth value of the inscription on every door (index 0..8) for the given layout and role assignment.
static func truth_values(layout: Array, role_map: Array = DEFAULT_ROLES) -> Array[bool]:
	var memo: Dictionary = {}
	var result: Array[bool] = []
	for k in range(1, DOOR_COUNT + 1):
		result.append(_truth(k, layout, memo, role_map))
	return result

static func _door_of(role: int, role_map: Array) -> int:
	return role_map.find(role) + 1

static func _truth(k: int, layout: Array, memo: Dictionary, role_map: Array = DEFAULT_ROLES) -> bool:
	if memo.has(k):
		return memo[k] == 1
	memo[k] = 0 # cycle guard: a circular reference counts as false
	var value: bool = _evaluate(k, layout, memo, role_map)
	memo[k] = 1 if value else 0
	return value

static func _tiger(layout: Array, room: int) -> bool:
	return layout[room - 1] == Content.TIGER

static func _princess(layout: Array, room: int) -> bool:
	return layout[room - 1] == Content.PRINCESS

static func _empty(layout: Array, room: int) -> bool:
	return layout[room - 1] == Content.EMPTY

static func _evaluate(k: int, layout: Array, memo: Dictionary, role_map: Array = DEFAULT_ROLES) -> bool:
	var role: int = role_map[k - 1]
	var d1 := _door_of(1, role_map)
	var d2 := _door_of(2, role_map)
	var d3 := _door_of(3, role_map)
	var d4 := _door_of(4, role_map)
	var d5 := _door_of(5, role_map)
	var d6 := _door_of(6, role_map)
	var d7 := _door_of(7, role_map)
	var d8 := _door_of(8, role_map)
	var d9 := _door_of(9, role_map)
	match role:
		1:
			var odd_princess := false
			for r in [1, 3, 5, 7, 9]:
				odd_princess = odd_princess or _princess(layout, r)
			var even_tiger := false
			for r in [2, 4, 6, 8]:
				even_tiger = even_tiger or _tiger(layout, r)
			return odd_princess and not even_tiger
		2:
			return _empty(layout, k)
		3:
			return _truth(d5, layout, memo, role_map) and not _truth(d7, layout, memo, role_map) and _tiger(layout, d3)
		4:
			return not _truth(d1, layout, memo, role_map) and not _tiger(layout, d8) and _truth(d9, layout, memo, role_map)
		5:
			var cond: bool = _truth(d2, layout, memo, role_map) or _truth(d4, layout, memo, role_map)
			return (not cond) or not _tiger(layout, d1)
		6:
			return not _truth(d3, layout, memo, role_map) and _princess(layout, d2) and not _tiger(layout, d2)
		7:
			return _princess(layout, d1) and _truth(d5, layout, memo, role_map)
		8:
			return not _tiger(layout, k) and _empty(layout, d9)
		9:
			return not _tiger(layout, k) and not _tiger(layout, d1) and _truth(d6, layout, memo, role_map)
	return false

## Does the layout satisfy the Royal Logic Protocol for the given role assignment?
static func is_consistent(layout: Array, role_map: Array = DEFAULT_ROLES) -> bool:
	if layout.size() != DOOR_COUNT or role_map.size() != DOOR_COUNT:
		return false
	var princesses := 0
	for c in layout:
		if c == Content.PRINCESS:
			princesses += 1
	if princesses != 1:
		return false
	var truths: Array[bool] = truth_values(layout, role_map)
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
static func enumerate_consistent(role_map: Array = DEFAULT_ROLES) -> Array:
	var found: Array = []
	var total: int = int(pow(3, DOOR_COUNT))
	for n in total:
		var layout: Array[int] = []
		var x := n
		for i in DOOR_COUNT:
			layout.append(x % 3)
			x /= 3
		if is_consistent(layout, role_map):
			found.append(layout)
	return found

## Rooms (1..9) that hold the Princess in at least one consistent layout.
static func princess_candidates(role_map: Array = DEFAULT_ROLES) -> Array[int]:
	var rooms: Array[int] = []
	for layout in enumerate_consistent(role_map):
		var room: int = layout.find(Content.PRINCESS) + 1
		if room not in rooms:
			rooms.append(room)
	rooms.sort()
	return rooms

static func inscription_text(room: int, role_map: Array = DEFAULT_ROLES) -> String:
	var role: int = role_map[room - 1]
	var d1 := _door_of(1, role_map)
	var d2 := _door_of(2, role_map)
	var d3 := _door_of(3, role_map)
	var d4 := _door_of(4, role_map)
	var d5 := _door_of(5, role_map)
	var d6 := _door_of(6, role_map)
	var d7 := _door_of(7, role_map)
	var d8 := _door_of(8, role_map)
	var d9 := _door_of(9, role_map)
	match role:
		1:
			return "The princess is in a room with an odd number and there is no tiger in the rooms with an even number."
		2:
			return "This room is empty."
		3:
			return "The inscription on Room No. %d is true, the inscription on Room No. %d is false, and there is a tiger in Room No. %d." % [d5, d7, d3]
		4:
			return "The inscription on Room No. %d is false, there is no tiger in Room No. %d, and the inscription on Room No. %d is true." % [d1, d8, d9]
		5:
			return "If the inscription on Room No. %d or on Room No. %d is true, then there is no tiger in Room No. %d." % [d2, d4, d1]
		6:
			return "The inscription on Room No. %d is false, the princess is in Room No. %d, and there is no tiger in Room No. %d." % [d3, d2, d2]
		7:
			return "The princess is in Room No. %d and the inscription on Room No. %d is true." % [d1, d5]
		8:
			return "There is no tiger in this room and Room No. %d is empty." % [d9]
		9:
			return "Neither in this room nor in Room No. %d is there a tiger, and moreover, the inscription on Room No. %d is true." % [d1, d6]
	return INSCRIPTIONS[room - 1]
