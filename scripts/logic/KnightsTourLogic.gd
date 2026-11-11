class_name KnightsTourLogic
extends RefCounted

## Pure logical model of the Knight's Tour on an 8x8 board.
## Source: Theoretical Computer Science: Logic & Puzzles, Chapter 5, Section 5.6.2.
##
## Cells are Vector2i(column, row), 0..BOARD_SIZE-1. The knight starts on START (already
## visited). Only unvisited knight moves are legal. The puzzle is solved when all 64 cells have
## been visited, and failed when the knight is in a dead end with unvisited cells remaining.

const BOARD_SIZE: int = 8
const START: Vector2i = Vector2i(0, 0)
const KNIGHT_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 2), Vector2i(2, 1), Vector2i(2, -1), Vector2i(1, -2),
	Vector2i(-1, -2), Vector2i(-2, -1), Vector2i(-2, 1), Vector2i(-1, 2),
]

signal state_changed(current: Vector2i, path: Array)
signal move_executed(description: String)
signal move_rejected(reason: String)
signal puzzle_failed(reason: String)
signal puzzle_solved()

var current: Vector2i = START
var path: Array[Vector2i] = []   # visited cells in order, path[-1] == current
var is_solved: bool = false
var is_failed: bool = false

func _init() -> void:
	reset()

func reset() -> void:
	current = START
	path = [START]
	is_solved = false
	is_failed = false
	state_changed.emit(current, path.duplicate())

static func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < BOARD_SIZE and cell.y >= 0 and cell.y < BOARD_SIZE

static func is_knight_move(a: Vector2i, b: Vector2i) -> bool:
	var d := b - a
	return (abs(d.x) == 1 and abs(d.y) == 2) or (abs(d.x) == 2 and abs(d.y) == 1)

func visited_count() -> int:
	return path.size()

func is_visited(cell: Vector2i) -> bool:
	return cell in path

## Unvisited cells a knight on `from` could jump to, given the visited set.
static func moves_from(from: Vector2i, visited: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for o in KNIGHT_OFFSETS:
		var c: Vector2i = from + o
		if in_bounds(c) and c not in visited:
			result.append(c)
	return result

## Legal moves from the current cell.
func valid_moves() -> Array[Vector2i]:
	if is_solved:
		return []
	return moves_from(current, path)

func move_to(cell: Vector2i) -> bool:
	if is_solved or is_failed:
		return false
	if not in_bounds(cell):
		move_rejected.emit("That tile is outside the chasm.")
		return false
	if is_visited(cell):
		move_rejected.emit("That rune has already crumbled.")
		return false
	if not is_knight_move(current, cell):
		move_rejected.emit("A knight cannot jump there.")
		return false
	current = cell
	path.append(cell)
	move_executed.emit("Leapt to %s. Visits: %d / %d." % [cell_name(cell), path.size(), BOARD_SIZE * BOARD_SIZE])
	state_changed.emit(current, path.duplicate())
	if path.size() == BOARD_SIZE * BOARD_SIZE:
		is_solved = true
		puzzle_solved.emit()
	elif valid_moves().is_empty():
		is_failed = true
		puzzle_failed.emit("Dead end!")
	return true

## Take back the last jump (also recovers from a dead end).
func undo() -> bool:
	if path.size() <= 1 or is_solved:
		return false
	path.pop_back()
	current = path[-1]
	is_failed = false
	move_executed.emit("Stepped back to %s." % cell_name(current))
	state_changed.emit(current, path.duplicate())
	return true

## Warnsdorff-guided backtracking search: a complete tour starting at `start`, or [] if none.
static func find_tour(start: Vector2i = START) -> Array[Vector2i]:
	var tour: Array[Vector2i] = [start]
	var budget: Array[int] = [100000]
	if _extend(tour, budget):
		return tour
	return []

## Find remaining steps to complete a tour from the given path (or [] if none).
static func find_tour_from_path(existing_path: Array) -> Array[Vector2i]:
	var tour: Array[Vector2i] = []
	for p in existing_path:
		tour.append(p)
	if tour.is_empty():
		tour = [START]
	var budget: Array[int] = [100000]
	if _extend(tour, budget):
		return tour
	return []

static func _extend(tour: Array[Vector2i], budget: Array[int] = [100000]) -> bool:
	if budget[0] <= 0:
		return false
	budget[0] -= 1
	if tour.size() == BOARD_SIZE * BOARD_SIZE:
		return true
	var options := moves_from(tour[-1], tour)
	# Warnsdorff: try the cell with the fewest onward moves first.
	options.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return moves_from(a, tour).size() < moves_from(b, tour).size())
	for c in options:
		tour.append(c)
		if _extend(tour, budget):
			return true
		tour.pop_back()
	return false

static func is_valid_tour(cells: Array) -> bool:
	if cells.size() != BOARD_SIZE * BOARD_SIZE:
		return false
	var seen: Dictionary = {}
	for i in cells.size():
		if not in_bounds(cells[i]) or seen.has(cells[i]):
			return false
		seen[cells[i]] = true
		if i > 0 and not is_knight_move(cells[i - 1], cells[i]):
			return false
	return true

static func cell_name(cell: Vector2i) -> String:
	return "%s%d" % [char(65 + cell.x), cell.y + 1]
